using UnityEngine;
using System.Collections.Generic;
using AssetPipeline;

/// <summary>
/// 能自动管理所属UI缓存的Controller。
/// @MarsZ 2016-11-25 16:29:45
/// </summary>
public class MonolessAutoCacher:IViewController
{
	//缓存起来了的UI GameObject列表
	private List<GameObject> mCachedUIList = null;
    private List<IViewController> mCachedUIControllerList = null;

	#region 重写的方法，用以实现管理的自动化。

    protected virtual void InitView()
	{
	}

	protected virtual void OnDispose()
	{
	}

    public virtual void Dispose()
    {
        
    }

    protected virtual void RegisterEvent()
    {
    }
	#endregion

	#region 缓存自动管理相关辅助方法

    protected void InitUICacheList()
	{
		AutoCacherHelper.InitUICacheList(ref mCachedUIList);
        AutoCacherHelper.InitUIControllerCacheList(ref mCachedUIControllerList);
	}

	private void AddToUICacheList(GameObject pGo)
	{
		AutoCacherHelper.AddToUICacheList(pGo, ref mCachedUIList);
	}

	private void RemoveFromUICacheList(GameObject pGo)
	{
		AutoCacherHelper.RemoveFromUICacheList(pGo, ref mCachedUIList);
	}

    protected void DespawnUIList()
	{
		AutoCacherHelper.DespawnUIList(ref mCachedUIList);
	}

	private void DespawnUI(GameObject pGo)
	{
		AutoCacherHelper.DespawnUI(pGo, ref mCachedUIList);
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
	protected GameObject AddChild(GameObject pParent, string pPrefabName)
	{
        return AutoCacherHelper.AddChild(pParent,pPrefabName);
	}
	#endregion
}