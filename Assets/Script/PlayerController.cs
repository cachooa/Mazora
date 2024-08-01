using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public float moveSpeed = 5f;
    public float dashMultiplier = 2f; // 대시 속도의 배수
    public float rotationSpeed = 1f; // 회전 속도 (1이면 1초에 목표 각도에 도달)
    public float jumpForce = 7f;
    public Transform cameraTransform;
    public Animator animator; // Animator를 Inspector에서 지정할 수 있도록 변경

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

        if (Input.GetMouseButtonDown(0))
        {
            PerformAction();
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

        // Shift 키를 누르면 대시
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

        // Rigidbody를 이용한 이동
        Vector3 newPosition = rb.position + movement;
        rb.MovePosition(newPosition);

        // 애니메이터 매개변수 설정
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
                // 즉시 회전
                transform.rotation = targetRotation;
            }
            else
            {
                // 시간 기반 회전
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

    void PerformAction()
    {
        isPerformingAction = true;
        animator.SetTrigger("Action");
    }

    // 애니메이션 이벤트를 통해 액션 종료 시 호출
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
}