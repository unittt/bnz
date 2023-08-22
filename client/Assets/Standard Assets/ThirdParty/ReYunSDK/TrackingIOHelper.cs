using UnityEngine;
using System.Collections;

public class TrackingIOHelper
{
#if UNITY_IOS
    public static string appKey = "t7b7HKsCPgGcdnya";
#elif UNITY_ANDROID
    public static string appKey = "t7b7HKsCPgGcdnya";
#else
    public static string appKey = "";
#endif

#if UNITY_IOS
    public static string appID = "8c802ebe9c807d2b5fff8f369f3eebf3";
#elif UNITY_ANDROID
    public static string appID = "bb5f894b0395b97f2be67b7f31031cbe";
#else
    public static string appID = "";
#endif

    #region 统计启动,结束

    public static void Setup()
    {
        GameDebug.Log("TrackingIOHelper Setup appID:" + appID);
#if !UNITY_EDITOR
        if (string.IsNullOrEmpty(GameSetting.MutilPackageId))
        {
            TrackingIO.Instance.init(appID, GameSetting.Channel + "_" + GameSetting.SubChannel);
        }
        else
        {
            TrackingIO.Instance.init(appID, GameSetting.Channel + "_" + GameSetting.SubChannel + "_" + GameSetting.MutilPackageId);
        }

        //TrackingIO.Instance.setPrintLog(!(GameSetting.DomainName == "release"));
        //TrackingIO.Instance.setPrintLog(true);
#endif
    }

    public static void Dispose()
    {

    }

    #endregion

    /// <summary>
    /// 玩家服务器注册
    /// </summary>
    /// <param name="account">账号ID</param>
    /// 
    public static void Register(string account)
    {
        GameDebug.Log("TrackingIOHelper Register account:" + account);
#if !UNITY_EDITOR
        // 注册并且登录
        TrackingIO.Instance.register(account);
        TrackingIO.Instance.login(account);
#endif
    }

    /// <summary>
    /// 玩家的账号登陆服务器
    /// </summary>
    /// <param name="account">账号</param>
    public static void Login(string account)
    {
        GameDebug.Log("TrackingIOHelper Login account:" + account);
#if !UNITY_EDITOR
        TrackingIO.Instance.login(account);
#endif
    }

    /// <summary>
    /// 玩家开始充值数据
    /// </summary>
    /// <param name="transactionId">交易的流水号</param>
    /// <param name="paymentType">支付类型</param>
    /// <param name="currencyType">货币类型</param>
    /// <param name="currencyAmount">支付的真实货币的金额</param>

    public void SetryzfStart(string transactionId, string ryzfType, string currencyType, float currencyAmount)
    {
#if !UNITY_EDITOR
        TrackingIO.Instance.setryzfStart(transactionId, ryzfType, currencyType, currencyAmount);
#endif
    }

    /// <summary>
    /// 玩家的充值数据
    /// </summary>
    /// <param name="transactionId">交易的流水号</param>
    /// <param name="paymentType">支付类型</param>
    /// <param name="currencyType">货币类型</param>
    /// <param name="currencyAmount">支付的真实货币的金额</param>

    public void Setryzf(string transactionId, string ryzfType, string currencyType, float currencyAmount)
    {
#if !UNITY_EDITOR
        TrackingIO.Instance.setryzf(transactionId, ryzfType, currencyType, currencyAmount);
#endif
    }
}

