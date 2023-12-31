﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class QiniuCloudWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(QiniuCloud), typeof(System.Object));
		L.RegFunction("SetUploadCallback", SetUploadCallback);
		L.RegFunction("SetDownloadCallback", SetDownloadCallback);
		L.RegFunction("UploadFile", UploadFile);
		L.RegFunction("DownloadFile", DownloadFile);
        L.RegFunction("SetAppID", SetAppID);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetUploadCallback(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 1);
			QiniuCloud.SetUploadCallback(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetDownloadCallback(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 1);
			QiniuCloud.SetDownloadCallback(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UploadFile(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			QiniuCloud.UploadFile(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetAppID(IntPtr L)
	{
		try
		{
            ToLua.CheckArgsCount(L, 2);
            string arg0 = ToLua.CheckString(L, 1);
            string arg1 = ToLua.CheckString(L, 2);
            QiniuCloud.SetAppID(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DownloadFile(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			QiniuCloud.DownloadFile(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

