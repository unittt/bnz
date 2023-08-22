using UnityEngine;
using System.Collections;
using System;

public class BuiltInWebViewController : MonoViewController<BuiltInWebView>
{
    private UniWebView _uniWebView;


    public void Open(string url)
    {
        GameDebuger.Log("GameSpirit URL:" + url);
        _uniWebView = UniWebViewExtHelper.CreateUniWebView(_view.subview_UISprite, url);
        if (_uniWebView != null)
        {
            _uniWebView.OnLoadComplete += uniWebViewCompleteHandler;
            _uniWebView.OnReceivedMessage  += _uniWebView_OnReceivedMessage;
            _uniWebView.zoomEnable = true;
            _uniWebView.SetUseWideViewPort(true);
            _uniWebView.SetUseLoadWithOverviewMode(true);
            _uniWebView.Load();
        }
    }

    void _uniWebView_OnReceivedMessage (UniWebView webView, UniWebViewMessage message)
    {
        GameEventCenter.SendEvent(GameEvent.BuiltInWebView_OnReceivedMessage, message);
    }

    private void uniWebViewCompleteHandler(UniWebView view, bool b, string message)
    {
        if (!b)
        {
            GameDebuger.Log(message);
        }
        if (_uniWebView != null)
        {
            _uniWebView.Show();
        }
    }

    override protected void RegisterEvent()
    {
        EventDelegate.Set(_view.CloseBtn_UIButton.onClick, OnClickCloseButton);
        EventDelegate.Set(_view.RefreshBtn_UIButton.onClick, OnRefreshBtnClick);
        EventDelegate.Set(_view.GoBackBtn_UIButton.onClick, OnGoBackBtnClick);
        EventDelegate.Set(_view.GoForwardBtn_UIButton.onClick, OnGoForwardBtnClick);
    }

    private void OnRefreshBtnClick()
    {
        _uniWebView.Reload();
    }
    private void OnGoBackBtnClick()
    {
        _uniWebView.GoBack();
    }
    private void OnGoForwardBtnClick()
    {
        _uniWebView.GoForward();
    }

    private void OnClickCloseButton()
    {
        ProxyBuiltInWebModule.Close();
    }

    override protected void OnDispose()
    {
        if (_uniWebView != null)
        {
            _uniWebView.OnLoadComplete -= uniWebViewCompleteHandler;
            _uniWebView.OnReceivedMessage  -= _uniWebView_OnReceivedMessage;
        }
        _uniWebView = null;
    }
}
