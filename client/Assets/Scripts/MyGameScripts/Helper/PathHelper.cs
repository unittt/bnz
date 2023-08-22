﻿using System;
using AssetPipeline;
using UnityEngine;

public static class PathHelper
{
	//Movie Path
    public const string CG_Asset_PATH = "Movies/xlsj.mp4";

	// SHADOW_PREFAB_PATH
	public const string SHADOW_PREFAB_PATH = "Shadow";
	
	// MISSION ACCEPT \ SUBMIT _PREFAB_PATH
	public const string ACCEPTMISSION_PREFAB_PATH = "acceptSign";
	public const string SUBMITMISSION_PREFAB_PATH = "completeSign";

	//Chest Model Prefab
	public const string Chest_PREFAB_PATH = "chest_2";

    //SedanBox Prefab
    public const string SedanBox_PREFAB_PATH = "chest_1";

    //SedanBox Prefab
    public const string SedanPetBox_PREFAB_PATH = "pet_5709";

    //MarrigeSweetBox Model Prefab
    public const string MarrigeSweetBox_PREFAB_PATH = "chest_5";

    //Portal Model Prefab
    public const string Portal_PREFAB_PATH = "portal";

    //Chest Model Prefab
	public const string WorldBoss_Chest_PREFAB_PATH = "chest_3";
	
	//	Dreamland Chest Model Prefab
	public const string Dreamland_Chest_PREFAB_PATH = "chest_{0}";

    //Chest Model Prefab
    public const string Grass_PREFAB_PATH = "chest_6";

    //Resource Setting Path
    public const string SETTING_PATH = "Setting/";

    public const string Novice_Box_Path = "NoviceBox";

    public const string Revelry_Box_Path = "jinyuanbao_1";

    public const string Ingot_Box_Path = "jinyuanbao";


    public const string Rebirth_Point = "spawnpoint";      //复活点
    public const string SpringFestival_Box_Path = "pet_5722";//新春宝箱





    public static string GetEffectPath (string effectName)
	{
		return effectName;
	}
    private static string _screenshotRoot;

    public static string ScreenshotRoot
    {
        get
        {
            if (String.IsNullOrEmpty(_screenshotRoot))
            {
#if UNITY_EDITOR
                _screenshotRoot = GameResPath.appRoot;
#else
                _screenshotRoot = Application.persistentDataPath;
#endif

            }
            return _screenshotRoot;
        }
    }

    /// <summary>
    /// 兼用处理新旧版本资源Key
    /// </summary>
    /// <param name="prefabName"></param>
    /// <param name="resGroup"></param>
    /// <returns></returns>
    public static string ReplacePrefabName(string prefabName, ResGroup resGroup)
    {
        if (resGroup == ResGroup.Model)
        {
            return prefabName.Replace("_Model", "");
        }
        if (resGroup == ResGroup.Effect)
        {
            return prefabName.Replace("_Effect", "");
        }
        return prefabName;
    }
}
