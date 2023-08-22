// **********************************************************************
// Copyright (c) 2017 cilugame. All rights reserved.
// File     : ChannelPackInfo.cs
// Author   : senkay <senkay@126.com>
// Created  : 7/15/2017 
// Porpuse  : 
// **********************************************************************
//
using System;

public class ChannelPackInfo {

    // 是否自定义公告，如果有， 则读取这个， 如果没有则读取平台默认设置
    public bool useCustomNotice;

    //公告文件名称
    public string noticeFileName;

    //公告版本md5
    public string noticeVersion;

    //支付切换开关
    public bool paySwitch;
}
