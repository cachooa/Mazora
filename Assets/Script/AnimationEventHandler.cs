using UnityEngine;
using System.Collections.Generic;

public class AnimationEventHandler : MonoBehaviour
{
    public PlayerController playerController; // PlayerController 참조

    public List<ActionPreset> actionPresets; // 액션 프리셋 리스트
    private ActionPreset currentPreset; // 현재 활성화된 프리셋
    private bool actionActivated; // 액션 활성화 여부

    void Update()
    {
        if (actionActivated && currentPreset != null)
        {
            ApplyForceToNearbyObjects(currentPreset);
            actionActivated = false; // 한 번만 적용되도록 설정
        }
    }

    // 애니메이션 이벤트에 의해 호출되는 메서드
    public void OnActionEnd()
    {
        playerController.OnActionEnd(); // PlayerController의 OnActionEnd 메서드를 호출
    }

    // 애니메이션 이벤트에 의해 호출되는 메서드
    public void ActivateActionPreset(string presetName)
    {
        currentPreset = actionPresets.Find(p => p.name == presetName);
        actionActivated = true;
    }

    // 설정된 영역 내의 오브젝트들에게 힘을 가하거나 값을 전달하는 메서드
    void ApplyForceToNearbyObjects(ActionPreset preset)
    {
        Vector3 actionPosition = playerController.transform.position + playerController.transform.forward * preset.actionOffset.z + playerController.transform.right * preset.actionOffset.x + playerController.transform.up * preset.actionOffset.y;
        Collider[] colliders = Physics.OverlapSphere(actionPosition, preset.actionRadius);

        foreach (Collider collider in colliders)
        {
            Rigidbody targetRb = collider.GetComponent<Rigidbody>();
            if (targetRb != null && targetRb != playerController.GetComponent<Rigidbody>())
            {
                // Rigidbody가 있는 경우 힘을 가함
                Vector3 forceDirection = playerController.transform.TransformDirection(preset.actionForceDirection.normalized);
                targetRb.AddForce(forceDirection * preset.actionForce, ForceMode.Impulse);
            }
            else
            {
                // Rigidbody가 없는 경우 다른 값을 전달
                collider.SendMessage("OnReceiveAction", SendMessageOptions.DontRequireReceiver);
            }
        }
    }

    // 기즈모를 사용하여 액션 범위를 시각화
    void OnDrawGizmosSelected()
    {
        foreach (var preset in actionPresets)
        {
            if (preset.showPreview)
            {
                DrawGizmo(preset);
            }
        }

        if (actionActivated && currentPreset != null)
        {
            DrawGizmo(currentPreset);
        }
    }

    private void DrawGizmo(ActionPreset preset)
    {
        Gizmos.color = Color.red;
        Vector3 actionPosition = playerController.transform.position + playerController.transform.forward * preset.actionOffset.z + playerController.transform.right * preset.actionOffset.x + playerController.transform.up * preset.actionOffset.y;
        Gizmos.DrawWireSphere(actionPosition, preset.actionRadius);

        // 힘이 가해지는 방향을 화살표로 시각화
        Gizmos.color = Color.blue;
        Vector3 forceDirection = playerController.transform.TransformDirection(preset.actionForceDirection.normalized);
        Gizmos.DrawLine(actionPosition, actionPosition + forceDirection * preset.actionRadius);
        Gizmos.DrawRay(actionPosition, forceDirection * preset.actionRadius);
    }
}