using UnityEngine;
using UnityEditor;
using System;
using System.Text;
using System.IO;
using System.Collections;
using LuaInterface;

public class EditorUtil
{
    public static string projectPath
    {
        get;
        private set;
    }

    static EditorUtil()
    {
        string dataPath = Application.dataPath;
        projectPath = dataPath.Substring(0, dataPath.Length - "Assets".Length);
    }

    public static string GetParentFolder(string assetPath)
    {
        if (string.IsNullOrEmpty(assetPath))
        {
            return null;
        }
        string[] names = assetPath.Split(new char[] { '/' }, StringSplitOptions.RemoveEmptyEntries);
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < names.Length - 1; ++i)
        {
            sb.Append(names[i]);
            if (i < names.Length - 2)
            {
                sb.Append("/");
            }
        }
        return sb.ToString();
    }

    public static string GetParentFolder(GameObject gameObject)
    {
        if (gameObject == null)
        {
            return null;
        }
        string assetPath = AssetDatabase.GetAssetPath(gameObject);
        return GetParentFolder(assetPath);
    }

    public static string GetParentFolderName(string assetPath)
    {
        if (string.IsNullOrEmpty(assetPath))
        {
            return null;
        }
        string[] names = assetPath.Split(new char[] { '/' }, StringSplitOptions.RemoveEmptyEntries);
        if (names.Length < 2)
        {
            return null;
        }
        return names[names.Length - 2];
    }

    public static bool IsAssetExist(string assetPath)
    {
        return File.Exists(projectPath + assetPath);
    }

    public static bool IsDirectoryExist(string directoryPath)
    {
        return Directory.Exists(projectPath + directoryPath);
    }

    public static string GetPrefabParentPath(GameObject obj)
    {
        if (PrefabUtility.GetPrefabType(obj) == PrefabType.PrefabInstance)
        {
            UnityEngine.Object parentObj = PrefabUtility.GetPrefabParent(obj);
            string path = AssetDatabase.GetAssetPath(parentObj);
            return path;
        }
        return null;
    }


    public static void RunLuaFunc(string luaFuncName, params object[] args)
    {
        LuaState luaState = new LuaState();
        luaState.OpenLibs(LuaDLL.luaopen_protobuf_c);
        luaState.OpenLibs(LuaDLL.luaopen_lpeg);

        luaState.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
        luaState.OpenLibs(LuaDLL.luaopen_cjson);
        luaState.LuaSetField(-2, "cjson");
        luaState.LuaSetTop(0);
        LuaBinder.Bind(luaState);
        luaState.Start();
        try
        {
            object[] array = luaState.DoFile("main");
            LuaTable luaTable = array[0] as LuaTable;
			LuaFunction init = luaTable["RequireModule"] as LuaFunction;
            init.Call();
            init.Dispose();
            LuaFunction func = luaState.GetFunction(luaFuncName);
            func.Call(args);
            func.Dispose();
        }
        catch (Exception e)
        {
            Debug.Log(e.ToString());
        }
        luaState.Dispose();
    }

}
