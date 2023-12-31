﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using DG.Tweening;
using LuaInterface;

public class DG_Tweening_SequenceWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(DG.Tweening.Sequence), typeof(DG.Tweening.Tween));
		L.RegFunction("SetSpeedBased", SetSpeedBased);
		L.RegFunction("SetRelative", SetRelative);
		L.RegFunction("SetDelay", SetDelay);
		L.RegFunction("InsertCallback", InsertCallback);
		L.RegFunction("PrependCallback", PrependCallback);
		L.RegFunction("AppendCallback", AppendCallback);
		L.RegFunction("PrependInterval", PrependInterval);
		L.RegFunction("AppendInterval", AppendInterval);
		L.RegFunction("Insert", Insert);
		L.RegFunction("Join", Join);
		L.RegFunction("Prepend", Prepend);
		L.RegFunction("Append", Append);
		L.RegFunction("SetAs", SetAs);
		L.RegFunction("OnWaypointChange", OnWaypointChange);
		L.RegFunction("OnKill", OnKill);
		L.RegFunction("OnComplete", OnComplete);
		L.RegFunction("OnStepComplete", OnStepComplete);
		L.RegFunction("OnUpdate", OnUpdate);
		L.RegFunction("OnRewind", OnRewind);
		L.RegFunction("OnPause", OnPause);
		L.RegFunction("OnPlay", OnPlay);
		L.RegFunction("OnStart", OnStart);
		L.RegFunction("SetUpdate", SetUpdate);
		L.RegFunction("SetRecyclable", SetRecyclable);
		L.RegFunction("SetEase", SetEase);
		L.RegFunction("SetLoops", SetLoops);
		L.RegFunction("SetTarget", SetTarget);
		L.RegFunction("SetId", SetId);
		L.RegFunction("SetAutoKill", SetAutoKill);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetSpeedBased(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				DG.Tweening.Tween o = obj.SetSpeedBased();
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween), typeof(bool)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				bool arg0 = LuaDLL.lua_toboolean(L, 2);
				DG.Tweening.Tween o = obj.SetSpeedBased(arg0);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: DG.Tweening.Sequence.SetSpeedBased");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetRelative(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				DG.Tweening.Tween o = obj.SetRelative();
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween), typeof(bool)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				bool arg0 = LuaDLL.lua_toboolean(L, 2);
				DG.Tweening.Tween o = obj.SetRelative(arg0);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: DG.Tweening.Sequence.SetRelative");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetDelay(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			DG.Tweening.Tween o = obj.SetDelay(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int InsertCallback(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			DG.Tweening.TweenCallback arg1 = null;
			LuaTypes funcType3 = LuaDLL.lua_type(L, 3);

			if (funcType3 != LuaTypes.LUA_TFUNCTION)
			{
				 arg1 = (DG.Tweening.TweenCallback)ToLua.CheckObject(L, 3, typeof(DG.Tweening.TweenCallback));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 3);
				arg1 = DelegateFactory.CreateDelegate(typeof(DG.Tweening.TweenCallback), func) as DG.Tweening.TweenCallback;
			}

			DG.Tweening.Sequence o = obj.InsertCallback(arg0, arg1);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PrependCallback(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.TweenCallback arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (DG.Tweening.TweenCallback)ToLua.CheckObject(L, 2, typeof(DG.Tweening.TweenCallback));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(DG.Tweening.TweenCallback), func) as DG.Tweening.TweenCallback;
			}

			DG.Tweening.Sequence o = obj.PrependCallback(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AppendCallback(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.TweenCallback arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (DG.Tweening.TweenCallback)ToLua.CheckObject(L, 2, typeof(DG.Tweening.TweenCallback));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(DG.Tweening.TweenCallback), func) as DG.Tweening.TweenCallback;
			}

			DG.Tweening.Sequence o = obj.AppendCallback(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PrependInterval(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			DG.Tweening.Sequence o = obj.PrependInterval(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AppendInterval(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			DG.Tweening.Sequence o = obj.AppendInterval(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Insert(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			DG.Tweening.Tween arg1 = (DG.Tweening.Tween)ToLua.CheckObject(L, 3, typeof(DG.Tweening.Tween));
			DG.Tweening.Sequence o = obj.Insert(arg0, arg1);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Join(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.Tween arg0 = (DG.Tweening.Tween)ToLua.CheckObject(L, 2, typeof(DG.Tweening.Tween));
			DG.Tweening.Sequence o = obj.Join(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Prepend(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.Tween arg0 = (DG.Tweening.Tween)ToLua.CheckObject(L, 2, typeof(DG.Tweening.Tween));
			DG.Tweening.Sequence o = obj.Prepend(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Append(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.Tween arg0 = (DG.Tweening.Tween)ToLua.CheckObject(L, 2, typeof(DG.Tweening.Tween));
			DG.Tweening.Sequence o = obj.Append(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetAs(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween), typeof(DG.Tweening.Tween)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				DG.Tweening.Tween arg0 = (DG.Tweening.Tween)ToLua.ToObject(L, 2);
				DG.Tweening.Tween o = obj.SetAs(arg0);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween), typeof(DG.Tweening.TweenParams)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				DG.Tweening.TweenParams arg0 = (DG.Tweening.TweenParams)ToLua.ToObject(L, 2);
				DG.Tweening.Tween o = obj.SetAs(arg0);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: DG.Tweening.Sequence.SetAs");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnWaypointChange(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.TweenCallback<int> arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (DG.Tweening.TweenCallback<int>)ToLua.CheckObject(L, 2, typeof(DG.Tweening.TweenCallback<int>));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(DG.Tweening.TweenCallback<int>), func) as DG.Tweening.TweenCallback<int>;
			}

			DG.Tweening.Tween o = obj.OnWaypointChange(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnKill(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.TweenCallback arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (DG.Tweening.TweenCallback)ToLua.CheckObject(L, 2, typeof(DG.Tweening.TweenCallback));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(DG.Tweening.TweenCallback), func) as DG.Tweening.TweenCallback;
			}

			DG.Tweening.Tween o = obj.OnKill(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnComplete(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.TweenCallback arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (DG.Tweening.TweenCallback)ToLua.CheckObject(L, 2, typeof(DG.Tweening.TweenCallback));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(DG.Tweening.TweenCallback), func) as DG.Tweening.TweenCallback;
			}

			DG.Tweening.Tween o = obj.OnComplete(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnStepComplete(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.TweenCallback arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (DG.Tweening.TweenCallback)ToLua.CheckObject(L, 2, typeof(DG.Tweening.TweenCallback));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(DG.Tweening.TweenCallback), func) as DG.Tweening.TweenCallback;
			}

			DG.Tweening.Tween o = obj.OnStepComplete(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnUpdate(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.TweenCallback arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (DG.Tweening.TweenCallback)ToLua.CheckObject(L, 2, typeof(DG.Tweening.TweenCallback));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(DG.Tweening.TweenCallback), func) as DG.Tweening.TweenCallback;
			}

			DG.Tweening.Tween o = obj.OnUpdate(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnRewind(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.TweenCallback arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (DG.Tweening.TweenCallback)ToLua.CheckObject(L, 2, typeof(DG.Tweening.TweenCallback));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(DG.Tweening.TweenCallback), func) as DG.Tweening.TweenCallback;
			}

			DG.Tweening.Tween o = obj.OnRewind(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnPause(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.TweenCallback arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (DG.Tweening.TweenCallback)ToLua.CheckObject(L, 2, typeof(DG.Tweening.TweenCallback));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(DG.Tweening.TweenCallback), func) as DG.Tweening.TweenCallback;
			}

			DG.Tweening.Tween o = obj.OnPause(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnPlay(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.TweenCallback arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (DG.Tweening.TweenCallback)ToLua.CheckObject(L, 2, typeof(DG.Tweening.TweenCallback));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(DG.Tweening.TweenCallback), func) as DG.Tweening.TweenCallback;
			}

			DG.Tweening.Tween o = obj.OnPlay(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int OnStart(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			DG.Tweening.TweenCallback arg0 = null;
			LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

			if (funcType2 != LuaTypes.LUA_TFUNCTION)
			{
				 arg0 = (DG.Tweening.TweenCallback)ToLua.CheckObject(L, 2, typeof(DG.Tweening.TweenCallback));
			}
			else
			{
				LuaFunction func = ToLua.ToLuaFunction(L, 2);
				arg0 = DelegateFactory.CreateDelegate(typeof(DG.Tweening.TweenCallback), func) as DG.Tweening.TweenCallback;
			}

			DG.Tweening.Tween o = obj.OnStart(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetUpdate(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween), typeof(bool)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				bool arg0 = LuaDLL.lua_toboolean(L, 2);
				DG.Tweening.Tween o = obj.SetUpdate(arg0);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween), typeof(int)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				DG.Tweening.UpdateType arg0 = (DG.Tweening.UpdateType)(int)LuaDLL.lua_tonumber(L, 2);
				DG.Tweening.Tween o = obj.SetUpdate(arg0);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween), typeof(int), typeof(bool)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				DG.Tweening.UpdateType arg0 = (DG.Tweening.UpdateType)(int)LuaDLL.lua_tonumber(L, 2);
				bool arg1 = LuaDLL.lua_toboolean(L, 3);
				DG.Tweening.Tween o = obj.SetUpdate(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: DG.Tweening.Sequence.SetUpdate");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetRecyclable(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				DG.Tweening.Tween o = obj.SetRecyclable();
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween), typeof(bool)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				bool arg0 = LuaDLL.lua_toboolean(L, 2);
				DG.Tweening.Tween o = obj.SetRecyclable(arg0);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: DG.Tweening.Sequence.SetRecyclable");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetEase(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween), typeof(int)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				DG.Tweening.Ease arg0 = (DG.Tweening.Ease)(int)LuaDLL.lua_tonumber(L, 2);
				DG.Tweening.Tween o = obj.SetEase(arg0);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween), typeof(UnityEngine.AnimationCurve)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				UnityEngine.AnimationCurve arg0 = (UnityEngine.AnimationCurve)ToLua.ToObject(L, 2);
				DG.Tweening.Tween o = obj.SetEase(arg0);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween), typeof(DG.Tweening.EaseFunction)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				DG.Tweening.EaseFunction arg0 = null;
				LuaTypes funcType2 = LuaDLL.lua_type(L, 2);

				if (funcType2 != LuaTypes.LUA_TFUNCTION)
				{
					 arg0 = (DG.Tweening.EaseFunction)ToLua.ToObject(L, 2);
				}
				else
				{
					LuaFunction func = ToLua.ToLuaFunction(L, 2);
					arg0 = DelegateFactory.CreateDelegate(typeof(DG.Tweening.EaseFunction), func) as DG.Tweening.EaseFunction;
				}

				DG.Tweening.Tween o = obj.SetEase(arg0);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween), typeof(int), typeof(float)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				DG.Tweening.Ease arg0 = (DG.Tweening.Ease)(int)LuaDLL.lua_tonumber(L, 2);
				float arg1 = (float)LuaDLL.lua_tonumber(L, 3);
				DG.Tweening.Tween o = obj.SetEase(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 4 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween), typeof(int), typeof(float), typeof(float)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				DG.Tweening.Ease arg0 = (DG.Tweening.Ease)(int)LuaDLL.lua_tonumber(L, 2);
				float arg1 = (float)LuaDLL.lua_tonumber(L, 3);
				float arg2 = (float)LuaDLL.lua_tonumber(L, 4);
				DG.Tweening.Tween o = obj.SetEase(arg0, arg1, arg2);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: DG.Tweening.Sequence.SetEase");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetLoops(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween), typeof(int)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				DG.Tweening.Tween o = obj.SetLoops(arg0);
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 3 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween), typeof(int), typeof(int)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				int arg0 = (int)LuaDLL.lua_tonumber(L, 2);
				DG.Tweening.LoopType arg1 = (DG.Tweening.LoopType)(int)LuaDLL.lua_tonumber(L, 3);
				DG.Tweening.Tween o = obj.SetLoops(arg0, arg1);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: DG.Tweening.Sequence.SetLoops");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetTarget(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			object arg0 = ToLua.ToVarObject(L, 2);
			DG.Tweening.Tween o = obj.SetTarget(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetId(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.CheckObject(L, 1, typeof(DG.Tweening.Sequence));
			object arg0 = ToLua.ToVarObject(L, 2);
			DG.Tweening.Tween o = obj.SetId(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetAutoKill(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				DG.Tweening.Tween o = obj.SetAutoKill();
				ToLua.PushObject(L, o);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes(L, 1, typeof(DG.Tweening.Tween), typeof(bool)))
			{
				DG.Tweening.Sequence obj = (DG.Tweening.Sequence)ToLua.ToObject(L, 1);
				bool arg0 = LuaDLL.lua_toboolean(L, 2);
				DG.Tweening.Tween o = obj.SetAutoKill(arg0);
				ToLua.PushObject(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: DG.Tweening.Sequence.SetAutoKill");
			}
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

