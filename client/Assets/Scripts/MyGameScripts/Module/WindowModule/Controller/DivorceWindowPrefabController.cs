using System;
using UnityEngine;

public class DivorceWindowPrefabController : MonoViewController<DivorceWindowPrefab>{


   

    private bool _isComfirmWin = false;
    private bool _isCloseCallCancelHandler = true;

    #region

    

protected override void RegisterEvent ()
	{
		base.RegisterEvent ();        EventDelegate.Set(View.OKButton_UIEventTrigger.onClick, OnClickOkButton);
        EventDelegate.Set(View.CancelButton_UIEventTrigger.onClick, OnClickCancelButton);
        EventDelegate.Set(View.CloseBtn_UIEventTrigger.onClick, OnClickCloseButton);

        //xxj begin
        //GameEventCenter.AddListener(GameEvent.Marry_UpdateDivorceWindowContent, UpdateContent);
        //xxj end
    }

    private void UpdateContent(long playerId , string str)
    {
        if (View == null) return;

        if (str.Length < 19)
        {
            View.InfoLabel_UILabel.pivot = UIWidget.Pivot.Center;
        }

        //xxj begin
        //if (playerId == ModelManager.Player.GetPlayerId())
        //xxj end
        {
            //自己
            //隐藏2个按钮和x
            View.CloseBtn_UIEventTrigger.gameObject.SetActive(false);
            View.OKButton_UIEventTrigger.gameObject.SetActive(false);
            View.CancelButton_UIEventTrigger.gameObject.SetActive(false);
        }
        
         View.InfoLabel_UILabel.text = str;
    }

protected override void OnDispose ()
	{
		base.OnDispose ();

        //xxj begin
        //GameEventCenter.RemoveListener(GameEvent.Marry_UpdateDivorceWindowContent, UpdateContent);
        //xxj end
    }
    #endregion

    public event Action OnOkHandler;
    public event Action OnCancelHandler;

    public void OpenConfirmWindow(string msg,
                                  string title = "",
                                  Action onHandler = null,
                                  Action cancelHandler = null,
                                  UIWidget.Pivot pivot = UIWidget.Pivot.Left,
                                  string okLabelStr = "确定", 
                                  string cancelLabelStr = "取消",
                                  int time = 0,
                                  bool isCloseCallCancelHandler = true)
    {
	
        
        SetupCancelCoolDown();
        _isComfirmWin = true;
        _isCloseCallCancelHandler = isCloseCallCancelHandler;

        char[] strArr = msg.ToCharArray();
        if (strArr.Length < 19)
        {
            View.InfoLabel_UILabel.pivot = UIWidget.Pivot.Center;
        }
        else
        {
            View.InfoLabel_UILabel.pivot = pivot;
        }
        View.InfoLabel_UILabel.text = msg;


        View.TitleLabel_UILabel.text = title;
        View.OKLabel_UILabel.text = okLabelStr;
        View.OKLabel_UILabel.spacingX = GetLabelSpacingX(okLabelStr);
        View.OKButton_UIEventTrigger.transform.localPosition = new Vector3(103, -71, 0);

        if (time > 0)
        {
            View.CancelLabel_UILabel.text = cancelLabelStr + "(" + time + ")";
			View.CancelLabel_UILabel.spacingX = GetLabelSpacingX(View.CancelLabel_UILabel.text);

            JSTimer.Instance.SetupCoolDown("DivorceWindowPrefab", time,
                (currTime) => {
                    if (View == null) return;
                    int t = (int)Math.Ceiling(currTime);
                    if (t > 0)
                    {
                        View.CancelLabel_UILabel.text = cancelLabelStr + "(" + t + ")";
                    }
                    else
                    {
                        View.CancelLabel_UILabel.text = cancelLabelStr;
                        View.CancelLabel_UILabel.spacingX = GetLabelSpacingX(cancelLabelStr);
                    }
                },
                () => {
                    View.CancelLabel_UILabel.text = cancelLabelStr;
                    View.CancelLabel_UILabel.spacingX = GetLabelSpacingX(cancelLabelStr);
                    OnClickCancelButton();
                }, 1f);
        }
        else
        {
            View.CancelLabel_UILabel.text = cancelLabelStr;
            View.CancelLabel_UILabel.spacingX = GetLabelSpacingX(cancelLabelStr);
        }

        View.OKButton_UIEventTrigger.gameObject.SetActive(true);
        View.CancelButton_UIEventTrigger.gameObject.SetActive(true);

        OnOkHandler = onHandler;
        OnCancelHandler = cancelHandler;
    }

    private const float CloseCoolDownTimer = 30f;
    public const string CloseCoolDownTime = "CloseCoolDownTime";
    private void SetupCancelCoolDown()
    {
        
        JSTimer.Instance.SetupCoolDown(CloseCoolDownTime, CloseCoolDownTimer, (currTime) =>
        {
            if (View == null) return;
            int t = (int) Math.Ceiling(currTime);
            View.CoolDownTimeLbl_UILabel.text = t > 0 ? "(" + t + ")" : "0";
        }, TimeOutCloseView);
        View.CoolDownTimeLbl_UILabel.gameObject.SetActive(true);
    }

    private void TimeOutCloseView()
    {
        //xxj begin
        //TipManager.AddTip("确认离婚意愿超时，请重新申请！");
        //xxj end

        CloseWin();
    }

    private bool _topWin = false;

    public void OpenMessageWindow(string msg,
                                  string title = "",
                                  Action onHandler = null,
                                  UIWidget.Pivot pivot = UIWidget.Pivot.Center,
                                  string okLabelStr = "确定", bool justClose = false, bool topWin = false)
    {
	
        
        _isCloseCallCancelHandler = false;
        _isComfirmWin = justClose;
        _topWin = topWin;

        char[] strArr = msg.ToCharArray();
        if (strArr.Length < 19)
        {
            View.InfoLabel_UILabel.pivot = UIWidget.Pivot.Center;
        }
        else
        {
            View.InfoLabel_UILabel.pivot = UIWidget.Pivot.Left;
        }
        View.InfoLabel_UILabel.text = msg;

        View.TitleLabel_UILabel.text = title;
        View.OKLabel_UILabel.text = okLabelStr;
        View.OKLabel_UILabel.spacingX = GetLabelSpacingX(okLabelStr);
        View.OKButton_UIEventTrigger.transform.localPosition = new Vector3(0, -71, 0);
        View.OKButton_UIEventTrigger.gameObject.SetActive(true);
        View.CancelButton_UIEventTrigger.gameObject.SetActive(false);

        OnOkHandler = onHandler;
    }

    private int GetLabelSpacingX(string text)
    {
        if (text.Length <= 2)
        {
            return 12;
        }
        else if (text.Length <= 3)
        {
            return 6;
        }
        else
        {
            return 1;
        }
    }

    private void OnClickOkButton()
    {
        JSTimer.Instance.CancelCd("DivorceWindowPrefabTime");
        ChangeStateAfterClick();
//        CloseWin();

        if (OnOkHandler != null)
        {
            OnOkHandler();
        }
    }

    private void ChangeStateAfterClick()
    {
        View.OKButton_UIEventTrigger.enabled = false;
        View.CancelButton_UIEventTrigger.enabled = false;
        View.CloseBtn_UIEventTrigger.enabled = false;
    }

    private void OnClickCancelButton()
    {
        JSTimer.Instance.CancelCd("DivorceWindowPrefabTime");
        CloseWin();

        if (OnCancelHandler != null)
        {
            OnCancelHandler();
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
            JSTimer.Instance.CancelCd("DivorceWindowPrefabTime");
            CloseWin();
        }
    }

    private void CloseWin()
    {
        //if (_topWin)
        //{
        //    ProxyWindowModule.CloseForTop();
        //}
        //else
        {
//            CoolDownManager.Instance.CancelCoolDown(CloseCoolDownTime);
            ProxyWindowModule.CloseDivorceWindow();
        }
    }
}
