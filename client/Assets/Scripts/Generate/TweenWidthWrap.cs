﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class TweenWidthWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(TweenWidth), typeof(UITweener));
		L.RegFunction("Begin", Begin);
		L.RegFunction("SetStartToCurrentValue", SetStartToCurrentValue);
		L.RegFunction("SetEndToCurrentValue", SetEndToCurrentValue);
		L.RegVar("from", get_from, set_from);
		L.RegVar("to", get_to, set_to);
		L.RegVar("updateTable", get_updateTable, set_updateTable);
		L.RegVar("cachedWidget", get_cachedWidget, null);
		L.RegVar("value", get_value, set_value);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Begin(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UIWidget arg0 = (UIWidget)ToLua.CheckUnityObject(L, 1, typeof(UIWidget));
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 2);
			int arg2 = (int)LuaDLL.luaL_checknumber(L, 3);
			TweenWidth o = TweenWidth.Begin(arg0, arg1, arg2);
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetStartToCurrentValue(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			TweenWidth obj = (TweenWidth)ToLua.CheckObject(L, 1, typeof(TweenWidth));
			obj.SetStartToCurrentValue();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetEndToCurrentValue(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			TweenWidth obj = (TweenWidth)ToLua.CheckObject(L, 1, typeof(TweenWidth));
			obj.SetEndToCurrentValue();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_from(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TweenWidth obj = (TweenWidth)o;
			int ret = obj.from;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index from on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_to(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TweenWidth obj = (TweenWidth)o;
			int ret = obj.to;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index to on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_updateTable(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TweenWidth obj = (TweenWidth)o;
			bool ret = obj.updateTable;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index updateTable on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_cachedWidget(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TweenWidth obj = (TweenWidth)o;
			UIWidget ret = obj.cachedWidget;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index cachedWidget on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_value(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TweenWidth obj = (TweenWidth)o;
			int ret = obj.value;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index value on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_from(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TweenWidth obj = (TweenWidth)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.from = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index from on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_to(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TweenWidth obj = (TweenWidth)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.to = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index to on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_updateTable(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TweenWidth obj = (TweenWidth)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.updateTable = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index updateTable on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_value(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			TweenWidth obj = (TweenWidth)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.value = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index value on a nil value" : e.Message);
		}
	}
}

