﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_KeyframeWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.Keyframe), null);
		L.RegFunction("Equals", Equals);
		L.RegFunction("GetHashCode", GetHashCode);
		L.RegFunction("ToString", ToString);
		L.RegFunction("GetType", GetType);
		L.RegFunction("New", _CreateUnityEngine_Keyframe);
		L.RegVar("time", get_time, set_time);
		L.RegVar("value", get_value, set_value);
		L.RegVar("inTangent", get_inTangent, set_inTangent);
		L.RegVar("outTangent", get_outTangent, set_outTangent);
		L.RegVar("tangentMode", get_tangentMode, set_tangentMode);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUnityEngine_Keyframe(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 1);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 2);
				UnityEngine.Keyframe obj = new UnityEngine.Keyframe(arg0, arg1);
				ToLua.PushValue(L, obj);
				return 1;
			}
			else if (count == 4 && TypeChecker.CheckTypes(L, 1, typeof(float), typeof(float), typeof(float), typeof(float)))
			{
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 1);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 2);
				float arg2 = (float)LuaDLL.luaL_checknumber(L, 3);
				float arg3 = (float)LuaDLL.luaL_checknumber(L, 4);
				UnityEngine.Keyframe obj = new UnityEngine.Keyframe(arg0, arg1, arg2, arg3);
				ToLua.PushValue(L, obj);
				return 1;
			}
			else if (count == 0)
			{
				UnityEngine.Keyframe obj = new UnityEngine.Keyframe();
				ToLua.PushValue(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: UnityEngine.Keyframe.New");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Equals(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Keyframe obj = (UnityEngine.Keyframe)ToLua.ToObject(L, 1);
			object arg0 = ToLua.ToVarObject(L, 2);
			bool o = obj.Equals(arg0);
			LuaDLL.lua_pushboolean(L, o);
			ToLua.SetBack(L, 1, obj);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetHashCode(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.Keyframe obj = (UnityEngine.Keyframe)ToLua.CheckObject(L, 1, typeof(UnityEngine.Keyframe));
			int o = obj.GetHashCode();
			LuaDLL.lua_pushinteger(L, o);
			ToLua.SetBack(L, 1, obj);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ToString(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.Keyframe obj = (UnityEngine.Keyframe)ToLua.CheckObject(L, 1, typeof(UnityEngine.Keyframe));
			string o = obj.ToString();
			LuaDLL.lua_pushstring(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetType(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.Keyframe obj = (UnityEngine.Keyframe)ToLua.CheckObject(L, 1, typeof(UnityEngine.Keyframe));
			System.Type o = obj.GetType();
			ToLua.Push(L, o);
			ToLua.SetBack(L, 1, obj);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_time(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Keyframe obj = (UnityEngine.Keyframe)o;
			float ret = obj.time;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index time on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_value(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Keyframe obj = (UnityEngine.Keyframe)o;
			float ret = obj.value;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index value on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_inTangent(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Keyframe obj = (UnityEngine.Keyframe)o;
			float ret = obj.inTangent;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index inTangent on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_outTangent(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Keyframe obj = (UnityEngine.Keyframe)o;
			float ret = obj.outTangent;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index outTangent on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_tangentMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Keyframe obj = (UnityEngine.Keyframe)o;
			int ret = obj.tangentMode;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index tangentMode on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_time(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Keyframe obj = (UnityEngine.Keyframe)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.time = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index time on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_value(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Keyframe obj = (UnityEngine.Keyframe)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.value = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index value on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_inTangent(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Keyframe obj = (UnityEngine.Keyframe)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.inTangent = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index inTangent on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_outTangent(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Keyframe obj = (UnityEngine.Keyframe)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.outTangent = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index outTangent on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_tangentMode(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Keyframe obj = (UnityEngine.Keyframe)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.tangentMode = arg0;
			ToLua.SetBack(L, 1, obj);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index tangentMode on a nil value" : e.Message);
		}
	}
}

