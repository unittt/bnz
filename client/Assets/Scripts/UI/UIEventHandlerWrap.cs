﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UIEventHandlerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UIEventHandler), typeof(UnityEngine.MonoBehaviour));
        L.RegFunction("SetEventID", SetEventID);
		L.RegFunction("AddEventType", AddEventType);
		L.RegFunction("DelEventType", DelEventType);
		L.RegFunction("GetUnderHandler", GetUnderHandler);
        L.RegFunction("Call", Call);
		L.EndClass();
	}


	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int SetEventID(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UIEventHandler obj = (UIEventHandler)ToLua.CheckObject(L, 1, typeof(UIEventHandler));
            int arg0 = LuaDLL.lua_tointeger(L, 2);
            obj.SetEventID(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddEventType(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UIEventHandler obj = (UIEventHandler)ToLua.CheckObject(L, 1, typeof(UIEventHandler));
			UIEventHandler.EventType arg0 = (UIEventHandler.EventType)(int)LuaDLL.lua_tonumber(L, 2);
			obj.AddEventType(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DelEventType(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UIEventHandler obj = (UIEventHandler)ToLua.CheckObject(L, 1, typeof(UIEventHandler));
			UIEventHandler.EventType arg0 = (UIEventHandler.EventType)(int)LuaDLL.lua_tonumber(L, 2);
			obj.DelEventType(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetUnderHandler(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UIEventHandler obj = (UIEventHandler)ToLua.CheckObject(L, 1, typeof(UIEventHandler));
			UIEventHandler o = obj.GetUnderHandler();
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int Call(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            UIEventHandler obj = (UIEventHandler)ToLua.CheckObject(L, 1, typeof(UIEventHandler));
            UIEventHandler.EventType arg0 = (UIEventHandler.EventType)(int)LuaDLL.lua_tonumber(L, 2);
            obj.Call(arg0);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
}

