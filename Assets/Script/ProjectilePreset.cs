using UnityEngine;

[CreateAssetMenu(fileName = "ProjectilePreset", menuName = "ScriptableObjects/ProjectilePreset", order = 1)]
public class ProjectilePreset : ScriptableObject
{
    public GameObject prefabSlot;
    public float fireRate;
    public float actionForce; // 액션 시 가할 힘 (데미지 및 힘으로 사용)
    public float destroyAfterSeconds;
}