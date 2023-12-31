﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UIBasicSpriteWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UIBasicSprite), typeof(UIWidget));
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("centerType", get_centerType, set_centerType);
		L.RegVar("leftType", get_leftType, set_leftType);
		L.RegVar("rightType", get_rightType, set_rightType);
		L.RegVar("bottomType", get_bottomType, set_bottomType);
		L.RegVar("topType", get_topType, set_topType);
		L.RegVar("type", get_type, set_type);
		L.RegVar("flip", get_flip, set_flip);
		L.RegVar("fillDirection", get_fillDirection, set_fillDirection);
		L.RegVar("fillAmount", get_fillAmount, set_fillAmount);
		L.RegVar("minWidth", get_minWidth, null);
		L.RegVar("minHeight", get_minHeight, null);
		L.RegVar("invert", get_invert, set_invert);
		L.RegVar("hasBorder", get_hasBorder, null);
		L.RegVar("premultipliedAlpha", get_premultipliedAlpha, null);
		L.RegVar("pixelSize", get_pixelSize, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Equality(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
			UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
			bool o = arg0 == arg1;
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_centerType(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			UIBasicSprite.AdvancedType ret = obj.centerType;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index centerType on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_leftType(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			UIBasicSprite.AdvancedType ret = obj.leftType;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index leftType on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_rightType(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			UIBasicSprite.AdvancedType ret = obj.rightType;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index rightType on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_bottomType(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			UIBasicSprite.AdvancedType ret = obj.bottomType;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index bottomType on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_topType(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			UIBasicSprite.AdvancedType ret = obj.topType;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index topType on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_type(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			UIBasicSprite.Type ret = obj.type;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index type on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_flip(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			UIBasicSprite.Flip ret = obj.flip;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index flip on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_fillDirection(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			UIBasicSprite.FillDirection ret = obj.fillDirection;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index fillDirection on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_fillAmount(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			float ret = obj.fillAmount;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index fillAmount on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_minWidth(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			int ret = obj.minWidth;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index minWidth on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_minHeight(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			int ret = obj.minHeight;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index minHeight on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_invert(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			bool ret = obj.invert;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index invert on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_hasBorder(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			bool ret = obj.hasBorder;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index hasBorder on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_premultipliedAlpha(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			bool ret = obj.premultipliedAlpha;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index premultipliedAlpha on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pixelSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			float ret = obj.pixelSize;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index pixelSize on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_centerType(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			UIBasicSprite.AdvancedType arg0 = (UIBasicSprite.AdvancedType)(int)LuaDLL.lua_tonumber(L, 2);
			obj.centerType = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index centerType on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_leftType(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			UIBasicSprite.AdvancedType arg0 = (UIBasicSprite.AdvancedType)(int)LuaDLL.lua_tonumber(L, 2);
			obj.leftType = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index leftType on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_rightType(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			UIBasicSprite.AdvancedType arg0 = (UIBasicSprite.AdvancedType)(int)LuaDLL.lua_tonumber(L, 2);
			obj.rightType = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index rightType on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_bottomType(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			UIBasicSprite.AdvancedType arg0 = (UIBasicSprite.AdvancedType)(int)LuaDLL.lua_tonumber(L, 2);
			obj.bottomType = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index bottomType on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_topType(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			UIBasicSprite.AdvancedType arg0 = (UIBasicSprite.AdvancedType)(int)LuaDLL.lua_tonumber(L, 2);
			obj.topType = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index topType on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_type(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			UIBasicSprite.Type arg0 = (UIBasicSprite.Type)(int)LuaDLL.lua_tonumber(L, 2);
			obj.type = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index type on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_flip(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			UIBasicSprite.Flip arg0 = (UIBasicSprite.Flip)(int)LuaDLL.lua_tonumber(L, 2);
			obj.flip = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index flip on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_fillDirection(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			UIBasicSprite.FillDirection arg0 = (UIBasicSprite.FillDirection)(int)LuaDLL.lua_tonumber(L, 2);
			obj.fillDirection = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index fillDirection on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_fillAmount(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.fillAmount = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index fillAmount on a nil value" : e.Message);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_invert(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UIBasicSprite obj = (UIBasicSprite)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.invert = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index invert on a nil value" : e.Message);
		}
	}
}

