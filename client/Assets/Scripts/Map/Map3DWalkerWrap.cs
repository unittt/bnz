using System;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;

public class Map3DWalkerWrap
{
    public static void Register(LuaState L)
    {
        L.BeginClass(typeof(Map3DWalker), typeof(UnityEngine.MonoBehaviour));
        L.RegFunction("WalkTo", WalkTo);
        L.RegFunction("StopWalk", StopWalk);
        L.RegFunction("Follow", Follow);
        L.RegFunction("GetPath", GetPath);
        L.RegFunction("SetWalkEndCallback", SetWalkEndCallback);
        L.RegFunction("SetWalkStartCallback", SetWalkStartCallback);
        L.RegFunction("GetWayPoint", GetWayPoint);
        L.RegFunction("GetWayPointIndex", GetWayPointIndex);
        L.RegFunction("SetTraversableTags", SetTraversableTags);
        L.RegFunction("SetMapID", SetMapID);
        L.RegVar("moveTransform", get_moveTransform, set_moveTransform);
        L.RegVar("rotateTransform", get_rotateTransform, set_rotateTransform);
        L.RegVar("moveable", get_moveable, set_moveable);
        L.RegVar("moveSpeed", get_moveSpeed, set_moveSpeed);
        L.RegVar("rotateSpeed", get_rotateSpeed, set_rotateSpeed);
        L.EndClass();
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int WalkTo(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 4);
            Map3DWalker obj = (Map3DWalker)ToLua.CheckObject(L, 1, typeof(Map3DWalker));
            float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
            float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
            bool arg2 = LuaDLL.luaL_checkboolean(L, 4);
            obj.WalkTo(arg0, arg1, arg2);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int StopWalk(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Map3DWalker obj = (Map3DWalker)ToLua.CheckObject(L, 1, typeof(Map3DWalker));
            obj.StopWalk();
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int Follow(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 3);
            Map3DWalker obj = (Map3DWalker)ToLua.CheckObject(L, 1, typeof(Map3DWalker));
            Map3DWalker arg0 = (Map3DWalker)ToLua.CheckUnityObject(L, 2, typeof(Map3DWalker));
            float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
            obj.Follow(arg0, arg1);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }


    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int GetPath(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 1);
            Map3DWalker obj = (Map3DWalker)ToLua.CheckObject(L, 1, typeof(Map3DWalker));
            List<Vector3> path = obj.GetPath();

            LuaDLL.lua_newtable(L);
            if (path != null)
            {
                for (int i = 0; i < path.Count; i++)
                {
                    ToLua.Push(L, i * 2 + 1);
                    ToLua.Push(L, path[i].x);
                    LuaDLL.lua_settable(L, -3);

                    ToLua.Push(L, i * 2 + 2);
                    ToLua.Push(L, path[i].y);
                    LuaDLL.lua_settable(L, -3);
                }
            }
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int SetWalkEndCallback(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Map3DWalker obj = (Map3DWalker)ToLua.CheckObject(L, 1, typeof(Map3DWalker));
            LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
            obj.SetWalkEndCallback(arg0);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int SetWalkStartCallback(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Map3DWalker obj = (Map3DWalker)ToLua.CheckObject(L, 1, typeof(Map3DWalker));
            LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
            obj.SetWalkStartCallback(arg0);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int GetWayPoint(IntPtr L)
    {
        try
        {
            Map3DWalker obj = (Map3DWalker)ToLua.CheckObject(L, 1, typeof(Map3DWalker));
            Vector2 pos = obj.GetWayPoint();
            LuaDLL.lua_pushnumber(L, pos.x);
            LuaDLL.lua_pushnumber(L, pos.y);
            return 2;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int GetWayPointIndex(IntPtr L)
    {
        try
        {
            Map3DWalker obj = (Map3DWalker)ToLua.CheckObject(L, 1, typeof(Map3DWalker));
            int index = obj.GetWayPointIndex();
            LuaDLL.lua_pushnumber(L, index);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int SetTraversableTags(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Map3DWalker obj = (Map3DWalker)ToLua.CheckObject(L, 1, typeof(Map3DWalker));
            int arg0 = LuaDLL.lua_tointeger(L, 2);
            obj.SetTraversableTags(arg0);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int SetMapID(IntPtr L)
    {
        try
        {
            ToLua.CheckArgsCount(L, 2);
            Map3DWalker obj = (Map3DWalker)ToLua.CheckObject(L, 1, typeof(Map3DWalker));
            int arg0 = LuaDLL.lua_tointeger(L, 2);
            obj.SetMapID(arg0);
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e);
        }
    }


    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int get_moveTransform(IntPtr L)
    {
        object o = null;

        try
        {
            o = ToLua.ToObject(L, 1);
            Map3DWalker obj = (Map3DWalker)o;
            UnityEngine.Transform ret = obj.moveTransform;
            ToLua.Push(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index moveTransform on a nil value" : e.Message);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int get_rotateTransform(IntPtr L)
    {
        object o = null;

        try
        {
            o = ToLua.ToObject(L, 1);
            Map3DWalker obj = (Map3DWalker)o;
            UnityEngine.Transform ret = obj.rotateTransform;
            ToLua.Push(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index rotateTransform on a nil value" : e.Message);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int get_moveable(IntPtr L)
    {
        object o = null;

        try
        {
            o = ToLua.ToObject(L, 1);
            Map3DWalker obj = (Map3DWalker)o;
            bool ret = obj.moveable;
            LuaDLL.lua_pushboolean(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index moveable on a nil value" : e.Message);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int get_moveSpeed(IntPtr L)
    {
        object o = null;

        try
        {
            o = ToLua.ToObject(L, 1);
            Map3DWalker obj = (Map3DWalker)o;
            float ret = obj.moveSpeed;
            LuaDLL.lua_pushnumber(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index moveSpeed on a nil value" : e.Message);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int get_rotateSpeed(IntPtr L)
    {
        object o = null;

        try
        {
            o = ToLua.ToObject(L, 1);
            Map3DWalker obj = (Map3DWalker)o;
            float ret = obj.rotateSpeed;
            LuaDLL.lua_pushnumber(L, ret);
            return 1;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index rotateSpeed on a nil value" : e.Message);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int set_moveTransform(IntPtr L)
    {
        object o = null;

        try
        {
            o = ToLua.ToObject(L, 1);
            Map3DWalker obj = (Map3DWalker)o;
            UnityEngine.Transform arg0 = (UnityEngine.Transform)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.Transform));
            obj.moveTransform = arg0;
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index moveTransform on a nil value" : e.Message);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int set_rotateTransform(IntPtr L)
    {
        object o = null;

        try
        {
            o = ToLua.ToObject(L, 1);
            Map3DWalker obj = (Map3DWalker)o;
            UnityEngine.Transform arg0 = (UnityEngine.Transform)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.Transform));
            obj.rotateTransform = arg0;
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index rotateTransform on a nil value" : e.Message);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int set_moveable(IntPtr L)
    {
        object o = null;

        try
        {
            o = ToLua.ToObject(L, 1);
            Map3DWalker obj = (Map3DWalker)o;
            bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
            obj.moveable = arg0;
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index moveable on a nil value" : e.Message);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int set_moveSpeed(IntPtr L)
    {
        object o = null;

        try
        {
            o = ToLua.ToObject(L, 1);
            Map3DWalker obj = (Map3DWalker)o;
            float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
            obj.moveSpeed = arg0;
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index moveSpeed on a nil value" : e.Message);
        }
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    static int set_rotateSpeed(IntPtr L)
    {
        object o = null;

        try
        {
            o = ToLua.ToObject(L, 1);
            Map3DWalker obj = (Map3DWalker)o;
            float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
            obj.rotateSpeed = arg0;
            return 0;
        }
        catch (Exception e)
        {
            return LuaDLL.toluaL_exception(L, e, o == null ? "attempt to index rotateSpeed on a nil value" : e.Message);
        }
    }

}

