using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

public class UIEventHandlerCheck
{
    public static void Run()
    {
        Debug.Log("UIEventHandlerCheck");
        string resPath = "Assets/GameRes/UI";
        string[] files = Directory.GetFiles(resPath, "*.prefab", SearchOption.AllDirectories);

        foreach (string fname in files)
        {
            string name = fname.Replace("\\", "/");
            GameObject prefab = AssetDatabase.LoadAssetAtPath(name, typeof(GameObject)) as GameObject;
            GameObject go = Object.Instantiate(prefab) as GameObject;
            if (go != null)
            {
                int count = ReplaceOne(go);
                if (count > 0)
                {
                    Debug.Log(string.Format("更新 name = {0}, count = {1}", name, count));
                    PrefabUtility.CreatePrefab(name, go, ReplacePrefabOptions.ConnectToPrefab);
                }
            }
            else
            {
                Debug.LogError("error " + name);
            }
            GameObject.DestroyImmediate(go);
        }
        Debug.Log("替换完成");
    }

    public static int ReplaceOne(GameObject parent)
    {
        int count = 0;
        Transform[] containers = parent.transform.GetComponentsInChildren<Transform>(true);
        for (int i = 0; i < containers.Length; i++)
        {
            GameObject go = containers[i].gameObject;
            UIEventListener uiListener = go.GetComponent<UIEventListener>();
            if (uiListener != null)
            {
                GameObject.DestroyImmediate(uiListener);
            }

            if (go.GetComponent<BoxCollider>() != null && go.GetComponent<UIScrollView>() == null)
            {
                UIEventHandler uiHanlder = go.GetComponent<UIEventHandler>();
                if (uiHanlder == null)
                {
                    go.AddComponent<UIEventHandler>();
                    count++;
                }
            }
        }
        return count;
    }
}
