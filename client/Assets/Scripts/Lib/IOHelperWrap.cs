﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class IOHelperWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(IOHelper), typeof(System.Object));
        L.RegFunction("Exists", Exists);
        L.RegFunction("Delete", Delete);
        L.RegFunction("Copy", Copy);
        L.RegFunction("Move", Move);
		L.RegFunction("CreateDirectory", CreateDirectory);
		L.RegFunction("ClearDirectory", ClearDirectory);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}


	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Exists(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
            string arg0 = ToLua.CheckString(L, 1);
            bool o = IOHelper.Exists(arg0);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int Delete(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            string arg0 = ToLua.CheckString(L, 1);
            IOHelper.Delete(arg0);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int Copy(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            string srcPath = ToLua.CheckString(L, 1);
            string dstPath = ToLua.CheckString(L, 2);
            IOHelper.Copy(srcPath, dstPath);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int Move(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            string srcPath = ToLua.CheckString(L, 1);
            string dstPath = ToLua.CheckString(L, 2);
            IOHelper.Move(srcPath, dstPath);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CreateDirectory(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
            string arg0 = ToLua.CheckString(L, 1);
            IOHelper.CreateDirectory(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ClearDirectory(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
            string arg0 = ToLua.CheckString(L, 1);
            IOHelper.ClearDirectory(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

}
