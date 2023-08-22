using System;
using LuaInterface;
using System.Collections;
using System.Collections.Generic;

public class ResourceManagerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(ResourceManager), typeof(System.Object));
        L.RegFunction("GetPersistentDataPath", GetPersistentDataPath);
		L.RegFunction("IsExist", IsExist);
		L.RegFunction("Load", Load);
		L.RegFunction("LoadAsync", LoadAsync);
		L.RegFunction("LoadStreamingAssetsTexture", LoadStreamingAssetsTexture);
		L.RegFunction("CleanLoadQueue", CleanLoadQueue);
        L.RegFunction("UnloadUnusedAssetBundle", UnloadUnusedAssetBundle);
        L.RegFunction("UnloadAtlas", UnloadAtlas);
        L.RegFunction("UnloadAsset", UnloadAsset);
        L.RegFunction("UnloadUnusedAssets", UnloadUnusedAssets);
        L.RegFunction("AddAssetBundleRef", AddAssetBundleRef);
        L.RegFunction("DelAssetBundleRef", DelAssetBundleRef);
		L.RegFunction("UnloadAssetBundle", UnloadAssetBundle);
		L.EndClass();
	}

    
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int GetPersistentDataPath(IntPtr L)
    {
        try
        {
            LuaDLL.lua_pushstring(L, GameResPath.persistentDataPath);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IsExist(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			bool b = ResourceManager.IsExist(arg0);
			ToLua.Push(L, b);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int Load(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            string arg0 = ToLua.CheckString(L, 1);
            object obj = ResourceManager.Load(arg0);
            ToLua.Push(L, obj);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadAsync(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
            int eventid = LuaDLL.lua_tointeger(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			float arg1 = (float)LuaDLL.lua_tonumber(L, 3);
			ResourceManager.LoadAsync(eventid, arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadStreamingAssetsTexture(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			int eventid = LuaDLL.lua_tointeger(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			ResourceManager.LoadStreamingAssetsTexture(eventid, arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CleanLoadQueue(IntPtr L)
	{
		try
		{
			ResourceManager.CleanLoadQueue();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
    
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int UnloadAtlas(IntPtr L)
    {
        try
        {
            bool unloadAll = LuaDLL.lua_toboolean(L, 1);
            ResourceManager.UnloadAtlas(unloadAll);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int UnloadUnusedAssetBundle(IntPtr L)
    {
        try
        {
            ResourceManager.UnloadUnusedAssetBundle();
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int UnloadUnusedAssets(IntPtr L)
    {
        try
        {
            UnityEngine.Resources.UnloadUnusedAssets();
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int UnloadAsset(IntPtr L)
    {
        try
        {
            UnityEngine.Object obj = (UnityEngine.Object)ToLua.ToObject(L, 1);
            UnityEngine.Resources.UnloadAsset(obj);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int AddAssetBundleRef(IntPtr L)
    {
        try
        {
            string arg0 = ToLua.CheckString(L, 1);
            ResourceManager.AddAssetBundleRef(arg0);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int DelAssetBundleRef(IntPtr L)
    {
        try
        {
            string arg0 = ToLua.CheckString(L, 1);
			ResourceManager.DelAssetBundleRef(arg0);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UnloadAssetBundle(IntPtr L)
	{
		try
		{
			string arg0 = ToLua.CheckString(L, 1);
			bool arg1 = LuaDLL.lua_toboolean(L, 2);
			ResourceManager.UnloadAssetBundle(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

