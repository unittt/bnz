// **********************************************************************
// Copyright (c) 2016 cilugame. All rights reserved.
// File     : SdkCallbackInfo.cs
// Author   : senkay <senkay@126.com>
// Created  : 7/6/2016 
// Porpuse  : 
// **********************************************************************
//
using System;

namespace SdkAccountDto
{
    public class SdkChannelExtInfoDto:ResponseDto
    {
        public SdkChannelExtItem item;
    }

    public class SdkChannelExtItem
    {
        //分区 如"1,2,3"
        public string area;

        //转化过后的渠道编号
        public int channelId;

        //是否关闭登录
        public bool close;

        //公告内容,close=false的情况，也可能存在公告
        public string notice;

        //是否关闭扫码功能
        public bool closeQRCodeScan;
    }
}