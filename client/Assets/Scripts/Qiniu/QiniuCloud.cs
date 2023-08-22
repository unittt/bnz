using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using AssetPipeline;
using System.Collections;
using LuaInterface;


public class QiniuCloud
{
    //public static string CLOUD_DOMAIN = null; //"ol6yb4d6h.bkt.clouddn.com";
    //public static string CLOUD_BUCKET = null; //"h7-private";

    public static LuaFunction luaUploadCallback;
    public static LuaFunction luaDownloadCallback;

    private static Queue<KeyValuePair<string, bool>> uploadFinishQueue = new Queue<KeyValuePair<string,bool>>();

    public static void SetAppID(string domain, string bucket)
    {
        //CLOUD_DOMAIN = domain;
        //CLOUD_BUCKET = bucket;
    }

    public static void CallUpdate()
    {
        while(uploadFinishQueue.Count > 0)
        {
            KeyValuePair<string, bool> kv = uploadFinishQueue.Dequeue();
            UploadFinish(kv.Value, kv.Key);
        }
    }

    public static void SetUploadCallback(LuaFunction function)
    {
        if(luaUploadCallback != null)
        {
            luaUploadCallback.Dispose();
        }
        luaUploadCallback = function;
    }

    public static void SetDownloadCallback(LuaFunction function)
    {
        if (luaDownloadCallback != null)
        {
            luaDownloadCallback.Dispose();
        }
        luaDownloadCallback = function;
    }

    public static void UploadFile(string filePath, string key, string mineType = null)
    {
        byte[] data = FileHelper.ReadAllBytes(filePath);
        if (data != null)
        {
            ByteArray byteArray = new ByteArray(data);
            QiNiuSaveFileThreadTask.SaveFileToQiNiu(byteArray, byteArray.Length, GameConfig.QINIU_BUCKET, key, true, mineType, OnUploadFinish);
        }
    }


    private static void OnUploadFinish(bool isSucc, string key)
    {
        uploadFinishQueue.Enqueue(new KeyValuePair<string, bool>(key, isSucc));
    }

    private static void UploadFinish(bool isSucc, string key)
    {
        if (luaUploadCallback != null)
        {
            luaUploadCallback.BeginPCall();
            luaUploadCallback.Push(key);
            luaUploadCallback.Push(isSucc);
            luaUploadCallback.PCall();
            luaUploadCallback.EndPCall();
        }
    }

    public static void DownloadFile(string key)
    {
        //Debug.Log(string.Format("DownloadFile  key={0}", key));
        string url = QiNiuFileExt.GetFileUrl(GameConfig.QINIU_DOMAIN, key);
        AssetUpdate.Instance.LoadFileByWWW(url, www =>
        {
            OnDownloadFinish(key, www);
        },
        error =>
        {
            OnDownloadFinish(key, null);
        }
        );
    }

    private static void OnDownloadFinish(string key, WWW www)
    {
        if (luaDownloadCallback != null)
        {
            luaDownloadCallback.BeginPCall();
            luaDownloadCallback.Push(key);
            luaDownloadCallback.Push(www);
            luaDownloadCallback.PCall();
            luaDownloadCallback.EndPCall();
        }
    }
}


