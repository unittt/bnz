using System;
using UnityEngine;


/// <summary>
/// 处理 
/// Android jar 热更
/// iOS 框架热更
/// 等问题
/// 调用频繁的，不建议这样子处理，单独分开来写
/// </summary>
public static class FrameworkUpgradeHelper
{
    #region 定义具体的版本号,例如 dataeye 热云
    public const int DATAEYE_VERSION = 25618;
    public const int REYUN_VERSION = 25619;
    //推送系统版本
    public const int NOTIFYCATION_VERSION = 25620;
    //热云ios支付参数
    public const int REYUN_PAY_PARAMS_VERSION = 25621;
    //微信支付框架
    public const int IOS_WX_PAY = 26657;
    //H5Alipay
    public const int H5_ALI_PAY = 26657;

    //广点通,版本调到最高，相当于先不支持ios
    public const int DEMI_REYUN_GDY = 100000;

    #endregion

    #region 接口调用
    public static void Call(Action action)
    {
        try
        {
            action();
        }
        catch (Exception e)
        {
            Debug.Log(e.Message);
        }
    }

    public static void Call(Action action, int version)
    {
        if (IsSupported(version))
        {
            if (Application.platform != RuntimePlatform.Android)
            {
                action();
            }
            else
            {
                Call(action);
            }
        }
    }

    public static T Get<T>(Func<T> func)
    {
        try
        {
            return func();
        }
        catch (Exception e)
        {
            Debug.Log(e.Message);

            return default(T);
        }
    }

    public static T Get<T>(Func<T> func, int version)
    {
        if (IsSupported(version))
        {
            if (Application.platform != RuntimePlatform.Android)
            {
                return func();
            }
            else
            {
                Get(func);
            }
        }
        return default(T);
    }

    public static bool IsSupported(int version)
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
        {
            // 框架版本 >= 业务层保存的框架版本,就执行函数
            return FrameworkVersion.ver >= version;
        }
        else if (Application.platform == RuntimePlatform.Android)
        {
            // 考虑后续添加BundleVersion做对比
            return true;
        }

        return true;
    }
    #endregion
}
