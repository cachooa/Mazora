using System.Collections;
using UnityEngine;

public class CustomMountableController : MonoBehaviour
{
    public float moveSpeed = 5f;
    public float dashMultiplier = 2f;
    public float rotationSpeed = 1f; // 회전 시간이 1이면 1초, 0.5면 0.5초 동안 회전
    public float aimingMoveSpeed = 3f;
    public float aimingRotationSpeed = 0.5f; // aim 상황에서의 회전 속도 조정
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
    private bool isJumping = false;

    public Transform cameraTransform; // 카메라 참조
    public Animator animator; // 애니메이터 참조

    private Vector3 originalLocalPosition; // 탑승 시 로컬 위치 저장
    private Quaternion originalRotation; // 탑승 시 로컬 회전 저장
    private float currentSpeed; // 현재 이동 속도

    void Start()
    {
        rb = GetComponent<Rigidbody>();

        // 만약 cameraTransform이 할당되지 않았다면, 메인 카메라를 자동으로 할당
        if (cameraTransform == null)
        {
            cameraTransform = Camera.main.transform;
        }

        // Animator를 자동으로 가져옴
        if (animator == null)
        {
            animator = GetComponent<Animator>();
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

            // 애니메이터 파라미터 업데이트
            UpdateAnimatorParameters();
        }
    }

    void Control()
    {
        float moveHorizontal = Input.GetAxis("Horizontal");
        float moveVertical = Input.GetAxis("Vertical");

        Vector3 forward = cameraTransform.forward;
        Vector3 right = cameraTransform.right;

        forward.y = 0f; // 수평 이동만 고려
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

        if (!isJumping) // 점프 중이 아닐 때만 이동 처리
        {
            Vector3 movement = (forward * moveVertical + right * moveHorizontal).normalized * speed * Time.deltaTime;
            rb.MovePosition(rb.position + movement);

            if (isAiming)
            {
                // 조준 시 캐릭터를 카메라 방향으로 회전
                Vector3 lookDirection = cameraTransform.forward;
                lookDirection.y = 0f;
                Quaternion targetRotation = Quaternion.LookRotation(lookDirection);
                transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, (1f / currentRotationSpeed) * 360f * Time.deltaTime);
            }
            else if (movement.magnitude > 0)
            {
                // 일반 이동 시 이동 방향으로 회전
                Quaternion targetRotation = Quaternion.LookRotation(movement);
                transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, (1f / currentRotationSpeed) * 360f * Time.deltaTime);
            }
        }

        if (isGrounded && Input.GetKeyDown(KeyCode.Space))
        {
            Jump();
        }

        CheckGroundStatus();
    }

    void CheckGroundStatus()
    {
        RaycastHit hit;
        if (Physics.Raycast(transform.position + Vector3.up * 0.1f, Vector3.down, out hit, groundCheckDistance + 0.1f, groundLayer))
        {
            if (!isGrounded && isJumping && rb.linearVelocity.y <= 0)
            {
                // 착지 상태로 업데이트
                isJumping = false;
                animator.ResetTrigger("Jump");
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
        if (isGrounded) // 지면에 있을 때만 점프 가능
        {
            rb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
            isGrounded = false; // 점프를 시작했으므로 지면에 있지 않음으로 설정
            isJumping = true; // 점프 상태로 설정
            animator.SetTrigger("Jump"); // 점프 애니메이션 트리거

            // 애니메이션 파라미터 업데이트
            UpdateAnimatorParameters();
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

        // 플레이어 이동 비활성화
        playerController.enabled = false;

        // 플레이어의 로컬 위치와 회전을 기억
        originalLocalPosition = transform.InverseTransformPoint(playerController.transform.position);
        originalRotation = playerController.transform.rotation;

        // 플레이어를 탑승 오브젝트의 하단 (로컬 좌표 0, 0, 0)으로 이동
        playerController.transform.SetParent(transform);
        playerController.transform.localPosition = Vector3.zero;
        playerController.transform.localRotation = Quaternion.identity;

        // Rigidbody 비활성화
        Rigidbody playerRb = playerController.GetComponent<Rigidbody>();
        if (playerRb != null)
        {
            playerRb.isKinematic = true; // 물리 연산 비활성화
        }

        // 플레이어 콜라이더 비활성화
        Collider playerCollider = playerController.GetComponent<Collider>();
        if (playerCollider != null)
        {
            playerCollider.enabled = false;
        }
    }

    void Dismount()
    {
        isMounted = false;

        // 플레이어 이동 다시 활성화
        playerController.enabled = true;

        // 플레이어를 오브젝트의 하위 구조에서 제거
        playerController.transform.SetParent(null);

        // 플레이어의 위치를 탑승 시 기억된 로컬 좌표로 복귀
        playerController.transform.position = transform.TransformPoint(originalLocalPosition);
        playerController.transform.rotation = originalRotation;

        // Rigidbody 다시 활성화
        Rigidbody playerRb = playerController.GetComponent<Rigidbody>();
        if (playerRb != null)
        {
            playerRb.isKinematic = false; // 물리 연산 활성화
        }

        // 플레이어 콜라이더 다시 활성화
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

        // 점프 상태일 때는 다른 파라미터를 업데이트하지 않음
        if (!isJumping)
        {
            animator.SetFloat("Speed", currentSpeed);
            animator.SetBool("IsDashing", isDashing);
            animator.SetBool("IsAiming", isAiming);
            animator.SetFloat("MoveX", Input.GetAxis("Horizontal"));
            animator.SetFloat("MoveZ", Input.GetAxis("Vertical"));
        }

        // 점프 상태를 애니메이터에 반영
        animator.SetBool("IsJumping", isJumping);
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(transform.position, mountCheckRadius);
    }
}
