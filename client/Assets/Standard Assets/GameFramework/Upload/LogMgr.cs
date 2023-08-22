using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using LuaInterface;
using LITJson;

public class LogInfo
{
	public string account;
	public string channel;
	public int pid;
	public int operate;
	public string time;
	public string device;
	public string net;
	public string error;
	public RuntimePlatform platform;
	public string mac;
}


//打点日志管理器
public class LogMgr
{
	//	正式
	private static string url = "http://bsh7d.demigame.com/clientlog";
	//	内开发
	// private static string url = "http://devh7d.demigame.com/clientlog";


	private static float startTick = Time.realtimeSinceStartup;
	private static string beforeVersion = GameVersion.ResVersion;

	public static void SendLog(string jsonData)
	{
#if UNITY_EDITOR
		return;
#endif
		WWW www = new WWW (url, Encoding.UTF8.GetBytes (jsonData));
		Debug.Log ("json:" + jsonData);
	}
		
	public static void SendLog(int operate)
	{
		LogInfo logInfo = new LogInfo ();
		logInfo.account = "";
		logInfo.channel = "";
		logInfo.device = PlatformAPI.GetDeviceName();
		logInfo.error = "";
		logInfo.net = PlatformAPI.getNetworkType();
		logInfo.operate = operate;
		logInfo.pid = 0;
		logInfo.time = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
		logInfo.platform = Application.platform;
		logInfo.mac = PlatformAPI.GetDeviceUID();


		string jsonData = JsonMapper.ToJson(logInfo);
		SendLog (jsonData);

	}

	private static string GetPlatID() {
		string plat = "1";
		#if UNITY_IPHONE || UNITY_IOS
		plat = "2";
		#elif UNITY_STANDALONE
		plat = "3";
		#endif
		return plat;
	}

	//	以下是数据中心日志===================================

	//	启动游戏日志
	public static void StartGameLog() {
#if UNITY_EDITOR
		return;
#endif
		JsonData data = new JsonData ();
		data["logtype"] = "analylog";
		data["analytype"] = "StartGame";
		data["data"] = new JsonData();
		data["data"]["time"] = "";
		data["data"]["ip"] = UnityEngine.Network.player.ipAddress;
		data["data"]["device_model"] = SystemInfo.deviceModel;
		data["data"]["udid"] = PlatformAPI.GetDeviceUID();
		data["data"]["os"] = SystemInfo.operatingSystem;
		data["data"]["app_channel"] = "";
		data["data"]["sub_channel"] = "";
		data["data"]["version"] = GameVersion.ResVersion;
		data["data"]["plat"] = GetPlatID();
		data["data"]["device_id"] = PlatformAPI.GetDeviceId();
		string jsonData = data.ToJson();
		SendLog (jsonData);
	}
	
	//	更新客户端日志
	public static void UpdateGameStartLog(string beforVersion, string afterVersion) {
#if UNITY_EDITOR
		return;
#endif
		startTick = Time.realtimeSinceStartup;
		beforeVersion = GameVersion.ResVersion;

		JsonData data = new JsonData ();
		data["logtype"] = "analylog";
		data["analytype"] = "UpdateGameStart";
		data["data"] = new JsonData();
		data["data"]["time"] = "";
		data["data"]["net"] = PlatformAPI.getNetworkType();
		data["data"]["ip"] = UnityEngine.Network.player.ipAddress;
		data["data"]["device_model"] = SystemInfo.deviceModel;
		data["data"]["udid"] = PlatformAPI.GetDeviceUID();
		data["data"]["os"] = SystemInfo.operatingSystem;
		data["data"]["app_channel"] = "";
		data["data"]["sub_channel"] = "";
		data["data"]["version_before"] = beforVersion;
		data["data"]["version_after"] = afterVersion;
		data["data"]["plat"] = GetPlatID();
		string jsonData = data.ToJson();
		SendLog (jsonData);
	}
	
	//	更新客户端结束日志
	public static void UpdateGameEndLog(string beforVersion, string afterVersion, bool result = true, long packageSize = 0) {
#if UNITY_EDITOR
		return;
#endif
		float duration = Time.realtimeSinceStartup - startTick;
		JsonData data = new JsonData ();
		data["logtype"] = "analylog";
		data["analytype"] = "UpdateGameEnd";
		data["data"] = new JsonData();
		data["data"]["time"] = "";
		data["data"]["update_result"] = result;
		data["data"]["duration"] = duration;
		data["data"]["update_package"] = packageSize;
		data["data"]["net"] = PlatformAPI.getNetworkType();
		data["data"]["ip"] = UnityEngine.Network.player.ipAddress;
		data["data"]["device_model"] = SystemInfo.deviceModel;
		data["data"]["udid"] = PlatformAPI.GetDeviceUID();
		data["data"]["os"] = SystemInfo.operatingSystem;
		data["data"]["app_channel"] = "";
		data["data"]["sub_channel"] = "";
		data["data"]["version_before"] = beforeVersion;
		data["data"]["version_after"] = afterVersion;
		data["data"]["plat"] = GetPlatID();
		string jsonData = data.ToJson();
		SendLog (jsonData);
	}
}

