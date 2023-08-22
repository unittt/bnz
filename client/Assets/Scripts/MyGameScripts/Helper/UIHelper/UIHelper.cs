using System;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;
//using AppDto;
using AssetPipeline;

public static class UIHelper
{


    public static void RemoveNGUIEvent(GameObject go)
    {
        UIButton[] buttons = go.GetComponentsInChildren<UIButton>(true);
        buttons.ForEach(item => item.onClick.Clear());

        UIToggle[] toggles = go.GetComponentsInChildren<UIToggle>(true);
        toggles.ForEach(item => item.onChange.Clear());

        //UIEventListener[] eventListeners = go.GetComponentsInChildren<UIEventListener>(true);
        //eventListeners.ForEach(item => item.OnDestroy());

        UISlider[] sliders = go.GetComponentsInChildren<UISlider>(true);
        sliders.ForEach(item => item.onChange.Clear());
    }

    public static int GetMaxDepthWithPanelAndWidget(this GameObject go)
    {
        if (go == null)
        {
            return 0;
        }

        var rootDepth = 0;
        var panel = go.GetComponent<UIPanel>();
        if (panel != null)
        {
            rootDepth = panel.depth;
        }

        List<int> depthList = new List<int>();
        UIPanel[] panels = go.GetComponentsInChildren<UIPanel>(true);
        panels.ForEach(s => depthList.Add(s.depth));

        depthList.Sort();

        var max = depthList[depthList.Count - 1];
        return rootDepth <= max ? max : rootDepth + max;
    }
}

