using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;
using UnityEditor;

public class UILabelStyleMenu
{
    private static string labelStylePath = "Assets/Editor/UILabelStyle";
    private static Dictionary<string, UILabel> labelStyleDict = new Dictionary<string, UILabel>();
    
    public static void LabelStyleUpdate()
    {
        string[] guids = Selection.assetGUIDs;
        if (guids == null || Selection.assetGUIDs.Length == 0)
        {
            Debug.LogError("请选择正确的样式文件");
            return;
        }

        string file = AssetDatabase.GUIDToAssetPath(guids[0]);
        if (!(file.StartsWith(labelStylePath) && file.EndsWith(".prefab")))
        {
            Debug.LogError("请选择正确的样式文件");
            return;
        }

        LoadAllLabelStyle();
        string styleName = Path.GetFileNameWithoutExtension(file);

        Debug.Log("替换样式  " + styleName);
        string resPath = "Assets/GameRes/UI";
        string[] files = Directory.GetFiles(resPath, "*.prefab", SearchOption.AllDirectories);

        foreach (string fname in files)
        {
            string name = fname.Replace("\\", "/");
            GameObject prefab = AssetDatabase.LoadAssetAtPath(name, typeof(GameObject)) as GameObject;
            GameObject go = Object.Instantiate(prefab) as GameObject;
            if (go != null)
            {
                int count = ReplaceOne(go, styleName);
                if (count > 0)
                {
                    Debug.Log(string.Format("更新 name = {0}, count = {1}", name, count));
                    PrefabUtility.CreatePrefab(name, go, ReplacePrefabOptions.ConnectToPrefab);
                }
            }
            else
                Debug.LogError("error " + name);
            GameObject.DestroyImmediate(go);
        }
        Debug.Log("替换完成");
    }

    //private static string GetStyleName(string path)
    //{
    //    return Path.GetFileNameWithoutExtension(path);
    //}

    //private static void LoadOneLabelStyles(string file)
    //{
    //    labelStyleDict.Clear();
    //    string name = file.Substring(labelStylePath.Length + 1, file.Length - 8 - labelStylePath.Length);
    //    GameObject stylePrefab = AssetDatabase.LoadAssetAtPath(file, typeof(GameObject)) as GameObject;
    //    UILabel styleLabel = stylePrefab.GetComponent<UILabel>();
    //    labelStyleDict.Add(name, styleLabel);
    //}


    private static void LoadAllLabelStyle()
    {
        labelStyleDict.Clear();
        string[] guids = AssetDatabase.FindAssets("t:GameObject", new string[] { labelStylePath });
        for (int i = 0; i < guids.Length; ++i)
        {
            string file = AssetDatabase.GUIDToAssetPath(guids[i]);
            string name = Path.GetFileNameWithoutExtension(file);
            GameObject stylePrefab = AssetDatabase.LoadAssetAtPath(file, typeof(GameObject)) as GameObject;
            UILabel styleLabel = stylePrefab.GetComponent<UILabel>();
            labelStyleDict.Add(name, styleLabel);
        }
    }

    public static List<string> GetStyleNameList()
    {
        LoadAllLabelStyle();
        List<string> list = new List<string>(labelStyleDict.Keys);
        return list;
    }

    public static UILabel GetLabelByStyle(string style)
    {
        LoadAllLabelStyle();
        return labelStyleDict[style];
    }

    public static int ReplaceOne(GameObject go, string styleName)
    {
        int count = 0;
        UILabel[] list = go.GetComponentsInChildren<UILabel>();
        for (int i = 0; i < list.Length; i++)
        {
            UILabel label = list[i];
            if (label.mTextStyle == styleName && labelStyleDict.ContainsKey(styleName))
            {
                UILabel src = labelStyleDict[styleName];
                label.SetTextStyleData(src.GetTextStyleData());
                count += 1;
            }
        }
        return count;
    }


}

