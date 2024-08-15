using System.Collections;
using UnityEngine;

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

    private Vector3 originalLocalPosition;
    private Quaternion originalRotation;
    private float currentSpeed;

    // Projectile 관련 변수
    public ProjectileGroup[] projectileGroups; // 발사체 그룹 배열
    private int currentGroupIndex = 0;
    private bool isFiring = false;
    private Coroutine firingCoroutine;

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

        // 발사체 그룹이 설정되었는지 확인
        if (projectileGroups.Length == 0)
        {
            Debug.LogError("ProjectileGroups가 설정되지 않았습니다.");
        }
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.E))
        {
            if (isMounted)
            {
                Dismount();
            }
            else
            {
                CheckForMountable();
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

            // 마우스 왼쪽 버튼을 누르면 발사체 발사
            if (Input.GetMouseButtonDown(0))
            {
                StartFiring();
            }
            if (Input.GetMouseButtonUp(0))
            {
                StopFiring();
            }

            // 숫자 키를 누르면 프리셋 변경
            if (Input.GetKeyDown(KeyCode.Alpha1)) ChangePreset(0);
            if (Input.GetKeyDown(KeyCode.Alpha2)) ChangePreset(1);
            if (Input.GetKeyDown(KeyCode.Alpha3)) ChangePreset(2);
            if (Input.GetKeyDown(KeyCode.Alpha4)) ChangePreset(3);

            UpdateAnimatorParameters();
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

        if (isGrounded && Input.GetKeyDown(KeyCode.Space))
        {
            Jump();
        }

        CheckGroundStatus();
    }

    void ChangePreset(int index)
    {
        if (index >= 0 && index < projectileGroups.Length && projectileGroups[index].projectilePreset != null && projectileGroups[index].projectileSpawnPoint != null)
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
        ProjectileGroup currentGroup = projectileGroups[currentGroupIndex];
        if (currentGroup.projectilePreset != null && currentGroup.projectilePreset.prefabSlot != null && currentGroup.projectileSpawnPoint != null)
        {
            Vector3 spawnPosition = currentGroup.projectileSpawnPoint.position + currentGroup.projectileSpawnPoint.forward * 0.5f;
            GameObject projectile = Instantiate(currentGroup.projectilePreset.prefabSlot, spawnPosition, currentGroup.projectileSpawnPoint.rotation);
            Debug.Log("발사체 생성: " + projectile.name + " at " + spawnPosition);

            ParticleDamage particleDamage = projectile.GetComponent<ParticleDamage>();
            if (particleDamage != null)
            {
                particleDamage.SetProjectilePreset(currentGroup.projectilePreset);
            }

            Destroy(projectile, currentGroup.projectilePreset.destroyAfterSeconds);
        }
        else
        {
            Debug.LogWarning("ProjectilePreset, prefabSlot 또는 projectileSpawnPoint가 설정되지 않았습니다.");
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
        Collider[] hitColliders = Physics.OverlapSphere(transform.position, mountCheckRadius);
        foreach (var hitCollider in hitColliders)
        {
            if (hitCollider.CompareTag("Player"))
            {
                PlayerController controller = hitCollider.GetComponent<PlayerController>();
                if (controller != null)
                {
                    Mount(controller);
                    break;
                }
            }
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
    }

    void Dismount()
    {
        isMounted = false;

        playerController.enabled = true;

        playerController.transform.SetParent(null);

        playerController.transform.position = transform.TransformPoint(originalLocalPosition);
        playerController.transform.rotation = originalRotation;

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
}
