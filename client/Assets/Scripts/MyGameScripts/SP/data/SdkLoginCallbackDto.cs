// **********************************************************************
// Copyright (c) 2016 cilugame. All rights reserved.
// File     : SdkCallbackInfo.cs
// Author   : senkay <senkay@126.com>
// Created  : 7/6/2016 
// Porpuse  : 
// **********************************************************************
//
using System;

public class SdkLoginCallbackDto
{
	public string sessionId;
    //可能是渠道唯一id、代理商唯一id，也可能为空
	public string uid;
    //支付下订单时需要传的参数
    public string payExt;
}