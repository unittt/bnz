﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using System.Collections.Generic;using LuaInterface;

public class WWWRequestWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(WWWRequest), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("CreateInstance", CreateInstance);
		L.RegFunction("Get", Get);
		L.RegFunction("Post", Post);
		L.RegFunction("PostBytes", PostBytes);
		L.RegFunction("PostHttp", PostHttp);
		L.RegVar("Instance", get_Instance, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CreateInstance(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			WWWRequest.CreateInstance();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Get(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			WWWRequest obj = (WWWRequest)ToLua.CheckObject(L, 1, typeof(WWWRequest));
			string arg0 = ToLua.CheckString(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			UnityEngine.WWW o = obj.Get(arg0, arg1);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Post(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 5);
			WWWRequest obj = (WWWRequest)ToLua.CheckObject(L, 1, typeof(WWWRequest));
			string arg0 = ToLua.CheckString(L, 2);
			Dictionary<string, string> headers = ToLua.Table2Dict(L, 3);
			byte[] arg2 = ToLua.CheckByteBuffer(L, 4);
			LuaFunction arg3 = ToLua.CheckLuaFunction(L, 5);
			UnityEngine.WWW o = obj.Post(arg0, headers, arg2, arg3);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PostBytes(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 5);
			WWWRequest obj = (WWWRequest)ToLua.CheckObject(L, 1, typeof(WWWRequest));
			string arg0 = ToLua.CheckString(L, 2);
			Dictionary<string, string> headers = ToLua.Table2Dict(L, 3);
			string arg2 = ToLua.CheckString(L, 4);
			LuaFunction arg3 = ToLua.CheckLuaFunction(L, 5);
			UnityEngine.WWW o = obj.PostBytes(arg0, headers, arg2, arg3);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PostHttp(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 7);
			WWWRequest obj = (WWWRequest)ToLua.CheckObject(L, 1, typeof(WWWRequest));
			string arg0 = ToLua.CheckString(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			string arg2 = ToLua.CheckString(L, 4);
			string arg3 = ToLua.CheckString(L, 5);
			string arg4 = ToLua.CheckString(L, 6);
			LuaFunction arg5 = ToLua.CheckLuaFunction(L, 7);
			obj.PostHttp(arg0, arg1, arg2, arg3, arg4, arg5);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Instance(IntPtr L)
	{
		try
		{
			ToLua.Push(L, WWWRequest.Instance);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

