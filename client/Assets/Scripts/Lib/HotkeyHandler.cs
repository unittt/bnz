using UnityEngine;
using LuaInterface;
using System.Collections.Generic;

public class HotkeyHandler
{
    public static HotkeyHandler Instance
    {
        get;
        private set;
    }

    private List<KeyCode> hotkeyList;
    private List<KeyCode> addList;
    private List<KeyCode> delList;
    private List<int> keyUpList;
    private List<int> keyDownList;
    private LuaFunction luaKeyUpCallback;
    private LuaFunction luaKeyDownCallback;

    public static void CreateInsatnce()
    {
        if (Instance != null)
        {
            return;
        }
        Instance = new HotkeyHandler();
    }

    public HotkeyHandler()
    {
        hotkeyList = new List<KeyCode>();
        addList = new List<KeyCode>();
        delList = new List<KeyCode>();
        keyUpList = new List<int>();
        keyDownList = new List<int>();
    }

    public void Release()
    {
        if (luaKeyUpCallback != null)
        {
            luaKeyUpCallback.Dispose();
            luaKeyUpCallback = null;
        }
        if (luaKeyDownCallback != null)
        {
            luaKeyDownCallback.Dispose();
            luaKeyDownCallback = null;
        }
    }

    public void CallUpdate()
    {
        for (int i = 0; i < addList.Count; ++i)
        {
            hotkeyList.Add(addList[i]);
        }
        addList.Clear();

        for (int i = 0; i < delList.Count; ++i)
        {
            hotkeyList.Remove(delList[i]);
        }
        delList.Clear();

        keyUpList.Clear();
        keyDownList.Clear();

        for (int i = 0; i < hotkeyList.Count; ++i)
        {
            if (Input.GetKeyDown(hotkeyList[i]))
            {
                keyDownList.Add((int)hotkeyList[i]);
            }
            else if (Input.GetKeyUp(hotkeyList[i]))
            {
                keyUpList.Add((int)hotkeyList[i]);
            }
        }

        if (luaKeyDownCallback != null && keyDownList.Count > 0)
        {
            luaKeyDownCallback.Call(keyDownList);
        }

        if (luaKeyUpCallback != null && keyUpList.Count > 0)
        {
            luaKeyUpCallback.Call(keyUpList);
        }

    }

    public void SetKeyUpCallback(LuaFunction callback)
    {
        if (luaKeyUpCallback != null)
        {
            luaKeyUpCallback.Dispose();
            luaKeyUpCallback = null;
        }
        luaKeyUpCallback = callback;
    }

    public void SetKeyDownCallback(LuaFunction callback)
    {
        if (luaKeyDownCallback != null)
        {
            luaKeyDownCallback.Dispose();
            luaKeyDownCallback = null;
        }
        luaKeyDownCallback = callback;
    }

    public void AddHotKey(int keyCode)
    {
        KeyCode key = (KeyCode)keyCode;
        if (hotkeyList.Contains(key) || addList.Contains(key))
        {
            return;
        }
        addList.Add(key);
    }

    public void DelHotKey(int keyCode)
    {
        KeyCode key = (KeyCode)keyCode;
        if (hotkeyList.Contains(key) || addList.Contains(key))
        {
            delList.Add(key);
        }
    }


}
