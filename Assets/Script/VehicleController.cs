using System.Collections;
using UnityEngine;

[System.Serializable]
public class ProjectileGroup
{
    public ProjectilePreset projectilePreset;
    public Transform projectileSpawnPoint;
}

public class VehicleController : MonoBehaviour, IVehicleControl
{
    public float maxMoveSpeed = 10f;
    public float maxTurnPower = 4f; // 최대 선회력
    public float accelerationTime = 1f; // 최대 속도까지 도달하는데 걸리는 시간 (초)
    public float mountCheckRadius = 5f; // 탑승 가능 인식 범위

    private float currentMoveSpeed = 0f;
    private Rigidbody rb;

    // Projectile 그룹 관련 변수
    public ProjectileGroup[] projectileGroups; // ProjectileGroup 참조 배열
    private int currentGroupIndex = 0; // 현재 선택된 그룹 인덱스
    private bool isFiring = false;
    private float lastFireTime; // 마지막 발사 시간
    private Coroutine firingCoroutine;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
        if (projectileGroups.Length == 0)
        {
            Debug.LogError("ProjectileGroups가 설정되지 않았습니다.");
        }
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

        // 프리셋 변경 입력 처리
        if (Input.GetKeyDown(KeyCode.Alpha1)) ChangePreset(0);
        if (Input.GetKeyDown(KeyCode.Alpha2)) ChangePreset(1);
        if (Input.GetKeyDown(KeyCode.Alpha3)) ChangePreset(2);
        if (Input.GetKeyDown(KeyCode.Alpha4)) ChangePreset(3);

        // 현재 인덱스가 배열 크기를 넘지 않도록 제한
        currentGroupIndex = Mathf.Clamp(currentGroupIndex, 0, projectileGroups.Length - 1);
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

    void OnCollisionEnter(Collision collision)
    {
        // 충돌한 오브젝트가 고정된 콜라이더인지 확인
        if (collision.rigidbody == null || collision.rigidbody.isKinematic)
        {
            // 속도를 절반으로 줄임
            currentMoveSpeed *= 0.5f;
        }
    }

    public void StartFiring()
    {
        if (firingCoroutine == null)
        {
            isFiring = true;
            firingCoroutine = StartCoroutine(FireProjectiles());
        }
    }

    public void StopFiring()
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
            Vector3 spawnPosition = currentGroup.projectileSpawnPoint.position + currentGroup.projectileSpawnPoint.forward * 0.5f; // 본체로부터 약간 떨어진 위치
            GameObject projectile = Instantiate(currentGroup.projectilePreset.prefabSlot, spawnPosition, currentGroup.projectileSpawnPoint.rotation);
            Debug.Log("발사체 생성: " + projectile.name + " at " + spawnPosition);

            ParticleDamage particleDamage = projectile.GetComponent<ParticleDamage>();
            if (particleDamage != null)
            {
                particleDamage.SetProjectilePreset(currentGroup.projectilePreset);
                Debug.Log("ParticleDamage 설정됨: " + particleDamage);
            }

            Destroy(projectile, currentGroup.projectilePreset.destroyAfterSeconds);
        }
        else
        {
            Debug.LogWarning("ProjectilePreset, prefabSlot 또는 projectileSpawnPoint가 설정되지 않았습니다.");
        }
    }

    public void SetMounted(bool mounted)
    {
        // 차량 탑승 상태 설정
    }
}
