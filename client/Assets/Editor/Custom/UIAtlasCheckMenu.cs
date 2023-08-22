using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;


public class UIAtlasCheckMenu
{
    public static void FindNotRefAtlas()
    {
        Debug.Log("检查开始，以下资源引用非Ref类型图集");
        //LoadAllAtlas();
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
        Debug.Log("检查完成");
    }

    public static void FindNotRefAtlas(string path)
    {
        GameObject go = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
        FindInGameObject(path, go);
        AssetDatabase.Refresh();
    }

    private static Dictionary<string, UIAtlas> atlasDict = new Dictionary<string,UIAtlas>();

    private static void LoadAllAtlas()
    {
        atlasDict.Clear();
        string[] paths = new string[]
        {
            "Assets/GameRes/Atlas",
        };
        string[] guids = AssetDatabase.FindAssets("t:GameObject", paths);
        foreach (string guid in guids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            GameObject go = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            if(go.name.StartsWith("Ref"))
            {
                UIAtlas atlas = go.GetComponent<UIAtlas>();

                //if (go.name == "RefItemAtlas")
                //{
                //    atlasDict.Add("ItemAtlas1", atlas);
                //}
                //else
                //{
                    atlasDict.Add(go.name.Substring(3), atlas);
                //}

                Debug.Log("加载 " + atlas.replacement);
            }
        }
    }

    private static void FindInGameObject(string path, GameObject go)
    {
        //GameObject go = GameObject.Instantiate<GameObject>(prefab);
        UISprite[] comps = go.GetComponentsInChildren<UISprite>(true);
        bool isReplaceed = false;
        for (int i = 0; i < comps.Length; ++i)
        {
            UISprite sprite = comps[i];
            if (sprite != null && sprite.atlas != null)
            {
                if (sprite.atlas.replacement == null)
                {
                    //if (!atlasDict.ContainsKey(sprite.atlas.name))
                    //{
                    //    Debug.LogError(path + " 找不到Atlas " + sprite.atlas.name);
                    //    return;
                    //}
                    //sprite.atlas = atlasDict[sprite.atlas.name];
                    //isReplaceed = true;

                    Debug.LogError(path + " " + sprite.gameObject.name + " -> "  + sprite.atlas);
                    EditorUtility.DisplayDialog("提示", path + " " + sprite.gameObject.name + " -> " + sprite.atlas + " 引用了非fre图集", "确定", "");
                }

            }
        }
        //if(isReplaceed)
        //{
        //    PrefabUtility.ReplacePrefab(go, prefab, ReplacePrefabOptions.ConnectToPrefab);
        //    Debug.Log(path);
        //}

    }
}
