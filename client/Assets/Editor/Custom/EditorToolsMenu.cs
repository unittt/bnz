using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using System.IO;
using AssetPipeline;

public class EditorToolsMenu
{
    [MenuItem("工具/打开AssetDataPath", false, 1)]
    static void OpenAssetDataPath()
    {
        System.Diagnostics.Process.Start (Application.dataPath);
    }
    
    [MenuItem("工具/LuaWrap工具", false, 51)]
    static void ExportLuaWrap()
    {
        ExportWrapWindow.Init();
    }

    [MenuItem("工具/Proto工具", false, 52)]
    public static void OpenProtoTools()
    {
        ProtoToolsWindow.OpenProtoTools();
    }

    [MenuItem("工具/Animator工具", false, 53)]
    public static void OpenAnimatorTools()
    {
        AnimatorToolsWindow.OpenAnimatorTools();
    }

    //[MenuItem("工具/导出Lua接口/导出CustomSetting中的LuaWrap", false, 52)]
    //public static void ExportCustomSettingLuaWrap()
    //{
    //    ToLuaMenu.GenerateClassWraps();
    //}

    [MenuItem("打包/Lua加载模式/Local", false, 11)]
    public static void DisableLuaZipMode()
    {
        EditorPrefs.SetBool("LuaZipMode", false);
    }

    [MenuItem("打包/Lua加载模式/Local", true, 11)]
    public static bool DisableLuaZipModeState()
    {
        return EditorPrefs.GetBool("LuaZipMode", false);
    }

    [MenuItem("打包/Lua加载模式/Zip", false, 12)]
    public static void EnableLuaZipMode()
    {
        EditorPrefs.SetBool("LuaZipMode", true);
    }

    [MenuItem("打包/Lua加载模式/Zip", true, 12)]
    public static bool EnableLuaZipModeState()
    {
        return !EditorPrefs.GetBool("LuaZipMode", false);
    }


    [MenuItem("打包/Res加载模式/EditorLocal", false, 21)]
    public static void EnableResLocalMode()
    {
        EditorPrefs.SetInt("ResLoadMode", (int)AssetManager.LoadMode.EditorLocal);
    }

    [MenuItem("打包/Res加载模式/EditorLocal", true, 21)]
    public static bool CheckResLocalMode()
    {
        return EditorPrefs.GetInt("ResLoadMode", 0) != (int)AssetManager.LoadMode.EditorLocal;
    }

    [MenuItem("打包/Res加载模式/Assetbundle", false, 22)]
    public static void EnableAssetbundle()
    {
        EditorPrefs.SetInt("ResLoadMode", (int)AssetManager.LoadMode.Assetbundle);
    }

    [MenuItem("打包/Res加载模式/Assetbundle", true, 22)]
    public static bool CheckAssetbundle()
    {
        return EditorPrefs.GetInt("ResLoadMode", 0) != (int)AssetManager.LoadMode.Assetbundle;
    }

    [MenuItem("打包/Lua打包工具", false, 51)]
    public static void OpenLuaTools()
    {
        LuaToolsWindow.OpenLuaTools();
    }

    [MenuItem("打包/AssetBundle打包工具", false, 52)]
    public static void ShowAssetBundleBuilder()
    {
        AssetPipeline.AssetBundleBuilder.ShowWindow();
    }

    [MenuItem("打包/发布打包工具", false, 52)]
    public static void ShowPlayerSettingTool()
    {
        PlayerSettingTool.ShowWindow();
    }
#if UNITY_STANDALONE_WIN
    [MenuItem("打包/一键BuildWin", false, 101)]
    public static void BuildWinTest()
    {
        AssetBundleBuilder.BuildWinTest();
    }
#endif

    [MenuItem("检查工具/检查GameObject引用丢失")]
    public static void FindMissScripts()
    {
        FindMissingComponent.FindMissScripts();
    }

    [MenuItem("检查工具/检查StandardShader材质")]
    public static void CheckStandardShader()
    {
        FindStandardShader.CheckStandardShader();
    }

    [MenuItem("检查工具/检查非Ref图集引用")]
    public static void FindNotRefAtlas()
    {
        UIAtlasCheckMenu.FindNotRefAtlas();
    }

    [MenuItem("检查工具/替换选中的UILabel Text样式")]
    public static void LabelStyleUpdate()
    {
        UILabelStyleMenu.LabelStyleUpdate();
    }

    [MenuItem("检查工具/检查缺少的的UIEventHandler")]
    public static void EventHandlerCheck()
    {
        UIEventHandlerCheck.Run();
    }

    [MenuItem("检查工具/去除图片Alpha通道")]
    private static void StripSelectTextureAlpha()
    {
        TextureTools.StripSelectTextureAlpha();
    }

    [MenuItem("检查工具/给所有的panel添加刚体")]
    private static void AllPanelAddRigidbody()
    {
        UIPanelCheckRigidbody.PanelAddRigidbody();
    }

    [MenuItem("检查工具/调整UILabel的FontStyle")]
    private static void AllLabelClearBold()
    {
        UILabelTools.LabelToolsWindow();
    }

    [MenuItem("检查工具/model检测工具")]
    private static void ModelCheck()
    {
        ModelCheckTools.ModelCheckToolsWindow();
    }

    //[MenuItem("检查工具/减少动作文件精度")]
    //private static void ReduceAnimationClip()
    //{
    //    AnimatorTools.ReduceAnimationClip();
    //}
}

