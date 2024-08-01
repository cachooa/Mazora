using UnityEngine;

public class AnimationEventHandler : MonoBehaviour
{
    public PlayerController playerController; // PlayerController 참조

    // 애니메이션 이벤트에 의해 호출되는 메서드
    public void OnActionEnd()
    {
        playerController.OnActionEnd(); // PlayerController의 OnActionEnd 메서드를 호출
    }
}