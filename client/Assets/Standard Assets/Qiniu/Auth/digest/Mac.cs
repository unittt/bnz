﻿using System;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using Qiniu.Conf;
using Qiniu.Util;

namespace Qiniu.Auth.digest
{
    /// <summary>
    ///     七牛消息认证(Message Authentication)
    /// </summary>
    public class Mac
    {
        private string accessKey;

        private byte[] secretKey;

        public Mac()
        {
            accessKey = Config.ACCESS_KEY;
            secretKey = Config.Encoding.GetBytes(Config.SECRET_KEY);
        }

        public Mac(string access, byte[] secretKey)
        {
            accessKey = access;
            this.secretKey = secretKey;
        }

        /// <summary>
        ///     Gets or sets the access key.
        /// </summary>
        /// <value>The access key.</value>
        public string AccessKey
        {
            get { return accessKey; }
            set { accessKey = value; }
        }

        /// <summary>
        ///     Gets the secret key.
        /// </summary>
        /// <value>The secret key.</value>
        public byte[] SecretKey
        {
            get { return secretKey; }
        }

        /// <summary>
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        private string _sign(byte[] data)
        {
            HMACSHA1 hmac = new HMACSHA1(SecretKey);
            byte[] digest = hmac.ComputeHash(data);
            return Base64URLSafe.Encode(digest);
        }

        /// <summary>
        ///     Sign
        /// </summary>
        /// <param name="b"></param>
        /// <returns></returns>
        public string Sign(byte[] b)
        {
            return string.Format("{0}:{1}", accessKey, _sign(b));
        }

        /// <summary>
        ///     SignWithData
        /// </summary>
        /// <param name="b"></param>
        /// <returns></returns>
        public string SignWithData(byte[] b)
        {
            string data = Base64URLSafe.Encode(b);
            return string.Format("{0}:{1}:{2}", accessKey, _sign(Config.Encoding.GetBytes(data)), data);
        }

        /// <summary>
        ///     SignRequest
        /// </summary>
        /// <param name="request"></param>
        /// <param name="body"></param>
        /// <returns></returns>
        public string SignRequest(HttpWebRequest request, byte[] body)
        {
            Uri u = request.Address;
            using (HMACSHA1 hmac = new HMACSHA1(secretKey))
            {
                string pathAndQuery = request.Address.PathAndQuery;
                byte[] pathAndQueryBytes = Config.Encoding.GetBytes(pathAndQuery);
                using (MemoryStream buffer = new MemoryStream())
                {
                    buffer.Write(pathAndQueryBytes, 0, pathAndQueryBytes.Length);
                    buffer.WriteByte((byte) '\n');
                    if (body.Length > 0)
                    {
                        buffer.Write(body, 0, body.Length);
                    }
                    byte[] digest = hmac.ComputeHash(buffer.ToArray());
                    string digestBase64 = Base64URLSafe.Encode(digest);
                    return accessKey + ":" + digestBase64;
                }
            }
        }
    }
}