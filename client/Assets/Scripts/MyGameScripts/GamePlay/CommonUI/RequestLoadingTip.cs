// **********************************************************************
// Copyright (c) 2013 Baoyugame. All rights reserved.
// File     :  RequestLoadingTip.cs
// Author   : SK
// Created  : 2013/8/29
// Purpose  : 
// **********************************************************************

using System.Collections.Generic;
using UnityEngine;

/// <summary>
///  Request loading tip.
/// Controled by ServiceRequestAction.ServerRequestMask
/// </summary>
public class RequestLoadingTip : MonoBehaviour
{
    private int _loadingCount;
    private GameObject _mGo;

    private List<string> _tipList = new List<string>();

    private RequestLoadingTipPrefab _view;
    // Use this for initialization
    public void InitView()
    {
        _mGo = gameObject;
        _view = new RequestLoadingTipPrefab();
        _view.Setup(_mGo.transform);

        _mGo.SetActive(false);
    }

    public void _Show(string tip, bool showCircle = false, bool boxCollider = false, float autoCloseTime = 0f)
    {
        _loadingCount++;

//		GameDebuger.Log("RequestLoadingTipShow "+tip +" "+_loadingCount);

        _view.LoadingGroup_Transform.gameObject.SetActive(showCircle);
        _view.BlackSprite_BoxCollider.enabled = boxCollider;

        _tipList.Add(tip);

        if (showCircle)
        {
            UpdateTip();
        }
        _mGo.SetActive(true);

        if (autoCloseTime > 0f)
        {
            CancelInvoke("_Reset");
            Invoke("_Reset", autoCloseTime);
        }
    }

    private void UpdateTip()
    {
#if UNITY_EDITOR
        string tips = "";
        tips = string.Join("\n\n", _tipList.ToArray());
        _view.TipLabel_UILabel.text = tips;
#endif
    }

    public void _Stop(string tip)
    {
        _loadingCount--;

        if (_tipList.Contains(tip))
        {
            _tipList.Remove(tip);
        }

        GameDebuger.Log("RequestLoadingTipStop" + " " + _loadingCount);

        if (_loadingCount > 0)
        {
            UpdateTip();
            return;
        }

        _Reset();
    }

    public void _Reset()
    {
        _tipList.Clear();
        _loadingCount = 0;
        _mGo.SetActive(false);
        CancelInvoke("_Reset");
    }

    #region Static Func

    private static RequestLoadingTip _instance;

    public static void Setup()
    {
        //xxj begin
        //GameObject prefab = AssetPipeline.ResourcePoolManager.Instance.LoadUI(RequestLoadingTipPrefab.NAME) as GameObject;
        //xxj end

        GameObject prefab = ResourceManager.Load(RequestLoadingTipPrefab.NAME) as GameObject;
        if (prefab != null)
        {
            //xxj begin
            //GameObject parent = LayerManager.Root.LockScreenPanel.cachedGameObject;
            //xxj end
            GameObject parent = LayerManager.Root.UITipsRoot;
            if (parent == null)
            {
                Debug.LogError("RequestLoadingTip Setup not find parent");
                return;
            }
            GameObject loadingTip = NGUITools.AddChild(parent, prefab);
            loadingTip.GetComponent<UIPanel>().depth = SdkModuleMgr.Instance.SdkTopLayer + 100;
            loadingTip.name = "RequestLoadingTip";
            _instance = loadingTip.GetMissingComponent<RequestLoadingTip>();
            _instance.InitView();
        }
    }

    public static void Show(string tip, bool showCircle = false, bool boxCollider = false, float autoCloseTime = 0f)
    {
        if (_instance != null)
        {
            if (showCircle || boxCollider)
            {
                _instance._Show(tip, showCircle, boxCollider, autoCloseTime);
            }
        }
    }

    public static void Stop(string tip)
    {
        if (_instance != null)
        {
            _instance._Stop(tip);
        }
    }

    public static void Reset()
    {
        if (_instance != null)
        {
            _instance._Reset();
        }
    }

    #endregion
}