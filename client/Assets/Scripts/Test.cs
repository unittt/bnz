using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LuaInterface;
using UnityEngine;
using System.IO;
using DG.Tweening;
using Pathfinding;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class Test : MonoBehaviour
{
    public void Start()
    {

    }

    public void Update()
    {

    }
    GameObject root;
    GameObject a;
    public void OnGUI()
    {
        if (GUI.Button(new Rect(300, 0, 200, 100), "Test 1"))
        {

            LuaFunction func = LuaMain.Instance.luaState.GetFunction("main.Test");
            func.Call();
            func.Dispose();

            //root = GameObject.Find("GameObject");
            //a = GameObject.Find("GameObject/GameObject2");
            //GameObject.Destroy(root);
            //Debug.Log(root);
            //Debug.Log(a);
            //GameObject go = new GameObject("1");
            //for (int i = 0; i < 1000; i++)
            //{

            //    //UIEventHandler.EventType t = UIEventHandler.EventType.Drag;
            //    //int a = (int)t;

            //    GameObject go = GameObject.Instantiate<GameObject>(root);
            //    //go.AddComponent<UIEventTest>();

            //    //MonoBehaviour mono = new MonoBehaviour();
            //    //go.AddComponent<Map2DWalker>();
            //}
        }

        else if (GUI.Button(new Rect(300, 100, 200, 100), "Test 2"))
        {
            LuaFunction func = LuaMain.Instance.luaState.GetFunction("main.Test2");
            func.Call();
            func.Dispose();
        }

        else if (GUI.Button(new Rect(300, 200, 200, 100), "Test 3"))
        {
            LuaFunction func = LuaMain.Instance.luaState.GetFunction("main.Test3");
            func.Call();
            func.Dispose();

        }
    }

    public void DestoryTextureAsset(GameObject go)
    {
        UITexture[] texs = go.transform.GetComponentsInChildren<UITexture>();
        for(int i = 0; i < texs.Length; i++)
        {
            Resources.UnloadAsset(texs[i].mainTexture);
        }
    }
}

