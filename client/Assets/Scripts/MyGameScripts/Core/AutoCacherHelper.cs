using UnityEngine;
using System.Collections.Generic;
using AssetPipeline;

public class AutoCacherHelper
{
    #region 缓存自动管理相关辅助方法

    public static void InitUICacheList(ref List<GameObject> pCachedUIList)
    {
//        pCachedUIList = new List<GameObject>();
    }

    public static void AddToUICacheList(GameObject pGo, ref List<GameObject> pCachedUIList)
    {
        if (null == pGo)
            return;
        if (null == pCachedUIList)
            pCachedUIList = new List<GameObject>();
        if (pCachedUIList.IndexOf(pGo) != -1)
            return;
        pCachedUIList.Add(pGo);
    }

    public static void RemoveFromUICacheList(GameObject pGo, ref List<GameObject> pCachedUIList)
    {
        if (null == pGo)
            return;
        if (null == pCachedUIList || pCachedUIList.Count <= 0)
            return;
        pCachedUIList.Remove(pGo);
    }

    public static void DespawnUIList(ref List<GameObject> pCachedUIList)
    {
        if (null == pCachedUIList || pCachedUIList.Count <= 0)
            return;
        for (int i = pCachedUIList.Count - 1; i >= 0; i--)
        {
            DespawnUI(pCachedUIList[i], ref pCachedUIList);
        }
        pCachedUIList.Clear();
    }

    public static void DespawnUI(GameObject pGo, ref List<GameObject> pCachedUIList)
    {
        if (null == pGo)
            return;
        RemoveFromUICacheList(pGo, ref pCachedUIList);

        //xxj begin
        //ResourcePoolManager.Instance.DespawnUI(pGo);
        //xxj end
        GameObject.Destroy(pGo);
    }

    #endregion

    #region 缓存自动管理相关接口，给子类调用

    public static GameObject AddCachedChild(GameObject pParent, string pPrefabName, ref List<GameObject> pCachedUIList)
    {
        if (string.IsNullOrEmpty(pPrefabName))
        {
            GameDebuger.LogError("AddChild failed , pPrefabName is IsNullOrEmpty !");
            return null;
        }
        GameObject tGameObject = LoadUI(pPrefabName, ref pCachedUIList);
        if (null == tGameObject)
            return null;
        tGameObject = GameObjectExt.AddPoolChild(pParent, tGameObject);
        AddToUICacheList(tGameObject, ref pCachedUIList);
        return tGameObject;
    }


    public static GameObject AddChild(GameObject pParent, string pPrefabName)
    {
        //xxj begin
        //GameObject tPrefab = ResourcePoolManager.Instance.LoadUI(pPrefabName);
        //xxj end

        GameObject tPrefab = ResourceManager.Load(pPrefabName) as GameObject;
        GameObject tChildGO = NGUITools.AddChild(pParent, tPrefab);
        return tChildGO;
    }

    private static GameObject LoadUI(string pPrefabName, ref List<GameObject> pCachedUIList)
    {
        return SpawnUIGo(pPrefabName, ref pCachedUIList);
    }

    private static Transform SpawnUI(string pPrefabName, ref List<GameObject> pCachedUIList)
    {
        GameObject tGameObject = SpawnUIGo(pPrefabName, ref pCachedUIList);
        if (null == tGameObject)
            return null;
        return tGameObject.transform;
    }

    private static GameObject SpawnUIGo(string pPrefabName, ref List<GameObject> pCachedUIList, GameObject parent = null)
    {
        if (string.IsNullOrEmpty(pPrefabName))
        {
            GameDebuger.LogError("SpawnUIGo failed , pPrefabName is null !");
            return null;		
        }

        //xxj begin
        //GameObject tGameObject = ResourcePoolManager.Instance.SpawnUIGo(pPrefabName, parent);
        //xxj end
        GameObject tGameObject = ResourceManager.SpawnUIGo(pPrefabName) as GameObject;
        AddToUICacheList(tGameObject, ref pCachedUIList);
        return tGameObject;
    }

    #endregion

    #region 缓存自动管理相关辅助方法

    public static void InitUIControllerCacheList(ref List<IViewController> pCachedUIList)
    {
        pCachedUIList = new List<IViewController>();
    }

    //这里边的V2 ， 跟父界面的 ， 一般都不同。（Item的View跟界面的View肯定不一样的。）
    public static void AddToUIControllerCacheList(IViewController pMonolessViewController, ref List<IViewController> pCachedUIList)
    {
        if (null == pMonolessViewController)
            return;
        if (null == pCachedUIList)
            pCachedUIList = new List<IViewController>();
        if (pCachedUIList.IndexOf(pMonolessViewController) != -1)
            return;
        pCachedUIList.Add(pMonolessViewController);
    }

    public static void RemoveFromUIControllerCacheList(IViewController pMonolessViewController, ref List<IViewController> pCachedUIList)
    {
        if (null == pMonolessViewController)
            return;
        if (null == pCachedUIList || pCachedUIList.Count <= 0)
            return;
        pCachedUIList.Remove(pMonolessViewController);
    }

    public static void AddToUIControllerCacheList<V>(MonolessViewController<V> pMonolessViewController) where V : BaseView, new()
    {
        if (null == pMonolessViewController)
            return;
        MonoAutoCacher tMonoViewController = pMonolessViewController.transform.GetComponentInParent<MonoAutoCacher>();
        if (null == tMonoViewController)
        {
            GameDebuger.LogWarning(string.Format("AddToUIControllerCacheList failed , can not find MonoViewController in parent , pMonolessViewController:{0}", pMonolessViewController));
            return;
        }
        tMonoViewController.AddToUIControllerCacheList(pMonolessViewController);
    }

    public static void DespawnUIControllerList(ref List<IViewController> pCachedUIList)
    {
        if (null == pCachedUIList || pCachedUIList.Count <= 0)
            return;
        for (int i = pCachedUIList.Count - 1; i >= 0; i--)
        {
            DespawnUIController(pCachedUIList[i], ref pCachedUIList);
        }
        pCachedUIList.Clear();
    }

    private static void DespawnUIController(IViewController pGo, ref List<IViewController> pCachedUIList)
    {
        if (null == pGo)
            return;
        RemoveFromUIControllerCacheList(pGo, ref pCachedUIList);
        pGo.Dispose();//调用目标Controller的Dispose，触发其OnDispose，自动触发其中UI预设的移除到缓存。
    }

    #endregion
}