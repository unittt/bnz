using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

public class ModelCheckTools : EditorWindow
{
    enum ModelCheckType
    {
        Controller = 0,
        SharedMaterials = 1,
    }
    private static ModelCheckType _modelCheckType;
    public static void ModelCheckToolsWindow()
    {
        var window = GetWindow<ModelCheckTools>(false, "ModelCheckTools", true);
        window.minSize = new Vector2(200, 100);
        window.Show();
    }
    public static void ActionCheck()
    {
        Debug.Log("开始检测");
        string[] paths = new string[]
        {
            "Assets/GameRes/Model/Character",
        };
        string[] guids = AssetDatabase.FindAssets("t:GameObject", paths);
        foreach (string guid in guids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            if (path.IndexOf(".prefab") != -1)
            {
                GameObject go = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
                FindInGameObject(path, go, _modelCheckType);
            }
        }
        AssetDatabase.Refresh();
        AssetDatabase.SaveAssets();
        Debug.Log("结束检测");
    }

    private static void FindInGameObject(string path, GameObject go, ModelCheckType modelCheckType)
    {
        if (modelCheckType == ModelCheckType.Controller)
        {
            Animator animator = go.GetComponent<Animator>();
            if (animator.runtimeAnimatorController == null)
            {
                Debug.Log(go.gameObject.name);
            }
        }
        else if (modelCheckType == ModelCheckType.SharedMaterials)
        {
            SkinnedMeshRenderer[] comps = go.GetComponentsInChildren<SkinnedMeshRenderer>(true);
            for (int i = 0; i < comps.Length; ++i)
            {
                SkinnedMeshRenderer skinnedMeshRenderer = comps[i];
                if (skinnedMeshRenderer && skinnedMeshRenderer.sharedMaterials.Length > 1)
                {
                    Debug.Log(go.gameObject.name + "--->" + comps[i].gameObject.name + "-->" + skinnedMeshRenderer.sharedMaterials.Length);
                }
            }
        }
    }

    private void OnGUI()
    {
        EditorGUILayout.Space();
        EditorGUILayout.BeginVertical("HelpBox", GUILayout.Width(400f));
        {
            if (GUILayout.Button("检测AnimatorController是否存在null", "LargeButton", GUILayout.Height(30f)))
            {
                _modelCheckType = ModelCheckType.Controller;
                ActionCheck();
            }
            if (GUILayout.Button("检测SkinnedMeshRenderer中Materials是否 > 2", "LargeButton", GUILayout.Height(30f)))
            {
                _modelCheckType = ModelCheckType.SharedMaterials;
                ActionCheck();
            }
        }
    }
}
