using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using AssetPipeline;
using LITJson;
using UnityEditor;
using UnityEngine;
public class PlayerSettingTool : EditorWindow
{
    private static PlayerSettingTool instance = null;

    public static void ShowWindow()
    {
        if (instance == null)
        {
            PlayerSettingTool window = (PlayerSettingTool)EditorWindow.GetWindow(typeof(PlayerSettingTool));
            window.minSize = new Vector2(562, 562);
            window.Show();
            PlayerSettingTool.instance = window;
        }
        else
        {
            PlayerSettingTool.instance.Close();
        }
    }

    private void OnEnable()
    {
        PlayerSettingTool.instance = this;

        _enableJSB = HasEnableJSBDefine();
        _useJsz = HasUseJszDefine();
        _minResBuild = IsMinResBuild();
    }

    private void OnDisable()
    {
        PlayerSettingTool.instance = null;
    }

    private GameSettingData _gameSettingData = null;
    private ChannelConfig _channelConfig = null;

    private bool _updateLog = false;
    private bool _developmentBuild = false;
    private bool _minResBuild = false;
    private bool _enableJSB = false;
    private bool _useJsz = false;


    private void GetGameSettingData()
    {
        _gameSettingData = GameSetting.LoadGameSettingData();
        _channelConfig = ChannelConfig.LoadChannelConfig(_gameSettingData.configSuffix);
    }

    private string _lastSelectGameType;
    private int _lastSelectGameTypeIndex = 0;
    private int _lastSelectDomainIndex = 0;
    private int _lastSelectChannelIndex = 0;

    private void SaveGameSettingData()
    {
        if (_gameSettingData != null)
        {
            FileHelper.SaveJsonObj(_gameSettingData, GameSetting.Config_WritePathV2, false);
			//保存一份到streamAsset下
			FileHelper.SaveJsonObj(_gameSettingData, GameSetting.Config_WritePathInAssetV2, false);
        }
        AssetDatabase.Refresh();
    }

    private Vector2 _scrollPos;
    private string _buildToFileName = "";
    private string _buildProjmods = "";

    private void OnGUI()
    {
        if (_gameSettingData == null)
        {
            GetGameSettingData();
        }

        _scrollPos = EditorGUILayout.BeginScrollView(_scrollPos);
        {
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("ProductName ： " + PlayerSettings.productName);
            EditorGUILayout.LabelField("Bundle Identifier ： " + PlayerSettings.bundleIdentifier);
            EditorGUILayout.LabelField("Bundle Version ： " + PlayerSettings.bundleVersion);
#if UNITY_ANDROID
            EditorGUILayout.LabelField("Bundle Version Code： " + PlayerSettings.Android.bundleVersionCode);
#elif UNITY_IPHONE
            EditorGUILayout.LabelField("Bundle Version Code： " + PlayerSettings.iOS.buildNumber);
#endif
            EditorGUILayout.LabelField("HttpRoot： " + _gameSettingData.httpRoot);
            EditorGUILayout.LabelField("TestHttpRoot： " + _gameSettingData.testHttpRoot);
			EditorGUILayout.LabelField("CSRoot： " + _gameSettingData.csRoot);
            EditorGUILayout.LabelField("BuildToFile： " + _buildToFileName);
            EditorGUILayout.LabelField("projmods： " + _buildProjmods);
            EditorGUILayout.Space();

            //GameType选项
            int selectGameTypeIndex = EditorGUILayout.IntPopup("GameType :", _lastSelectGameTypeIndex, _channelConfig._gameTypeValues, _channelConfig._gameTypeKeys);

            if (_lastSelectGameTypeIndex != selectGameTypeIndex)
            {
                _lastSelectGameTypeIndex = selectGameTypeIndex;
                _gameSettingData.gameType = _channelConfig._gameTypeValues[_lastSelectGameTypeIndex];
                GameInfo gameInfo = _channelConfig._gameInfoDic[_gameSettingData.gameType];
                _gameSettingData.gamename = gameInfo.gamename;
                _gameSettingData.configSuffix = gameInfo.configSuffix;
                _channelConfig.LoadSPChannelConfig(_gameSettingData.configSuffix);
            }

            //if (_gameInfoDic.ContainsKey(_gameSettingData.gameType) == false)
            //{
            //    EditorGUILayout.LabelField(string.Format("GameType {0} no support!!!", _gameSettingData.gameType));
            //    EditorGUILayout.EndScrollView();                
            //    return;
            //}

            ////Domain类型选项
            _lastSelectDomainIndex = _channelConfig.UpdateDomainList(_gameSettingData.gameType, _gameSettingData.domainType);
            _lastSelectDomainIndex = EditorGUILayout.IntPopup("DomainType : ", _lastSelectDomainIndex, _channelConfig._domainValues, _channelConfig._domainKeys);

            _gameSettingData.domainType = _channelConfig.GetDomianType(_gameSettingData.gameType, _lastSelectDomainIndex);

            DomainInfo domainInfo = _channelConfig.GetDomainInfo(_gameSettingData.gameType, _gameSettingData.domainType);
            if (domainInfo == null)
            {
                EditorGUILayout.LabelField(string.Format("DomainType {0} no support!!!", _gameSettingData.domainType));
                EditorGUILayout.EndScrollView();
                return;
            }
            _gameSettingData.httpRoot = domainInfo.httproot;
            _gameSettingData.testHttpRoot = domainInfo.testhttproot;
			_gameSettingData.csRoot = domainInfo.csroot;
            _gameSettingData.resdir = domainInfo.resdir;


            _lastSelectChannelIndex = _channelConfig.UpdateSpSdkList(_gameSettingData.domainType, _gameSettingData.channel);
            _lastSelectChannelIndex = EditorGUILayout.IntPopup("Channel : ", _lastSelectChannelIndex, _channelConfig._channelValues, _channelConfig._channelKeys);

            //Platform类型选项
            if (_channelConfig._channelValues[_lastSelectChannelIndex] == "demi")
            {
                _gameSettingData.platformType = (GameSetting.PlatformType)EditorGUILayout.EnumPopup("PlatformType :", _gameSettingData.platformType);
            }
            else
            {
                _gameSettingData.platformType = GameSetting.PlatformType.Win;
            }

            _gameSettingData.updateMode = (GameSetting.UpdateMode)EditorGUILayout.EnumPopup("补丁更新形式 :", _gameSettingData.updateMode);

            //调试选项
            EditorGUILayout.Space();
            //_gameSettingData.checkUpdate = EditorGUILayout.Toggle("检查资源更新 : ", _gameSettingData.checkUpdate);
            //_gameSettingData.showUpdateSetting = EditorGUILayout.Toggle("内开发选择补丁途径 : ", _gameSettingData.showUpdateSetting);
            _gameSettingData.channel = _channelConfig._channelValues[_lastSelectChannelIndex];
            GameInfo gameInfo2 = _channelConfig._gameInfoDic[_gameSettingData.gameType];

            _gameSettingData.gamename = gameInfo2.gamename;
            if (_gameSettingData.updateMode == GameSetting.UpdateMode.NoUpdate)
            {
				if (_gameSettingData.domainType == "release") {
				} else if (_gameSettingData.domainType == "business") {
                    _gameSettingData.gamename = gameInfo2.gamename + "_商务包";
				} else {
                    _gameSettingData.gamename = gameInfo2.gamename + "_不更新";
                }
            }
            else if (_gameSettingData.updateMode == GameSetting.UpdateMode.TestUpdate)
            {
                _gameSettingData.gamename = gameInfo2.gamename + "_开发版";
            }
            else if (_gameSettingData.updateMode == GameSetting.UpdateMode.Update) {
                if (_gameSettingData.domainType == "business") {
                    _gameSettingData.gamename = gameInfo2.gamename + "_商务包";
                }
            }
            
            _gameSettingData.showUpdateLog = EditorGUILayout.Toggle("输出更新日志 : ", _gameSettingData.showUpdateLog);
			_gameSettingData.qrpc = EditorGUILayout.Toggle("是否扫码PC端 : ", _gameSettingData.qrpc);
            _developmentBuild = EditorGUILayout.Toggle("Development Build : ", _developmentBuild);
            //EditorGUILayout.Toggle("MinRes Build : ", _minResBuild);
            //_gameSettingData.logType = (GameSetting.DebugInfoType)EditorGUILayout.EnumPopup("调试信息类型 :", _gameSettingData.logType);

            EditorGUILayout.Space();
            GUI.color = Color.yellow;
            if (GUILayout.Button("保存配置", GUILayout.Height(40)))
            {
                if (!CheckIsCompiling())
                {
                    SaveComeFromConfig();
                }
            }

#if UNITY_ANDROID
            EditorGUILayout.Space();
            if (GUILayout.Button("导出Android Project", GUILayout.Height(40)))
            {
                string outPutPath = EditorUtility.OpenFolderPanel("导出Android工程目录", "", "");
                if (!string.IsNullOrEmpty(outPutPath))
                {
                    EditorHelper.Run(() => ExportAndroidProject(outPutPath), true, false);
                }
            }

            EditorGUILayout.Space();
            if (GUILayout.Button("打包APK", GUILayout.Height(40)))
            {
                if (EditorUtility.DisplayDialog("打包确认", "是否确认打包APK?", "确认打包", "取消"))
                {
                    EditorApplication.delayCall += () => BuildAndroid();
                }
            }
#endif

#if UNITY_IPHONE
			EditorGUILayout.Space ();
			if (GUILayout.Button ("Expor2XCODE", GUILayout.Height (40))) {
				if (EditorUtility.DisplayDialog ("导出确认", "是否确认导出XCODE?", "确认", "取消")) 
				{
                     EditorApplication.delayCall += () =>
                     {
                         string applicationPath = Application.dataPath.Replace("/Assets", "/../..");
                         string target_dir = EditorUtility.OpenFolderPanel("导出目录", applicationPath, "xcode");
                         BuildIOS(target_dir);
                     };
				}
			}

            //EditorGUILayout.Space ();
            //if (GUILayout.Button ("ExportAllIpa", GUILayout.Height (40))) {
            //     EditorApplication.delayCall += () => BuildAllIpa();
            //}
#endif

#if UNITY_STANDALONE_WIN && !UNITY_IPHONE
            EditorGUILayout.Space();
            if (GUILayout.Button("一按键Build Win", GUILayout.Height(40)))
            {
                if (EditorUtility.DisplayDialog("打包确认", "是否确认打包Win版?", "确认打包", "取消"))
                {
                     EditorApplication.delayCall += () => BuildPC();
				}
			}
#endif
            //EditorGUILayout.Space();
            //GUI.color = Color.green;
            //if (GUILayout.Button("清除本地数据和PlayerPrefs", GUILayout.Height(40)))
            //{
            //    EditorApplication.delayCall += () =>
            //    {
            //        Debug.Log("清除本地数据和PlayerPrefs");
            //        PlayerPrefs.DeleteAll();
            //        FileUtil.DeleteFileOrDirectory(Application.persistentDataPath);
            //    };
            //}
            //GUI.color = Color.white;

            //EditorGUILayout.Space();
            //if (GUILayout.Button("复制Dll", GUILayout.Height(40)))
            //{
            //    CopyDll();
            //}

            //EditorGUILayout.Space();
            //if (GUILayout.Button("一键打包", GUILayout.Height(40)))
            //{
            //    OneKeyBuild();
            //}
        }
        EditorGUILayout.EndScrollView();
    }

    private void CopyDll()
    {
        string dllsRoot = null;
        if (EditorUserBuildSettings.activeBuildTarget == BuildTarget.StandaloneWindows)
        {
            dllsRoot = EditorUtility.SaveFolderPanel("选择dll目录", "BuildWin", "");
        }
        else if (EditorUserBuildSettings.activeBuildTarget == BuildTarget.Android)
        {
            dllsRoot = EditorUtility.SaveFolderPanel("选择dll目录", "BuildAPK", "");
        }

        if (string.IsNullOrEmpty(dllsRoot))
        {
            Debug.LogError(string.Format("该路径：{0} 不存在要拷贝的dll！", dllsRoot));

            return;
        }

        string cdnResDir = string.Format("{0}/{1}", AssetBundleBuilder.GetExportPlatformPath(), GameResPath.DLL_FILE_ROOT);
        IOHelper.CopyDirectory(dllsRoot, cdnResDir);
        Debug.Log("UploadDllsPatch Finished");
    }

    //private void OneKeyBuild()
    //{
    //        EditorApplication.delayCall += () =>
    //        {
    //            bool useCodeMove = EditorUtility.DisplayDialog("提示", "是否移除JSB或业务代码", "移除", "不移除");
    //#if UNITY_IPHONE
    //            string applicationPath = Application.dataPath.Replace("/Assets", "/../..");
    //            string target_dir = EditorUtility.OpenFolderPanel("导出目录", applicationPath, "xcode");
    //            JsExternalTools.OneKeyBuildAll(true, true);
    //            if(useCodeMove)
    //                CodeManagerTool.moveUnUsedMonoCode(true);
    //#endif
    //#if UNITY_ANDROID 
    //            if(useCodeMove)
    //                CodeManagerTool.moveJSBFramework(true);
    //#endif
    //            AssetBundleBuilder.ShowWindow();
    //            AssetBundleBuilder.Instance._slientMode = true;
    //            AssetBundleBuilder.Instance.UpdateAllBundleName();
    //            if (AssetBundleBuilder._curResConfig == null)
    //            {
    //                throw new SystemException("AssetBundleBuilder._curResConfig == null");
    //            }
    //            AssetBundleBuilder.Instance.BuildAll(AssetBundleBuilder._curResConfig.Version, true);
    //            AssetBundleBuilder.ShowWindow();

    //#if UNITY_IPHONE
    //            BuildIOS(target_dir, true);
    //#endif
    //#if UNITY_STANDALONE_WIN && !UNITY_IPHONE
    //            BuildPC(true);
    //#endif
    //#if UNITY_ANDROID
    //            BuildAndroid(true);
    //#endif

    //        };
    //}

    private void BuildIOS(string target_dir, bool cmd = false)
    {
        if (string.IsNullOrEmpty(target_dir))
        {
            return;
        }

		string target_name = string.Format("{0}_{1}_{2}", _gameSettingData.gameType, GameVersion.LocalAppVersion, _gameSettingData.domainType.ToString());

        if (!Directory.Exists(target_dir))
        {
            Directory.CreateDirectory(target_dir);
        }

        string fullPath = target_dir + "/" + target_name;

        Debug.Log(target_dir + "/" + target_name);

        if (cmd || EditorUtility.DisplayDialog("导出确认", string.Format("是否确认导出 {0}?", fullPath), "确认", "取消"))
        {
            //var ipaFlag = cmd ? true : EditorUtility.DisplayDialog("导出ipa", "是否导出ipa？", "确认", "取消");
            var buildoption = BuildOptions.ShowBuiltPlayer;
            if (_developmentBuild)
            {
                buildoption = buildoption | BuildOptions.AllowDebugging | BuildOptions.ConnectWithProfiler |
                              BuildOptions.Development;
            }
            string res = BuildPipeline.BuildPlayer(FindEnabledEditorScenes(), target_dir + "/" + target_name, BuildTarget.iOS, buildoption);
            if (res.Length > 0)
            {
                throw new Exception("BuildPlayer failure: " + res);
            }
            //if (ipaFlag)
            //{
                //XCodeToIpaPostProcess.OnPostProcessBuild(BuildTarget.iOS, target_dir + "/" + target_name);
            //}
        }
    }

    public static void BuildPCDLL(bool cmd = false)
    {
        string outputPath = string.Format("BuildDLL/{0}/dhxx.exe", PlayerSettings.bundleVersion);
        string outputDir = Path.GetDirectoryName(outputPath);

        FileHelper.DeleteDirectory(outputDir, true);
        FileHelper.CreateDirectory(outputDir);
        var buildoption = BuildOptions.ShowBuiltPlayer;
        string res = BuildPipeline.BuildPlayer(FindEnabledEditorScenes(), outputPath, BuildTarget.StandaloneWindows, buildoption);
        if (res.Length > 0)
        {
            throw new Exception("BuildPlayer failure: " + res);
        }

        CommonPostProcessBuild.GenerateWinDll(outputPath);

        string cdnResDir = string.Format("{0}/{1}", AssetBundleBuilder.GetExportPlatformPath(), GameResPath.DLL_FILE_ROOT);
        IOHelper.CopyDirectory(outputDir + "_Dll", cdnResDir);
        Debug.Log("复制Dll补丁文件 -> " + cdnResDir);

    }

    private void BuildPC(bool cmd = false)
    {
        var exportExe = cmd ? true : EditorUtility.DisplayDialog("导出确认", "是否导出exe", "确认", "取消");
        if (!CheckIsCompiling())
        {
            SaveComeFromConfig();
        }

		string app_name = string.Format("{0}_{1}_{2}", _gameSettingData.gameType, PlayerSettings.bundleVersion, _gameSettingData.channel);
        string outputPath = string.Format("BuildWin/{0}/dhxx.exe", app_name);
        string outputDir = Path.GetDirectoryName(outputPath);

        FileHelper.DeleteDirectory(outputDir, true);
        FileHelper.CreateDirectory(outputDir);
        var buildoption = BuildOptions.ShowBuiltPlayer;
        if (_developmentBuild)
        {
            buildoption = buildoption | BuildOptions.AllowDebugging | BuildOptions.ConnectWithProfiler |
                          BuildOptions.Development;
        }
        string res = BuildPipeline.BuildPlayer(FindEnabledEditorScenes(), outputPath, BuildTarget.StandaloneWindows, buildoption);
        if (res.Length > 0)
        {
            throw new Exception("BuildPlayer failure: " + res);
        }

        CommonPostProcessBuild.GenerateWinDll(outputPath);
        if (exportExe)
        {
            CommonPostProcessBuild.GenerateWinExe(BuildTarget.StandaloneWindows, outputPath);
        }
    }

    private void BuildAndroid(bool cmd = false)
    {
        if (!CheckIsCompiling())
        {
            //var isExportDll = cmd ? true : EditorUtility.DisplayDialog("导出dll", "是否需要对dll处理？", "确认", "取消");
            var isExportDll = true;
            SaveComeFromConfig();
            BulidTargetApk(_gameSettingData.channel, isExportDll);
        }
    }

    public static void BuildAndroidDLL(bool cmd = false)
    {
        PlayerSettings.Android.keystoreName = "PublishKey/nucleus.keystore";
        PlayerSettings.keystorePass = "nucleus123";
        PlayerSettings.Android.keyaliasName = "nucleus";
        PlayerSettings.Android.keyaliasPass = "nucleus123";


        string channel = "build";
        BuildTarget buildTarget = BuildTarget.Android;


        string target_name = string.Format("BuildDLL/{0}/build.apk", PlayerSettings.bundleVersion);
        string outputDir = Path.GetDirectoryName(target_name);


        FileHelper.DeleteDirectory(outputDir, true);
        FileHelper.CreateDirectory(outputDir);


        string[] scenes = FindEnabledEditorScenes();

        //开始Build场景，等待吧～
        BuildOptions buildOption = BuildOptions.ShowBuiltPlayer;

        EditorUserBuildSettings.SwitchActiveBuildTarget(buildTarget);
        string error = BuildPipeline.BuildPlayer(scenes, target_name, buildTarget, buildOption);

        if (error.Length > 0)
        {
            throw new Exception("BuildPlayer failure: " + error);
        }

        CommonPostProcessBuild.GenerateAndroidDll(target_name);

        string cdnResDir = string.Format("{0}/{1}", AssetBundleBuilder.GetExportPlatformPath(), GameResPath.DLL_FILE_ROOT);
        IOHelper.CopyDirectory(outputDir + "/build_Dll", cdnResDir);
        Debug.Log("复制Dll补丁文件 -> " + cdnResDir);

    }

    private bool CheckIsCompiling()
    {
        if (EditorApplication.isCompiling)
        {

            EditorUtility.DisplayDialog("Tip:",
                "please wait EditorApplication Compiling",
                "OK"
            );
            return true;

        }

        return false;
    }

    //保存渠道配置
    private void SaveComeFromConfig()
    {
        SaveGameSettingData();

        // 保存后做特定的回调
        ProjectCallback.TriggerAfterPlayerSettingToolSave();

        //修改游戏签名
        ChangeKeystorePass();

        //修改版本号
        ChangeBundleVersion();

        //修改游戏IconAndSplash
        //ChangeIconAndSplash();

        //修改游戏标签
        ChangeBundleIdentifier(_gameSettingData.channel);

        //更新打包文件名
        UpdateBuildToFileName();

        //改变需要的宏
        //ChangDefineSymbols(_gameSettingData.channel);

        //修改产品名
        ChangeProductName(_gameSettingData.channel);

        //修改BuildeSettings
        ChangBuildSettings();

        //修改打包projmods
        ChangeProjmods(_gameSettingData.channel);

        // 修改打包SDK版本
        ChangeIOSTargetOSVersion();

    }

    private void ChangeKeystorePass()
    {
#if UNITY_EDITOR && UNITY_ANDROID
        PlayerSettings.Android.keystoreName = "PublishKey/nucleus.keystore";
        PlayerSettings.keystorePass = "nucleus123";

        PlayerSettings.Android.keyaliasName = "nucleus";
        PlayerSettings.Android.keyaliasPass = "nucleus123";
#endif
    }

    private void ChangeBundleVersion()
    {
        PlayerSettings.bundleVersion = GameVersion.LocalAppVersion;
#if UNITY_ANDROID
        PlayerSettings.Android.bundleVersionCode = GameVersion.LocalSvnVersion;
#elif UNITY_IPHONE
        PlayerSettings.iOS.buildNumber = GameVersion.LocalSvnVersion.ToString();
#endif
    }

    private bool IsMinResBuild()
    {
        string configPath = Path.Combine(Application.streamingAssetsPath, GameResPath.MINIRESCONFIG_FILE);
        if (FileHelper.IsExist(configPath))
        {
            return true;
        }
        return false;
    }

    private bool HasEnableJSBDefine()
    {
#if UNITY_IPHONE
        string symbolsDefines = PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.iOS);
        return symbolsDefines.Contains("ENABLE_JSB");
#elif UNITY_ANDROID
        string symbolsDefines = PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android);
        return symbolsDefines.Contains("ENABLE_JSB");
#else
        string symbolsDefines = PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.Standalone);
        return symbolsDefines.Contains("ENABLE_JSB");
#endif
    }

    private bool HasUseJszDefine()
    {
#if UNITY_IPHONE
        string symbolsDefines = PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.iOS);
        return symbolsDefines.Contains("USE_JSZ");
#elif UNITY_ANDROID
        string symbolsDefines = PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android);
        return symbolsDefines.Contains("USE_JSZ");
#else
        string symbolsDefines = PlayerSettings.GetScriptingDefineSymbolsForGroup(BuildTargetGroup.Standalone);
        return symbolsDefines.Contains("USE_JSZ");
#endif
    }

    //    private void ChangDefineSymbols(string channel)
    //    {
    //        List<string> defineSymbolsList = new List<string>();

    //        string defineSymbols = string.Empty;

    //        string spDefineSymbol = GetChannelSymbol(channel);
    //        if (!string.IsNullOrEmpty(spDefineSymbol))
    //        {
    //            defineSymbolsList.Add(spDefineSymbol);
    //        }

    //        if (_enableJSB)
    //        {
    //            defineSymbolsList.Add("ENABLE_JSB");
    //        }

    //        if (_useJsz)
    //        {
    //            defineSymbolsList.Add("USE_JSZ");
    //        }

    //        defineSymbols = string.Join(";", defineSymbolsList.ToArray());

    //#if UNITY_IPHONE
    //        PlayerSettings.SetScriptingDefineSymbolsForGroup (BuildTargetGroup.iOS, defineSymbols);
    //#elif UNITY_ANDROID
    //        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android, defineSymbols);
    //#else
    //        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Standalone, defineSymbols);
    //#endif
    //    }

    private void ChangeProjmods(string channel)
    {
        _buildProjmods = _channelConfig.GetChannelProjmods(channel);
        EditorPrefs.SetString("selectProjmods", _buildProjmods);
    }

    private void ChangeIOSTargetOSVersion()
    {
        //		// 仅针对ios渠道
        //		if (_gameSettingData.platformType != GameSetting.PlatformType.ROOTIOS &&
        //		    _gameSettingData.platformType != GameSetting.PlatformType.IOS)
        //		{
        //			return;
        //		}

        var modFolder = Application.dataPath.Replace("/Assets", "/Mods");
        var modName = _channelConfig.GetChannelProjmods(_gameSettingData.channel);
        var modPath = string.Format("{0}/{1}", modFolder, modName);
        if (string.IsNullOrEmpty(modName) || !File.Exists(modPath))
        {
            return;
        }

        //var mod = new XCMod(modPath);
        //PlayerSettings.iOS.targetOSVersion = mod.IOSTargetOSVersion >= iOSTargetOSVersion.iOS_6_0
        //    ? mod.IOSTargetOSVersion : iOSTargetOSVersion.iOS_6_0;
    }

    private void ChangeProductName(string channel)
    {
        PlayerSettings.companyName = "cilugame";
        //string suffix = GetDomainAliasName(_gameSettingData.domainType);
        PlayerSettings.productName = _gameSettingData.gamename;
    }

    private void ChangeBundleIdentifier(string channel)
    {
        string bundleId = _channelConfig.GetChannelBundleId(channel);
        string bundleIdentifier = "";
        if (bundleId.Contains("{0}"))
        {
            bundleIdentifier = string.Format(bundleId, _gameSettingData.domainType.ToLower());
        }
        else
        {
            bundleIdentifier = bundleId;
        }

//        bundleIdentifier = string.Format("{0}.{1}.{2}", bundleIdentifier, _gameSettingData.domainType.ToLower(), _gameSettingData.updateMode.ToString().ToLower());

        //如果是正式包， 则去掉后面的域定义
		#if UNITY_EDITOR && UNITY_IOS
		bundleIdentifier = bundleIdentifier.Replace(".release", ".apple");
		#else
		bundleIdentifier = bundleIdentifier.Replace(".release", "");
		bundleIdentifier = bundleIdentifier.Replace(".update", "");
		#endif

        PlayerSettings.bundleIdentifier = bundleIdentifier;
    }

    private void UpdateBuildToFileName()
    {
#if UNITY_ANDROID
        _buildToFileName = GetBuildTargetDir() + "/" + GetBuildTargetFileName();
#endif
    }

    private static string IconAndSplashRoot = "Assets/IconAndSplash";

    private void ChangeIconAndSplash()
    {
        //修改默认ICON
        Texture2D defaultIcon = AssetDatabase.LoadMainAssetAtPath(IconAndSplashRoot + "/Icon/Other/icon.png") as Texture2D;
        if (defaultIcon != null)
        {
            PlayerSettings.SetIconsForTargetGroup(BuildTargetGroup.Unknown, new Texture2D[1] { defaultIcon });
        }
        else
        {
            Debug.Log("Set Defaut ICON Error!!!");
        }

#if UNITY_ANDROID
        String iconUrl = IconAndSplashRoot + "/Icon/Android/{0}x{0}.png";
        Texture2D icon_192 = AssetDatabase.LoadMainAssetAtPath(string.Format(iconUrl, 192)) as Texture2D;
        Texture2D icon_144 = AssetDatabase.LoadMainAssetAtPath(string.Format(iconUrl, 144)) as Texture2D;
        Texture2D icon_96 = AssetDatabase.LoadMainAssetAtPath(string.Format(iconUrl, 96)) as Texture2D;
        Texture2D icon_72 = AssetDatabase.LoadMainAssetAtPath(string.Format(iconUrl, 72)) as Texture2D;
        Texture2D icon_48 = AssetDatabase.LoadMainAssetAtPath(string.Format(iconUrl, 48)) as Texture2D;
        Texture2D icon_36 = AssetDatabase.LoadMainAssetAtPath(string.Format(iconUrl, 36)) as Texture2D;

        PlayerSettings.SetIconsForTargetGroup(BuildTargetGroup.Android, new Texture2D[6] {
            icon_192,
            icon_144,
            icon_96,
            icon_72,
            icon_48,
            icon_36
        });
#elif UNITY_IPHONE
		//修改平台ICON
		String iconUrl = IconAndSplashRoot + "/Icon/iOS/{0}x{0}.png";
		Texture2D icon_180 = AssetDatabase.LoadMainAssetAtPath (string.Format (iconUrl, 180)) as Texture2D;
		Texture2D icon_152 = AssetDatabase.LoadMainAssetAtPath (string.Format (iconUrl, 152)) as Texture2D;
		Texture2D icon_144 = AssetDatabase.LoadMainAssetAtPath (string.Format (iconUrl, 144)) as Texture2D;
		Texture2D icon_120 = AssetDatabase.LoadMainAssetAtPath (string.Format (iconUrl, 120)) as Texture2D;
		Texture2D icon_114 = AssetDatabase.LoadMainAssetAtPath (string.Format (iconUrl, 114)) as Texture2D;
		Texture2D icon_76 = AssetDatabase.LoadMainAssetAtPath (string.Format (iconUrl, 76)) as Texture2D;
		Texture2D icon_72 = AssetDatabase.LoadMainAssetAtPath (string.Format (iconUrl, 72)) as Texture2D;
		Texture2D icon_57 = AssetDatabase.LoadMainAssetAtPath (string.Format (iconUrl, 57)) as Texture2D;

		PlayerSettings.SetIconsForTargetGroup (BuildTargetGroup.iOS, new Texture2D[8] {
			icon_180,
			icon_152,
			icon_144,
			icon_120,
			icon_114,
			icon_76,
			icon_72,
			icon_57
		});
#endif

        /*
		 * 
    320x480 pixels for 1–3rd gen devices
    1024x768 for iPad mini/iPad 1st/2nd gen
    2048x1536 for iPad 3th/4th gen
    640x960 for 4th gen iPhone / iPod devices
    640x1136 for 5th gen devices
		 */

        //设置开始界面
        //        if (File.Exists(splashPath))
        //        {
        //            File.Delete(splashPath);
        //        }
        //
        //        File.Copy(platformIconPath + splash, splashPath);
    }

    private void ChangBuildSettings()
    {
        EditorBuildSettingsScene[] original = EditorBuildSettings.scenes;
        EditorBuildSettingsScene[] newSettings = new EditorBuildSettingsScene[original.Length];
        System.Array.Copy(original, newSettings, original.Length);

        //if (_resLoadMode == AssetPipeline.AssetUpdate.LoadMode.EditorLocal)
        //{
        //    foreach (EditorBuildSettingsScene scene in newSettings)
        //    {
        //        scene.enabled = true;
        //    }
        //}
        //else
        //{
        //打包资源模式下，禁用掉所有游戏场景，只保留入口场景
        foreach (EditorBuildSettingsScene scene in newSettings)
        {
            if (scene.path == "Assets/Scenes/main.unity")
            {
                scene.enabled = true;
            }
            else
            {
                scene.enabled = false;
            }
        }
        //}
        EditorBuildSettings.scenes = newSettings;
    }

    #region 批量打包渠道

    /// <summary>
    /// 导出Android工程
    /// </summary>
    public static void ExportAndroidProject(string path)
    {
        if (!Directory.Exists(path))
        {
            throw new Exception("不存在路径：" + path);
        }

        var buildOption = BuildOptions.AcceptExternalModificationsToPlayer |
                          BuildOptions.ShowBuiltPlayer;
        BuildPipeline.BuildPlayer(FindEnabledEditorScenes(), path, BuildTarget.Android,
            buildOption);

    }

    private string GetBuildTargetDir()
    {
        string applicationPath = Application.dataPath.Replace("/Assets", "");
        string target_dir = string.Format(applicationPath + "/BuildAPK/{0}_{1}_{2}", _gameSettingData.gameType.ToString(), PlayerSettings.bundleVersion, GameVersion.LocalSvnVersion);
        return target_dir;
    }

    private string GetBuildTargetFileName()
    {
        string app_name = string.Format("{0}_{1}_{2}_{3}_{4}", _gameSettingData.gameType.ToString(), PlayerSettings.bundleVersion, GameVersion.LocalSvnVersion, _gameSettingData.domainType.ToString(), _gameSettingData.updateMode.ToString().ToLower());

        app_name = app_name.Replace("_Release", "");

        //if (!_gameSettingData.release)
        //{
        //    app_name += "_debug";
        //}

        if (_developmentBuild)
        {
            app_name += "_dev";
        }

        //if (_enableJSB)
        //{
        //    app_name += "_JSB";
        //}

        if (_minResBuild)
        {
            app_name += "_min";
        }

        return app_name + ".apk";
    }

    //这里封装了一个简单的通用方法。
    private void BulidTargetApk(string channel, bool isExportDll)
    {
        BuildTarget buildTarget = BuildTarget.Android;

        string target_dir = GetBuildTargetDir();
        string target_name = GetBuildTargetFileName();

        //if (Directory.Exists(target_dir))
        //{
        //	Directory.Delete(target_dir, true);
        //}
        Debug.Log(target_name);

        ShowNotification(new GUIContent("正在打包:" + target_name));

        //每次build删除之前的残留
        if (Directory.Exists(target_dir))
        {
            if (File.Exists(target_name))
            {
                File.Delete(target_name);
            }
        }
        else
        {
            Directory.CreateDirectory(target_dir);
        }

        string[] scenes = FindEnabledEditorScenes();

        //开始Build场景，等待吧～
        BuildOptions buildOption = BuildOptions.ShowBuiltPlayer;
        if (_developmentBuild)
        {
            buildOption = BuildOptions.ShowBuiltPlayer | BuildOptions.Development | BuildOptions.ConnectWithProfiler;
        }

        GenericBuild(scenes, target_dir + "/" + target_name, buildTarget, buildOption);
        if (isExportDll)
        {
            CommonPostProcessBuild.GenerateAndroidDll(target_dir + "/" + target_name);
        }
    }

    private string GetBuildDateTime()
    {
        DateTime dateTtime = DateTime.UtcNow.ToLocalTime();
        string str = string.Format("{0:D2}{1:D2}{2:D2}_{3:D2}{4:D2}", dateTtime.Year, dateTtime.Month, dateTtime.Day, dateTtime.Hour, dateTtime.Minute);
        return str;
    }

    public static string[] FindEnabledEditorScenes()
    {
        List<string> EditorScenes = new List<string>();
        foreach (EditorBuildSettingsScene scene in EditorBuildSettings.scenes)
        {
            if (!scene.enabled)
                continue;
            EditorScenes.Add(scene.path);
        }
        return EditorScenes.ToArray();
    }

    private void GenericBuild(string[] scenes, string targetPath, BuildTarget build_target, BuildOptions build_options)
    {
        EditorUserBuildSettings.SwitchActiveBuildTarget(build_target);
        string error = BuildPipeline.BuildPlayer(scenes, targetPath, build_target, build_options);

        if (error.Length > 0)
        {
            throw new Exception("BuildPlayer failure: " + error);
        }
    }


    //private void BuildAllIpa()
    //{
    //    if (EditorUtility.DisplayDialog("打包全部Ipa", "先保存到任意一个渠道环境！\n你准备好卡死了么!", "确定", "取消"))
    //    {
    //        string applicationPath = Application.dataPath.Replace("/Assets", "/../..");
    //        string target_dir = EditorUtility.OpenFolderPanel("导出目录", applicationPath, "xcode");
    //        if (string.IsNullOrEmpty(target_dir))
    //        {
    //            return;
    //        }

    //        foreach (var channel in _channelValues)
    //        {
    //            _gameSettingData.channel = channel;
    //            SaveComeFromConfig();

    //            string target_name = string.Format("H1_{0}_{1}_{2}", GameVersion.BundleVersion, _gameSettingData.channel, _gameSettingData.domainType.ToString());

    //            if (!Directory.Exists(target_dir))
    //            {
    //                Directory.CreateDirectory(target_dir);
    //            }

    //            string fullPath = target_dir + "/" + target_name;

    //            Debug.Log(fullPath);

    //            string res = BuildPipeline.BuildPlayer(FindEnabledEditorScenes(), fullPath, BuildTarget.iOS, BuildOptions.ShowBuiltPlayer);
    //            if (res.Length > 0)
    //            {
    //                throw new Exception("BuildPlayer failure: " + res);
    //            }
    //            //				break;
    //        }
    //    }
    //}

    #endregion
}

//打包域信息
public class GameInfo
{
    //游戏ID
    //public string gametype;
    //游戏名
    public string gamename;
    //配置标示识别
    public string configSuffix;
    //打包域信息
    public List<DomainInfo> domains;

    public List<SPChannel> channels;
}

//打包域信息
public class DomainInfo
{
    //域名字,打包放置目录也是它
    public string type;
    //正式域名地址
    public string httproot;
    //测试域名地址
    public string testhttproot;
	//cs服务器地址
	public string csroot;

    //资源加载目录，结合CDN路径使用
    public string resdir;
    //打包识别
    public string bundleId;

	public string bundleName;
}

public class SPChannel
{
    //{"name":"kuaiyong","alias":"快用苹果助手","bundleId":"com.tiancity.xlsj.ky","projmods":"","symbol":""},
    public string name;
    public string alias;
    public string bundleId;
    public string projmods;
    public string symbol;
    //TESTIN  APPSTORE
    public string platforms;
    //Android = 1,ROOTIOS = 2,IOS = 3
    public string domains;
    //LocalDev,内开发    LocalTest,内测试   Release,正式服   BetaTest,永测服    Business,商务服
}