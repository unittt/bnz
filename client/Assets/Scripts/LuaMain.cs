using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using LuaInterface;
using DG.Tweening;

public class LuaMain: MonoBehaviour 
{
    private LuaFunction luaStart;
    private LuaFunction luaUpdate;
    private LuaFunction luaLateUpdate;
	private LuaFunction luaPause;

    private bool initDone = false;
	private DateTime pauseTime;
	private TimeSpan leftTime;

    public static LuaMain Instance
    {
        get;
        protected set;
    }

    public LuaState luaState
    {
        get;
        protected set;
    }

    private void Awake()
    {
        Instance = this;
        EasyTouchHandler.Init();
        DOTween.Init(false, true, LogBehaviour.ErrorsOnly);
		TcpParser.InitKeyMap();
        NetworkManager.CreateInstance();
        WWWRequest.CreateInstance();
        AstarPathManager.CreateInstance();
        AudioRecord.CreateInsatnce();
        HotkeyHandler.CreateInsatnce();
        GameEventHandler.CreateInstance();
        PayManager.CreateInstance();
        PlatformAPI.Init();
        SPSDK.Setup();

        //启动Luastsate，绑定c和c#的库
        luaState = new LuaState();
        //luaState.LogGC = true;
        luaState.OpenLibs(LuaDLL.luaopen_protobuf_c);
        //luaState.OpenLibs(LuaDLL.luaopen_struct);
        //luaState.OpenLibs(LuaDLL.luaopen_lpeg);

        luaState.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
        luaState.OpenLibs(LuaDLL.luaopen_cjson);
        luaState.LuaSetField(-2, "cjson");
        //luaState.OpenLibs(LuaDLL.luaopen_cjson_safe);
        //luaState.LuaSetField(-2, "cjson.safe");

        luaState.LuaSetTop(0);
        LuaBinder.Bind(luaState);
        luaState.Start();

        object[] array = luaState.DoFile("main");
        LuaTable luaTable = array[0] as LuaTable;
        luaStart = luaTable["start"] as LuaFunction;
        luaUpdate = luaTable["update"] as LuaFunction;
        luaLateUpdate = luaTable["lateupdate"] as LuaFunction;
		luaPause = luaTable ["pause"] as LuaFunction;
    }

    private void Start()
    {
        GameDebug.SetLogLevel(GameDebug.LEVEL_LOG);
        if (luaStart != null)
        {
            luaStart.Call();
            luaStart.Dispose();
            luaStart = null;
        }
        initDone = true;

        GameLauncherViewController.ShowTips("");
    }

    private void Update()
    {
        if (!initDone)
            return;
//#if UNITY_EDITOR || UNITY_STANDALONE_WIN || UNITY_STANDALONE_OSX || UNITY_STANDALONE_LINUX
//		HotkeyHandler.Instance.CallUpdate();
//#endif
        HotkeyHandler.Instance.CallUpdate();
        NetworkManager.Instance.CallUpdate();
        GameDebug.CallUpdate();
        QiniuCloud.CallUpdate();
        ResourceManager.CallUpdate();
        if (luaUpdate != null)
        {
            luaUpdate.BeginPCall();
            luaUpdate.Push(Time.deltaTime);
            luaUpdate.PCall();
            luaUpdate.EndPCall();
        }

        luaState.Collect();
    }

    private void LateUpdate()
    {
		if (luaLateUpdate != null)
		{
			luaLateUpdate.BeginPCall();
            luaLateUpdate.Push(Time.deltaTime);
			luaLateUpdate.PCall();
			luaLateUpdate.EndPCall();
		}

        if (Map2DCamera.Instance != null)
        {
            Map2DCamera.Instance.CallLateUpdate();
        }
        Hud.CallUpdateAll();
        UpdateManager.CallLateUpdate();
    }

    private void OnApplicationPause(bool paused)
    {
        if (!paused)
        {
			//Debug.LogError("resume " + System.DateTime.Now);
			leftTime = DateTime.UtcNow - pauseTime;
			//Debug.LogError ("left time " + leftTime.TotalSeconds);
			luaPause.BeginPCall();
			luaPause.Push(paused);
			luaPause.Push(leftTime.TotalSeconds);
			luaPause.PCall();
			luaPause.EndPCall();
        }
        else
        {
			pauseTime = DateTime.UtcNow;
			//Debug.LogError("pause" + System.DateTime.Now);
        }
    }

    private void OnDestroy()
    {
        luaState.Dispose();
        EasyTouchHandler.Release();
        PlatformAPI.Release();
        AudioRecord.Release();
        HotkeyHandler.Instance.Release();              
        GameDebug.Release();
    }

}

