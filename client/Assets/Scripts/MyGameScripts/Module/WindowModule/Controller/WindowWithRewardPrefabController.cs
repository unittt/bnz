using UnityEngine;
using System;
using System.Collections.Generic;
//using AppDto;

public class WindowWithRewardPrefabController : MonoViewController<WindowWithRewardPrefab>
{
    private const string RewardItemCellPrefabPath = "RewardItemCell";

    private bool _isComfirmWin = false;
    private bool _isCloseCallCancelHandler = true;

    //xxj begin
    //private List<RewardItemCellController> _rewardItemCells;
    //xxj end

    protected override void InitView()
    {
        //xxj begin
        //_rewardItemCells = new List<RewardItemCellController>();
        //xxj end
    }

    protected override void RegisterEvent()
    {
        base.RegisterEvent(); EventDelegate.Set(View.OKButton.onClick, OnClickOkButton);
        EventDelegate.Set(View.CancelButton.onClick, OnClickCancelButton);
        EventDelegate.Set(View.CloseBtn.onClick, OnClickCloseButton);
    }

    public event Action OnOkHandler;
    public event Action OnCancelHandler;

    public void OpenWindow(
        string msg, string title = "",
        Action onHandler = null,
        Action cancelHandler = null,
        UIWidget.Pivot pivot = UIWidget.Pivot.Left,
        string okLabelStr = "确定",
        string cancelLabelStr = "取消",
        int time = 0,
        bool isCloseCallCancelHandler = true,
        bool isClearColor = false,
        List<int> rewardList = null,
        string rewardTips = "")
    {
        _isComfirmWin = true;
        _isCloseCallCancelHandler = isCloseCallCancelHandler;

        if (string.IsNullOrEmpty(msg))
        {
            msg = "";
        }

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

        if (time > 0)
        {
            View.CancelLabel.text = cancelLabelStr + "(" + time + ")";
            View.CancelLabel.spacingX = GetLabelSpacingX(View.CancelLabel.text);

            JSTimer.Instance.SetupCoolDown("WindowWithRewardPrefab", time,
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
            View.CancelLabel.text = cancelLabelStr;
            View.CancelLabel.spacingX = GetLabelSpacingX(cancelLabelStr);
        }

        UpdateBtnStatus(View.OKButton.gameObject, true, false);
        UpdateBtnStatus(View.CancelButton.gameObject, true);

        OnOkHandler = onHandler;
        OnCancelHandler = cancelHandler;

        if (string.IsNullOrEmpty(rewardTips))
            rewardTips = "活动奖励";
        View.InfoTipsLabel.text = rewardTips;

        if (rewardList != null && rewardList.Count > 0)
        {
            //xxj begin
            //int count = Math.Min(4, rewardList.Count);
            //for (int i = 0; i < count; i++)
            //{
            //    GameObject item = AddCachedChild(View.RewardItemGrid.gameObject, RewardItemCellPrefabPath);
            //    RewardItemCellController com = new RewardItemCellController(item);
            //    com.SetScheduleReward(i, rewardList[i], ShowTips);
            //    _rewardItemCells.Add(com);
            //}
            //xxj end
            View.RewardItemGrid.Reposition();
        }

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
        bool isCloseCallCancelHandler = true, 
        bool isClearColor = false,
        List<int> rewardList = null,
        string rewardTips = "")
    {
        _isComfirmWin = true;
        _isCloseCallCancelHandler = isCloseCallCancelHandler;

        if (string.IsNullOrEmpty(msg))
        {
            msg = "";
        }

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
            JSTimer.Instance.SetupTimer("WindowWithRewardPrefab", () =>
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

        if (string.IsNullOrEmpty(rewardTips))
            rewardTips = "活动奖励";
        View.InfoTipsLabel.text = rewardTips;

        if (rewardList != null && rewardList.Count > 0)
        {
            //xxj begin
            //int count = Math.Min(4, rewardList.Count);
            //for (int i = 0; i < count; i++)
            //{
            //    GameObject item = AddCachedChild(View.RewardItemGrid.gameObject, RewardItemCellPrefabPath);
            //    RewardItemCellController com = new RewardItemCellController(item);
            //    com.SetScheduleReward(i, rewardList[i], ShowTips);
            //    _rewardItemCells.Add(com);
            //}
            //xxj end
            View.RewardItemGrid.Reposition();
        }
        UIModuleManager.Instance.SendOpenEvent(ProxyWindowModule.NAME_WindowPrefab, this);
    }

    private void ShowTips(int itemId, GameObject go)
    {
        //xxj begin
        //GeneralItem item = DataCache.getDtoByCls<GeneralItem>(itemId);
        //if (item is AppVirtualItem)
        //{
        //    ProxyItemTipsModule.OpenVirtualItemTip(item as AppVirtualItem, go, ItemTipSide.Top);
        //}
        //else if (item != null)
        //{
        //    ProxyItemTipsModule.Open(item.id, go, ItemTipSide.Top);
        //}
        //xxj end
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
        JSTimer.Instance.CancelCd("WindowWithRewardPrefab");
        CloseWin();

        if (OnOkHandler != null)
        {
            OnOkHandler();
        }
    }

    private void OnClickCancelButton()
    {
        JSTimer.Instance.CancelCd("WindowWithRewardPrefab");
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
            JSTimer.Instance.CancelCd("WindowWithRewardPrefab");
            CloseWin();
        }
    }

    private void CloseWin()
    {
        ProxyWindowModule.CloseWithRewardWindow();
    }

    private void UpdateBtnStatus(GameObject pUIButton, bool pVisible, bool pUpdateGrid = true)
    {
        if (pVisible)
        {
            pUIButton.transform.parent = View.BtnGrid_UIGrid.transform;
            pUIButton.gameObject.SetActive(true);
        }
        else
        {
            pUIButton.transform.parent = View.transform;
            pUIButton.gameObject.SetActive(false);
        }
        if (pUpdateGrid)
            View.BtnGrid_UIGrid.Reposition();
    }

    protected override void OnDispose()
    {
        //xxj begin
        //for (int index = 0; index < _rewardItemCells.Count; index++)
        //{
        //    _rewardItemCells[index].Dispose();
        //}
        //_rewardItemCells.Clear();
        //JSTimer.Instance.CancelCd("WindowWithRewardPrefab");
        //xxj end
    }
}

