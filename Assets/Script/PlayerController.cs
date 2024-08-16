using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;

public class PlayerController : MonoBehaviour
{
    public float moveSpeed = 5f;
    public float dashMultiplier = 2f;
    public float rotationSpeed = 1f;
    public float aimingMoveSpeed = 3f;
    public float jumpForce = 7f;
    public float groundCheckDistance = 0.1f;
    public float mountCheckDistance = 2f;
    public LayerMask groundLayer;
    public float health = 100f;
    public Transform cameraTransform;
    public Animator animator;
    public AnimationEventHandler animationEventHandler;

    [System.Serializable]
    public class ActionSlot
    {
        public ActionPreset actionPreset;
        public float attackDamage;
    }

    public ActionSlot[] actionSlots;

    private Rigidbody rb;
    private Collider playerCollider;
    private bool isGrounded;
    private bool isDashing;
    private bool isPerformingAction;
    private bool isAiming;
    private bool isActionInProgress;
    public Transform mountPoint;
    private GameObject currentVehicle;
    private bool isMounted = false;
    private Vector3 originalLocalPosition;
    private Quaternion originalRotation;
    private bool canMoveVehicle = true;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
        playerCollider = GetComponent<Collider>();

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
                PerformAction(0);
            }

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

        Vector3 newPosition = rb.position + movement;
        rb.MovePosition(newPosition);

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
            Ray ray = new Ray(cameraTransform.position, cameraTransform.forward);
            if (Physics.Raycast(ray, out RaycastHit hit))
            {
                ObjectTarget target = hit.collider.GetComponent<ObjectTarget>();
                if (target != null)
                {
                    target.OnReceiveAction(slot.actionPreset);
                    target.TakeDamage(slot.attackDamage);
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

    public void OnActionEnd()
    {
        isPerformingAction = false;
        isActionInProgress = false;
    }

    void CheckForMountable()
    {
        Collider[] hitColliders = Physics.OverlapSphere(transform.position, 5f);
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
        originalLocalPosition = vehicle.transform.InverseTransformPoint(transform.position);
        originalRotation = transform.rotation;

        transform.SetParent(vehicle.transform);
        transform.localPosition = Vector3.zero;
        rb.isKinematic = true;
        playerCollider.enabled = false;

        if (EventSystem.current != null)
        {
            EventSystem.current.SetSelectedGameObject(vehicle);
            Debug.Log("Vehicle selected: " + vehicle.name);
        }
        else
        {
            Debug.LogWarning("EventSystem is null!");
        }

        isMounted = true;
        var vehicleController = currentVehicle.GetComponent<VehicleController>();
        if (vehicleController != null)
        {
            vehicleController.SetMounted(true);
        }
        
        yield return null;
    }

    void Dismount()
    {
        transform.SetParent(null);
        transform.position = currentVehicle.transform.TransformPoint(originalLocalPosition);
        transform.rotation = originalRotation;

        rb.isKinematic = false;
        playerCollider.enabled = true;

        var vehicleController = currentVehicle.GetComponent<VehicleController>();
        if (vehicleController != null)
        {
            vehicleController.SetMounted(false);
        }
        
        currentVehicle = null;
        isMounted = false;

        // 캐릭터를 다시 보이게 설정
        SetCharacterVisible(true);
    }

    void HandleVehicleControls()
    {
        var vehicleControl = currentVehicle.GetComponent<IVehicleControl>();
        if (vehicleControl != null && canMoveVehicle)
        {
            vehicleControl.Control();
        }

        if (Input.GetMouseButtonDown(0))
        {
            var vehicleController = currentVehicle.GetComponent<VehicleController>();
            if (vehicleController != null)
            {
                vehicleController.StartFiring();
            }
        }
        if (Input.GetMouseButtonUp(0))
        {
            var vehicleController = currentVehicle.GetComponent<VehicleController>();
            if (vehicleController != null)
            {
                vehicleController.StopFiring();
            }
        }
    }

    public GameObject GetCurrentVehicle()
    {
        return currentVehicle;
    }

    public void SetCurrentVehicle(GameObject vehicle)
    {
        currentVehicle = vehicle;
    }

    public bool GetIsMounted()
    {
        return isMounted;
    }

    public void SetIsMounted(bool mounted)
    {
        isMounted = mounted;
    }

    // 캐릭터의 Renderer를 활성화 또는 비활성화하는 메서드
    public void SetCharacterVisible(bool isVisible)
    {
        Renderer[] renderers = GetComponentsInChildren<Renderer>();
        foreach (Renderer renderer in renderers)
        {
            renderer.enabled = isVisible;
        }
    }
}
