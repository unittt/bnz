﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class FileHandlerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(FileHandler), typeof(System.Object));
		L.RegFunction("CreateText", CreateText);
        L.RegFunction("OpenText", OpenText);
		L.RegFunction("AppendText", AppendText);
        L.RegFunction("OpenByte", OpenByte);
        L.RegFunction("CreateByte", CreateByte);
        L.RegFunction("ReadText", ReadText);
		L.RegFunction("ReadByte", ReadByte);
        L.RegFunction("WriteText", WriteText);
        L.RegFunction("WriteByte", WriteByte);
        L.RegFunction("ReadByteToString", ReadByteToString);
        L.RegFunction("WriteStringToByte", WriteStringToByte);
        L.RegFunction("ReadCompressText", ReadCompressText);
        L.RegFunction("WriteCompressText", WriteCompressText);
		L.RegFunction("Close", Close);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}


	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CreateText(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			FileHandler o = FileHandler.CreateText(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CreateByte(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			FileHandler o = FileHandler.CreateByte(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int OpenText(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
            FileHandler o = FileHandler.OpenText(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AppendText(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			FileHandler o = FileHandler.AppendText(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OpenByte(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
            string arg0 = ToLua.CheckString(L, 1);
			FileHandler o = FileHandler.OpenByte(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int ReadText(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			FileHandler obj = (FileHandler)ToLua.CheckObject(L, 1, typeof(FileHandler));
			string o = obj.ReadText();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}


	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ReadByte(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			FileHandler obj = (FileHandler)ToLua.CheckObject(L, 1, typeof(FileHandler));
			byte[] o = obj.ReadByte();
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int ReadCompressText(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            FileHandler obj = (FileHandler)ToLua.CheckObject(L, 1, typeof(FileHandler));
            string s = obj.ReadCompressText();
            ToLua.Push(L, s);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int WriteText(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			FileHandler obj = (FileHandler)ToLua.CheckObject(L, 1, typeof(FileHandler));
			string arg0 = ToLua.CheckString(L, 2);
            obj.WriteText(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int WriteByte(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			FileHandler obj = (FileHandler)ToLua.CheckObject(L, 1, typeof(FileHandler));
			byte[] arg0 = ToLua.CheckByteBuffer(L, 2);
			obj.WriteByte(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int WriteCompressText(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            FileHandler obj = (FileHandler)ToLua.CheckObject(L, 1, typeof(FileHandler));
            string arg0 = ToLua.CheckString(L, 2);
            obj.WriteCompressText(arg0);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Close(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			FileHandler obj = (FileHandler)ToLua.CheckObject(L, 1, typeof(FileHandler));
			obj.Close();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    private static int ReadByteToString(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            FileHandler obj = (FileHandler)ToLua.CheckObject(L, 1, typeof(FileHandler));
            byte[] o = obj.ReadByte();
            LuaDLL.lua_pushlstring(L, o, o.Length);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int WriteStringToByte(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            FileHandler obj = (FileHandler)ToLua.CheckObject(L, 1, typeof(FileHandler));
            byte[] data = LuaDLL.lua_tobytearray(L, 2);
            obj.WriteByte(data);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
}

