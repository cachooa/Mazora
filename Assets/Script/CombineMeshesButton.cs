using UnityEngine;
using UnityEngine.UI;
using MTAssets.SkinnedMeshCombiner;

public class CombineMeshesButton : MonoBehaviour
{
    public Button uiButton;
    public SkinnedMeshCombiner skinnedMeshCombiner;

    void Start()
    {
        // UI 버튼의 클릭 이벤트에 OnButtonClick 함수 연결
        uiButton.onClick.AddListener(OnUIButtonClick);
    }

    public void OnUIButtonClick()
    {
        // Combine Meshes 메서드 호출
        skinnedMeshCombiner.DoCombineMeshs_AllInOne();
    }
}