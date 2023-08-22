using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using System.IO;
using System.Text;
using SimpleJson;
using System.Diagnostics;
using System.Text.RegularExpressions;
using Debug = UnityEngine.Debug;

public class LuaToolsWindow : EditorWindow
{
    private static readonly string SETTING_FILE = Application.dataPath + "/Editor/setting.json";
    private static readonly string clientProtoPath = Application.dataPath + "/Lua/proto/";
    private static int scriptVersion;

    private static int oldVersion;
    private static int newVersion;

    private static int curVersion;
    private static int patchVersion;

    
    public static void OpenLuaTools()
    {
        LuaToolsWindow window = (LuaToolsWindow)EditorWindow.GetWindow(typeof(LuaToolsWindow));
        window.Show();
    }

    void OnGUI()
    {
        scriptVersion = EditorGUILayout.IntField("版本号", scriptVersion);

        if (GUILayout.Button("打包脚本"))
        {
            //if (scriptVersion == 0)
            //{
            //    Debug.LogError("请输入scriptVersion");
            //    return;
            //}

            BuildLuaScript(scriptVersion);
        }

        GUILayout.Space(40);
        oldVersion = EditorGUILayout.IntField("oldVersion", oldVersion);
        newVersion = EditorGUILayout.IntField("newVersion", newVersion);
        if (GUILayout.Button("制作脚本补丁"))
        {
            //if (oldVersion == 0)
            //{
            //    Debug.LogError("请输入oldVersion");
            //    return;
            //}

            //if (newVersion == 0)
            //{
            //    Debug.LogError("请输入newVersion");
            //    return;
            //}

            if (newVersion <= oldVersion)
            {
                Debug.LogError("错误：newVersion <= oldVersion");
                return;
            }
            MakeScriptPatch(oldVersion, newVersion);
        }

        GUILayout.Space(40);
        curVersion = EditorGUILayout.IntField("curVersion", curVersion);
        patchVersion = EditorGUILayout.IntField("patchVersion", patchVersion);
        if (GUILayout.Button("升级补丁"))
        {
            //if (curVersion == 0)
            //{
            //    Debug.LogError("请输入curVersion");
            //    return;
            //}

            //if (patchVersion == 0)
            //{
            //    Debug.LogError("请输入patchVersion");
            //    return;
            //}

            if (patchVersion <= curVersion)
            {
                Debug.LogError("错误：patchVersion <= curVersion");
                return;
            }
            MergeScriptPatch(curVersion, patchVersion);
        }
    }

    public static void BuildLuaScript(int version)
    {
        string srcDir = Application.dataPath + "/Lua";
        string dstFile = Application.streamingAssetsPath + "/script_" + version;
        string dstDir = Path.GetDirectoryName(dstFile);
        if (!Directory.Exists(dstDir))
        {
            Directory.CreateDirectory(dstDir);
        }

        LuaScript scriptPack = new LuaScript();
        scriptPack.LoadFromDir(srcDir);
        scriptPack.SaveToFile(dstFile, version);
        Debug.Log(string.Format("打包脚本成功 path={0} 版本号={1}", dstFile, version));
    }

    //public static void MakeScriptPatch(int version)
    //{
    //    string srcDir = Application.dataPath + "/Lua";
    //    string dstFile = Application.streamingAssetsPath + "/script_" + version;
    //    string dstDir = Path.GetDirectoryName(dstFile);
    //    if (!Directory.Exists(dstDir))
    //    {
    //        Directory.CreateDirectory(dstDir);
    //    }

    //    LuaScript scriptPack = new LuaScript();
    //    scriptPack.LoadFromDir(srcDir);
    //    scriptPack.SaveToFile(dstFile, version);
    //    Debug.Log(string.Format("打包脚本成功 path={0} 版本号={1}", dstFile, version));
    //}

    public static void MakeScriptPatch(int oldVersion, int newVersion)
    {
        string oldFile = Application.streamingAssetsPath + "/script_" + oldVersion;
        string newFile = Application.streamingAssetsPath + "/script_" + newVersion;

        LuaScript oldZip = new LuaScript();
        oldZip.LoadFrom(oldFile);

        LuaScript newZip = new LuaScript();
        newZip.LoadFrom(newFile);

        string patchFile = Application.streamingAssetsPath + "/patch_" + newVersion;

        LuaScript patchZip = LuaScript.MakePatch(oldZip, newZip);
        patchZip.SaveToFile(patchFile, newVersion);

        Debug.Log(string.Format("MakeScriptPatch Done! path={0} version={1}", patchFile, newVersion));
    }


    public static void MergeScriptPatch(int curVersion, int patchVersion)
    {
        string oldFile = Application.streamingAssetsPath + "/script_" + curVersion;
        string newFile = Application.streamingAssetsPath + "/patch_" + patchVersion;

        LuaScript oldZip = new LuaScript();
        oldZip.LoadFrom(oldFile);

        LuaScript newZip = new LuaScript();
        newZip.LoadFrom(newFile);

        string patchFile = Application.streamingAssetsPath + "/new_script_" + patchVersion;

        oldZip.MergePatch(newZip);

        //LuaScript patchZip = LuaScript.MakePatch(oldZip, newZip);
        oldZip.SaveToFile(patchFile, patchVersion);

        Debug.Log(string.Format("MergeScriptPatch Done! path={0} 版本号={1}", patchFile, patchVersion));
    }



}


