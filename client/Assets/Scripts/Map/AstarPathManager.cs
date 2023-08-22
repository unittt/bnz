using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class AstarPathManager
{
    public static readonly int LayerGround = 0;
    public static readonly int LayerSky = 1;

    public static AstarPathManager Instance
    {
        get;
        private set;
    }

    public AstarPath astarPath
    {
        get;
        private set;
    }
    
    public static void CreateInstance()
    {
        if (Instance != null)
        {
            Debug.LogError("AstarPathManager.Instance already exist");
            return;
        }

        Instance = new AstarPathManager();
    }

    public AstarPathManager()
    {
        astarPath = GameObject.FindObjectOfType<AstarPath>();
        if (astarPath == null)
        {
            GameObject go = new GameObject("AstarPath");
            astarPath = go.AddComponent<AstarPath>();
        }
 
        astarPath.heuristic = Heuristic.Manhattan;
        astarPath.logPathResults = PathLog.None;
        astarPath.maxFrameTime = 10;
        astarPath.showGraphs = false;
        astarPath.showNavGraphs = false;
        astarPath.maxFrameTime = 10;
        astarPath.debugMode = GraphDebugMode.Tags;
    }

}
