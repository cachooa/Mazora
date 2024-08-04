using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using MTAssets.SkinnedMeshCombiner;

public class CombineMeshesManager : MonoBehaviour
{
    public Button oneButton;
    public Button allButton;

    public List<SkinnedMeshCombiner> skinnedMeshCombiners = new List<SkinnedMeshCombiner>();

    void Start()
    {
        oneButton.onClick.AddListener(OnOneButtonClick);
        allButton.onClick.AddListener(OnAllButtonClick);

        // Skinned Mesh Combiner 컴포넌트를 자동으로 찾아 배열에 추가
        SkinnedMeshCombiner[] foundCombiners = FindObjectsOfType<SkinnedMeshCombiner>();
        skinnedMeshCombiners.AddRange(foundCombiners);
    }

    public void OnOneButtonClick()
    {
        if (skinnedMeshCombiners.Count > 0)
        {
            // 첫 번째 SkinnedMeshCombiner만 작동
            skinnedMeshCombiners[0].DoCombineMeshs_AllInOne();
        }
    }

    public void OnAllButtonClick()
    {
        foreach (var combiner in skinnedMeshCombiners)
        {
            combiner.DoCombineMeshs_AllInOne();
        }
    }
}