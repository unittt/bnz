﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class HolePaintWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(HolePaint), typeof(UnityEngine.MonoBehaviour));
		L.RegVar("mTexture", get_mTexture, set_mTexture);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mTexture(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			HolePaint obj = (HolePaint)o;
			UnityEngine.Texture2D ret = obj.mTexture;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index mTexture on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mTexture(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			HolePaint obj = (HolePaint)o;
			UnityEngine.Texture2D arg0 = (UnityEngine.Texture2D)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.Texture2D));
			obj.mTexture = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index mTexture on a nil value" : e.Message);
		}
	}
}
