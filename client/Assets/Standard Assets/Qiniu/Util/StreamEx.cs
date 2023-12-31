﻿using System.IO;
using Qiniu.Conf;

namespace Qiniu.Util
{
    public static class StreamEx
    {
        /// <summary>
        ///     string To Stream
        /// </summary>
        /// <param name="str"></param>
        /// <returns></returns>
        public static Stream ToStream(string str)
        {
            Stream s = new MemoryStream(Config.Encoding.GetBytes(str));
            return s;
        }

        public static Stream ToStream(byte[] buf, int bufSize)
        {
            Stream s = new MemoryStream(buf, 0, bufSize);
            return s;
        }
    }
}