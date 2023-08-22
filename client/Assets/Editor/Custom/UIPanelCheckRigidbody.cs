using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

public class UIPanelCheckRigidbody
{
    public static void PanelAddRigidbody()
    {
        Debug.Log("开始:为所有Panel调价Rigidbody");
        string[] paths = new string[]
        {
            "Assets/GameRes/UI",
        };
        string[] guids = AssetDatabase.FindAssets("t:GameObject", paths);
        foreach (string guid in guids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            GameObject go = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            FindInGameObject(path, go);
        }
        AssetDatabase.Refresh();
        Debug.Log("结束:为所有Panel调价Rigidbody");
    }

    private static Dictionary<string, UIPanel> atlasDict = new Dictionary<string, UIPanel>();
    private static void FindInGameObject(string path, GameObject go)
    {
        UIPanel[] comps = go.GetComponentsInChildren<UIPanel>(true);
        for (int i = 0; i < comps.Length; ++i)
        {
            UIPanel uipanel = comps[i];
            Rigidbody rigidbody = uipanel.GetComponent<Rigidbody>();
            if (uipanel != null && rigidbody == null)
            {
                Debug.Log("新加Rigidbody的Panel：" + path + "" + uipanel.gameObject.name);
                uipanel.gameObject.AddComponent<Rigidbody>();
                rigidbody = uipanel.gameObject.GetComponent<Rigidbody>();
                rigidbody.useGravity = false;
                rigidbody.isKinematic = true;
            }
            else if (uipanel != null && rigidbody != null)
            {
                Debug.Log("修改Panel的Rigidbody属性：" + path + "" + uipanel.gameObject.name);
                rigidbody = uipanel.gameObject.GetComponent<Rigidbody>();
                rigidbody.useGravity = false;
                rigidbody.isKinematic = true;
            }
        }
    }
}
