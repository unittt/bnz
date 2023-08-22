using System;

public class GameConfig
{
    //#region 七牛配置
    //https://portal.qiniu.com/bucket/h7-private
    //七牛访问域名
    public const string QINIU_DOMAIN = "ol6yb4d6h.bkt.clouddn.com";
    //七牛存储空间名
    public const string QINIU_BUCKET = "h7-private";
    //#endregion

//    #region talkingdata配置
//    public const string TALKINGDATA_APPID = "81EE7C4728B348339A51C0277740873D";
//    #endregion

    //#region 百度语音转文字配置
    ////http://yuyin.baidu.com/app
    //public const string BAIDU_VOP_APPID = "8997474";
    //public const string BAIDU_VOP_APIKEY = "GdRqsjLgaOTQ7LQfKONXWOBr";
    //public const string BAIDU_VOP_SECRETKEY = "76f61181d44f7e5351451458729a1f45";
    //#endregion

    #region Crasheye配置
#if UNITY_IPHONE
    public const string CRASHEYE_APPKEY = "f3d4dce0";
#else
    public const string CRASHEYE_APPKEY = "f7024f10";
#endif
    #endregion
}

