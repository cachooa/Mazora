using UnityEngine;

public class VehicleController : MonoBehaviour, IVehicleControl
{
    public float maxMoveSpeed = 10f;
    public float maxTurnPower = 4f; // 최대 선회력
    public float accelerationTime = 1f; // 최대 속도까지 도달하는데 걸리는 시간 (초)
    public float mountCheckRadius = 5f; // 탑승 가능 인식 범위

    private float currentMoveSpeed = 0f;
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

        // 가속도 계산
        float acceleration = maxMoveSpeed / accelerationTime;

        if (moveInput != 0)
        {
            // 이동 속도 업데이트
            currentMoveSpeed += moveInput * acceleration * Time.deltaTime;
            currentMoveSpeed = Mathf.Clamp(currentMoveSpeed, -maxMoveSpeed, maxMoveSpeed);

            // 이동
            Vector3 move = transform.forward * currentMoveSpeed * Time.deltaTime;
            rb.MovePosition(rb.position + move);
        }
        else
        {
            // 이동 입력이 없을 경우 속도를 즉시 0으로 설정
            currentMoveSpeed = 0f;
        }

        // 선회력은 이동 속도에 비례하여 적용
        float speedFactor = Mathf.Abs(currentMoveSpeed) / maxMoveSpeed;
        float adjustedTurnPower = maxTurnPower * speedFactor;

        if (turnInput != 0 && Mathf.Abs(currentMoveSpeed) > 0)
        {
            if (moveInput < 0)
            {
                turnInput = -turnInput; // S를 누를 때 A와 D가 반대로 적용되도록 함
            }

            float turn = (turnInput * adjustedTurnPower) * 360f * Time.deltaTime;
            Quaternion turnRotation = Quaternion.Euler(0f, turn, 0f);
            rb.MoveRotation(rb.rotation * turnRotation);
        }
    }

    void OnCollisionEnter(Collision collision)
    {
        // 충돌한 오브젝트가 고정된 콜라이더인지 확인
        if (collision.rigidbody == null || collision.rigidbody.isKinematic)
        {
            // 속도를 절반으로 줄임
            currentMoveSpeed *= 0.5f;
        }
    }
}