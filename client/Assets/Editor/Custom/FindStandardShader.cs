using UnityEditor;
using UnityEngine;
using System.Collections;
using System.Text;

public class FindStandardShader
{
    public static void CheckStandardShader()
    {
        Debug.Log("检查开始，以下资源使用StandardShader");
        string[] paths = new string[]
        {
            "Assets",
        };
        string[] guids = AssetDatabase.FindAssets("t:Material", paths);
        foreach (string guid in guids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            Material mat = AssetDatabase.LoadAssetAtPath(path, typeof(Material)) as Material;
            if (mat.shader == Shader.Find("Standard"))
            {
                Debug.Log(path, mat);
            }
            //FindInGameObject(path, go);
        }
        Debug.Log("检查完成");
    }

    //private static void FindInGameObject(string path, GameObject go)
    //{
    //    if (go == null)
    //    {
    //        return;
    //    }
    //    Component[] comps = go.GetComponents<Component>();
    //    for (int i = 0; i < comps.Length; ++i)
    //    {
    //        if (comps[i] == null)
    //        {
    //            Transform tran = go.transform;
    //            StringBuilder sb = new StringBuilder();
    //            sb.Append(go.name);
    //            while (tran.parent != null)
    //            {
    //                sb.Insert(0, "/");
    //                sb.Insert(0, tran.parent.name);
    //                tran = tran.parent;
    //            }
    //            sb.Insert(0, string.Format("{0}/", path));
    //            Debug.Log(sb.ToString());
    //        }
    //    }
    //    foreach (Transform child in go.transform)
    //    {
    //        FindInGameObject(path, child.gameObject);
    //    }
    //}
}
