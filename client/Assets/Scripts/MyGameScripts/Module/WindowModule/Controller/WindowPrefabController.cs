using UnityEngine;
using System;

public class WindowPrefabController : MonoViewController<WindowPrefab>
{
	private bool _isComfirmWin = false;
    private bool _isCloseCallCancelHandler = true;
    private bool mShowNotTipToggle = false;              //不再提醒Toggle      
    private Action<bool> mNotTipCallBack = null;

    #region
	protected override void RegisterEvent ()
	{
		base.RegisterEvent ();
        EventDelegate.Set (View.OKButton.onClick, OnClickOkButton);
		EventDelegate.Set (View.CancelButton.onClick, OnClickCancelButton);
		EventDelegate.Set (View.CloseBtn.onClick, OnClickCloseButton);
	}

	
	#endregion

	public event Action OnOkHandler;
	public event Action OnCancelHandler;

	public void OpenConfirmWindow (
        string msg, 
        string title="",
        Action onHandler = null,
        Action cancelHandler = null,
        UIWidget.Pivot pivot = UIWidget.Pivot.Left,
        string okLabelStr = "确定", 
        string cancelLabelStr = "取消", 
        int time = 0, 
        bool isCloseCallCancelHandler = true,
        bool isClearColor=false, bool isAutoClose = true,/*倒计时是自动关闭*/
         bool pShowNotTipToggle = false,              //不再提醒Toggle  
        Action<bool> pNotTipCallBack = null
        )
    {
		_isComfirmWin = true;
        _isCloseCallCancelHandler = isCloseCallCancelHandler;
	    mShowNotTipToggle = pShowNotTipToggle;
	    mNotTipCallBack = pNotTipCallBack;

		if (string.IsNullOrEmpty(msg))
		{
			msg = "";
		}

	    ShowNotTipToggle();

		char[] strArr = msg.ToCharArray ();
		if(strArr.Length < 19)
		{
			View.InfoLabel.pivot = UIWidget.Pivot.Center;
		}else
		{
			View.InfoLabel.pivot = pivot;
		}
        if(isClearColor)
            View.InfoLabel.color = Color.white;
        View.InfoLabel.text = msg;


		View.TitleLabel.text = title;

	    if (time > 0)
	    {
	        if (isAutoClose)
	        {
                View.OKLabel.text = okLabelStr;
                View.OKLabel.spacingX = GetLabelSpacingX(okLabelStr);
                View.OKButton.transform.localPosition = new Vector3(103, View.OKButton.transform.localPosition.y, 0);

                View.CancelLabel.text = cancelLabelStr + "(" + time + ")";
                View.CancelLabel.spacingX = GetLabelSpacingX(View.CancelLabel.text);

                JSTimer.Instance.SetupCoolDown("WindowPrefabTime", time,
                    (currTime) => {
                        int t = (int)Math.Ceiling(currTime);
                        if (t > 0)
                        {
                            View.CancelLabel.text = cancelLabelStr + "(" + t + ")";
                        }
                        else
                        {
                            View.CancelLabel.text = cancelLabelStr;
                            View.CancelLabel.spacingX = GetLabelSpacingX(cancelLabelStr);
                        }
                    },
                    () => {
                        View.CancelLabel.text = cancelLabelStr;
                        View.CancelLabel.spacingX = GetLabelSpacingX(cancelLabelStr);
                        OnClickCancelButton();
                    }, 1f);
            }
	        else
	        {
                View.OKLabel.text = okLabelStr + "(" + time + ")";
                View.OKLabel.spacingX = GetLabelSpacingX(View.OKLabel.text);
                View.OKButton.transform.localPosition = new Vector3(103, View.OKButton.transform.localPosition.y, 0);
                JSTimer.Instance.SetupCoolDown("WindowPrefabTime", time,
                    (currTime) => {
                        int t = (int)Math.Ceiling(currTime);
                        if (t > 0)
                        {
                            View.OKLabel.text = okLabelStr + "(" + t + ")";
                        }
                        else
                        {
                            View.OKLabel.text = okLabelStr;
                            View.OKLabel.spacingX = GetLabelSpacingX(okLabelStr);
                        }
                    },
                    () => {
                        View.OKLabel.text = okLabelStr;
                        View.OKLabel.spacingX = GetLabelSpacingX(okLabelStr);
                        OnClickOkButton();
                    }, 1f);

                View.CancelLabel.text = cancelLabelStr;
                View.CancelLabel.spacingX = GetLabelSpacingX(cancelLabelStr);
            }
	    }
	    else
	    {
            View.OKLabel.text = okLabelStr;
            View.OKLabel.spacingX = GetLabelSpacingX(okLabelStr);
            View.OKButton.transform.localPosition = new Vector3(103, View.OKButton.transform.localPosition.y, 0);

            View.CancelLabel.text = cancelLabelStr;
            View.CancelLabel.spacingX = GetLabelSpacingX(cancelLabelStr);
        }

		UpdateBtnStatus ( View.OKButton.gameObject,true,false);
		UpdateBtnStatus ( View.CancelButton.gameObject,true);

        OnOkHandler = onHandler;
        OnCancelHandler = cancelHandler;

        UIModuleManager.Instance.SendOpenEvent(ProxyWindowModule.NAME_WindowPrefab, this);
    }

    public void OpenWithCheckCallback(
        string msg,
        string title = "",
        Action onHandler = null,
        Action cancelHandler = null,
        UIWidget.Pivot pivot = UIWidget.Pivot.Left,
        string okLabelStr = "确定", string cancelLabelStr = "取消",
        ProxyWindowModule.checkCloseHandle checkClose = null,
        bool isCloseCallCancelHandler = true, bool isClearColor = false, bool isAutoClose = true/*倒计时是自动关闭*/,
        bool pShowNotTipToggle = false,              //不再提醒Toggle      
        Action<bool> pNotTipCallBack = null
        )
    {
        _isComfirmWin = true;
        _isCloseCallCancelHandler = isCloseCallCancelHandler;
        mShowNotTipToggle = pShowNotTipToggle;
        mNotTipCallBack = pNotTipCallBack;

        if (string.IsNullOrEmpty(msg))
        {
            msg = "";
        }

        ShowNotTipToggle();

        char[] strArr = msg.ToCharArray();
        if (strArr.Length < 19)
        {
            View.InfoLabel.pivot = UIWidget.Pivot.Center;
        }
        else
        {
            View.InfoLabel.pivot = pivot;
        }
        if (isClearColor)
            View.InfoLabel.color = Color.white;
        View.InfoLabel.text = msg;


        View.TitleLabel.text = title;
        View.OKLabel.text = okLabelStr;
        View.OKLabel.spacingX = GetLabelSpacingX(okLabelStr);
        View.OKButton.transform.localPosition = new Vector3(103, View.OKButton.transform.localPosition.y, 0);

        if (checkClose != null)
        {
            JSTimer.Instance.SetupTimer("WindowPrefabTime", () =>
            {
                if (checkClose())
                {
                    OnClickCancelButton();
                }
            }, 0.6f);
        }
        else
        {
            View.CancelLabel.text = cancelLabelStr;
            View.CancelLabel.spacingX = GetLabelSpacingX(cancelLabelStr);
        }

        UpdateBtnStatus(View.OKButton.gameObject, true, false);
        UpdateBtnStatus(View.CancelButton.gameObject, true);

        OnOkHandler = onHandler;
        OnCancelHandler = cancelHandler;

        UIModuleManager.Instance.SendOpenEvent(ProxyWindowModule.NAME_WindowPrefab, this);
    }

    private bool _topWin = false;

	public void OpenMessageWindow (string msg,
	                              string title="",
	                              Action onHandler = null,
	                              UIWidget.Pivot pivot = UIWidget.Pivot.Center,
                                  string okLabelStr = "确定", bool justClose = false, bool topWin = false,
                                  bool pShowNotTipToggle = false,              //不再提醒Toggle      
                                  Action<bool> pNotTipCallBack = null
        )
	{
	
		
		_isCloseCallCancelHandler = false;
        _isComfirmWin = justClose;
		_topWin = topWin;
        mShowNotTipToggle = pShowNotTipToggle;
        mNotTipCallBack = pNotTipCallBack;

		if (string.IsNullOrEmpty(msg))
		{
			msg = "";
		}

	    ShowNotTipToggle();

		char[] strArr = msg.ToCharArray ();
		if(strArr.Length < 19)
		{
			View.InfoLabel.pivot = UIWidget.Pivot.Center;
		}else
		{
			View.InfoLabel.pivot = UIWidget.Pivot.Left;
		}
		View.InfoLabel.text = msg;

		View.TitleLabel.text = title;
		View.OKLabel.text = okLabelStr;
		View.OKLabel.spacingX = GetLabelSpacingX (okLabelStr);
		View.OKButton.transform.localPosition = new Vector3 (0, View.OKButton.transform.localPosition.y, 0);
		UpdateBtnStatus ( View.OKButton.gameObject,true,false);
		UpdateBtnStatus ( View.CancelButton.gameObject,false);

		OnOkHandler = onHandler;
	}

	private int GetLabelSpacingX (string text)
	{
		if (text.Length <= 2) {
			return 12;
		} else if (text.Length <= 3) {
			return 6;
		} else {
			return 1;
		}
	}

	private void OnClickOkButton ()
	{
        JSTimer.Instance.CancelCd("WindowPrefabTime");
		CloseWin();	

		if (OnOkHandler != null) {
			OnOkHandler ();
		}
	}

	private void OnClickCancelButton ()
	{
        JSTimer.Instance.CancelCd("WindowPrefabTime");
		CloseWin();

		if (OnCancelHandler != null) {
			OnCancelHandler ();
		}
	}

	private void OnClickCloseButton()
	{
        if (_isCloseCallCancelHandler)
        {
            OnClickCancelButton();
        }
        else if (_isComfirmWin == false)
        {
            OnClickOkButton();
        }
        else
        {
            JSTimer.Instance.CancelCd("WindowPrefabTime");
		    CloseWin();
        }
	}

	private void CloseWin()
	{
	    if (mShowNotTipToggle == true && mNotTipCallBack != null)
	    {
	        mNotTipCallBack(View.SaveToggle_UIToggle.value);
	    }

		if (_topWin)
		{
			ProxyWindowModule.CloseForTop();
		}
		else
		{
			ProxyWindowModule.Close();
		}
	}

	private void UpdateBtnStatus(GameObject pUIButton, bool pVisible,bool pUpdateGrid = true)
	{
		if (pVisible) {
			pUIButton.transform.parent = View.BtnGrid_UIGrid.transform;
			pUIButton.gameObject.SetActive (true);
		} else {
			pUIButton.transform.parent = View.transform;
			pUIButton.gameObject.SetActive (false);
		}
		if(pUpdateGrid)
			View.BtnGrid_UIGrid.Reposition ();
	}

    private void ShowNotTipToggle()
    {
        View.BtnGrid_UIWidget.topAnchor.absolute = mShowNotTipToggle ? -48 : 30;
        View.toggleWidget_UIWidget.gameObject.SetActive(mShowNotTipToggle);
    }

    protected override void OnDispose()
    {
        JSTimer.Instance.CancelCd("WindowPrefabTime");
    }
}

