﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class AnimEffectWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(AnimEffect), typeof(UnityEngine.MonoBehaviour));
		L.RegVar("animName", get_animName, set_animName);
		L.RegVar("effectArray", get_effectArray, set_effectArray);
		L.RegVar("soundArray", get_soundArray, set_soundArray);
		L.RegVar("EffectLength", get_EffectLength, set_EffectLength);
		L.RegVar("SoundLength", get_SoundLength, set_SoundLength);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_animName(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AnimEffect obj = (AnimEffect)o;
			string ret = obj.animName;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index animName on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_effectArray(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AnimEffect obj = (AnimEffect)o;
			AnimEffectInfo[] ret = obj.effectArray;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index effectArray on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_soundArray(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AnimEffect obj = (AnimEffect)o;
			AnimEffectInfo[] ret = obj.soundArray;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index soundArray on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_EffectLength(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AnimEffect obj = (AnimEffect)o;
			int ret = obj.EffectLength;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index EffectLength on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_SoundLength(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AnimEffect obj = (AnimEffect)o;
			int ret = obj.SoundLength;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index SoundLength on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_animName(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AnimEffect obj = (AnimEffect)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.animName = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index animName on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_effectArray(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AnimEffect obj = (AnimEffect)o;
			AnimEffectInfo[] arg0 = ToLua.CheckObjectArray<AnimEffectInfo>(L, 2);
			obj.effectArray = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index effectArray on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_soundArray(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AnimEffect obj = (AnimEffect)o;
			AnimEffectInfo[] arg0 = ToLua.CheckObjectArray<AnimEffectInfo>(L, 2);
			obj.soundArray = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index soundArray on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_EffectLength(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AnimEffect obj = (AnimEffect)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.EffectLength = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index EffectLength on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_SoundLength(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			AnimEffect obj = (AnimEffect)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.SoundLength = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index SoundLength on a nil value" : e.Message);
		}
	}
}

