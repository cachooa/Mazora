using UnityEngine;

[CreateAssetMenu(fileName = "ActionPreset", menuName = "ScriptableObjects/ActionPreset", order = 1)]
public class ActionPreset : ScriptableObject
{
    public float actionForce; // 액션 시 가할 힘
    public float actionRadius; // 액션 범위 반지름
    public Vector3 actionOffset; // 액션 범위의 위치 오프셋
    public Vector3 actionForceDirection; // 힘이 가해질 방향
    public bool showPreview; // 미리보기 체크박스
}