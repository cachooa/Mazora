using UnityEngine;

[CreateAssetMenu(fileName = "ActionPreset", menuName = "ScriptableObjects/ActionPreset", order = 1)]
public class DeathPreset : ScriptableObject
{
    public GameObject deathEffectPrefab; // 폭파 이펙트 프리팹
    public float destroyTime = 2f; // 오브젝트가 삭제될 시간 (초)
}