using UnityEngine;
using UnityEngine.UI;

public class PerformanceDisplay : MonoBehaviour
{
    public Text fpsText;
    public Text memoryText;
    private float deltaTime = 0.0f;

    void Update()
    {
        // FPS 계산
        deltaTime += (Time.unscaledDeltaTime - deltaTime) * 0.1f;
        float fps = 1.0f / deltaTime;
        fpsText.text = string.Format("FPS: {0:0.}", fps);

        // 메모리 사용량 계산
        long totalMemory = System.GC.GetTotalMemory(false);
        memoryText.text = string.Format("Memory: {0} MB", totalMemory / (1024 * 1024));
    }
}