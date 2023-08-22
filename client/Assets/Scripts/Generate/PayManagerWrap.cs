﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class PayManagerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(PayManager), typeof(System.Object));
		L.RegFunction("CreateInstance", CreateInstance);
		L.RegFunction("Setup", Setup);
		L.RegFunction("SetupForDemi", SetupForDemi);
		L.RegFunction("ResetCallbackURL", ResetCallbackURL);
		L.RegFunction("ChargeByIOSInAppPurchase", ChargeByIOSInAppPurchase);
		L.RegFunction("RestoreCompletedTransactions", RestoreCompletedTransactions);
		L.RegFunction("StartCoroutineSendReceiptToServer", StartCoroutineSendReceiptToServer);
		L.RegFunction("IosUseWechatAliPay", IosUseWechatAliPay);
		L.RegFunction("SupportInAppPurchase", SupportInAppPurchase);
		L.RegFunction("ChargeByOrderJsonDto", ChargeByOrderJsonDto);
		L.RegFunction("GetGameSettingDemiSdkServer", GetGameSettingDemiSdkServer);
		L.RegFunction("New", _CreatePayManager);
		L.RegVar("productIdDic", get_productIdDic, set_productIdDic);
		L.RegVar("openSwitchPay", get_openSwitchPay, set_openSwitchPay);
		L.RegVar("isSupportThirdPay", get_isSupportThirdPay, set_isSupportThirdPay);
		L.RegVar("thirdPayIsAli", get_thirdPayIsAli, set_thirdPayIsAli);
		L.RegVar("Instance", get_Instance, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreatePayManager(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				PayManager obj = new PayManager();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: PayManager.New");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CreateInstance(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			PayManager.CreateInstance();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Setup(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			PayManager obj = (PayManager)ToLua.CheckObject(L, 1, typeof(PayManager));
			string arg0 = ToLua.CheckString(L, 2);
			obj.Setup(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetupForDemi(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			PayManager obj = (PayManager)ToLua.CheckObject(L, 1, typeof(PayManager));
			obj.SetupForDemi();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ResetCallbackURL(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			PayManager obj = (PayManager)ToLua.CheckObject(L, 1, typeof(PayManager));
			string arg0 = ToLua.CheckString(L, 2);
			obj.ResetCallbackURL(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ChargeByIOSInAppPurchase(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 5);
			PayManager obj = (PayManager)ToLua.CheckObject(L, 1, typeof(PayManager));
			string arg0 = ToLua.CheckString(L, 2);
			int arg1 = (int)LuaDLL.luaL_checknumber(L, 3);
			string arg2 = ToLua.CheckString(L, 4);
			LuaFunction arg3 = ToLua.CheckLuaFunction(L, 5);
			obj.ChargeByIOSInAppPurchase(arg0, arg1, arg2, arg3);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RestoreCompletedTransactions(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			PayManager obj = (PayManager)ToLua.CheckObject(L, 1, typeof(PayManager));
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			obj.RestoreCompletedTransactions(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int StartCoroutineSendReceiptToServer(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			PayManager obj = (PayManager)ToLua.CheckObject(L, 1, typeof(PayManager));
			IOSStoreKitResult arg0 = (IOSStoreKitResult)ToLua.CheckObject(L, 2, typeof(IOSStoreKitResult));
			string arg1 = ToLua.CheckString(L, 3);
			bool arg2 = LuaDLL.luaL_checkboolean(L, 4);
			obj.StartCoroutineSendReceiptToServer(arg0, arg1, arg2);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IosUseWechatAliPay(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			bool o = PayManager.IosUseWechatAliPay();
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SupportInAppPurchase(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			bool o = PayManager.SupportInAppPurchase();
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ChargeByOrderJsonDto(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 10);
			PayManager obj = (PayManager)ToLua.CheckObject(L, 1, typeof(PayManager));
			string arg0 = ToLua.CheckString(L, 2);
			int arg1 = (int)LuaDLL.luaL_checknumber(L, 3);
			string arg2 = ToLua.CheckString(L, 4);
			string arg3 = ToLua.CheckString(L, 5);
			string arg4 = ToLua.CheckString(L, 6);
			string arg5 = ToLua.CheckString(L, 7);
			string arg6 = ToLua.CheckString(L, 8);
			string arg7 = ToLua.CheckString(L, 9);
			LuaFunction arg8 = ToLua.CheckLuaFunction(L, 10);
			obj.ChargeByOrderJsonDto(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetGameSettingDemiSdkServer(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			PayManager obj = (PayManager)ToLua.CheckObject(L, 1, typeof(PayManager));
			string o = obj.GetGameSettingDemiSdkServer();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_productIdDic(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			PayManager obj = (PayManager)o;
			System.Collections.Generic.Dictionary<string,int> ret = obj.productIdDic;
			ToLua.PushObject(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index productIdDic on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_openSwitchPay(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushboolean(L, PayManager.openSwitchPay);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_isSupportThirdPay(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushboolean(L, PayManager.isSupportThirdPay);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_thirdPayIsAli(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushboolean(L, PayManager.thirdPayIsAli);
			return 1;
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
			ToLua.PushObject(L, PayManager.Instance);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_productIdDic(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			PayManager obj = (PayManager)o;
			System.Collections.Generic.Dictionary<string,int> arg0 = (System.Collections.Generic.Dictionary<string,int>)ToLua.CheckObject(L, 2, typeof(System.Collections.Generic.Dictionary<string,int>));
			obj.productIdDic = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index productIdDic on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_openSwitchPay(IntPtr L)
	{
		try
		{
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			PayManager.openSwitchPay = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_isSupportThirdPay(IntPtr L)
	{
		try
		{
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			PayManager.isSupportThirdPay = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_thirdPayIsAli(IntPtr L)
	{
		try
		{
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			PayManager.thirdPayIsAli = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

