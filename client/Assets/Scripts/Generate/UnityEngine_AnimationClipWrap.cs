﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_AnimationClipWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.AnimationClip), typeof(UnityEngine.Motion));
		L.RegFunction("SampleAnimation", SampleAnimation);
		L.RegFunction("SetCurve", SetCurve);
		L.RegFunction("EnsureQuaternionContinuity", EnsureQuaternionContinuity);
		L.RegFunction("ClearCurves", ClearCurves);
		L.RegFunction("AddEvent", AddEvent);
		L.RegFunction("New", _CreateUnityEngine_AnimationClip);
		L.RegVar("length", get_length, null);
		L.RegVar("frameRate", get_frameRate, set_frameRate);
		L.RegVar("wrapMode", get_wrapMode, set_wrapMode);
		L.RegVar("localBounds", get_localBounds, set_localBounds);
		L.RegVar("legacy", get_legacy, set_legacy);
		L.RegVar("humanMotion", get_humanMotion, null);
		L.RegVar("events", get_events, set_events);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUnityEngine_AnimationClip(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				UnityEngine.AnimationClip obj = new UnityEngine.AnimationClip();
				ToLua.Push(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: UnityEngine.AnimationClip.New");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SampleAnimation(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)ToLua.CheckObject(L, 1, typeof(UnityEngine.AnimationClip));
			UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.GameObject));
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			obj.SampleAnimation(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetCurve(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 5);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)ToLua.CheckObject(L, 1, typeof(UnityEngine.AnimationClip));
			string arg0 = ToLua.CheckString(L, 2);
			System.Type arg1 = (System.Type)ToLua.CheckObject(L, 3, typeof(System.Type));
			string arg2 = ToLua.CheckString(L, 4);
			UnityEngine.AnimationCurve arg3 = (UnityEngine.AnimationCurve)ToLua.CheckObject(L, 5, typeof(UnityEngine.AnimationCurve));
			obj.SetCurve(arg0, arg1, arg2, arg3);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int EnsureQuaternionContinuity(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)ToLua.CheckObject(L, 1, typeof(UnityEngine.AnimationClip));
			obj.EnsureQuaternionContinuity();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ClearCurves(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)ToLua.CheckObject(L, 1, typeof(UnityEngine.AnimationClip));
			obj.ClearCurves();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddEvent(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)ToLua.CheckObject(L, 1, typeof(UnityEngine.AnimationClip));
			UnityEngine.AnimationEvent arg0 = (UnityEngine.AnimationEvent)ToLua.CheckObject(L, 2, typeof(UnityEngine.AnimationEvent));
			obj.AddEvent(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_length(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)o;
			float ret = obj.length;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index length on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_frameRate(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)o;
			float ret = obj.frameRate;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index frameRate on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_wrapMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)o;
			UnityEngine.WrapMode ret = obj.wrapMode;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index wrapMode on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_localBounds(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)o;
			UnityEngine.Bounds ret = obj.localBounds;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index localBounds on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_legacy(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)o;
			bool ret = obj.legacy;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index legacy on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_humanMotion(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)o;
			bool ret = obj.humanMotion;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index humanMotion on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_events(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)o;
			UnityEngine.AnimationEvent[] ret = obj.events;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index events on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_frameRate(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.frameRate = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index frameRate on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_wrapMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)o;
			UnityEngine.WrapMode arg0 = (UnityEngine.WrapMode)(int)LuaDLL.lua_tonumber(L, 2);
			obj.wrapMode = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index wrapMode on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_localBounds(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)o;
			UnityEngine.Bounds arg0 = ToLua.ToBounds(L, 2);
			obj.localBounds = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index localBounds on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_legacy(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.legacy = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index legacy on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_events(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.AnimationClip obj = (UnityEngine.AnimationClip)o;
			UnityEngine.AnimationEvent[] arg0 = ToLua.CheckObjectArray<UnityEngine.AnimationEvent>(L, 2);
			obj.events = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index events on a nil value" : e.Message);
		}
	}
}

