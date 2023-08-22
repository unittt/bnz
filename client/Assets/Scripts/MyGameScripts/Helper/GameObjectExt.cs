// --------------------------------------
//  Unity Foundation
//  MonoBehaviourExt.cs
//  copyright (c) 2014 Nicholas Ventimiglia, http://avariceonline.com
//  All rights reserved.
//  -------------------------------------
// 
using UnityEngine;

/// <summary>
///     extension class for monobehaviour.
/// </summary>
public static class GameObjectExt
{
    /// <summary>
    ///     Gets the hierarchy.
    /// </summary>
    /// <returns>
    ///     The hierarchy.
    public static string GetHierarchyWithRoot(Transform obj, Transform root)
    {
        if (obj == null || obj == root)
            return "";
        string path = obj.name;

        while (obj.parent != root)
        {
            obj = obj.parent;
            path = obj.name + "/" + path;
        }
        return path;
    }

    /// <summary>
    ///     Gets the missing component.
    /// </summary>
    public static T GetMissingComponent<T>(this GameObject go) where T : Component
    {
        var t = go.GetComponent<T>();
        if (t == null)
        {
            t = go.AddComponent<T>();
        }
        MonoController tMonoController = t as MonoController;
        if (null != tMonoController)
            tMonoController.BindComponent();
        return t;
    }

    #region find by Name

    /// <summary>
    ///     Gets the child transform.
    /// </summary>
    public static Transform GetChildTransform(this Transform root, string childName)
    {
        if (root.name == childName)
        {
            return root;
        }

        if (root.childCount != 0)
        {
            var childTransform = root.FindChild(childName);
            if (childTransform != null)
            {
                return childTransform;
            }
            for (int i = 0; i < root.childCount; i++)
            {
                childTransform = GetChildTransform(root.GetChild(i), childName);
                if (childTransform != null)
                {
                    return childTransform;
                }
            }
        }

        return null;
    }

    public static GameObject FindCom(this GameObject UIcomponent,string childComponentName){
        if (UIcomponent == null)
        {
            GameDebuger.LogWarning("the gameobject is null");
            return null;
        }
        else
        {
            Transform t = UIcomponent.transform.Find(childComponentName);
            return t != null ? t.gameObject : null;
        }
    }

    public static T FindScript<T>(this GameObject UIcomponent,string childComponentName)
        where T : Component{
        if (UIcomponent == null) return default(T);
        Transform t = UIcomponent.transform.Find(childComponentName);
        return t != null ? t.GetComponent<T>() : null;
    }
    #endregion

    #region add child

    /// <summary>
    ///     根据prefab实例化对象并加入parent中，并设置其坐标
    /// </summary>
    public static GameObject AddChild(GameObject parent, GameObject prefab, float localX = 0.0f, float localY = 0.0f,
        float localZ = 0.0f)
    {
        var go = NGUITools.AddChild(parent, prefab);
        if (go != null)
        {
            var t = go.transform;
            t.localPosition = new Vector3(localX, localY, localZ);
            NGUITools.SetChildLayer(t, parent.layer);
        }
        return go;
    }

    /// <summary>
    ///     直接将child加入parent中，并设置其坐标
    /// </summary>
    public static GameObject AddPoolChild(GameObject parent, GameObject child, float localX = 0.0f, float localY = 0.0f,
        float localZ = 0.0f)
    {
        if (child == null || parent == null)
        {
            Debug.Log("AddCachedChild Failed");
            return null;
        }

        var t = child.transform;
        t.parent = parent.transform;
        t.localPosition = new Vector3(localX, localY, localZ);
        t.localRotation = Quaternion.identity;
        t.localScale = Vector3.one;
        child.layer = parent.layer;

        NGUITools.SetChildLayer(t, parent.layer);

        return child;
    }

    public static void ReparentTransform(Transform parent, Transform child, int index = -1)
    {
        if (parent == null || child == null)
            return;

        child.parent = parent.transform;
        child.localPosition = Vector3.zero;
        if (index >= 0)
            child.SetSiblingIndex(index);
        else
            child.SetAsLastSibling();
    }

    #endregion

    #region clear all child GameObject

    /// <summary>
    ///     Removes the game object children.
    /// </summary>
    public static void RemoveChildren(this GameObject go)
    {
        if (go == null)
            return;

        go.transform.DestroyChildren();
    }

    public static void RemoveChildren(this Transform t)
    {
        if (t == null)
            return;

        t.DestroyChildren();
    }

    /// <summary>
    ///     remove component at this gameobject
    /// </summary>
    public static void RemoveComponent<T>(this Component component) where T : Component
    {
        RemoveComponent<T>(component.gameObject);
    }

    public static void RemoveComponent<T>(this GameObject go) where T : Component
    {
        var t = go.GetComponent<T>();
        if (t != null)
        {
            Object.Destroy(t);
        }
    }
    public static void RemoveAllComponent<T>(this Component component) where T : Component
    {
        RemoveAllComponent<T>(component.gameObject);
    }
    public static void RemoveAllComponent<T>(this GameObject go) where T : Component
    {
        var t = go.GetComponents<T>();
        if (t != null)
        {
            for (int i = 0; i < t.Length; i++)
                Object.Destroy(t[i]);
        }
    }

    #endregion

    #region find parent

    /// <summary>
    ///     max number of hierarchy checks 32
    /// </summary>
    private const int MaxParentLevels = 32;

    /// <summary>
    ///     Finds highest level transform from source in hierarchy.
    /// </summary>
    /// <param name="monoCom">source</param>
    /// <returns></returns>
    public static Transform GetTransformRoot(this MonoBehaviour monoCom)
    {
        var t = monoCom.transform;

        for (int i = 0; i < MaxParentLevels; i++)
        {
            var tran = t.transform;

            if (tran.parent == null)
            {
                return tran;
            }

            t = t.parent;
        }

        return null;
    }

    public static int ParentPanelDepth(this GameObject go){
        if (go == null
            || go.name == "UICamera"
            || go.transform.parent == null)
        {
            return 0;
        }

        GameUtil.LogFish("GetUIParentPanelDepth  " + go.name);
        var parentTrans = go.transform.parent;
        var panel = parentTrans.GetComponent<UIPanel>();
        return (panel != null) ? panel.depth : parentTrans.gameObject.ParentPanelDepth(); 
    }
    
    public static void ResetPanelsDepth(this GameObject go, int depth){
        if (go == null){
            return;
        }

        System.Comparison<UIPanel> compare = delegate(UIPanel a, UIPanel b){
            return a.depth - b.depth;
        };
            
        var panels = go.GetComponentsInChildren<UIPanel>(true);
        var list = panels.ToList();
        list.Sort(compare);

        var offset = list.IsNullOrEmpty() ? 0 : list[0].depth;
        list.ForEach(s =>s.depth = s.depth + depth -  offset);
    }

    public static void ResetPanelsDepth(this GameObject go, GameObject parent){
        if (go == null || parent == null){
            return;
        }

        var parentDepth = parent.ParentPanelDepth();
        go.ResetPanelsDepth(parentDepth + 1);
    }

    #endregion
}