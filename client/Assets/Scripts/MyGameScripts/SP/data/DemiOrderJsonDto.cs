// **********************************************************************
// Copyright (c) 2017 cilugame. All rights reserved.
// File     : DemiOrderJsonDto.cs
// Author   : senkay <senkay@126.com>
// Created  : 6/8/2017 
// Porpuse  : 
// **********************************************************************
//
using System;
using System.Collections.Generic;

public class DemiOrderJsonDto
{
    public int code;
    public string msg;
    //渠道的额外信息（json格式），每个渠道不一样。不解析直接传递给sdk处理
    public DemiItemJsonDto item;
}

public class DemiItemJsonDto
{
    public string orderId;
}

