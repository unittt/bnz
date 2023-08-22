// **********************************************************************
// Copyright (c) 2017 cilugame. All rights reserved.
// File     : LogoAutoLocation.cs
// Author   : senkay <senkay@126.com>
// Created  : 3/15/2017 
// Porpuse  : 
// **********************************************************************
//
using System;
using UnityEngine;

//logo自动对位，左上，居中等模式
public class LogoAutoLocation : MonoBehaviour
{
    public static int LocationMode = 0; //0 默认居中， 1 左上
    // Use this for initialization
    void Start ()
    {
        UpdateOne ();
    }

    #if UNITY_EDITOR || UNITY_STANDALONE_WIN
    private void Awake()
    {
        UICamera.onScreenResize += UpdateOne;
    }


    private void OnDestroy()
    {
        UICamera.onScreenResize -= UpdateOne;
    }
    #endif


    [ContextMenu("Execute")]
    public void UpdateOne ()
    {
        if (LocationMode == 0)
        {
            UIWidget widget = this.GetComponent<UIWidget>();
            if (widget != null)
            {
                Transform trans = this.transform;

                widget.pivot = UIWidget.Pivot.Center;

                trans.localPosition = new Vector3(0, 120, 0);
            }            
        }        
        else if (LocationMode == 1)
        {
            UIWidget widget = this.GetComponent<UIWidget>();
            if (widget != null)
            {
                Transform trans = this.transform;
                float factor = UIRoot.GetPixelSizeAdjustment(this.gameObject);

                int width = (int)(Screen.width);
                int height = (int)(Screen.height);

                float newX = -width / 2 * factor + 10;
                float newY = height / 2 * factor - 10;

                //Debug.Log(string.Format("factor={0} Screen={1}x{2} pos={3}x{4}", factor, Screen.width, Screen.height, newX, newY));

                widget.pivot = UIWidget.Pivot.TopLeft;

                trans.localPosition = new Vector3(newX, newY, 0);
            }            
        }
    }
}

