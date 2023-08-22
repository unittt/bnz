using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;


[CustomEditor(typeof(ColorShortText))]
public class ColorShortTextEdior : Editor
{
    public override void OnInspectorGUI()
    {
        ShowInputField(target as ColorShortText);
        if (GUI.changed)
        {
            EditorUtility.SetDirty(target);
        }
    }


    private void ShowInputField(ColorShortText obj)
    {
        for (int i = 0; i < 26; i++)
        {
            char key = (char)(i + 'A');
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("匹配字符: " + key.ToString(), GUILayout.MaxWidth(80));
            obj.colorArray[i] = EditorGUILayout.ColorField(obj.colorArray[i], GUILayout.MaxWidth(180));
            EditorGUILayout.EndHorizontal();
        }

    }
        
}
