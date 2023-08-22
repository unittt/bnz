﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class System_IO_PathWrap
{
	public static void Register(LuaState L)
	{
		L.BeginStaticLibs("Path");
		L.RegFunction("ChangeExtension", ChangeExtension);
		L.RegFunction("Combine", Combine);
		L.RegFunction("GetDirectoryName", GetDirectoryName);
		L.RegFunction("GetExtension", GetExtension);
		L.RegFunction("GetFileName", GetFileName);
		L.RegFunction("GetFileNameWithoutExtension", GetFileNameWithoutExtension);
		L.RegFunction("GetFullPath", GetFullPath);
		L.RegFunction("GetPathRoot", GetPathRoot);
		L.RegFunction("GetTempFileName", GetTempFileName);
		L.RegFunction("GetTempPath", GetTempPath);
		L.RegFunction("HasExtension", HasExtension);
		L.RegFunction("IsPathRooted", IsPathRooted);
		L.RegFunction("GetInvalidFileNameChars", GetInvalidFileNameChars);
		L.RegFunction("GetInvalidPathChars", GetInvalidPathChars);
		L.RegFunction("GetRandomFileName", GetRandomFileName);
		L.RegVar("AltDirectorySeparatorChar", get_AltDirectorySeparatorChar, null);
		L.RegVar("DirectorySeparatorChar", get_DirectorySeparatorChar, null);
		L.RegVar("PathSeparator", get_PathSeparator, null);
		L.RegVar("VolumeSeparatorChar", get_VolumeSeparatorChar, null);
		L.EndStaticLibs();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ChangeExtension(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			string o = System.IO.Path.ChangeExtension(arg0, arg1);
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Combine(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			string o = System.IO.Path.Combine(arg0, arg1);
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetDirectoryName(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			string o = System.IO.Path.GetDirectoryName(arg0);
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetExtension(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			string o = System.IO.Path.GetExtension(arg0);
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetFileName(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			string o = System.IO.Path.GetFileName(arg0);
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetFileNameWithoutExtension(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			string o = System.IO.Path.GetFileNameWithoutExtension(arg0);
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetFullPath(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			string o = System.IO.Path.GetFullPath(arg0);
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetPathRoot(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			string o = System.IO.Path.GetPathRoot(arg0);
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetTempFileName(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			string o = System.IO.Path.GetTempFileName();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetTempPath(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			string o = System.IO.Path.GetTempPath();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int HasExtension(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			bool o = System.IO.Path.HasExtension(arg0);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IsPathRooted(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			bool o = System.IO.Path.IsPathRooted(arg0);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetInvalidFileNameChars(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			char[] o = System.IO.Path.GetInvalidFileNameChars();
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetInvalidPathChars(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			char[] o = System.IO.Path.GetInvalidPathChars();
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetRandomFileName(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			string o = System.IO.Path.GetRandomFileName();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_AltDirectorySeparatorChar(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, System.IO.Path.AltDirectorySeparatorChar);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_DirectorySeparatorChar(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, System.IO.Path.DirectorySeparatorChar);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_PathSeparator(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, System.IO.Path.PathSeparator);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_VolumeSeparatorChar(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushnumber(L, System.IO.Path.VolumeSeparatorChar);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}
