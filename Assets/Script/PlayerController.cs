using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public float moveSpeed = 5f;
    public float dashMultiplier = 2f;
    public float rotationSpeed = 1f;
    public float aimingMoveSpeed = 3f; // 조준 모드에서의 이동 속도
    public float jumpForce = 7f;
    public float health = 100f; // 캐릭터의 체력
    public Transform cameraTransform;
    public Animator animator;
    public AnimationEventHandler animationEventHandler; // 추가된 필드

    [System.Serializable]
    public class ActionSlot
    {
        public ActionPreset actionPreset; // 액션 프리셋
        public float attackDamage; // 공격력
    }

    public ActionSlot[] actionSlots; // 액션 슬롯 배열

    private Rigidbody rb;
    private bool isGrounded;
    private bool isDashing;
    private bool isPerformingAction;
    private bool isAiming; // 조준 모드 여부
    private bool isActionInProgress; // 액션 진행 여부

    void Start()
    {
        rb = GetComponent<Rigidbody>();

        // 상위 오브젝트에서 Animator 및 AnimationEventHandler 찾기
        animator = GetComponentInChildren<Animator>();
        animationEventHandler = GetComponentInChildren<AnimationEventHandler>();

        if (animationEventHandler != null)
        {
            animationEventHandler.playerController = this;
        }
    }

    void Update()
    {
        if (!isPerformingAction)
        {
            Move();
            Rotate();
            if (!isAiming) Jump();
        }

        if (Input.GetKeyDown(KeyCode.F))
        {
            PerformAction(0); // 첫 번째 액션 슬롯 실행
        }

        // 마우스 오른쪽 버튼 입력을 감지하여 조준 모드 전환
        if (Input.GetMouseButtonDown(1))
        {
            isAiming = true;
            animator.SetBool("IsAiming", true);
        }
        else if (Input.GetMouseButtonUp(1))
        {
            isAiming = false;
            animator.SetBool("IsAiming", false);
        }
    }

    void Move()
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
        if (!isAiming && (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift)))
        {
            speed *= dashMultiplier;
            isDashing = true;
        }
        else
        {
            isDashing = false;
        }

        Vector3 movement = (forward * moveVertical + right * moveHorizontal).normalized * speed * Time.deltaTime;

        // 캐릭터를 이동시킴
        Vector3 newPosition = rb.position + movement;
        rb.MovePosition(newPosition);

        // 애니메이터 매개변수 설정
        if (isAiming)
        {
            animator.SetFloat("MoveX", moveHorizontal);
            animator.SetFloat("MoveZ", moveVertical);
        }
        else
        {
            animator.SetFloat("Speed", movement.magnitude);
            animator.SetBool("IsDashing", isDashing);
        }
    }

    void Rotate()
    {
        float moveHorizontal = Input.GetAxis("Horizontal");
        float moveVertical = Input.GetAxis("Vertical");

        if (isAiming)
        {
            Vector3 lookDirection = cameraTransform.forward;
            lookDirection.y = 0f;
            Quaternion targetRotation = Quaternion.LookRotation(lookDirection);
            transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, 360 / rotationSpeed * Time.deltaTime);
        }
        else
        {
            Vector3 forward = cameraTransform.forward;
            Vector3 right = cameraTransform.right;

            forward.y = 0f;
            right.y = 0f;
            forward.Normalize();
            right.Normalize();

            Vector3 direction = (forward * moveVertical + right * moveHorizontal).normalized;

            if (direction.magnitude >= 0.1f)
            {
                Quaternion targetRotation = Quaternion.LookRotation(direction);
                transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, 360 / rotationSpeed * Time.deltaTime);
            }
        }
    }

    void Jump()
    {
        if (isGrounded && Input.GetKeyDown(KeyCode.Space))
        {
            rb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
            animator.SetTrigger("Jump");
        }
    }

    void PerformAction(int slotIndex)
    {
        if (slotIndex < 0 || slotIndex >= actionSlots.Length || isActionInProgress)
        {
            Debug.LogWarning("Invalid action slot index or action already in progress!");
            return;
        }

        isPerformingAction = true;
        isActionInProgress = true;
        ActionSlot slot = actionSlots[slotIndex];

        if (slot.actionPreset != null)
        {
            // 대상에게 액션 전달
            Ray ray = new Ray(cameraTransform.position, cameraTransform.forward); // 카메라 뷰 방향으로 설정
            if (Physics.Raycast(ray, out RaycastHit hit))
            {
                ObjectTarget target = hit.collider.GetComponent<ObjectTarget>();
                if (target != null)
                {
                    target.OnReceiveAction(slot.actionPreset); // 액션 프리셋 전달
                    target.TakeDamage(slot.attackDamage); // 공격력 적용
                }
            }
        }

        animator.SetTrigger("Action");
    }

    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Ground"))
        {
            isGrounded = true;
            animator.SetBool("IsGrounded", true);
        }
    }

    void OnCollisionExit(Collision collision)
    {
        if (collision.gameObject.CompareTag("Ground"))
        {
            isGrounded = false;
            animator.SetBool("IsGrounded", false);
        }
    }

    public void TakeDamage(float damage)
    {
        health -= damage;
        if (health <= 0f)
        {
            Die();
        }
    }

    void Die()
    {
        // 캐릭터 사망 처리 로직
    }

    // 추가된 메서드
    public void OnActionEnd()
    {
        isPerformingAction = false;
        isActionInProgress = false;
    }
}