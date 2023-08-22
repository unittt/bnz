﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;
using System.Collections.Generic;

public class Map2DWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(Map2D), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("Release", Release);
		L.RegFunction("LoadAsync", LoadAsync);
		L.RegFunction("Load", Load);
        L.RegFunction("GetTransfer", GetTransfer);
		L.RegFunction("LoadMapEffect", LoadMapEffect);
		L.RegFunction("World2GridPos", World2GridPos);
		L.RegFunction("GetNearWalkablePos", GetNearWalkablePos);
		L.RegFunction("IsInMapArea", IsInMapArea);
		L.RegFunction("IsWalkable", IsWalkable);
		L.RegFunction("IsTransparent", IsTransparent);
		L.RegFunction("IsLinePath", IsLinePath);
		L.RegFunction("PrintMapData", PrintMapData);
		L.RegFunction("GetPos2Transfer", GetPos2Transfer);
		L.RegFunction("GetTransferList", GetTransferList);
		L.RegFunction("SetMapEffectGoActive", SetMapEffectGoActive);
		L.RegFunction ("SetMapEffectNodeActive", SetMapEffectNodeActive);
		L.RegVar("cameraHalfHeight", get_cameraHalfHeight, set_cameraHalfHeight);
		L.RegVar("cameraHalfWidth", get_cameraHalfWidth, set_cameraHalfWidth);
		L.RegVar("mapId", get_mapId, set_mapId);
		L.RegVar("width", get_width, set_width);
		L.RegVar("height", get_height, set_height);
		L.RegVar("xTile", get_xTile, set_xTile);
		L.RegVar("yTile", get_yTile, set_yTile);
		L.RegVar("xGrid", get_xGrid, set_xGrid);
		L.RegVar("yGrid", get_yGrid, set_yGrid);
		L.RegVar("graphSize", get_graphSize, set_graphSize);
		L.RegVar("gridPixel", get_gridPixel, set_gridPixel);
		L.RegVar("luaCallback", get_luaCallback, set_luaCallback);
		L.RegVar("CurrentMap", get_CurrentMap, null);
		L.RegVar("isReleased", get_isReleased, null);
		L.EndClass();
	}

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int GetTransfer(IntPtr L)
    {
        try
        {
            Map2D obj = (Map2D)ToLua.CheckObject(L, 1, typeof(Map2D));
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
	static int Release(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Map2D obj = (Map2D)ToLua.CheckObject(L, 1, typeof(Map2D));
			obj.Release();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadAsync(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			Map2D obj = (Map2D)ToLua.CheckObject(L, 1, typeof(Map2D));
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Vector3 arg1 = ToLua.ToVector3(L, 3);
			LuaFunction arg2 = ToLua.CheckLuaFunction(L, 4);
			obj.LoadAsync(arg0, arg1, arg2);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Load(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			Map2D obj = (Map2D)ToLua.CheckObject(L, 1, typeof(Map2D));
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Vector3 arg1 = ToLua.ToVector3(L, 3);
			obj.Load(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadMapEffect(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Map2D obj = (Map2D)ToLua.CheckObject(L, 1, typeof(Map2D));
			obj.LoadMapEffect();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int World2GridPos(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Map2D obj = (Map2D)ToLua.CheckObject(L, 1, typeof(Map2D));
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			UnityEngine.Vector2 o = obj.World2GridPos(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetNearWalkablePos(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			Map2D obj = (Map2D)ToLua.CheckObject(L, 1, typeof(Map2D));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			UnityEngine.Vector2 o = obj.GetNearWalkablePos(arg0, arg1);
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IsInMapArea(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			Map2D obj = (Map2D)ToLua.CheckObject(L, 1, typeof(Map2D));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			bool o = obj.IsInMapArea(arg0, arg1);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IsWalkable(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(Map2D), typeof(float), typeof(float)))
			{
				Map2D obj = (Map2D)ToLua.ToObject(L, 1);
				float arg0 = (float)LuaDLL.lua_tonumber(L, 2);
				float arg1 = (float)LuaDLL.lua_tonumber(L, 3);
				bool o = obj.IsWalkable(arg0, arg1);
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(Map2D), typeof(int), typeof(int)))
			{
				Map2D obj = (Map2D)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				int arg1 = (int)LuaDLL.lua_tonumber(L, 3);
				bool o = obj.IsWalkable(arg0, arg1);
				LuaDLL.lua_pushboolean(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: Map2D.IsWalkable");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IsTransparent(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			Map2D obj = (Map2D)ToLua.CheckObject(L, 1, typeof(Map2D));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			bool o = obj.IsTransparent(arg0, arg1);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IsLinePath(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			Map2D obj = (Map2D)ToLua.CheckObject(L, 1, typeof(Map2D));
			UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
			UnityEngine.Vector3 arg1 = ToLua.ToVector3(L, 3);
			bool o = obj.IsLinePath(arg0, arg1);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PrintMapData(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Map2D obj = (Map2D)ToLua.CheckObject(L, 1, typeof(Map2D));
			obj.PrintMapData();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetPos2Transfer(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Map2D obj = (Map2D)ToLua.CheckObject(L, 1, typeof(Map2D));
			UnityEngine.Vector2 arg0 = ToLua.ToVector2(L, 2);
			int o = obj.GetPos2Transfer(arg0);
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetTransferList(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Map2D obj = (Map2D)ToLua.CheckObject(L, 1, typeof(Map2D));
			System.Collections.Generic.List<GridMapTransferData> o = obj.GetTransferList();
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetMapEffectGoActive(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Map2D obj = (Map2D)ToLua.CheckObject(L, 1, typeof(Map2D));
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.SetMapEffectGoActive(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}


	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetMapEffectNodeActive(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Map2D obj = (Map2D)ToLua.CheckObject(L, 1, typeof(Map2D));
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.SetMapEffectNodeActive(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_cameraHalfHeight(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, Map2D.cameraHalfHeight);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_cameraHalfWidth(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, Map2D.cameraHalfWidth);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mapId(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			int ret = obj.mapId;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index mapId on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_width(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			float ret = obj.width;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index width on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_height(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			float ret = obj.height;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index height on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_xTile(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			int ret = obj.xTile;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index xTile on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_yTile(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			int ret = obj.yTile;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index yTile on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_xGrid(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			int ret = obj.xGrid;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
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
			Map2D obj = (Map2D)o;
			int ret = obj.yGrid;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index yGrid on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_graphSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			float ret = obj.graphSize;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index graphSize on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_gridPixel(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			int ret = obj.gridPixel;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index gridPixel on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_luaCallback(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			LuaInterface.LuaFunction ret = obj.luaCallback;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index luaCallback on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_CurrentMap(IntPtr L)
	{
		try
		{
			ToLua.Push(L, Map2D.CurrentMap);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isReleased(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			bool ret = obj.isReleased;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index isReleased on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_cameraHalfHeight(IntPtr L)
	{
		try
		{
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			Map2D.cameraHalfHeight = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_cameraHalfWidth(IntPtr L)
	{
		try
		{
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			Map2D.cameraHalfWidth = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mapId(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.mapId = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index mapId on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_width(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.width = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index width on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_height(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.height = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index height on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_xTile(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.xTile = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index xTile on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_yTile(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.yTile = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index yTile on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_xGrid(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.xGrid = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index xGrid on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_yGrid(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.yGrid = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index yGrid on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_graphSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.graphSize = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index graphSize on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_gridPixel(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.gridPixel = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index gridPixel on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_luaCallback(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			Map2D obj = (Map2D)o;
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			obj.luaCallback = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index luaCallback on a nil value" : e.Message);
		}
	}
}

