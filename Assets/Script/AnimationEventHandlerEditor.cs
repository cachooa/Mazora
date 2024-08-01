using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(AnimationEventHandler))]
public class AnimationEventHandlerEditor : Editor
{
    SerializedProperty playerControllerProp;
    SerializedProperty actionPresetsProp;
    bool[] showPresetSettings; // 각 프리셋의 설정을 보이게 할지 여부를 저장하는 배열

    void OnEnable()
    {
        playerControllerProp = serializedObject.FindProperty("playerController");
        actionPresetsProp = serializedObject.FindProperty("actionPresets");

        showPresetSettings = new bool[actionPresetsProp.arraySize];
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        EditorGUILayout.PropertyField(playerControllerProp);

        if (actionPresetsProp.isExpanded)
        {
            EditorGUILayout.PropertyField(actionPresetsProp, new GUIContent("Action Presets"), true);

            EditorGUI.indentLevel++;
            for (int i = 0; i < actionPresetsProp.arraySize; i++)
            {
                var element = actionPresetsProp.GetArrayElementAtIndex(i);
                var preset = element.objectReferenceValue as ActionPreset;

                if (preset != null)
                {
                    EditorGUILayout.BeginVertical("box");
                    showPresetSettings[i] = EditorGUILayout.Foldout(showPresetSettings[i], $"Preset {i} ({preset.name})");

                    if (showPresetSettings[i])
                    {
                        preset.actionForce = EditorGUILayout.FloatField("Action Force", preset.actionForce);
                        preset.actionRadius = EditorGUILayout.FloatField("Action Radius", preset.actionRadius);
                        preset.actionOffset = EditorGUILayout.Vector3Field("Action Offset", preset.actionOffset);
                        preset.actionForceDirection = EditorGUILayout.Vector3Field("Action Force Direction", preset.actionForceDirection);
                        preset.showPreview = EditorGUILayout.Toggle("Show Preview", preset.showPreview);

                        if (GUI.changed)
                        {
                            EditorUtility.SetDirty(preset);
                        }
                    }
                    EditorGUILayout.EndVertical();
                }
            }
            EditorGUI.indentLevel--;
        }
        else
        {
            EditorGUILayout.PropertyField(actionPresetsProp, new GUIContent("Action Presets"), true);
        }

        serializedObject.ApplyModifiedProperties();
    }
}