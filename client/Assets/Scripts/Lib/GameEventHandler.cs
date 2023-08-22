using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LuaInterface;
using UnityEngine;
using AssetPipeline;

public class GameEventHandler : MonoBehaviour
{
    public LuaFunction luaOnClick;
    public LuaFunction luaApplicationPause;
    public LuaFunction luaApplicationFocus;
	public LuaFunction luaApplicationQuit;

    public static GameEventHandler Instance
    {
        private set;
        get;
    }

    public static void CreateInstance()
    {
        if (Instance != null)
        {
            Debug.LogError("GameEventHandler.Instance already exist");
            return;
        }

        GameObject go = new GameObject("GameEventHandler");
        GameObject.DontDestroyOnLoad(go);
        Instance = go.AddComponent<GameEventHandler>();
    }

    private void OnEnable()
    {
        UICamera.onClick += OnClickCallback;
    }

    private void OnDisable()
    {
        UICamera.onClick -= OnClickCallback;
    }

    private void OnDestroy()
    {
        if (luaOnClick != null)
        {
            luaOnClick.Dispose();
            luaOnClick = null;
        }
    }

    private void OnApplicationFocus(bool focus)
    {
        if (luaApplicationFocus != null)
        {
            luaApplicationFocus.BeginPCall();
            luaApplicationFocus.Push(focus);
            luaApplicationFocus.PCall();
            luaApplicationFocus.EndPCall();
        }
    }

    private void OnApplicationPause(bool paused)
    {
        if(luaApplicationPause != null)
        {
            luaApplicationPause.BeginPCall();
            luaApplicationPause.Push(paused);
            luaApplicationPause.PCall();
            luaApplicationPause.EndPCall();
        }
    }

	private void OnApplicationQuit()
	{
		if (luaApplicationQuit != null)
		{
			luaApplicationQuit.BeginPCall();
			luaApplicationQuit.Push();
			luaApplicationQuit.PCall();
			luaApplicationQuit.EndPCall();
		}
	}

	public void CallApplicationQuit()
	{
		CSTimer.Instance.DoApplicationQuit ();
		ZipManager.Instance.DoApplicationQuit ();
		AssetUpdate.Instance.DoApplicationQuit ();
		PhotoReaderManager.Instance.DoApplicationQuit ();
		AstarPathManager.Instance.astarPath.DoApplicationQuit ();
		HttpController.Instance.httpController.DoApplicationQuit ();
	}

    public void SetApplicationPauseCallback(LuaFunction func)
    {
        if (luaApplicationPause != null)
        {
            luaApplicationPause.Dispose();
        }
        luaApplicationPause = func;
    }

    public void SetApplicationFocusCallback(LuaFunction func)
    {
        if (luaApplicationFocus != null)
        {
            luaApplicationFocus.Dispose();
        }
        luaApplicationFocus = func;
	}
	
	public void SetApplicationQuitCallback(LuaFunction func)
	{
		if (luaApplicationQuit != null)
		{
			luaApplicationQuit.Dispose();
		}
		luaApplicationQuit = func;
	}

    private void OnClickCallback(GameObject go)
    {
        if (luaOnClick != null)
        {
            luaOnClick.BeginPCall();
            luaOnClick.Push(go);
            luaOnClick.PCall();
            luaOnClick.EndPCall();
        }
    }

    public void SetClickCallback(LuaFunction func)
    {
        if (luaOnClick != null)
        {
            luaOnClick.Dispose();
        }
        luaOnClick = func;        
    }
}

