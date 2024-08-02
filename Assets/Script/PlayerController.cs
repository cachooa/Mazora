using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public float moveSpeed = 5f;
    public float dashMultiplier = 2f;
    public float rotationSpeed = 1f;
    public float jumpForce = 7f;
    public float health = 100f; // 캐릭터의 체력
    public Transform cameraTransform;
    public Animator animator;

    [System.Serializable]
    public class ActionSlot
    {
        public ActionPreset actionPreset; // 액션 프리셋
        public float attackDamage; // 해당 프리셋의 공격력
    }

    public ActionSlot[] actionSlots; // 액션 슬롯 배열

    private Rigidbody rb;
    private bool isGrounded;
    private bool isDashing;
    private bool isPerformingAction;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    void Update()
    {
        if (!isPerformingAction)
        {
            Move();
            Rotate();
            Jump();
        }

        if (Input.GetKeyDown(KeyCode.F))
        {
            PerformAction(0); // 첫 번째 액션 슬롯 실행
        }
        // 다른 키와 액션 슬롯을 연결하려면 추가적인 키 입력 체크를 여기에 추가하세요.
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

        float speed = moveSpeed;
        if (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift))
        {
            speed *= dashMultiplier;
            isDashing = true;
        }
        else
        {
            isDashing = false;
        }

        Vector3 movement = (forward * moveVertical + right * moveHorizontal).normalized * speed * Time.deltaTime;
        Vector3 newPosition = rb.position + movement;
        rb.MovePosition(newPosition);

        animator.SetFloat("Speed", movement.magnitude);
        animator.SetBool("IsDashing", isDashing);
    }

    void Rotate()
    {
        float moveHorizontal = Input.GetAxis("Horizontal");
        float moveVertical = Input.GetAxis("Vertical");

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
            if (rotationSpeed == 0f)
            {
                transform.rotation = targetRotation;
            }
            else
            {
                transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, 360f / rotationSpeed * Time.deltaTime);
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
        if (slotIndex < 0 || slotIndex >= actionSlots.Length)
        {
            Debug.LogWarning("Invalid action slot index!");
            return;
        }

        isPerformingAction = true;
        ActionSlot slot = actionSlots[slotIndex];
        
        if (slot.actionPreset != null)
        {
            // 여기서 공격력을 적용하는 로직을 추가합니다.
            ApplyDamage(slot.attackDamage);
        }

        animator.SetTrigger("Action");
    }

    public void OnActionEnd()
    {
        isPerformingAction = false;
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

    void ApplyDamage(float damage)
    {
        // 여기에 상대방 캐릭터나 대상에게 데미지를 적용하는 로직을 추가합니다.
        // 예: 타격된 대상에게 데미지를 적용하는 메서드 호출
        Debug.Log($"Applying {damage} damage.");
    }

    void Die()
    {
        // 캐릭터 사망 처리 로직
    }
}