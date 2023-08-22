﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using System.Collections.Generic;
using LuaInterface;

public class Map3DWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(Map3D), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("LoadAsync", LoadAsync);
        L.RegFunction("GetTransfer", GetTransfer);
        L.RegFunction("Release", Release);
		L.RegFunction("GetHeight", GetHeight);
		L.RegVar("mapid", get_mapid, null);
        L.RegVar("lightmapid", get_lightmapid, null);
        L.RegVar("xGrid", get_xGrid, null);
        L.RegVar("yGrid", get_yGrid, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadAsync(IntPtr L)
	{
		try
		{
			Map3D obj = (Map3D)ToLua.CheckObject(L, 1, typeof(Map3D));
            int mapid = (int)LuaDLL.lua_tonumber(L, 2);
            int lightmapid = (int)LuaDLL.lua_tonumber(L, 3);
            bool loadnav = LuaDLL.lua_toboolean(L, 4);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 5);
            obj.LoadAsync(mapid, lightmapid, loadnav, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int Release(IntPtr L)
    {
        try
        {
            Map3D obj = (Map3D)ToLua.CheckObject(L, 1, typeof(Map3D));
            obj.Release();
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }


	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mapid(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map3D obj = (Map3D)o;
			int ret = obj.mapid;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index mapid on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int get_lightmapid(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map3D obj = (Map3D)o;
			int ret = obj.lightmapid;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index lightmapID on a nil value" : e.Message);
		}
	}
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int GetTransfer(IntPtr L)
    {
        try
        {
            Map3D obj = (Map3D)ToLua.CheckObject(L, 1, typeof(Map3D));
            List<GridMapTransferData> list = obj.GetTransferList();
            LuaDLL.lua_newtable(L);
            for (int i = 0; i < list.Count; i++)
            {
                GridMapTransferData data = list[i];
                ToLua.Push(L, i + 1);
                LuaDLL.lua_newtable(L);

                ToLua.Push(L, 1);
                ToLua.Push(L, data.pos.x - data.size.x / 2);
                LuaDLL.lua_settable(L, -3);

                ToLua.Push(L, 2);
                ToLua.Push(L, data.pos.x + data.size.x / 2);
                LuaDLL.lua_settable(L, -3);

                ToLua.Push(L, 3);
                ToLua.Push(L, data.pos.y - data.size.y / 2);
                LuaDLL.lua_settable(L, -3);

                ToLua.Push(L, 4);
                ToLua.Push(L, data.pos.y + data.size.y / 2);
                LuaDLL.lua_settable(L, -3);

                LuaDLL.lua_settable(L, -3);

            }
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetHeight(IntPtr L)
	{
		try
		{
			Map3D obj = (Map3D)ToLua.CheckObject(L, 1, typeof(Map3D));
			float x = (float)LuaDLL.lua_tonumber(L, 2);
			float z = (float)LuaDLL.lua_tonumber(L, 3);
			float ret = obj.GetHeight(x, z);
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}


    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int get_xGrid(IntPtr L)
    {
        object o = null;

        try
        {
            o = ToLua.ToObject(L, 1);
            Map3D obj = (Map3D)o;
            int ret = obj.xGrid;
            LuaDLL.lua_pushinteger(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index xGrid on a nil value" : e.Message);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int get_yGrid(IntPtr L)
    {
        object o = null;

        try
        {
            o = ToLua.ToObject(L, 1);
            Map3D obj = (Map3D)o;
            int ret = obj.yGrid;
            LuaDLL.lua_pushinteger(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index yGrid on a nil value" : e.Message);
        }
    }
}

