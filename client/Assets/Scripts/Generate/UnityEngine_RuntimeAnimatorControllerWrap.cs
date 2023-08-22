﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_RuntimeAnimatorControllerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.RuntimeAnimatorController), typeof(UnityEngine.Object));
		L.RegFunction("New", _CreateUnityEngine_RuntimeAnimatorController);
		L.RegVar("animationClips", get_animationClips, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUnityEngine_RuntimeAnimatorController(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				UnityEngine.RuntimeAnimatorController obj = new UnityEngine.RuntimeAnimatorController();
				ToLua.Push(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: UnityEngine.RuntimeAnimatorController.New");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_animationClips(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.RuntimeAnimatorController obj = (UnityEngine.RuntimeAnimatorController)o;
			UnityEngine.AnimationClip[] ret = obj.animationClips;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index animationClips on a nil value" : e.Message);
		}
	}
}

