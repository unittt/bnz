using System;
using System.Collections.Generic;
using HedgehogTeam.EasyTouch;
using UnityEngine;
using LuaInterface;


public class EasyTouchHandler
{
    public enum EasyTouchType
    {
        None,
        TouchDown,
        TouchUp,
        Swipe,
		LongTapStart,
		LongTap,
		LongTapEnd,
		Drag,
		SwipeStart,
		SwipeEnd,
        TouchDown2Fingers,
        TouchUp2Fingers,
    }

    private static LuaFunction luaCallback;
    private static bool isTouch;
    private static Vector2 touchPos1;
    private static Vector2 touchPos2;


    public static void Init()
    {
        EasyTouch.On_TouchDown += OnTouchDown;
        EasyTouch.On_TouchUp += OnTouchUp;
        EasyTouch.On_Swipe += OnSwipe;
		EasyTouch.On_LongTapStart += OnLongTabStart;
		EasyTouch.On_LongTap += OnLongTab;
		EasyTouch.On_LongTapEnd += OnLongTabEnd;
		EasyTouch.On_Drag += OnDrag;
		EasyTouch.On_SwipeStart += OnSwipeStart;
		EasyTouch.On_SwipeEnd += OnSwipeEnd;
        EasyTouch.On_TouchDown2Fingers += OnTouchDown2Fingers;
        EasyTouch.On_TouchUp2Fingers += OnTouchUp2Fingers;
    }

	public static int GetTouchCount()
	{
		return EasyTouch.instance.input.TouchCount();
	}

    public static void Release()
    {
        EasyTouch.On_TouchDown -= OnTouchDown;
        EasyTouch.On_TouchUp -= OnTouchUp;
    }

    public static void SetCallback(LuaFunction func)
    {
        if (luaCallback != null)
        {
            luaCallback.Dispose();
            luaCallback = null;
        }
        luaCallback = func;
    }
    
    private static void OnTouchDown(Gesture gesture)
    {
        if (!isTouch)
        {
            isTouch = true;
            UpdateTouchPosition(gesture);
            OnCall(EasyTouchType.TouchDown, touchPos1, touchPos2);
        }
    }

    private static void OnTouchUp(Gesture gesture)
    {
        UpdateTouchPosition(gesture);
        OnCall(EasyTouchType.TouchUp, touchPos1, touchPos2);
        ClearTouchPos();
        isTouch = false;
    }

    private static void OnSwipe(Gesture gesture)
    {
		OnCall(EasyTouchType.Swipe, gesture.position, touchPos2);
    }

	private static void OnLongTabStart(Gesture gesture)
	{
		OnCall(EasyTouchType.LongTapStart, touchPos1, touchPos2);
	}

	private static void OnLongTab(Gesture gesture)
	{
		OnCall(EasyTouchType.LongTap, touchPos1, touchPos2);
	}

	private static void OnLongTabEnd(Gesture gesture)
	{
		OnCall(EasyTouchType.LongTapEnd, touchPos1, touchPos2);
	}

	private static void OnDrag(Gesture gesture)
	{
		OnCall(EasyTouchType.Drag, touchPos1, touchPos2);
	}

	private static void OnSwipeStart(Gesture gesture)
	{
		OnCall(EasyTouchType.SwipeStart, touchPos1, touchPos2);
	}

	private static void OnSwipeEnd(Gesture gesture)
	{
		OnCall(EasyTouchType.SwipeEnd, touchPos1, touchPos2);
	}

    private static void OnTouchDown2Fingers(Gesture gesture)
    {
        UpdateTouchPosition(gesture);
        OnCall(EasyTouchType.TouchDown2Fingers, touchPos1, touchPos2);
    }

      private static void OnTouchUp2Fingers(Gesture gesture)
    {
        UpdateTouchPosition(gesture);
        OnCall(EasyTouchType.TouchUp2Fingers, touchPos1, touchPos2);
    }

    public static void AddCamera(Camera camera, bool guiCam)
    {
        EasyTouch.AddCamera(camera, guiCam);
    }

    public static void DelCamera(Camera camera)
    {
        EasyTouch.RemoveCamera(camera);
    }


    private static void UpdateTouchPosition(Gesture gesture)
    {
        Vector2 pos1 = touchPos1;
        Vector2 pos2 = touchPos2;
        if (gesture.touchCount == 1)
        {
            touchPos1 = gesture.position;
            touchPos2 = Vector2.zero;
        }
        else if (gesture.touchCount == 2)
        {
            if (EasyTouch.instance.isRealTouch)
            {
                touchPos1 = EasyTouch.GetFingerPosition(Input.GetTouch(0).fingerId);
                touchPos2 = EasyTouch.GetFingerPosition(Input.GetTouch(1).fingerId);
            }
            else
            {
                touchPos1 = gesture.position;
                touchPos2 = Vector2.zero;
            }
        }
        else
        {
            touchPos1 = Vector2.zero;
            touchPos2 = Vector2.zero;
        }
    }

    private static void ClearTouchPos()
    {
        touchPos1 = Vector2.zero;
        touchPos2 = Vector2.zero;
    }

    private static void OnCall(EasyTouchHandler.EasyTouchType type, Vector2 pos_1, Vector2 pos_2)
    {
        try
        {
            if (luaCallback != null)
            {
                luaCallback.BeginPCall();
                luaCallback.Push(type);
                luaCallback.Push(pos_1.x);
                luaCallback.Push(pos_1.y);
                luaCallback.Push(pos_2.x);
                luaCallback.Push(pos_2.y);
                luaCallback.PCall();
                luaCallback.EndPCall();
            }
        }
        catch (Exception e)
        {
            Debug.LogError(e);
        }
    }

}
