using UnityEngine;
//using AppServices;
//using AppDto;
using LuaInterface;

public class NumberConfirmViewController : MonoViewController<NumberConfirmView>
{
    private bool mUseable = false;
    private System.Action mCallBack;

    public void Open(string pTitleName,string pDecription, string pDetail, System.Action pCallBack)
    {
        View.titleLbl_UILabel.text = pTitleName;
        View.descriptionLabel_UILabel.text = pDecription;
        View.detailLabel_UILabel.text = pDetail;

        mCallBack = pCallBack;
        GetRandomNum();
    }

    #region IViewController

    protected override void InitView()
    {
        View.NumInput_UIInput.characterLimit = 4;
        View.NumInput_UIInput.validation = UIInput.Validation.Integer;
    }

    protected override void RegisterEvent()
    {
        EventDelegate.Set(View.confirmBtn_UIButton.onClick, OnClickConfirmBtn);
        EventDelegate.Set(View.cancelBtn_UIButton.onClick, OnClickCancelBtn);
        EventDelegate.Set(View.CloseBtn_UIButton.onClick, OnClickCancelBtn);
    }

    protected override void OnDispose()
    {
        JSTimer.Instance.CancelCd("NumberConfirViewTimer");
        mUseable = false;
    }

    #endregion


    private void OnClickConfirmBtn()
    {
        if (string.IsNullOrEmpty(View.NumInput_UIInput.value))
        {
            //TipManager.AddTip("请输入验证码");

            LuaFunction func = LuaMain.Instance.luaState.GetFunction("main.tip");
            func.Call("请输入验证码");
            func.Dispose();
            return;
        }
        if (View.NumInput_UIInput.value == View.RandomLabel_UILabel.text)
        {
            if (mUseable)
            {
                if (mCallBack != null)
                    mCallBack();
                OnClickCancelBtn();
            }
            else
            {
                //TipManager.AddTip("验证码已超时，请重新输入");

                LuaFunction func = LuaMain.Instance.luaState.GetFunction("main.tip");
                func.Call("验证码已超时，请重新输入");
                func.Dispose();

                GetRandomNum();
            }
        }
        else
        {
            //TipManager.AddTip("验证码输入错误");

            LuaFunction func = LuaMain.Instance.luaState.GetFunction("main.tip");
            func.Call("验证码输入错误");
            func.Dispose();
        }
    }

    private void OnClickCancelBtn()
    {
        ProxyWindowModule.CloseNumberConfirmWindow();
    }

    private void GetRandomNum()
    {
        View.RandomLabel_UILabel.text = Random.Range(1000, 9999).ToString();
        mUseable = true;
        JSTimer.Instance.SetupCoolDown("NumberConfirViewTimer", 180, null, TimerFinish);
    }

    /// <summary>
    /// 3分钟失效
    /// </summary>
    private void TimerFinish()
    {
        mUseable = false;
    }
}
