using UnityEngine;

public class ObjectTarget : MonoBehaviour
{
    public float health = 100f; // 대상의 체력
    public Animator animator; // 대상의 애니메이터
    public DeathPreset deathPreset; // 사망 프리셋

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
        // 사망 애니메이션 Bool 설정
        if (animator != null)
        {
            animator.SetBool("IsDead", true);
        }

        // 폭파 이펙트 생성
        if (deathPreset != null && deathPreset.deathEffectPrefab != null)
        {
            Instantiate(deathPreset.deathEffectPrefab, transform.position, transform.rotation);
        }

        // 오브젝트 비활성화 또는 삭제
        if (deathPreset != null)
        {
            Destroy(gameObject, deathPreset.destroyTime); // 지정된 시간 후에 오브젝트 삭제
        }
        else
        {
            Destroy(gameObject, 2f); // 기본값으로 2초 후 삭제
        }
    }

    public void OnReceiveAction(ActionPreset actionPreset)
    {
        Debug.Log("Action received by " + gameObject.name);

        // 액션 프리셋을 기반으로 데미지 처리
        float damage = actionPreset.actionForce; // 예를 들어 actionForce를 데미지로 사용
        TakeDamage(damage);
    }
}