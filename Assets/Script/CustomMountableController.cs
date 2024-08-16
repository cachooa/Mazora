using System.Collections;
using UnityEngine;
using UnityEngine.Playables;

[System.Serializable]
public class CustomProjectileGroup
{
    public ProjectilePreset projectilePreset;
    public Transform[] projectileSpawnPoints;
}

public class CustomMountableController : MonoBehaviour
{
    public float moveSpeed = 5f;
    public float dashMultiplier = 2f;
    public float rotationSpeed = 1f;
    public float aimingMoveSpeed = 3f;
    public float aimingRotationSpeed = 0.5f;
    public float jumpForce = 7f;
    public float groundCheckDistance = 0.1f;
    public float mountCheckRadius = 5f;
    public LayerMask groundLayer;

    private Rigidbody rb;
    private bool isGrounded;
    private PlayerController playerController;
    private bool isMounted = false;
    private bool isDashing = false;
    private bool isAiming = false;

    public Transform cameraTransform;
    public Animator animator;
    public PlayableDirector mountTimeline;

    private Vector3 originalLocalPosition;
    private Quaternion originalRotation;
    private float currentSpeed;

    public CustomProjectileGroup[] projectileGroups;
    private int currentGroupIndex = 0;
    private bool isFiring = false;
    private Coroutine firingCoroutine;

    private static readonly int FireBlendParam = Animator.StringToHash("FireBlend");

    void Start()
    {
        rb = GetComponent<Rigidbody>();

        if (cameraTransform == null)
        {
            cameraTransform = Camera.main.transform;
        }

        if (animator == null)
        {
            animator = GetComponent<Animator>();
        }

        if (projectileGroups.Length == 0)
        {
            Debug.LogError("ProjectileGroups가 설정되지 않았습니다.");
        }

        if (mountTimeline != null)
        {
            mountTimeline.stopped += OnTimelineStopped;
            mountTimeline.gameObject.SetActive(false);
        }
        else
        {
            Debug.LogError("mountTimeline is not assigned!");
        }
    }

    void Update()
    {
        if (mountTimeline != null && mountTimeline.state == PlayState.Playing)
        {
            return; // 타임라인 재생 중에는 입력 무시
        }

        if (Input.GetKeyDown(KeyCode.E))
        {
            if (isMounted)
            {
                Dismount();
            }
            else
            {
                StartMountProcess();
            }
        }

        if (isMounted)
        {
            Control();

            if (Input.GetMouseButtonDown(1))
            {
                isAiming = true;
            }
            if (Input.GetMouseButtonUp(1))
            {
                isAiming = false;
            }

            if (Input.GetMouseButtonDown(0))
            {
                StartFiring();
                if (animator != null)
                {
                    animator.SetFloat(FireBlendParam, 1f);
                }
            }
            if (Input.GetMouseButtonUp(0))
            {
                StopFiring();
                if (animator != null)
                {
                    animator.SetFloat(FireBlendParam, 0f);
                }
            }

            if (Input.GetKeyDown(KeyCode.Alpha1)) ChangePreset(0);
            if (Input.GetKeyDown(KeyCode.Alpha2)) ChangePreset(1);
            if (Input.GetKeyDown(KeyCode.Alpha3)) ChangePreset(2);
            if (Input.GetKeyDown(KeyCode.Alpha4)) ChangePreset(3);

            if (Input.GetKeyDown(KeyCode.Space))
            {
                Jump();
            }

            UpdateAnimatorParameters();
        }
    }

    void StartMountProcess()
    {
        CheckForMountable();
        
        if (playerController == null)
        {
            Debug.LogError("playerController is null after CheckForMountable!");
            return;
        }

        // 캐릭터를 탑승 오브젝트의 중심으로 이동
        playerController.transform.position = transform.position;

        // 타임라인 활성화 및 재생
        if (mountTimeline != null)
        {
            Debug.Log("Activating and playing mount timeline.");
            mountTimeline.gameObject.SetActive(true);
            mountTimeline.Play();
        }
        else
        {
            Debug.LogError("mountTimeline is not set!");
        }
    }

    void OnTimelineStopped(PlayableDirector director)
    {
        if (director == mountTimeline)
        {
            Debug.Log("Timeline Stopped, Mounting Player.");
            Mount(playerController); // 타임라인이 종료되면 플레이어를 탑승시킴
        }
    }

    public void SetCharacterScale(float scale)
    {
        if (playerController != null)
        {
            playerController.transform.localScale = new Vector3(scale, scale, scale);
        }
    }

    void Control()
    {
        float moveHorizontal = Input.GetAxis("Horizontal");
        float moveVertical = Input.GetAxis("Vertical");

        Vector3 forward = cameraTransform.forward;
        Vector3 right = cameraTransform.right;

        forward.y = 0f;
        right.y = 0f;
        forward.Normalize();
        right.Normalize();

        float speed = isAiming ? aimingMoveSpeed : moveSpeed;
        float currentRotationSpeed = isAiming ? aimingRotationSpeed : rotationSpeed;

        if (!isAiming && (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift)))
        {
            speed *= dashMultiplier;
            isDashing = true;
        }
        else
        {
            isDashing = false;
        }

        currentSpeed = new Vector3(moveHorizontal, 0, moveVertical).magnitude * speed;

        Vector3 movement = (forward * moveVertical + right * moveHorizontal).normalized * speed * Time.deltaTime;
        rb.MovePosition(rb.position + movement);

        if (isAiming)
        {
            Vector3 lookDirection = cameraTransform.forward;
            lookDirection.y = 0f;
            Quaternion targetRotation = Quaternion.LookRotation(lookDirection);
            transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, (1f / currentRotationSpeed) * 360f * Time.deltaTime);
        }
        else if (movement.magnitude > 0)
        {
            Quaternion targetRotation = Quaternion.LookRotation(movement);
            transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, (1f / currentRotationSpeed) * 360f * Time.deltaTime);
        }

        CheckGroundStatus();
    }

    void ChangePreset(int index)
    {
        if (index >= 0 && index < projectileGroups.Length && projectileGroups[index].projectilePreset != null && projectileGroups[index].projectileSpawnPoints != null)
        {
            currentGroupIndex = index;
            Debug.Log("현재 프리셋 인덱스: " + currentGroupIndex);

            if (isFiring)
            {
                StopFiring();
                StartFiring();
            }
        }
        else
        {
            Debug.LogWarning("유효하지 않은 프리셋 인덱스 또는 설정되지 않은 프리셋입니다.");
        }
    }

    void StartFiring()
    {
        if (firingCoroutine == null)
        {
            isFiring = true;
            firingCoroutine = StartCoroutine(FireProjectiles());
        }
    }

    void StopFiring()
    {
        if (firingCoroutine != null)
        {
            StopCoroutine(firingCoroutine);
            firingCoroutine = null;
            isFiring = false;
        }
    }

    private IEnumerator FireProjectiles()
    {
        while (isFiring)
        {
            FireProjectile();
            yield return new WaitForSeconds(1f / projectileGroups[currentGroupIndex].projectilePreset.fireRate);
        }
    }

    private void FireProjectile()
    {
        CustomProjectileGroup currentGroup = projectileGroups[currentGroupIndex];
        if (currentGroup.projectilePreset != null && currentGroup.projectilePreset.prefabSlot != null && currentGroup.projectileSpawnPoints != null)
        {
            foreach (Transform spawnPoint in currentGroup.projectileSpawnPoints)
            {
                if (spawnPoint != null)
                {
                    Vector3 spawnPosition = spawnPoint.position + spawnPoint.forward * 0.5f;
                    GameObject projectile = Instantiate(currentGroup.projectilePreset.prefabSlot, spawnPosition, spawnPoint.rotation);
                    Debug.Log("발사체 생성: " + projectile.name + " at " + spawnPosition);

                    ParticleDamage particleDamage = projectile.GetComponent<ParticleDamage>();
                    if (particleDamage != null)
                    {
                        particleDamage.SetProjectilePreset(currentGroup.projectilePreset);
                    }

                    Destroy(projectile, currentGroup.projectilePreset.destroyAfterSeconds);
                }
            }
        }
        else
        {
            Debug.LogWarning("ProjectilePreset, prefabSlot 또는 projectileSpawnPoints가 설정되지 않았습니다.");
        }
    }

    void Jump()
    {
        if (isGrounded)
        {
            Debug.Log("Jumping: Grounded and Space key pressed.");
            rb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
            isGrounded = false;

            animator.SetTrigger("Jump");
            Debug.Log("Jump trigger set.");

            UpdateAnimatorParameters();
        }
        else
        {
            Debug.Log("Jump failed: Not grounded.");
        }
    }

    void CheckGroundStatus()
    {
        RaycastHit hit;
        if (Physics.Raycast(transform.position + Vector3.up * 0.1f, Vector3.down, out hit, groundCheckDistance + 0.1f, groundLayer))
        {
            if (!isGrounded && rb.linearVelocity.y <= 0)
            {
                animator.ResetTrigger("Jump");
                Debug.Log("Landed: Jump trigger reset.");
            }

            isGrounded = true;
            animator.SetBool("IsGrounded", true);
        }
        else
        {
            isGrounded = false;
            animator.SetBool("IsGrounded", false);
        }
    }

    void TriggerJump()
    {
        if (isMounted && animator != null)
        {
            animator.SetTrigger("Jump");
            Debug.Log("Jump trigger directly set on mount object.");
        }
    }

    void CheckForMountable()
    {
        Debug.Log("Checking for mountable objects...");
        Collider[] hitColliders = Physics.OverlapSphere(transform.position, mountCheckRadius);
        foreach (var hitCollider in hitColliders)
        {
            Debug.Log("Collider found: " + hitCollider.name);
            
            // Check for Player tag
            if (hitCollider.CompareTag("Player"))
            {
                PlayerController controller = hitCollider.GetComponent<PlayerController>();
                if (controller != null)
                {
                    playerController = controller;
                    Debug.Log("PlayerController detected and assigned.");
                    Mount(controller);
                    break;
                }
                else
                {
                    Debug.LogWarning("Player object found but no PlayerController component is attached!");
                }
            }
            else
            {
                Debug.Log("Collider is not tagged as Player: " + hitCollider.tag);
            }
        }

        if (playerController == null)
        {
            Debug.LogWarning("No PlayerController found within mountable range or the PlayerController component is missing on the player object.");
        }
    }

    void Mount(PlayerController controller)
    {
        playerController = controller;
        isMounted = true;

        playerController.enabled = false;

        originalLocalPosition = transform.InverseTransformPoint(playerController.transform.position);
        originalRotation = playerController.transform.rotation;

        playerController.transform.SetParent(transform);
        playerController.transform.localPosition = Vector3.zero;
        playerController.transform.localRotation = Quaternion.identity;

        Rigidbody playerRb = playerController.GetComponent<Rigidbody>();
        if (playerRb != null)
        {
            playerRb.isKinematic = true;
        }

        Collider playerCollider = playerController.GetComponent<Collider>();
        if (playerCollider != null)
        {
            playerCollider.enabled = false;
        }

        // 타임라인을 활성화하기 전에 게임 오브젝트가 이미 활성화된 상태인지 확인
        if (mountTimeline != null && !mountTimeline.gameObject.activeInHierarchy)
        {
            mountTimeline.gameObject.SetActive(true);
            mountTimeline.Play();
        }
        else
        {
            Debug.LogWarning("mountTimeline is already active or null.");
        }
    }

    void Dismount()
    {
        isMounted = false;

        SetCharacterScale(1f); // 스케일을 원래대로 복원

        playerController.enabled = true;

        // 하차 시 탑승 오브젝트의 로컬 위치와 회전 값을 월드 좌표로 변환하여 복구
        Vector3 worldPosition = transform.TransformPoint(originalLocalPosition);
        Quaternion worldRotation = transform.rotation * originalRotation;

        playerController.transform.SetParent(null);
        playerController.transform.position = worldPosition;
        playerController.transform.rotation = worldRotation;

        Rigidbody playerRb = playerController.GetComponent<Rigidbody>();
        if (playerRb != null)
        {
            playerRb.isKinematic = false;
        }

        Collider playerCollider = playerController.GetComponent<Collider>();
        if (playerCollider != null)
        {
            playerCollider.enabled = true;
        }

        // 캐릭터를 다시 보이게 하기
        playerController.SetCharacterVisible(true);

        playerController = null;
    }

    void UpdateAnimatorParameters()
    {
        if (animator == null) return;

        animator.SetFloat("Speed", currentSpeed);
        animator.SetBool("IsDashing", isDashing);
        animator.SetBool("IsAiming", isAiming);
        animator.SetFloat("MoveX", Input.GetAxis("Horizontal"));
        animator.SetFloat("MoveZ", Input.GetAxis("Vertical"));

        animator.SetBool("IsGrounded", isGrounded);
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(transform.position, mountCheckRadius);
    }

    void OnDestroy()
    {
        if (mountTimeline != null)
        {
            mountTimeline.stopped -= OnTimelineStopped;
        }
    }
}
