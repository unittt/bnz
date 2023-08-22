using System;
//xxj begin
//using AppDto;
//xxj end
using UnityEngine;
using System.Collections.Generic;

public static class GameEvent
{
    #region BuiltInWebView
    public static readonly GameEvents.Event<UniWebViewMessage> BuiltInWebView_OnReceivedMessage = new GameEvents.Event<UniWebViewMessage>("BuiltInWebView_OnReceivedMessage");
    #endregion
}
