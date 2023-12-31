﻿//------------------------------------------------------------------------------
// <auto-generated>
// This code was generated by a tool.
// </auto-generated>
//------------------------------------------------------------------------------
using UnityEngine;
using System.Collections;

/// <summary>
/// Generates a safe wrapper for SdkBaseView.
/// </summary>
public partial class SdkBaseView : BaseView
{
	public const string NAME = "UI/SdkAcccountPrefabs/SdkBaseView.prefab";
	public Transform SmallAreaTrans;
	public Transform BigAreaTrans;
	public Transform SmallAreaHideTrans;
	public Transform BigAreaHideTrans;
	public GameObject OtherGroupGo;
	public GameObject BgBoxCollider;
    public GameObject BgBehindLayerGo;
    public UIPanel BgBehindLayer;
    protected override void InitElementBinding ()
	{
		var root = this.gameObject.transform;
		SmallAreaTrans = root.Find("SmallArea");
		BigAreaTrans = root.Find("BigArea");
		SmallAreaHideTrans = root.Find("SmallArea/HidePos");
		BigAreaHideTrans = root.Find("BigArea/HidePos");
		OtherGroupGo = root.Find("OtherGroup").gameObject;
		BgBoxCollider = root.Find("BgBoxCollider").gameObject;
        BgBehindLayerGo = root.Find("BehindLayer").gameObject;
        if (BgBehindLayerGo != null)
        {
            BgBehindLayer = BgBehindLayerGo.GetComponent<UIPanel>();
        }
    }
}
