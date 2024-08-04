using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using TMPro;
using MTAssets.SkinnedMeshCombiner;

public class CombineMeshesManager : MonoBehaviour
{
    public Button oneButton;
    public Button allButton;
    public Button restartButton;

    public TextMeshProUGUI oneButtonText;
    public TextMeshProUGUI allButtonText;
    public TextMeshProUGUI statusText; // 추가된 TextMeshProUGUI 필드

    public List<SkinnedMeshCombiner> skinnedMeshCombiners = new List<SkinnedMeshCombiner>();

    private int currentIndex = 0;

    void Start()
    {
        oneButton.onClick.AddListener(OnOneButtonClick);
        allButton.onClick.AddListener(OnAllButtonClick);
        restartButton.onClick.AddListener(OnRestartButtonClick);

        // Skinned Mesh Combiner 컴포넌트를 자동으로 찾아 배열에 추가
        SkinnedMeshCombiner[] foundCombiners = FindObjectsOfType<SkinnedMeshCombiner>();
        skinnedMeshCombiners.AddRange(foundCombiners);

        UpdateStatusText();
    }

    public void OnOneButtonClick()
    {
        if (currentIndex < skinnedMeshCombiners.Count)
        {
            skinnedMeshCombiners[currentIndex].DoCombineMeshs_AllInOne();
            currentIndex++;
            UpdateStatusText();
        }
    }

    public void OnAllButtonClick()
    {
        foreach (var combiner in skinnedMeshCombiners)
        {
            combiner.DoCombineMeshs_AllInOne();
        }
        currentIndex = skinnedMeshCombiners.Count; // 모든 캐릭터가 변경되었으므로 currentIndex 업데이트
        UpdateStatusText();
    }

    public void OnRestartButtonClick()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    private void UpdateStatusText()
    {
        statusText.text = $"Changed: {currentIndex} / Total: {skinnedMeshCombiners.Count}";
    }
}