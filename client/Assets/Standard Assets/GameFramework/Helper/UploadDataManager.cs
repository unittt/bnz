using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class UploadDataManager : MonoBehaviour
{

	public static UploadDataManager Instance
	{
		private set;
		get;
	}
	public static void CreateInstance()
	{
		if (Instance != null)
		{
			Debug.LogError("UploadDataManager.Instance already exist");
			return;
		}

		GameObject go = new GameObject("UploadDataManager");
		Instance = go.AddComponent<UploadDataManager>();
	}


	public static string _uploadUrl;

	public static string UploadUrl
	{
		get
		{
			if (_uploadUrl == null)
			{
				_uploadUrl = Application.isEditor ? "http://192.168.8.123:10003/clientdata/" : "http://gn1.demigame.com:10003/clientdata/";
			}
			return _uploadUrl;
		}
	}

	public long patchSize = 0;

	private void Upload(Dictionary<string, string> dict)
	{
		var s = JsonHelper.ToJson(dict);
		var headers = new Dictionary<string, string>();
		headers.Add("Content-Type", "application/x-www-form-urlencoded");
		var www = new WWW(UploadUrl, System.Text.Encoding.UTF8.GetBytes(s), headers);
		Debug.Log("UploadDataManager.Upload:" + dict["logname"] +"\n" + UploadUrl + "\n" + s);
		StartCoroutine(PostTask(www, dict["logname"]));
	}

	private IEnumerator PostTask(WWW www, string logName)
	{
		yield return www;
		Debug.Log("UploadDataManager.PostTask:" + logName + ",result:"+ www.error);
		www.Dispose();

	}

	private  void AddBase(ref Dictionary<string, string> dict)
	{
		dict.Add("content", "json");
		dict.Add("ip", UnityEngine.Network.player.ipAddress);
		dict.Add("device_model", UnityEngine.SystemInfo.deviceModel);
        dict.Add("udid", SystemInfo.deviceUniqueIdentifier);
        dict.Add("os", UnityEngine.SystemInfo.operatingSystem);
		if (SPSDK.GetChannelId() != null)
		{
			dict.Add("app_channel", SPSDK.GetChannelId().ToString());
		}
		else
		{
			dict.Add("app_channel","null");
		}
		if (SPSDK.GetChannelId() != null)
		{
			dict.Add("sub_channel", SPSDK.GetSubChannelId().ToString());
		}
		else
		{
			dict.Add("sub_channel", "null");
		}
		int platid = 3;
		if (UnityEngine.Application.platform == UnityEngine.RuntimePlatform.Android)
			platid = 1;
		else if (UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer)
			platid = 2;
		dict.Add("plat", platid.ToString());
	}

	public void StartGameUpload(string version)
	{
		var dict = new Dictionary<string, string>();
		dict.Add("logname", "StartGame");
		dict.Add("time", DateTime.Now.Ticks.ToString());
		dict.Add("version", version);
		AddBase(ref dict);
		Upload(dict);
	}

	public void StartUpdateUpload(string versionBefore, string versionAfter)
	{
		var dict = new Dictionary<string, string>();
		dict.Add("logname", "UpdateGameStart");
		dict.Add("net", PlatformAPI.getNetworkType());
		dict.Add("version_before", versionBefore);
		dict.Add("version_after", versionAfter);
		patchSize = 0;
		AddBase(ref dict);
		Upload(dict);
	}

	public void EndUpdateUpload(string versionBefore, string versionAfter)
	{
		var dict = new Dictionary<string, string>();
		dict.Add("logname", "UpdateGameEnd");
		dict.Add("net", PlatformAPI.getNetworkType());
		dict.Add("version_before", versionBefore);
		dict.Add("version_after", versionAfter);
		dict.Add("update_package", (patchSize / 1024) + "kb");
		AddBase(ref dict);
		Upload(dict);
	}

}