using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

public class UILabelTools : EditorWindow
{
    private static FontStyle _fromfontStyle;
    private static FontStyle _tofontStyle;
    public static void LabelToolsWindow()
    {
        var window = GetWindow<UILabelTools>(false, "UILabelTools", true);
        window.minSize = new Vector2(200, 200);
        window.Show();
    }
    public static void ChangeLabelFontStyle()
    {
        Debug.Log("开始转换");
        string[] paths = new string[]
        {
            "Assets/GameRes/UI",
        };
        string[] guids = AssetDatabase.FindAssets("t:GameObject", paths);
        foreach (string guid in guids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            GameObject go = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            FindInGameObject(path, go, _fromfontStyle, _tofontStyle);
        }
        AssetDatabase.Refresh();
        AssetDatabase.SaveAssets();
        Debug.Log("结束转换");
    }

    private static void FindInGameObject(string path, GameObject go, FontStyle fromType, FontStyle toType)
    {
        UILabel[] comps = go.GetComponentsInChildren<UILabel>(true);
        for (int i = 0; i < comps.Length; ++i)
        {
            UILabel uiLabel = comps[i];
            if (uiLabel.fontStyle == fromType)
            {
                Debug.Log("修改类型：" + fromType + "->" + toType + "--修改位置：" + path + "" + uiLabel.gameObject.name);
                uiLabel.fontStyle = toType;
                EditorUtility.SetDirty(go);
            }
        }
    }

    private void OnGUI()
    {
        EditorGUILayout.Space();
        EditorGUILayout.BeginVertical("HelpBox", GUILayout.Width(450f));
        {
            GUILayout.Label("字体类型修改", "BoldLabel");
            _fromfontStyle = (FontStyle)EditorGUILayout.EnumPopup("被修改的类型:", _fromfontStyle);
            _tofontStyle = (FontStyle)EditorGUILayout.EnumPopup("需要修改成的类型:", _tofontStyle);
            string tip = _fromfontStyle == _tofontStyle ? "(注意:转换类型相同)" : "";
            GUILayout.Label("转换信息：" + _fromfontStyle + "->" + _tofontStyle + tip, "BoldLabel");
            if (GUILayout.Button("执行", "LargeButton", GUILayout.Height(50f)))
            {
                if (tip == "")
                {
                    ChangeLabelFontStyle();
                }
            }
        }
    }
}
