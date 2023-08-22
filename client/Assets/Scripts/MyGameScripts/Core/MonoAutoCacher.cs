using UnityEngine;
using System.Collections.Generic;
using AssetPipeline;

/// <summary>
/// 能自动管理所属UI缓存的Controller。
/// @MarsZ 2016-11-25 16:29:45
/// </summary>
public class MonoAutoCacher : MonoController
{
    //缓存起来了的UI GameObject列表
    private List<GameObject> mCachedUIList = null;

    private List<IViewController> mControllerCachedUIList = null;


    #region 缓存自动管理相关辅助方法

    protected void InitUICacheList()
    {
        AutoCacherHelper.InitUICacheList(ref mCachedUIList);
        AutoCacherHelper.InitUIControllerCacheList(ref mControllerCachedUIList);
    }

    protected void DespawnUIList()
    {
        AutoCacherHelper.DespawnUIControllerList(ref mControllerCachedUIList);
        AutoCacherHelper.DespawnUIList(ref mCachedUIList);
    }

    #endregion

    #region 缓存自动管理相关接口，给子类调用
    /// <summary>
    /// 根据预设名字创建一个实例并添加到目标父级下。尝试从缓存池中取，且会在本Controller dispose时自动释放到缓存池中。
    /// </summary>
    /// <returns>The cached child.</returns>
    /// <param name="pParent">P parent.</param>
    /// <param name="pPrefabName">P prefab name.</param>
    protected GameObject AddCachedChild(GameObject pParent, string pPrefabName)
    {
        return AutoCacherHelper.AddCachedChild(pParent, pPrefabName, ref mCachedUIList);
    }

    /// <summary>
    /// 根据预设名字创建一个实例并添加到目标父级下。不从缓存池中取，也不会自动释放到缓存池中。
    /// </summary>
    /// <returns>The un cache child.</returns>
    /// <param name="pParent">P parent.</param>
    /// <param name="pPrefabName">P prefab name.</param>
    /// 
    /// 这里有一个隐患，没有加入dispose管理，只能自己手动dispose

    protected GameObject AddChild(GameObject pParent, string pPrefabName)
    {
        var go = AutoCacherHelper.AddChild(pParent, pPrefabName);
        var parentDepth = go.ParentPanelDepth();
        go.ResetPanelsDepth(parentDepth + 1);
        return go;
    }

    // use to replace NGUITools.AddChild -- fish
    protected static GameObject AddChild(GameObject pParent, GameObject tPrefab)
    {
        GameObject tChildGO = NGUITools.AddChild(pParent, tPrefab);
        var parentDepth = tChildGO.ParentPanelDepth();
        tChildGO.ResetPanelsDepth(parentDepth + 1);
        return tChildGO;
    }

    protected T AddChild<T>(GameObject pParent, string pPrefabName)
        where T : MonoBehaviour
    {
        var module = AddChild(pParent, pPrefabName);
        return module != null ? module.GetMissingComponent<T>() : null;
    }
    #endregion

    #region Controller 的缓存管理

    public void AddToUIControllerCacheList(IViewController pIViewController)
    {
        AutoCacherHelper.AddToUIControllerCacheList(pIViewController, ref mControllerCachedUIList);
    }

    #endregion
}