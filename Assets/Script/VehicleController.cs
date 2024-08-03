using UnityEngine;

public class VehicleController : MonoBehaviour, IVehicleControl
{
    public float moveSpeed = 10f;
    public float rotationSpeed = 1f; // 1이면 1초에 360도 회전
    public float mountCheckRadius = 5f; // 탑승 가능 인식 범위

    private Rigidbody rb;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    void OnDrawGizmosSelected()
    {
        // 탑승 가능 인식 범위를 시각적으로 표시
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(transform.position, mountCheckRadius);
    }

    public void Control()
    {
        // 기본적인 이동 및 회전 조작
        float moveInput = Input.GetAxis("Vertical");
        float turnInput = Input.GetAxis("Horizontal");

        // 이동
        Vector3 move = transform.forward * moveInput * moveSpeed * Time.deltaTime;
        rb.MovePosition(rb.position + move);

        // 회전
        if (turnInput != 0)
        {
            float turn = (turnInput / rotationSpeed) * 360f * Time.deltaTime;
            Quaternion turnRotation = Quaternion.Euler(0f, turn, 0f);
            rb.MoveRotation(rb.rotation * turnRotation);
        }
    }
}