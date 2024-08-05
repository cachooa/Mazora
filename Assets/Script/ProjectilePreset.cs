using UnityEngine;

[CreateAssetMenu(fileName = "ProjectilePreset", menuName = "ScriptableObjects/ProjectilePreset", order = 1)]
public class ProjectilePreset : ScriptableObject
{
    public GameObject prefabSlot; // 발사체 프리팹
    public float fireRate = 1f; // 연사 속도 (초당 발사 횟수)
    public float destroyAfterSeconds = 5f; // 발사체가 생성된 후 삭제될 때까지의 시간
}