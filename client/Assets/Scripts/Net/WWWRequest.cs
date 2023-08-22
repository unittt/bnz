using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using UnityEngine.Networking;
using LuaInterface;


public class WWWRequest : MonoBehaviour
{
    public static WWWRequest Instance
    {
        private set;
        get;
    }

    public static void CreateInstance()
    {
        if (Instance != null)
        {
            Debug.LogError("WWWRequest.Instance already exist");
            return;
        }

        GameObject go = new GameObject("WWWRequest");
        GameObject.DontDestroyOnLoad(go);
        Instance = go.AddComponent<WWWRequest>();
    }


    public WWW Get(string url, LuaFunction luaCallback)
    {
        WWW www = new WWW(url);
        StartCoroutine(GetTask(www, luaCallback));
        return www;
    }

    private IEnumerator GetTask(WWW www, LuaFunction luaCallback)
    {
        yield return www;

        if (luaCallback != null)
        {
            luaCallback.BeginPCall();
            luaCallback.Push(www);
            luaCallback.PCall();
            luaCallback.EndPCall();
            luaCallback.Dispose();
        }
    }

    public WWW Post(string url, Dictionary<string, string> headers, byte[] data, LuaFunction luaCallback)
    {
        WWW www = new WWW(url, data, headers);
        StartCoroutine(PostTask(www, luaCallback));
        return www;
    }

    public WWW PostBytes(string url, Dictionary<string, string> headers, string param, LuaFunction luaCallback)
    {
        byte[] bytes = Encoding.GetEncoding("UTF-8").GetBytes(param);
        return Post(url, headers, bytes, luaCallback);
    }

    public void PostHttp(string url, string key1, string param1, string key2, string param2, LuaFunction luaCallback)
    {
        WWWForm form = new WWWForm();
        form.AddField(key1, param1);
        form.AddField(key2, param2);
        StartCoroutine(SendPost(url, form));
    }

    private IEnumerator PostTask(WWW www, LuaFunction luaCallback)
    {
        yield return www;

        if (luaCallback != null)
        {
            luaCallback.BeginPCall();
            luaCallback.Push(www);
            luaCallback.PCall();
            luaCallback.EndPCall();
            luaCallback.Dispose();
        }
    }

    IEnumerator SendPost(string url, WWWForm wForm)
    {
        WWW postData = new WWW(url, wForm);
        yield return postData;
        if (postData.error != null)
        {
            GameDebug.Log("111111111 SendPost:" + postData.error);
        }
        else
        {
            GameDebug.Log("222222222 SendPost:" + postData.text);
        }
    }
}

