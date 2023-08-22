using System;
using LuaInterface;
using UnityEngine;

public class EasyTouchHandlerWrap
{
    public static void Register(LuaState L)
    {
        L.BeginClass(typeof(EasyTouchHandler), typeof(System.Object));
		L.RegFunction("GetTouchCount", GetTouchCount);
        L.RegFunction("SetCallback", SetCallback);
        L.RegFunction("AddCamera", AddCamera);
        L.RegFunction("DelCamera", DelCamera);
        L.RegFunction("Select", Select);
        L.RegFunction("SelectMultiple", SelectMultiple);
        L.EndClass();
    }

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetTouchCount(IntPtr L)
	{
		try
		{
			ToLua.Push(L, EasyTouchHandler.GetTouchCount());
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int SetCallback(IntPtr L)
    {
        try
        {
            LuaFunction luaFunc = ToLua.CheckLuaFunction(L, 1);
            EasyTouchHandler.SetCallback(luaFunc);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int AddCamera(IntPtr L)
    {
        try
        {
            UnityEngine.Camera arg0 = (UnityEngine.Camera)ToLua.CheckUnityObject(L, 1, typeof(UnityEngine.Camera));
            bool arg1 = LuaDLL.luaL_checkboolean(L, 2);
            EasyTouchHandler.AddCamera(arg0, arg1);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int DelCamera(IntPtr L)
    {
        try
        {
            UnityEngine.Camera arg0 = (UnityEngine.Camera)ToLua.CheckUnityObject(L, 1, typeof(UnityEngine.Camera));
            EasyTouchHandler.DelCamera(arg0);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    private static int Select(IntPtr L)
    {
        try
        {
            UnityEngine.Camera camera = (UnityEngine.Camera)ToLua.CheckUnityObject(L, 1, typeof(UnityEngine.Camera));
            float x = (float)LuaDLL.luaL_checknumber(L, 2);
            float y = (float)LuaDLL.luaL_checknumber(L, 3);
            int layerMask = LuaDLL.luaL_checkinteger(L, 4);
            Ray ray = camera.ScreenPointToRay(new Vector3(x, y, 0f));
            RaycastHit raycastHit;
            if (Physics.Raycast(ray, out raycastHit, float.PositiveInfinity, layerMask))
            {
                ToLua.Push(L, raycastHit.transform.gameObject);
                ToLua.Push(L, raycastHit.point);
                return 2;
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    private static int SelectMultiple(IntPtr L)
    {
        try
        {
            UnityEngine.Camera camera = (UnityEngine.Camera)ToLua.CheckUnityObject(L, 1, typeof(UnityEngine.Camera));
            float x = (float)LuaDLL.luaL_checknumber(L, 2);
            float y = (float)LuaDLL.luaL_checknumber(L, 3);
            int layerMask = LuaDLL.luaL_checkinteger(L, 4);
            Ray ray = camera.ScreenPointToRay(new Vector3(x, y, 0f));
            RaycastHit[] array = Physics.RaycastAll(ray, float.PositiveInfinity, layerMask);
            if (array != null && array.Length > 0)
            {
                LuaDLL.lua_newtable(L);
                int top = LuaDLL.lua_gettop(L);
                for (int i = 0; i < array.Length; i++)
                {
                    ToLua.Push(L, i * 2 + 1);
                    ToLua.Push(L, array[i].transform.gameObject);
                    LuaDLL.lua_settable(L, -3);
                    ToLua.Push(L, i * 2 + 2);
                    ToLua.Push(L, array[i].point);
                    LuaDLL.lua_settable(L, -3);
                }
                LuaDLL.lua_settop(L, top);
                return 1;
            }
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }
}

