using UnityEngine;
using System.Collections;
using UnityEditor;

public class PrefabApply : Editor
{
    [InitializeOnLoadMethod]
    static void StartInitializeOnLoadMethod()
    {
        PrefabUtility.prefabInstanceUpdated = delegate (GameObject instance)
        {
            //路径
           // Debug.Log(AssetDatabase.GetAssetPath(PrefabUtility.GetPrefabParent(instance)));
            UIAtlasCheckMenu.FindNotRefAtlas(AssetDatabase.GetAssetPath(PrefabUtility.GetPrefabParent(instance)));
        };
    }
    [InitializeOnLoadMethod]
    static void Star()
    {
        PrefabUtility.prefabInstanceUpdated = delegate
        {
            GameObject go = null;
            if (Selection.activeTransform)
            {
                go = Selection.activeGameObject;
            }
            AssetDatabase.SaveAssets();
            if (go)
            {
                EditorApplication.delayCall = delegate
                {
                    Selection.activeGameObject = go;
                };
                //Debug.Log(go.name);
                StartInitializeOnLoadMethod();
            }
        };
    }
}
