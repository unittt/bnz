using UnityEditor;
using UnityEngine;
using System.Collections;
using System.Text;

public class FindMissingComponent
{
    public static void FindMissScripts()
    {
        Debug.Log("检查开始，以下资源存在引用丢失");
        string[] paths = new string[]
        {
            "Assets",
        };
        string[] guids = AssetDatabase.FindAssets("t:GameObject", paths);
        foreach (string guid in guids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            GameObject go = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            FindInGameObject(path, go);
        }
        Debug.Log("检查完成");
    }

    private static void FindInGameObject(string path, GameObject go)
    {
        if (go == null)
        {
            return;
        }
        Component[] comps = go.GetComponents<Component>();
        for (int i = 0; i < comps.Length; ++i)
        {
            if (comps[i] == null)
            {
                Transform tran = go.transform;
                StringBuilder sb = new StringBuilder();
                sb.Append(go.name);
                while (tran.parent != null)
                {
                    sb.Insert(0, "/");
                    sb.Insert(0, tran.parent.name);
                    tran = tran.parent;
                }
                sb.Insert(0, string.Format("{0}/", path));
                Debug.Log(sb.ToString());
            }
        }
        foreach (Transform child in go.transform)
        {
            FindInGameObject(path, child.gameObject);
        }
    }
}
