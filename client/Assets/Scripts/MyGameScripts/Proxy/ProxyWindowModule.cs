using UnityEngine;
using System;
using System.Collections.Generic;
//using AppDto;

public class ProxyWindowModule
{

    public const string NAME_WindowPrefab = "WindowPrefab";
    public const string SIMPLE_NAME_WindowPrefab = "SimpleWindowPrefab";

    public const string NAME_WindowPrefabForTop = "WindowPrefabTop";
    public const string SIMPLE_NAME_WindowPrefabForTop = "SimpleWindowPrefabTop";

    public const string INPUT_NAME_WINDOWPREFAB = "WindowInputPrefab";
    public const string NAME_WindowOptSavePrefab = "WindowOptSavePrefab";

    public const string QueueWindowPrefabPath = "QueueWindowPrefab";
    public const string MarryWindowPrefabPath = "MarryWindowPrefab";
    public const string DivorceWindowPrefabPath = "DivorceWindowPrefab";
    public const string PhoneConfirmWindowPrefabPath = "PhoneConfirmWindowPrefab";

    public const string NAME_WindowWithRewardPrefab = "WindowWithRewardPrefab";

    public delegate bool checkCloseHandle();

    //checkCloseHandle 时时检测是否需要关闭确认框
    #region 带边框确认框
    public static void OpenConfirmWindow(string msg,
        string title = "",
        Action onHandler = null,
        Action cancelHandler = null,
        UIWidget.Pivot pivot = UIWidget.Pivot.Left,
        string okLabelStr = null,
        string cancelLabelStr = null,
        int closeWinTime = 0 /*秒*/,
        bool isCloseCallCancelHandler = true,
        bool clearColor=false,
        checkCloseHandle checkCloseHandle=null,bool isAutoClose = true,/*倒计时是自动关闭*/
        bool pShowNotTipToggle = false,              //不再提醒Toggle      
        Action<bool> pNotTipCallBack = null

        )
    {
        GameObject ui = UIModuleManager.Instance.OpenFunModule(NAME_WindowPrefab, UILayerType.Dialogue, true, false);

        if (string.IsNullOrEmpty(title))
        {
            title = "提示";
        }

        if (string.IsNullOrEmpty(okLabelStr))
        {
            okLabelStr = "确定";
        }

        if (string.IsNullOrEmpty(cancelLabelStr))
        {
            cancelLabelStr = "取消";
        }

        if (ui == null)
        {
            BuiltInDialogueViewController.OpenView(msg,
                onHandler, cancelHandler, UIWidget.Pivot.Center, okLabelStr, cancelLabelStr);
            return;
        }

        var controller = ui.GetMissingComponent<WindowPrefabController>();
        if (checkCloseHandle == null)
        {
            controller.OpenConfirmWindow(msg, title, onHandler, cancelHandler, pivot, okLabelStr, cancelLabelStr,
                closeWinTime, isCloseCallCancelHandler, clearColor, isAutoClose, pShowNotTipToggle, pNotTipCallBack);
        }
        else
        {
            controller.OpenWithCheckCallback(msg, title, onHandler, cancelHandler, pivot, okLabelStr, cancelLabelStr,
                checkCloseHandle, isCloseCallCancelHandler, clearColor, true, pShowNotTipToggle, pNotTipCallBack);
        }
    }
    #endregion

    #region 无边框确认框

    public static void OpenSimpleConfirmWindow(string msg,
        Action onHandler = null,
        Action cancelHandler = null,
        UIWidget.Pivot pivot = UIWidget.Pivot.Left,
        string okLabelStr = null, string cancelLabelStr = null, int closeWinTime = 0 /*秒*/,
        UILayerType layer = UILayerType.Dialogue, bool closeWinTimeForOk = false)
    {
        GameObject ui = UIModuleManager.Instance.OpenFunModule(SIMPLE_NAME_WindowPrefab, layer, true, false);

        if (string.IsNullOrEmpty(okLabelStr))
        {
            okLabelStr = "确定";
        }

        if (string.IsNullOrEmpty(cancelLabelStr))
        {
            cancelLabelStr = "取消";
        }

        var controller = ui.GetMissingComponent<SimpleWindowPrefabController>();
        controller.OpenConfirmWindow(msg, onHandler, cancelHandler, pivot, okLabelStr, cancelLabelStr, closeWinTime, closeWinTimeForOk);
    }

    #endregion

    #region 单个按钮,带边框提示框

    public static void OpenMessageWindow(string msg,
        string title = "",
        Action onHandler = null,
        UIWidget.Pivot pivot = UIWidget.Pivot.Left,
        string okLabelStr = null,
        UILayerType layer = UILayerType.Dialogue, bool justClose = false)
    {
        string prefabName = NAME_WindowPrefab;
        if (layer == UILayerType.TopDialogue)
        {
            prefabName = NAME_WindowPrefabForTop;
        }

        GameObject ui = UIModuleManager.Instance.OpenFunModule(prefabName, layer, true, false);

        if (string.IsNullOrEmpty(title))
        {
            title = "提示";
        }

        if (string.IsNullOrEmpty(okLabelStr))
        {
            okLabelStr = "确定";
        }

        var controller = ui.GetMissingComponent<WindowPrefabController>();
        controller.OpenMessageWindow(msg, title, onHandler, pivot, okLabelStr, justClose,
            layer == UILayerType.TopDialogue);
    }

    #endregion

    #region 无边框提示框

    public static void OpenSimpleMessageWindow(string msg,
        Action onHandler = null,
        UIWidget.Pivot pivot = UIWidget.Pivot.Left,
        string okLabelStr = null,
        UILayerType layer = UILayerType.Dialogue)
    {
        string prefabName = SIMPLE_NAME_WindowPrefab;
        if (layer == UILayerType.TopDialogue)
        {
            prefabName = SIMPLE_NAME_WindowPrefabForTop;
        }

        if (string.IsNullOrEmpty(okLabelStr))
        {
            okLabelStr = "确定";
        }

        GameObject ui = UIModuleManager.Instance.OpenFunModule(prefabName, layer, true, false);

        if (ui == null)
        {
            BuiltInDialogueViewController.OpenView(msg,
                onHandler, null, UIWidget.Pivot.Center, okLabelStr);
            return;
        }

        var controller = ui.GetMissingComponent<SimpleWindowPrefabController>();
        controller.OpenMessageWindow(msg, onHandler, pivot, okLabelStr, layer == UILayerType.TopDialogue);
    }

    #region 输入框

    public static void OpenInputWindow(int minChar = 0,
        int maxChar = 0,
        string title = "",
        string desContent = "",
        string inputTips = "",
        string inputVlaue = "",
        Action<string> onHandler = null,
        Action cancelHandler = null,
        UIWidget.Pivot pivot = UIWidget.Pivot.Left,
        string okLabelStr = "确定", string cancelLabelStr = "取消", int closeWinTime = 0, UILayerType layer = UILayerType.Dialogue,
        int type = 0)
    {
        GameObject ui = UIModuleManager.Instance.OpenFunModule(INPUT_NAME_WINDOWPREFAB, layer, true, false);

        if (string.IsNullOrEmpty(title))
        {
            title = "系统";
        }

        if (string.IsNullOrEmpty(okLabelStr))
        {
            okLabelStr = "确定";
        }

        if (string.IsNullOrEmpty(cancelLabelStr))
        {
            cancelLabelStr = "取消";
        }

        var controller = ui.GetMissingComponent<WindowInputPrefabController>();
        controller.OpenInputWindow(minChar, maxChar, title, desContent, inputTips, inputVlaue, onHandler, cancelHandler,
            pivot, okLabelStr, cancelLabelStr, closeWinTime, type);

    }

    #endregion

    #region 带不再提示框的确认框

    public static void OpenOptSaveWindow(string msg,
        string title = "",
        Action<bool> onHandler = null,
        Action<bool> cancelHandler = null,
        UIWidget.Pivot pivot = UIWidget.Pivot.Left,
        string okLabelStr = null, string cancelLabelStr = null, string toggleStr = null,
        int closeWinTime = 0 /*秒*/, UILayerType layer = UILayerType.Dialogue, bool isCloseCallCancelHandler = true)
    {
        GameObject ui = UIModuleManager.Instance.OpenFunModule(NAME_WindowOptSavePrefab, layer, true, false);

        if (string.IsNullOrEmpty(title))
        {
            title = "提示";
        }

        if (string.IsNullOrEmpty(okLabelStr))
        {
            okLabelStr = "确定";
        }

        if (string.IsNullOrEmpty(cancelLabelStr))
        {
            cancelLabelStr = "取消";
        }

        if (string.IsNullOrEmpty(toggleStr)) {
            toggleStr = "不再提示";
        }

        var controller = ui.GetMissingComponent<WindowOptSavePrefabController>();
        controller.OpenOptSaveWindow(msg, title, onHandler, cancelHandler, pivot, okLabelStr, cancelLabelStr, toggleStr,
            closeWinTime, isCloseCallCancelHandler);
    }

    #endregion


    #region 排队窗口

    public static QueueWindowPrefabController OpenQueueWindow(string serverName, int queuePosition, int waitTime,
        UILayerType layer = UILayerType.Dialogue, System.Action onHandler = null)
    {
        GameObject ui = UIModuleManager.Instance.OpenFunModule(QueueWindowPrefabPath, layer, true, false);
        var controller = ui.GetMissingComponent<QueueWindowPrefabController>();
        controller.Open(serverName, queuePosition, waitTime);
        return controller;
    }

    #endregion

    #region 求婚窗口
    //xxj begin
    //public static void OpenMarryWindow(MarryDto dto, UILayerType layer = UILayerType.ThreeModule, System.Action onHandler = null)
    //{
    //    GameObject ui = UIModuleManager.Instance.OpenFunModule(MarryWindowPrefabPath, layer, true, false);
    //    var controller = ui.GetMissingComponent<MarryWindowPrefabController>();
    //    controller.Open(dto);
    //    //        return controller;
    //}
    //xxj end
    #endregion

    #region 离婚
    public static void OpenDivorceWindow(string msg,
        string title = "",
        Action onHandler = null,
        Action cancelHandler = null,
        UIWidget.Pivot pivot = UIWidget.Pivot.Left,
        string okLabelStr = null, string cancelLabelStr = null, int closeWinTime = 0 /*秒*/,
        UILayerType layer = UILayerType.Dialogue, bool isCloseCallCancelHandler = true)
    {
        GameObject ui = UIModuleManager.Instance.OpenFunModule(DivorceWindowPrefabPath, layer, true, false);

        if (string.IsNullOrEmpty(title))
        {
            title = "提示";
        }

        if (string.IsNullOrEmpty(okLabelStr))
        {
            okLabelStr = "确定";
        }

        if (string.IsNullOrEmpty(cancelLabelStr))
        {
            cancelLabelStr = "取消";
        }

        if (ui == null)
        {
            BuiltInDialogueViewController.OpenView(msg,
                onHandler, cancelHandler, UIWidget.Pivot.Center, okLabelStr, cancelLabelStr);
            return;
        }

        var controller = ui.GetMissingComponent<DivorceWindowPrefabController>();
        controller.OpenConfirmWindow(msg, title, onHandler, cancelHandler, pivot, okLabelStr, cancelLabelStr,
            closeWinTime, isCloseCallCancelHandler);
    }

    #endregion

    //xxj begin
    //public static void OpenRewardWindow(string msg,
    //    string title = "",
    //    Action onHandler = null,
    //    Action cancelHandler = null,
    //    UIWidget.Pivot pivot = UIWidget.Pivot.Left,
    //    string okLabelStr = null,
    //    string cancelLabelStr = null,
    //    int dailyActivityInfoId = -1,
    //    int closeWinTime = 0 /*秒*/,
    //    bool isDelayShow = false, // 是否延迟显示(加载场景时候不显示)
    //    bool isCloseCallCancelHandler = true,
    //    bool clearColor = false,
    //    checkCloseHandle checkCloseHandle = null)
    //{
    //    DailyActivityInfo info = DataCache.getDtoByCls<DailyActivityInfo>(dailyActivityInfoId);
    //    if (info != null)
    //    {
    //        OpenRewardWindow(msg, title, onHandler, cancelHandler, pivot, okLabelStr, cancelLabelStr, info.itemId,
    //            closeWinTime, isCloseCallCancelHandler, clearColor, "活动奖励", checkCloseHandle, isDelayShow);
    //    }
    //    else
    //    {
    //        OpenConfirmWindow(msg, title, onHandler, cancelHandler, pivot, okLabelStr, cancelLabelStr, closeWinTime, isCloseCallCancelHandler, clearColor, checkCloseHandle);
    //    }
    //}
    //xxj end

    //checkCloseHandle 时时检测是否需要关闭确认框
        #region 可显示奖励物品的提示框
    public static void OpenRewardWindow(string msg,
        string title = "",
        Action onHandler = null,
        Action cancelHandler = null,
        UIWidget.Pivot pivot = UIWidget.Pivot.Left,
        string okLabelStr = null,
        string cancelLabelStr = null,
        List<int> rewardList = null, 
        int closeWinTime = 0 /*秒*/,
        bool isCloseCallCancelHandler = true,
        bool clearColor = false,
        string rewardTips = "",
        checkCloseHandle checkCloseHandle = null,
        bool isDelayShow = false)
    {
        if (rewardList == null || rewardList.Count == 0)
        {
            OpenConfirmWindow(msg, title, onHandler, cancelHandler, pivot, okLabelStr, cancelLabelStr, closeWinTime, isCloseCallCancelHandler, clearColor, checkCloseHandle);
        }
        else
        {
            CloseWithRewardWindow();
            GameObject ui = UIModuleManager.Instance.OpenFunModule(NAME_WindowWithRewardPrefab, UILayerType.Dialogue, true, false, isDelayShow);

            if (string.IsNullOrEmpty(title))
            {
                title = "提示";
            }

            if (string.IsNullOrEmpty(okLabelStr))
            {
                okLabelStr = "确定";
            }

            if (string.IsNullOrEmpty(cancelLabelStr))
            {
                cancelLabelStr = "取消";
            }

            if (ui == null)
            {
                BuiltInDialogueViewController.OpenView(msg,
                    onHandler, cancelHandler, UIWidget.Pivot.Center, okLabelStr, cancelLabelStr);
                return;
            }

            var controller = ui.GetMissingComponent<WindowWithRewardPrefabController>();
            if (checkCloseHandle == null)
            {
                controller.OpenWindow(msg, title, onHandler, cancelHandler, pivot, okLabelStr, cancelLabelStr,
                    closeWinTime, isCloseCallCancelHandler, clearColor, rewardList, rewardTips);
            }
            else
            {
                controller.OpenWithCheckCallback(msg, title, onHandler, cancelHandler, pivot, okLabelStr, cancelLabelStr,
                    checkCloseHandle, isCloseCallCancelHandler, clearColor, rewardList, rewardTips);
            }
        }
    }
    #endregion

    /*
    #region 手机号码

    public static void OpenPhoneConfirmWindow(string msg,
        string title = "",
        Action onHandler = null,
        Action cancelHandler = null,
        UIWidget.Pivot pivot = UIWidget.Pivot.Left,
        string okLabelStr = null, string cancelLabelStr = null, int closeWinTime = 0, //秒
        int layer = UILayerType.Dialogue, bool isCloseCallCancelHandler = true)
    {
        GameObject ui = UIModuleManager.Instance.OpenFunModule(PhoneConfirmWindowPrefabPath, layer, true, false);
        if (string.IsNullOrEmpty(title))
        {
            title = "提示";
        }

        if (string.IsNullOrEmpty(okLabelStr))
        {
            okLabelStr = "确定";
        }

        if (string.IsNullOrEmpty(cancelLabelStr))
        {
            cancelLabelStr = "取消";
        }

        if (ui == null)
        {
            BuiltInDialogueViewController.OpenView(msg,
                onHandler, cancelHandler, UIWidget.Pivot.Center, okLabelStr, cancelLabelStr);
            return;
        }

        var controller = ui.GetMissingComponent<PhoneConfirmWindowPrefabController>();
        controller.OpenConfirmWindow(msg, title, onHandler, cancelHandler, pivot, okLabelStr, cancelLabelStr,
            closeWinTime, isCloseCallCancelHandler);
    }

    #endregion
    */

    public static bool IsOpen ()
    {
        return UIModuleManager.Instance.IsModuleCacheContainsModule (NAME_WindowPrefab) || UIModuleManager.Instance.IsModuleCacheContainsModule (SIMPLE_NAME_WindowPrefab)
            || UIModuleManager.Instance.IsModuleCacheContainsModule(NAME_WindowOptSavePrefab ) || UIModuleManager.Instance.IsModuleCacheContainsModule(MarryWindowPrefabPath);
    }
    #endregion

    public static void Close ()
    {
        UIModuleManager.Instance.CloseModule (NAME_WindowPrefab);
    }

    public static void CloseForTop ()
    {
        UIModuleManager.Instance.CloseModule (NAME_WindowPrefabForTop);
    }

    public static void closeInputWin()
    {
        UIModuleManager.Instance.CloseModule (INPUT_NAME_WINDOWPREFAB);
    }

    public static void closeSimpleWin()
    {
        UIModuleManager.Instance.CloseModule (SIMPLE_NAME_WindowPrefab);
    }

    public static void closeSimpleWinForTop()
    {
        UIModuleManager.Instance.CloseModule (SIMPLE_NAME_WindowPrefabForTop);
    }

    public static void closeOptWin()
    {
        UIModuleManager.Instance.CloseModule(NAME_WindowOptSavePrefab);
    }

    public static void CloseQueueWindow()
    {
        UIModuleManager.Instance.CloseModule(QueueWindowPrefabPath);
    }

    public static void CloseMarryWindow()
    {
        UIModuleManager.Instance.CloseModule(MarryWindowPrefabPath);
    }

    public static void ClosePhoneConfirmWindow()
    {
        UIModuleManager.Instance.CloseModule(PhoneConfirmWindowPrefabPath);
    }

    public static void CloseDivorceWindow()
    {
        JSTimer.Instance.CancelCd(DivorceWindowPrefabController.CloseCoolDownTime);
        UIModuleManager.Instance.CloseModule(DivorceWindowPrefabPath);
    }

    public static void CloseWithRewardWindow()
    {
        UIModuleManager.Instance.CloseModule(NAME_WindowWithRewardPrefab);
    }

    public static void OpenNumberConfirmWindow(string pTitleName, string pDecription, string pDetail, Action pCallBack)
    {
        GameObject tGo = UIModuleManager.Instance.OpenFunModule(NumberConfirmView.NAME, UILayerType.Dialogue, true);
        var tController = tGo.GetMissingComponent<NumberConfirmViewController>();
        tController.Open(pTitleName, pDecription, pDetail, pCallBack);
    }

    public static void CloseNumberConfirmWindow()
    {
        UIModuleManager.Instance.CloseModule(NumberConfirmView.NAME);
    }

    //xxj begin
    //public static void OpenSellConfirmWin(List<PackItemDto> batchSelectList, Action yesBtnCallBack, Action noBtnCallBack = null)
    //{
    //    GameObject tGo = UIModuleManager.Instance.OpenFunModule(SellConfirmView.NAME, UILayerType.Dialogue, true);
    //    var tController = tGo.GetMissingComponent<SellConfirmViewController>();
    //    tController.Open(batchSelectList, yesBtnCallBack, noBtnCallBack);
    //}
    //xxj end

    public static void CloseSellConfirmWin()
    {
        UIModuleManager.Instance.CloseModule(SellConfirmView.NAME);
    }
}