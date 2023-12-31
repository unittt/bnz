﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_MeshFilterWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.MeshFilter), typeof(UnityEngine.Component));
		L.RegFunction("New", _CreateUnityEngine_MeshFilter);
		L.RegVar("mesh", get_mesh, set_mesh);
		L.RegVar("sharedMesh", get_sharedMesh, set_sharedMesh);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUnityEngine_MeshFilter(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				UnityEngine.MeshFilter obj = new UnityEngine.MeshFilter();
				ToLua.Push(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: UnityEngine.MeshFilter.New");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_mesh(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.MeshFilter obj = (UnityEngine.MeshFilter)o;
			UnityEngine.Mesh ret = obj.mesh;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index mesh on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_sharedMesh(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.MeshFilter obj = (UnityEngine.MeshFilter)o;
			UnityEngine.Mesh ret = obj.sharedMesh;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index sharedMesh on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_mesh(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.MeshFilter obj = (UnityEngine.MeshFilter)o;
			UnityEngine.Mesh arg0 = (UnityEngine.Mesh)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.Mesh));
			obj.mesh = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index mesh on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_sharedMesh(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.MeshFilter obj = (UnityEngine.MeshFilter)o;
			UnityEngine.Mesh arg0 = (UnityEngine.Mesh)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.Mesh));
			obj.sharedMesh = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index sharedMesh on a nil value" : e.Message);
		}
	}
}

