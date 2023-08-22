using System;
using UnityEngine;
//using AppDto;

public class MarryWindowPrefabController : MonoViewController<MarryWindowPrefab>
{
    private const string MarryOathStr = "此后无论环境是好是坏、富贵还是贫贱、健康还是疾病、都会忠贞不渝地爱着对方、珍惜对方、白头偕老吗？";

    //xxj begin
    //private MarryDto _dto;

    //public void Open(MarryDto dto)
    //{
        
    //    _dto = dto;
    //    SetMarryName();
    //    SetContent(MarryOathStr);
    //    SetupPromisedToMarryCoolDown();

    //}

    //private void SetMarryName()
    //{
    //    string marryName = _dto.playerId == ModelManager.Player.GetPlayerId()
    //        ? ModelManager.Team.GetTeamMemberByID(_dto.fereId).nickname
    //        : ModelManager.Team.GetTeamMemberByID(_dto.playerId).nickname;
    //    View.TopLbl_UILabel.text = string.Format("你愿意和{0}缔结婚姻吗？", marryName.WrapColor(ColorConstantV3.Color_MissionBlue_Str)).WrapColor(ColorConstantV3.Color_SealBrown);
    //}
    //xxj end 

    private void SetContent(string contentStr)
    {
        View.ContentLbl_UILabel.text = contentStr;
    }


   

    

protected override void RegisterEvent ()
	{
		base.RegisterEvent ();
        EventDelegate.Set(View.OkBtn_UIButton.onClick, OnOkBtnClick);
        EventDelegate.Set(View.PayAllBtn_UIButton.onClick, OnPayAllBtnClick);
        EventDelegate.Set(View.PayHalfBtn_UIButton.onClick, OnPayHalfBtnClick);
        EventDelegate.Set(View.CloseBtn_UIButton.onClick, OnCloseBtnClick);

        //xxj begin
        //GameEventCenter.AddListener(GameEvent.Marry_MarryCostsStateEvt, MarryCostsState);
        //GameEventCenter.AddListener(GameEvent.Marry_PromisedToMarryEvt, PromisedToMarry);
        //GameEventCenter.AddListener(GameEvent.Marry_ChangePayCostView, ChangeToPayView);
        //xxj end
    }




    private void OnCloseBtnClick()
    {
        //xxj begin
        //ModelManager.Marry.PromisedToMarry(false);
        //xxj end

        CloseView();
    }

    #region 是否同意结婚
    //xxj begin
    //private void PromisedToMarry(long playerId ,bool yes)
    //{
    //    if (playerId != ModelManager.Player.GetPlayerId())
    //    {
    //        if (yes)
    //        {
    //            View.ExtraLbl_UILabel.text = "对方已同意结婚";
    //            View.ExtraLbl_UILabel.transform.parent.gameObject.SetActive(true);
    //        }
    //        else
    //        {
    //            string marryName = _dto.playerId == ModelManager.Player.GetPlayerId()
    //       ? ModelManager.Team.GetTeamMemberByID(_dto.fereId).nickname
    //       : ModelManager.Team.GetTeamMemberByID(_dto.playerId).nickname;
    //            TipManager.AddTip(marryName.WrapColor(ColorConstantV3.Color_MissionBlue_Str) + "对于和您缔结婚姻还有疑虑");
    //            JSTimer.Instance.CancelCd(MarryCoolDown);
    //            JSTimer.Instance.CancelCd(PayMarryCostsCoolDown);
    //            ProxyWindowModule.CloseMarryWindow();
    //        }
    //    }
    //    else
    //    {
    //        View.ExtraLbl_UILabel.text = "等待对方同意";
    //        View.ExtraLbl_UILabel.transform.parent.gameObject.SetActive(true);
    //    }
    //}
    //xxj end
    #endregion

    #region 设置关闭按钮变灰
    //xxj begin
    //private void SetCloseBtnState(bool state)
    //{
    //    View.CloseBtn_UIButton.enabled = state;
    //    View.CloseBtn_UISprite.isGrey = !state;
    //}
    //xxj end
    #endregion



    #region 结婚费用支付状态  all  or  half
    //xxj begin
    //private void MarryCostsState(long playerId,bool payAll)
    //{
    //    if (View == null)
    //    {
    //        return;
    //    }
    //    if (playerId != ModelManager.Player.GetPlayerId())
    //    {
    //        if (payAll)
    //        {
    //            //对方支付了全部的话直接下一步
    //            View.PayAllBtn_UIButton.enabled = false;
    //            View.PayHalfBtn_UIButton.enabled = false;
    //        }
    //        else
    //        {
    //            View.PayAllBtn_UIButton.enabled = false;
    //            View.PayAllBtn_UISprite.isGrey = true;
    //            View.ExtraBg.SetActive(true);
    //            View.ExtraLbl_UILabel.text = "对方希望和你分摊支付";
    //        }
    //    }
    //    else
    //    {
    //        if (!payAll)
    //        {
    //            View.ExtraBg.SetActive(true);
    //            View.ExtraLbl_UILabel.text = "等待对方支付";
    //        }
    //    }
    //}
    //xxj end
    #endregion


    private void OnPayHalfBtnClick()
    {
        //xxj begin
        //MarriageConfig config = DataCache.getDtoByCls<MarriageConfig>(1);
        //if (ModelManager.Player.isEnoughCopper((int)(config.marryCostTotal * 0.5), true))
        //{
        //    JSTimer.Instance.CancelCd(PayMarryCostsCoolDown);
        //    ModelManager.Marry.MarryCosts(false);
        //    View.PayHalfBtn_UISprite.isGrey = true;
        //    View.PayHalfBtn_UIButton.enabled = false;
        //    View.PayAllBtn_UISprite.isGrey = true;
        //    View.PayAllBtn_UIButton.enabled = false;
        //    View.RemainTimeLbl_UILabel.text = "";
        //} 
        //xxj end
    }

    private void OnPayAllBtnClick()
    {
        //xxj begin
        //MarriageConfig config = DataCache.getDtoByCls<MarriageConfig>(1);
        //if (ModelManager.Player.isEnoughCopper(config.marryCostTotal, true))
        //{
        //    JSTimer.Instance.CancelCd(PayMarryCostsCoolDown);
        //    View.PayHalfBtn_UISprite.isGrey = true;
        //    View.PayHalfBtn_UIButton.enabled = false;
        //    View.PayAllBtn_UISprite.isGrey = true;
        //    View.PayAllBtn_UIButton.enabled = false;
        //    View.RemainTimeLbl_UILabel.gameObject.SetActive(false);
        //    ModelManager.Marry.MarryCosts(true);
        //    View.RemainTimeLbl_UILabel.text = "";
        //} 
        //xxj end
    }

    private void OnOkBtnClick()
    {
        //xxj begin
        //JSTimer.Instance.CancelCd(MarryCoolDown);
        //View.OkBtn_UIButton.enabled = false;
        //View.OkBtn_UISprite.isGrey = true;
        //View.CloseBtn_UIButton.enabled = false;
        //View.RemainTimeLbl_UILabel.text = "";
        //SetCloseBtnState(false);
        //ModelManager.Marry.PromisedToMarry(true);
        //xxj end
    }

    public const string MarryCoolDown = "MarryCoolDown";
    private const float MarryCoolDownTime = 30f;
    private void SetupPromisedToMarryCoolDown()
    {
        //xxj begin
        //JSTimer.Instance.SetupCoolDown(MarryCoolDown, MarryCoolDownTime, (currTime) =>
        //{
        //    if (View == null) return;
        //    int t = (int) Math.Ceiling(currTime);
        //    View.RemainTimeLbl_UILabel.text = t > 0 ? "(" + t + ")" : "0";
        //}, PromisedToMarryTimeOut);
        //xxj end
    }

    private void PromisedToMarryTimeOut()
    {
        //TipManager.AddTip("客户端判断----同意超时");
        OnCloseBtnClick();
    }


    #region 从同意界面变更到支付界面

    private void ChangeToPayView()
    {
        //xxj begin
        //View.ProposeMarriage.SetActive(false);
        //View.MarriageCosts.SetActive(true);
        //View.ExtraBg.SetActive(false);
        //View.ContentLbl_UILabel.text = string.Format("两位新人需支付{0}万#w3的婚仪费用之后即可拜堂成亲",DataCache.getDtoByCls<MarriageConfig>(1).marryCostTotal/10000);//MarriageCostsStr;
        //SetupPayMarryCostsCoolDown();
        //xxj end
    }

    #endregion


    private const float PayMarryCostsTime = 60f;
    public const string PayMarryCostsCoolDown = "PayMarryCostsCoolDown";

    private void SetupPayMarryCostsCoolDown()
    {
        //xxj begin
        //JSTimer.Instance.SetupCoolDown(PayMarryCostsCoolDown, PayMarryCostsTime, (currTime) =>
        //{
        //    if(View == null )return;
        //    int t = (int)Math.Ceiling(currTime);
        //    View.RemainTimeLbl_UILabel.text = t > 0 ? "(" + t + ")" : "0";
        //}, PayCostsTimeOut);
        //xxj end
    }

    private void PayCostsTimeOut()
    {
        //TipManager.AddTip("客户端判断----支付超时");
        CloseView();
    }
    //xxj end

    private void CloseView()
    {
        ProxyWindowModule.CloseMarryWindow();
    }

protected override void OnDispose ()
	{
		base.OnDispose ();
    
        //xxj begin
        //GameEventCenter.RemoveListener(GameEvent.Marry_MarryCostsStateEvt, MarryCostsState);
        //GameEventCenter.RemoveListener(GameEvent.Marry_PromisedToMarryEvt, PromisedToMarry);
        //GameEventCenter.RemoveListener(GameEvent.Marry_ChangePayCostView, ChangeToPayView);
        //xxj end
    }
}
