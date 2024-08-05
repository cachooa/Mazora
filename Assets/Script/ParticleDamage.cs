using UnityEngine;

public class ParticleDamage : MonoBehaviour
{
    private float actionForce = 10f; // 액션 시 가할 힘 (데미지 및 힘으로 사용)

    // 이 메서드는 발사체가 생성될 때 호출되어 공격력을 설정합니다.
    public void SetProjectilePreset(ProjectilePreset preset)
    {
        actionForce = preset.actionForce;
    }

    void OnParticleCollision(GameObject other)
    {
        Debug.Log("파티클 충돌 감지: " + other.name);
        ApplyDamageAndForce(other);
    }

    void OnCollisionEnter(Collision collision)
    {
        Debug.Log("OnCollisionEnter 감지: " + collision.gameObject.name);
        ApplyDamageAndForce(collision.gameObject);
    }

    private void ApplyDamageAndForce(GameObject targetObject)
    {
        // 충돌한 객체에 Rigidbody가 있으면 힘을 가함
        Rigidbody rb = targetObject.GetComponent<Rigidbody>();
        if (rb != null)
        {
            Vector3 direction = (targetObject.transform.position - transform.position).normalized;
            rb.AddForce(direction * actionForce, ForceMode.Impulse);
            Debug.Log("힘 적용됨: " + direction * actionForce);
        }
        else
        {
            Debug.Log("Rigidbody가 없는 객체: " + targetObject.name);
        }

        // 충돌한 객체가 ObjectTarget인지 확인하고 데미지를 적용
        ObjectTarget target = targetObject.GetComponent<ObjectTarget>();
        if (target != null)
        {
            Debug.Log("데미지 처리 대상: " + targetObject.name);
            target.TakeDamage(actionForce); // 데미지 적용
        }
        else
        {
            Debug.Log("데미지 처리 대상이 아님: " + targetObject.name);
        }
    }
}