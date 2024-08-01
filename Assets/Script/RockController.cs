using UnityEngine;

public class RockController : MonoBehaviour
{
    void OnReceiveAction()
    {
        // 여기에 바위가 액션을 받을 때 수행할 작업을 작성합니다.
        Debug.Log("Action received by " + gameObject.name);
    }
}