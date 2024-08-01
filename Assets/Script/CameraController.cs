using UnityEngine;

public class CameraController : MonoBehaviour
{
    public Transform target; // 카메라가 따라갈 타겟
    public float targetHeight = 0.5f; // 타겟의 높이 (Y축 위치 조정)
    public float distance = 5.0f; // 초기 거리
    public float minDistance = 2.0f; // 최소 줌 거리
    public float maxDistance = 10.0f; // 최대 줌 거리
    public float zoomSpeed = 2.0f; // 줌 속도
    public float rotationSpeed = 1.0f; // 회전 속도 (1이면 1초에 목표 각도에 도달)

    private float currentX = 0.0f;
    private float currentY = 0.0f;
    private bool isFocused = true; // 포커스 여부 확인

    // Y축 회전 각도의 최소/최대 값 (각도 제한)
    public float minYAngle = -80f;
    public float maxYAngle = 80f;

    void OnApplicationFocus(bool hasFocus)
    {
        isFocused = hasFocus;
    }

    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked; // 마우스 커서 숨김 및 고정
        Cursor.visible = false; // 마우스 커서 숨김
    }

    void Update()
    {
        if (isFocused)
        {
            // 마우스 입력 처리
            currentX += Input.GetAxis("Mouse X") * 360f / rotationSpeed * Time.deltaTime;
            currentY -= Input.GetAxis("Mouse Y") * 360f / rotationSpeed * Time.deltaTime;

            // Y축 회전 각도를 제한
            currentY = Mathf.Clamp(currentY, minYAngle, maxYAngle);

            // 줌 인/줌 아웃 처리
            float scroll = Input.GetAxis("Mouse ScrollWheel");
            distance -= scroll * zoomSpeed;
            distance = Mathf.Clamp(distance, minDistance, maxDistance);
        }
    }

    void LateUpdate()
    {
        // 카메라 위치 및 회전 설정
        Vector3 direction = new Vector3(0, 0, -distance);
        Quaternion rotation = Quaternion.Euler(currentY, currentX, 0);
        Vector3 targetPosition = target.position + new Vector3(0, targetHeight, 0);
        transform.position = targetPosition + rotation * direction;
        transform.LookAt(targetPosition);
    }
}