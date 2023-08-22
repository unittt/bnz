﻿// **********************************************************************
// Copyright (c) 2016 Baoyugame. All rights reserved.
// Author : Xianjian
// Created : 9/29/2016 10:20:20 AM
// Desc	: Auto generated by MarsZ. update this if need.
// **********************************************************************

using UnityEngine;
using SdkAccountDto;

 /// <summary>
 /// This is the controller class for module AccountSDKBase, use this to control the ui or view , such as it's init , update or dispose.
 /// @Xianjian in 9/29/2016 10:20:20 AM
 /// </summary>
public class SdkBaseController : MonoViewController<SdkBaseView>
{
    public static SdkBaseController Instance;
    public static void Setup(GameObject module)
    {
        Instance = module.GetMissingComponent<SdkBaseController>();
    }

    public static GameObject SmallAreaGo { get { return Instance.View.SmallAreaTrans.gameObject; } }
    public static GameObject BigAreaGo { get { return Instance.View.BigAreaTrans.gameObject; } }
    public static Vector3 SmallAreaPos { get { return Instance.View.SmallAreaTrans.position; } }
    public static Vector3 SmallAreaHidePos { get { return Instance.View.SmallAreaHideTrans.position; } }
    //用户中心主界面pos
    public static Vector3 BigAreaPos { get { return Instance.View.BigAreaTrans.position; } }
    //用户中心主界面隐藏pos
    public static Vector3 BigAreaHidePos { get { return Instance.View.BigAreaHideTrans.position; } }
    public static GameObject BgColliderGo { get { return Instance.View.BgBoxCollider; } }
    public static GameObject BgBehindLayerGo { get { return Instance.View.BgBehindLayerGo; } }
    public static UIPanel BgBehindLayer { get { return Instance.View.BgBehindLayer; } }

    private SdkToolbarController _barController;
    protected override void InitView()
    {
        //xxj begin
        //初始化工具栏
        //GameObject prefab = AssetPipeline.ResourcePoolManager.Instance.LoadUI(SdkToolbar.NAME);
        //xxj end

        GameObject prefab = ResourceManager.Load(SdkToolbar.NAME) as GameObject;
        prefab.SetActive(true);
        var go = NGUITools.AddChild(View.OtherGroupGo, prefab);
        go.SetActive(true);
        _barController = go.GetMissingComponent<SdkToolbarController>();
        _barController.Open();

        OnAccountReset(null);
    }

    protected override void RegisterEvent()
    {
        SdkAccountModel.Instance.OnAccountReset += OnAccountReset;
    }
    
    protected override void OnDispose()
    {
        SdkAccountModel.Instance.OnAccountReset -= OnAccountReset;
    }

    private void OnAccountReset(AccountDto dto)
    {
        _barController.gameObject.SetActive(dto != null);
    }

     public void ExpandToolBar(System.Action onFinish = null)
     {
         if (!_barController.gameObject.activeSelf)
             return;

         _barController.SetExpand(true, onFinish);
     }
}