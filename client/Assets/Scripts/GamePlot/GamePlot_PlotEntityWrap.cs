﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class GamePlot_PlotEntityWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(GamePlot.PlotEntity), typeof(System.Object));
		L.RegFunction("New", _CreateGamePlot_PlotEntity);
		L.RegVar("active", get_active, set_active);
		L.RegVar("startTime", get_startTime, set_startTime);
		L.RegVar("endTime", get_endTime, set_endTime);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateGamePlot_PlotEntity(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				GamePlot.PlotEntity obj = new GamePlot.PlotEntity();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: GamePlot.PlotEntity.New");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_active(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GamePlot.PlotEntity obj = (GamePlot.PlotEntity)o;
			bool ret = obj.active;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index active on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_startTime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GamePlot.PlotEntity obj = (GamePlot.PlotEntity)o;
			float ret = obj.startTime;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index startTime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_endTime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GamePlot.PlotEntity obj = (GamePlot.PlotEntity)o;
			float ret = obj.endTime;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index endTime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_active(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GamePlot.PlotEntity obj = (GamePlot.PlotEntity)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.active = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index active on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_startTime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GamePlot.PlotEntity obj = (GamePlot.PlotEntity)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.startTime = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index startTime on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_endTime(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			GamePlot.PlotEntity obj = (GamePlot.PlotEntity)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.endTime = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index endTime on a nil value" : e.Message);
		}
	}
}
