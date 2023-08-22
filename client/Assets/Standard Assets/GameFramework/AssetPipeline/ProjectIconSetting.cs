using System;
using LITJson;
using UnityEngine;
using AssetPipeline;

public static class ProjectIconSetting
{
    public const string ConfigPath = "Textures/" + ConfigName + ".bytes";
    public const string ConfigName = "ProjectIconConfig";
    public const string Texture = "/Textures";
    // public const string LogoAutoLocation = "LogoAutoLocation"; //H7未使用

    public const string Key_Banhao = "Banhao";
	public const string Key_FrameworkVersion = "FrameworkVersion";
    public const string Key_ChannelAreaFlag = "ChannelAreaFlag";
    public const string Key_ad_app_id_ios = "ad_app_id_ios";
    public const string Key_ad_activity_id_ios = "ad_activity_id_ios";
    public const string Key_trackingIO_appId = "trackingIO_appId";

    public static string BanhaoData = "";


    public static void Setup()
    {
        LoadSettingData();
    }

    public static void LoadSettingData()
    {
        string json = AssetManager.LoadStreamingAssetsText(ConfigPath);
        JsonData jsonData = JsonMapper.ToObject(json);

        if (jsonData.Keys.Contains(Key_Banhao))
        {
            BanhaoData = jsonData[Key_Banhao].GetString();    
            //Debug.Log("Config Banhao = " + BanhaoData);
        }

        if (jsonData.Keys.Contains(Key_FrameworkVersion))
        {
            int frameworkVersion = (int)jsonData[Key_FrameworkVersion].GetNatural();
            if (frameworkVersion != 0)
            {
                GameSetting.csrooturlid = frameworkVersion;
            }            
            Debug.Log("Config FrameworkVersion = " + GameSetting.csrooturlid);
        }

        if (jsonData.Keys.Contains(Key_ChannelAreaFlag))
        {
            string channelAreaFlag = jsonData[Key_ChannelAreaFlag].GetString();
            SPSDK.ChannelAreaFlag = channelAreaFlag;
            Debug.Log("Config channelAreaFlag = " + channelAreaFlag);
        }

        if (jsonData.Keys.Contains(Key_ad_app_id_ios))
        {
            string ad_app_id_ios = jsonData[Key_ad_app_id_ios].GetString();
            GameSetting.ad_app_id_for_ios = ad_app_id_ios;
            Debug.Log("Config ad_app_id_ios = " + GameSetting.ad_app_id_for_ios);
        }

        if (jsonData.Keys.Contains(Key_ad_activity_id_ios))
        {
            string ad_activity_id_ios = jsonData[Key_ad_activity_id_ios].GetString();
            GameSetting.ad_activity_id_for_ios = ad_activity_id_ios;
            Debug.Log("Config ad_activity_id_ios = " + GameSetting.ad_activity_id_for_ios);
        }

        if (jsonData.Keys.Contains(Key_trackingIO_appId))
        {
            string trackingIO_appId = jsonData[Key_trackingIO_appId].GetString();
            GameSetting.trackingIO_appId = trackingIO_appId;
            Debug.Log("Config trackingIO_appId = " + GameSetting.trackingIO_appId);
        }
        
    }
}