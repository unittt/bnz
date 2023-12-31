﻿using System;
using System.Text;

namespace Qiniu.Conf
{
    public class Config
    {
        public static string VERSION = "6.1.4";

        public static string USER_AGENT = getUa();

        /// <summary>
        ///     七牛SDK对所有的字节编码采用utf-8形式 .
        /// </summary>
        public static Encoding Encoding = Encoding.UTF8;

        /// <summary>
        ///     初始化七牛帐户、请求地址等信息，不应在客户端调用。
        /// </summary>
        public static void Init()
        {
        }

        private static string getUa()
        {
            return "QiniuCsharp/" + VERSION + " (" + Environment.OSVersion.Version + "; )";
        }

        #region 帐户信息

        /// <summary>
        ///     七牛提供的公钥，用于识别用户
        /// </summary>
        public static string ACCESS_KEY = "s1R8Yi01tcIrLmlnfzS6s3iAZ7fvv1WR4hWzCbNj";
            //"<Please apply your access key>";

        /// <summary>
        ///     七牛提供的秘钥，不要在客户端初始化该变量
        /// </summary>
        public static string SECRET_KEY = "L3oo6GgE1DWOi7TjDEySZDpr3CKooh2cBIU3RLFz";
            //"<Dont send your secret key to anyone>";

        #endregion

        #region 七牛服务器地址

        /// <summary>
        ///     七牛资源管理服务器地址
        /// </summary>
        public static string RS_HOST = "http://rs.Qbox.me";

        /// <summary>
        ///     七牛资源上传服务器地址.
        /// </summary>
        public static string UP_HOST = "http://upload.qiniu.com";

        /// <summary>
        ///     七牛资源列表服务器地址.
        /// </summary>
        public static string RSF_HOST = "http://rsf.Qbox.me";

        public static string PREFETCH_HOST = "http://iovip.qbox.me";

        public static string API_HOST = "http://api.qiniu.com";

        #endregion
    }
}