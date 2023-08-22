using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using UnityEngine;
using AssetPipeline;
using Object = UnityEngine.Object;

#if UNITY_EDITOR
using UnityEditor;
#endif

public enum LoadErrorCode
{
    None,
    BundleLoadFail,
    AssetLoadFail,
    Cancel,
}

public delegate void OnLoadAssetCallback(object asset, LoadErrorCode error);

public class ResourceManager
{
    public static void CallUpdate()
    {
    }

	public static bool IsExist(string path)
	{
		if (AssetManager.UseAssetBundle)
		{
			AssetNameInfo assetNameInfo = AssetNameInfo.ParseAssetPath(path);
			var resInfo = AssetManager.Instance.curResConfig.GetResInfo(assetNameInfo.bundleName);
			return (resInfo != null);
		}
		else
		{
#if UNITY_EDITOR
			path = Application.dataPath + "/GameRes/" + path;
			return  FileHelper.IsExist(path);
#endif
            return false;
		}
	}

    public static void UnloadAtlas(bool unloadall = false)
    {
        if (unloadall)
        {
            AssetBundleInfo.UnloadUnusedAtlas(true);
            UIPanel.RebuildAllPanel();
        }
        else
        {
            AssetBundleInfo.UnloadUnusedAtlas(false);
        }
    }

    public static void UnloadUnusedAssetBundle()
    {
        AssetManager.Instance.UnloadUnusedAssetBundle();
    }

    public static Object Load(string path)
    {
        Object obj = AssetManager.Instance.LoadAsset(path);
        return obj;
    }

    public static GameObject SpawnUIGo(string path, GameObject parent = null)
    {
        GameObject node = Load(path) as GameObject;
        if (node != null)
        {
            var nodeGo = node.gameObject;
            nodeGo.SetActive(true);
            if (parent != null)
                GameObjectExt.AddPoolChild(parent, nodeGo);
            return nodeGo;
        }
        return null;
    }

    public static void LoadAsync(int eventid, string path, float priority = 100)
    {
        AssetManager.Instance.LoadAssetAsync(path, asset =>
        {
            GlobalEventHanlder.luaGlobalCallback.BeginPCall();
            GlobalEventHanlder.luaGlobalCallback.Push(eventid);
            GlobalEventHanlder.luaGlobalCallback.Push(path);
            GlobalEventHanlder.luaGlobalCallback.Push(asset);
            GlobalEventHanlder.luaGlobalCallback.PCall();
            GlobalEventHanlder.luaGlobalCallback.EndPCall();
        }, 
        () =>
        {
            object o = null;
            GlobalEventHanlder.luaGlobalCallback.BeginPCall();
            GlobalEventHanlder.luaGlobalCallback.Push(eventid);
            GlobalEventHanlder.luaGlobalCallback.Push(path);
            GlobalEventHanlder.luaGlobalCallback.Push(o);
            GlobalEventHanlder.luaGlobalCallback.PCall();
            GlobalEventHanlder.luaGlobalCallback.EndPCall();
            GameDebug.LogError("LoadAssetAsync Error! " + path);
		}, null, priority);
    }


    public static void LoadAsync(string path, OnLoadAssetCallback callback)
    {
        AssetManager.Instance.LoadAssetAsync(path, asset =>
        {
            if (callback != null)
            {
                callback(asset, LoadErrorCode.None);
            }
        },
        () =>
        {
            if (callback != null)
            {
                callback(null, LoadErrorCode.AssetLoadFail);
            }
            GameDebug.LogError("LoadAssetAsync Error! " + path);
        });
    }

	public static void LoadStreamingAssetsTexture(int eventid, string path)
    {
		Texture tex = AssetManager.LoadStreamingAssetsTexture (path);
		if (tex != null) {
			GlobalEventHanlder.luaGlobalCallback.BeginPCall();
			GlobalEventHanlder.luaGlobalCallback.Push(eventid);
			GlobalEventHanlder.luaGlobalCallback.Push(path);
			GlobalEventHanlder.luaGlobalCallback.Push(tex);
			GlobalEventHanlder.luaGlobalCallback.PCall();
			GlobalEventHanlder.luaGlobalCallback.EndPCall();
		}else{
			object o = null;
			GlobalEventHanlder.luaGlobalCallback.BeginPCall();
			GlobalEventHanlder.luaGlobalCallback.Push(eventid);
			GlobalEventHanlder.luaGlobalCallback.Push(path);
			GlobalEventHanlder.luaGlobalCallback.Push(o);
			GlobalEventHanlder.luaGlobalCallback.PCall();
			GlobalEventHanlder.luaGlobalCallback.EndPCall();
			GameDebug.LogError("LoadStreamingAssetsTexture Error! " + path);
		}
    }

	public static void CleanLoadQueue()
	{
		AssetManager.Instance.CleanLoadQueue ();
	}

    public static void AddAssetBundleRef(string assetPath)
    {
        AssetManager.Instance.AddAssetBundleRef(assetPath);
    }

    public static void DelAssetBundleRef(string assetPath)
    {
        AssetManager.Instance.DelAssetBundleRef(assetPath);
    }

	public static void UnloadAssetBundle(string assetPath, bool unloadAll = false)
	{
		AssetManager.Instance.UnloadAssetBundle(assetPath, unloadAll);
	}


#if UNITY_IPHONE
        public const int WARNING_MEMORY = 70;
#else
    public const int WARNING_MEMORY = 70;
#endif
    public static AsyncOperation UnloadAssetsAndGC(bool forceGC = false)
    {
        AsyncOperation asyncOp = null;
        if (Application.isMobilePlatform && !forceGC)
        {
            //如果剩余内存小于50mb,才进行回收
            long memory = AndroidAPI.getFreeMemory() / 1024;
            if (memory < WARNING_MEMORY)
            {
                asyncOp = Resources.UnloadUnusedAssets();
                Debug.Log("ResourceManager UnloadUnusedAssets and GC");
            }
        }
        else
        {
            if (forceGC)
            {
                Debug.Log("ResourceManager UnloadUnusedAssets and GC");
                asyncOp = Resources.UnloadUnusedAssets();
            }
        }

        return asyncOp;
    }
}

