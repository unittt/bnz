using System;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;

[DisallowMultipleComponent]
public class UIEventHandler : MonoBehaviour
{
    public enum EventType
    {
        Submit = 1,
        Click = 2,
        DoubleClick = 3,
        Hover = 3,
        Press = 5,
        Select = 6,
        Scroll = 7,
        Change = 8,
        FocusChange = 9,

        DragStart = 11,
        Drag = 12,
        DragOut = 13,
        DragOver = 14,
        DragEnd = 15,

        ScrollDragStarted = 21,
        ScrollDragFinished = 22,
        ScrollMomentumMove = 23,
        ScrollStoppedMoving = 24,

        UICenterOnChildOnCenter = 31,
        UIPanelOnClipMove = 41,
        UIInputOnValidate = 51,
		UIWrapContentOnInitializeItem = 52,
    }

    public delegate void VoidDelegate(GameObject go);
    public delegate void BoolDelegate(GameObject go, bool state);
    public delegate void FloatDelegate(GameObject go, float delta);
    public delegate void VectorDelegate(GameObject go, Vector2 delta);
    public delegate void ObjectDelegate(GameObject go, GameObject obj);
    public delegate void KeyCodeDelegate(GameObject go, KeyCode key);

    public int eventID = 0;
    public object parameter;
    public VoidDelegate onSubmit;
    public VoidDelegate onClick;
    public VoidDelegate onDoubleClick;
    public BoolDelegate onHover;
    public BoolDelegate onPress;
    public BoolDelegate onSelect;
    public FloatDelegate onScroll;
    public VoidDelegate onDragStart;
    public VectorDelegate onDrag;
    public VoidDelegate onDragOver;
    public VoidDelegate onDragOut;
    public VoidDelegate onDragEnd;
    public ObjectDelegate onDrop;
    public KeyCodeDelegate onKey;
    public BoolDelegate onTooltip;


    bool isColliderEnabled
    {
        get
        {
            Collider c = GetComponent<Collider>();
            if (c != null) return c.enabled;
            Collider2D b = GetComponent<Collider2D>();
            return (b != null && b.enabled);
        }
    }

    void OnSubmit() { if (isColliderEnabled && onSubmit != null) onSubmit(gameObject); }
    void OnClick() { if (isColliderEnabled && onClick != null) onClick(gameObject); }
    void OnDoubleClick() { if (isColliderEnabled && onDoubleClick != null) onDoubleClick(gameObject); }
    void OnHover(bool isOver) { if (isColliderEnabled && onHover != null) onHover(gameObject, isOver); }
    void OnPress(bool isPressed) { if (isColliderEnabled && onPress != null) onPress(gameObject, isPressed); }
    void OnSelect(bool selected) { if (isColliderEnabled && onSelect != null) onSelect(gameObject, selected); }
    void OnScroll(float delta) { if (isColliderEnabled && onScroll != null) onScroll(gameObject, delta); }
    void OnDragStart() { if (onDragStart != null) onDragStart(gameObject); }
    void OnDrag(Vector2 delta) { if (onDrag != null) onDrag(gameObject, delta); }
    void OnDragOver() { if (isColliderEnabled && onDragOver != null) onDragOver(gameObject); }
    void OnDragOut() { if (isColliderEnabled && onDragOut != null) onDragOut(gameObject); }
    void OnDragEnd() { if (onDragEnd != null) onDragEnd(gameObject); }
    void OnDrop(GameObject go) { if (isColliderEnabled && onDrop != null) onDrop(gameObject, go); }
    void OnKey(KeyCode key) { if (isColliderEnabled && onKey != null) onKey(gameObject, key); }
    void OnTooltip(bool show) { if (isColliderEnabled && onTooltip != null) onTooltip(gameObject, show); }


    public void OnDestroy()
    {
        onSubmit = null;
        onClick = null;
        onDoubleClick = null;
        onHover = null;
        onPress = null;
        onSelect = null;
        onScroll = null;
        onDragStart = null;
        onDrag = null;
        onDragOver = null;
        onDragOut = null;
        onDragEnd = null;
        onDrop = null;
        onKey = null;
        onTooltip = null;
    }

    static public UIEventHandler Get(GameObject go)
    {
        UIEventHandler handler = go.GetComponent<UIEventHandler>();
        if (handler == null) handler = go.AddComponent<UIEventHandler>();
        return handler;
    }

    private UIPanel panel;
    private UIInput input;
    private UIScrollView scrollView;
    private UIPopupList popupList;
    private UIProgressBar progressBar;
    private UICenterOnChild centerOnChild;
	private UIWrapContent wrapContent;

    public UIPanel uiPanel
    {
        get
        {
            if (!panel)
            {
                panel = GetComponent<UIPanel>();
            }
            return panel;
        }
    }

    public UIInput uiInput
    {
        get
        {
            if (!input)
            {
                input = GetComponent<UIInput>();
            }
            return input;
        }
    }

    public UIScrollView uiScrollView
    {
        get
        {
            if (!scrollView)
            {
                scrollView = GetComponent<UIScrollView>();
            }
            return scrollView;
        }
    }

    public UIPopupList uiPopupList
    {
        get
        {
            if (!popupList)
            {
                popupList = GetComponent<UIPopupList>();
            }
            return popupList;
        }
    }

    public UIProgressBar uiProgressBar
    {
        get
        {
            if (!progressBar)
            {
                progressBar = GetComponent<UIProgressBar>();
            }
            return progressBar;
        }
    }

    public UICenterOnChild uiCenterOnChild
    {
        get
        {
            if (!centerOnChild)
            {
                centerOnChild = GetComponent<UICenterOnChild>();
            }
            return centerOnChild;
        }
    }


	public UIWrapContent uiWrapContent
	{
		get
		{
			if (!wrapContent)
			{
				wrapContent = GetComponent<UIWrapContent>();
			}
			return wrapContent;
		}
	}

    public void SetEventID(int id)
    {
        eventID = id;
    }

    public void AddEventType(EventType type)
    {
        if (type == EventType.Click)
        {
            onClick = (go) => 
            {
                Call(EventType.Click); 
            };
        }
        else if (type == EventType.DoubleClick)
        {
            onDoubleClick = (go) =>
            {
                Call(EventType.DoubleClick);
            };
        }
        else if (type == EventType.DragStart)
        {
            onDragStart = (go) =>
            {
                Call(EventType.DragStart);
            };
        }
        else if (type == EventType.Drag)
        {
            onDrag = (go, f) =>
            {
                Call(EventType.Drag, f);
            };
        }
        else if (type == EventType.DragEnd)
        {
            onDragEnd = (go) =>
            {
                Call(EventType.DragEnd);
            };
        }
        else if (type == EventType.DragOut)
        {
            onDragOut = (go) =>
            {
                Call(EventType.DragOut);
            };
        }
        else if (type == EventType.DragOver)
        {
            onDragOver = (go) =>
            {
                Call(EventType.DragOver);
            };
        }
        else if (type == EventType.Press)
        {
            onPress = (go, b) =>
            {
                Call(EventType.Press, b);
            };
        }
        else if (type == EventType.Scroll)
        {
            onScroll = (go, f) =>
            {
                Call(EventType.Scroll);
            };
        }
        else if (type == EventType.Select)
        {
            onSelect = (go, f) =>
            {
                Call(EventType.Select);
            };
        }
        else if (type == EventType.Hover)
        {
            onHover = (go, f) =>
            {
                Call(EventType.Hover);
            };
        }
        else if (type == EventType.Submit)
        {
            if (uiInput != null)
            {
                EventDelegate.Add(uiInput.onSubmit, OnCallSubmit);
            }
        }
        else if (type == EventType.Change)
        {
            if (uiInput != null)
            {
                EventDelegate.Add(uiInput.onChange, OnCallChange);
            }
            if (uiPopupList != null)
            {
                EventDelegate.Add(uiPopupList.onChange, OnCallChange);
            }
            if (uiProgressBar != null)
            {
                EventDelegate.Add(uiProgressBar.onChange, OnCallChange);
            }
        }
        else if (type == EventType.FocusChange)
        {
            if (uiInput != null)
            {
                EventDelegate.Add(uiInput.onFocusChange, OnCallFocusChange);
            }
        }
        else if (type == EventType.ScrollDragStarted)
        {
            if (uiScrollView != null)
            {
                uiScrollView.onDragStarted = () =>
                {
                    Call(EventType.ScrollDragStarted);
                };
            }
        }
        else if (type == EventType.ScrollDragFinished)
        {
            if (uiScrollView != null)
            {
                uiScrollView.onDragFinished = () =>
                {
                    Call(EventType.ScrollDragFinished);
                };
            }
        }
        else if (type == EventType.ScrollMomentumMove)
        {
            if (uiScrollView != null)
            {
                uiScrollView.onMomentumMove = () =>
                {
                    Call(EventType.ScrollMomentumMove);
                };
            }
        }
        else if (type == EventType.ScrollStoppedMoving)
        {
            if (uiScrollView != null)
            {
                uiScrollView.onStoppedMoving = () =>
                {
                    Call(EventType.ScrollStoppedMoving);
                };
            }
        }
        else if (type == EventType.UICenterOnChildOnCenter)
        {
            uiCenterOnChild.onCenter = (go) =>
            {
				GlobalEventHanlder.Call(eventID, (int)EventType.UICenterOnChildOnCenter, go);
            };
        }
        else if (type == EventType.UIInputOnValidate)
        {
            if (uiInput.onValidate == null)
            {
                uiInput.onValidate = (text, charIndex, addedChar) =>
                {
                    GlobalEventHanlder.luaGlobalCallback.BeginPCall();
                    GlobalEventHanlder.luaGlobalCallback.Push(eventID);
                    GlobalEventHanlder.luaGlobalCallback.Push((int)EventType.UIInputOnValidate);
                    GlobalEventHanlder.luaGlobalCallback.Push(addedChar.ToString());
                    GlobalEventHanlder.luaGlobalCallback.PCall();
                    string str = GlobalEventHanlder.luaGlobalCallback.CheckString();
                    GlobalEventHanlder.luaGlobalCallback.EndPCall();
                    if (str != null && str.Length == 1)
                    {
                        return Convert.ToChar(str);
                    }
                    else
                    {
                        return '\0';
                    }
                };
            }
        }
        else if (type == EventType.UIPanelOnClipMove)
        {
            if (uiPanel.onClipMove == null)
            {
                uiPanel.onClipMove = (panel) =>
                {
                    GlobalEventHanlder.Call(eventID, (int)EventType.UIPanelOnClipMove, panel);
                };
            }
        }
		else if (type == EventType.UIWrapContentOnInitializeItem)
		{
			if (uiWrapContent.onInitializeItem == null)
			{
				uiWrapContent.onInitializeItem = (go, idx, realidx) =>
				{
					GlobalEventHanlder.Call(eventID, (int)EventType.UIWrapContentOnInitializeItem, go, idx, realidx);
				};
			}
		}
    }

    public void DelEventType(EventType type)
    {
        if (type == EventType.Click)
        {
            onClick = null;
        }
        else if (type == EventType.DoubleClick)
        {
            onDoubleClick = null;
        }
        else if (type == EventType.DragStart)
        {
            onDragStart = null;
        }
        else if (type == EventType.Drag)
        {
            onDrag = null;
        }
        else if (type == EventType.DragEnd)
        {
            onDragEnd = null;
        }
        else if (type == EventType.DragOut)
        {
            onDragOut = null;
        }
        else if (type == EventType.DragOver)
        {
            onDragOver = null;
        }
        else if (type == EventType.Press)
        {
            onPress = null;
        }
        else if (type == EventType.Scroll)
        {
            onScroll = null;
        }
        else if (type == EventType.Select)
        {
            onSelect = null;
        }
        else if (type == EventType.Hover)
        {
            onHover = null;
        }
        else if (type == EventType.Submit)
        {
            if (input != null)
            {
                EventDelegate.Remove(input.onSubmit, OnCallSubmit);
            }
        }
        else if (type == EventType.Change)
        {
            if (input != null)
            {
                EventDelegate.Remove(input.onChange, OnCallChange);
            }
            if (popupList != null)
            {
                EventDelegate.Remove(popupList.onChange, OnCallChange);
            }
            if (progressBar != null)
            {
                EventDelegate.Remove(progressBar.onChange, OnCallChange);
            }
        }
        else if (type == EventType.FocusChange)
        {
            if (input != null)
            {
                EventDelegate.Remove(input.onFocusChange, OnCallFocusChange);
            }
        }
        else if (type == EventType.DragStart)
        {
            if (scrollView != null)
            {
                scrollView.onDragStarted = null;
            }
        }
        else if (type == EventType.ScrollDragFinished)
        {
            if (scrollView != null)
            {
                scrollView.onDragFinished = null;
            }
        }
        else if (type == EventType.ScrollMomentumMove)
        {
            if (scrollView != null)
            {
                scrollView.onMomentumMove = null;
            }
        }
        else if (type == EventType.ScrollStoppedMoving)
        {
            if (scrollView != null)
            {
                scrollView.onStoppedMoving = null;
            }
        }
        else if (type == EventType.UICenterOnChildOnCenter)
        {
            if(uiCenterOnChild != null)
            {
                uiCenterOnChild.onCenter = null;
            }
        }
        else if (type == EventType.UIInputOnValidate)
        {
            if (uiInput.onValidate == null)
            {
                uiInput.onValidate = null;   
            }
        }
        else if (type == EventType.UIPanelOnClipMove)
        {
            if (uiPanel.onClipMove == null)
            {
                uiPanel.onClipMove = null;
            }
        }
    }

    public void Call(EventType type)
    {
        GlobalEventHanlder.Call(eventID, (int)type);
    }

    private void Call(EventType type, float f)
    {
        GlobalEventHanlder.Call(eventID, (int)type, f);
    }

    private void Call(EventType type, bool b)
    {
        GlobalEventHanlder.Call(eventID, (int)type, b);
    }

    private void Call(EventType type, Vector2 v)
    {
        GlobalEventHanlder.Call(eventID, (int)type, v);
    }

    private void OnCallSubmit()
    {
        Call(EventType.Submit);
    }

    private void OnCallChange()
    {
        Call(EventType.Change);
    }
    
    private void OnCallFocusChange()
    {
        Call(EventType.FocusChange);
    }



    struct DepthEntry
    {
        public int depth;
        public UIEventHandler handler;
        public Vector3 point;
        public GameObject go;
    }

	bool IsVisible (ref DepthEntry de)
	{
		UIPanel panel = NGUITools.FindInParents<UIPanel>(de.go);
		while (panel != null)
		{
			if (!panel.IsVisible(de.point)) return false;
			panel = panel.parentPanel;
		}
		return true;
	}

    public UIEventHandler GetUnderHandler()
    {
        if (UICamera.current != null && UICamera.currentCamera != null && UICamera.lastHit.collider != null && UICamera.lastHit.collider.gameObject == gameObject) 
        {
            UICamera cam = UICamera.current;
            Camera currentCamera = UICamera.currentCamera;
            Ray ray = UICamera.currentCamera.ScreenPointToRay(UICamera.lastEventPosition);
			
            // Raycast into the screen
            int mask = currentCamera.cullingMask & (int)cam.eventReceiverMask;
            float dist = (cam.rangeDistance > 0f) ? cam.rangeDistance : currentCamera.farClipPlane - currentCamera.nearClipPlane;
            RaycastHit[] hits = Physics.RaycastAll(ray, dist, mask);
            DepthEntry mHit = new DepthEntry();
            BetterList<DepthEntry> mHits = new BetterList<DepthEntry>();
            for (int i = 0; i < hits.Length; ++i)
			{
				GameObject go = hits[i].collider.gameObject;
                if (go == gameObject) continue;

                UIEventHandler handler = go.GetComponent<UIEventHandler>();
                if (handler != null)
                {
                    UIWidget w = go.GetComponent<UIWidget>();
                    if (w != null)
                    {
                        if (!w.isVisible) continue;
                        if (w.hitCheck != null && !w.hitCheck(hits[i].point)) continue;
                    }
                    else
                    {
                        UIRect rect = NGUITools.FindInParents<UIRect>(go);
                        if (rect != null && rect.finalAlpha < 0.001f) continue;
                    }
                    mHit.depth = NGUITools.CalculateRaycastDepth(go);

                    if (mHit.depth != int.MaxValue)
                    {
                        mHit.handler = handler;
                        mHit.point = hits[i].point;
                        mHit.go = hits[i].collider.gameObject;
                        mHits.Add(mHit);
                    }
                }
                
            }
            mHits.Sort(delegate(DepthEntry r1, DepthEntry r2) { return r2.depth.CompareTo(r1.depth); });
            for (int b = 0; b < mHits.size; ++b)
            {
                if (IsVisible(ref mHits.buffer[b]))
                {
                    return mHits.buffer[b].handler;
                }
            }
        } 
        return null;
    }

}
