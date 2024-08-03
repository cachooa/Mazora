using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;

public class PlayerController : MonoBehaviour
{
    public float moveSpeed = 5f;
    public float dashMultiplier = 2f;
    public float rotationSpeed = 1f; // 1이면 1초에 360도 회전
    public float aimingMoveSpeed = 3f; // 조준 모드에서의 이동 속도
    public float jumpForce = 7f;
    public float groundCheckDistance = 0.1f; // 지면 체크 거리
    public LayerMask groundLayer; // 지면 레이어
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
    private Collider playerCollider;
    private bool isGrounded;
    private bool isDashing;
    private bool isPerformingAction;
    private bool isAiming; // 조준 모드 여부
    private bool isActionInProgress; // 액션 진행 여부
    public Transform mountPoint; // 탑승 시 위치
    private GameObject currentVehicle; // 현재 탑승한 오브젝트
    private bool isMounted = false;
    private Vector3 originalLocalPosition; // 차량 내 캐릭터의 로컬 위치
    private Quaternion originalRotation; // 하차 시 돌아갈 원래 회전
    private bool canMoveVehicle = true; // 차량 이동 가능 여부

    void Start()
    {
        rb = GetComponent<Rigidbody>();
        playerCollider = GetComponent<Collider>();

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
        if (!isMounted)
        {
            CheckGroundStatus();

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

        if (isMounted && currentVehicle != null && canMoveVehicle)
        {
            HandleVehicleControls();
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
            transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, (1f / rotationSpeed) * 360f * Time.deltaTime);
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
                transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, (1f / rotationSpeed) * 360f * Time.deltaTime);
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

    void CheckGroundStatus()
    {
        RaycastHit hit;
        if (Physics.Raycast(transform.position + Vector3.up * 0.1f, Vector3.down, out hit, groundCheckDistance + 0.1f, groundLayer))
        {
            isGrounded = true;
            animator.SetBool("IsGrounded", true);
        }
        else
        {
            isGrounded = false;
            animator.SetBool("IsGrounded", false);
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

    void CheckForMountable()
    {
        // 근처의 모든 콜라이더를 검색하여 탑승 가능한 오브젝트를 찾음
        Collider[] hitColliders = Physics.OverlapSphere(transform.position, 5f); // 기본 범위 5f
        foreach (var hitCollider in hitColliders)
        {
            if (hitCollider.CompareTag("Mountable"))
            {
                VehicleController vehicleController = hitCollider.GetComponent<VehicleController>();
                if (vehicleController != null)
                {
                    float mountRadius = vehicleController.mountCheckRadius;
                    if (Vector3.Distance(transform.position, hitCollider.transform.position) <= mountRadius)
                    {
                        StartCoroutine(MountWithDelay(hitCollider.gameObject));
                        break;
                    }
                }
            }
        }
    }

    IEnumerator MountWithDelay(GameObject vehicle)
    {
        currentVehicle = vehicle;
        originalLocalPosition = vehicle.transform.InverseTransformPoint(transform.position); // 탑승 시 차량 내 로컬 위치 저장
        originalRotation = transform.rotation; // 탑승 시 원래 회전 저장

        transform.SetParent(vehicle.transform);
        transform.localPosition = Vector3.zero; // 오브젝트 내부의 특정 위치로 설정
        rb.isKinematic = true; // 물리 연산 비활성화
        playerCollider.enabled = false; // 캐릭터 콜라이더 비활성화

        if (EventSystem.current != null)
        {
            EventSystem.current.SetSelectedGameObject(vehicle); // 차량 오브젝트를 선택 상태로 만듦
            Debug.Log("Vehicle selected: " + vehicle.name);
        }
        else
        {
            Debug.LogWarning("EventSystem is null!");
        }

        isMounted = true;
        canMoveVehicle = false; // 차량 이동 비활성화
        yield return new WaitForSeconds(1f); // 1초 대기
        canMoveVehicle = true; // 차량 이동 활성화
    }

    void Dismount()
    {
        transform.SetParent(null);
        transform.position = currentVehicle.transform.TransformPoint(originalLocalPosition); // 하차 시 원래 위치로 복귀
        transform.rotation = originalRotation; // 하차 시 원래 회전으로 복귀

        rb.isKinematic = false; // 물리 연산 활성화
        playerCollider.enabled = true; // 캐릭터 콜라이더 활성화

        currentVehicle = null;
        isMounted = false;
    }

    void HandleVehicleControls()
    {
        // 현재 탑승한 오브젝트의 조작 스크립트 호출
        var vehicleControl = currentVehicle.GetComponent<IVehicleControl>();
        if (vehicleControl != null && canMoveVehicle)
        {
            vehicleControl.Control();
        }
    }
}
