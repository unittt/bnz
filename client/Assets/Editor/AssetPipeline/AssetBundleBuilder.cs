using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
using YamlDotNet.Serialization;
using LITJson;
using Debug = UnityEngine.Debug;

namespace AssetPipeline
{
    [Flags]
    public enum UpdateBundleFlag
    {
        Everything = -1,
        Nothing = 0,
        UI = 1 << 1,
        Model = 1 << 2,
        Effect = 1 << 3,
        Map2d = 1 << 4,
        Map3d = 1 << 5,
        Audio = 1 << 6,
        Config = 1 << 7,
        Script = 1 << 8,
        Atlas = 1 << 9,
        Font = 1 << 10,
        Texture = 1 << 11,
        Live2d = 1 << 12,
        Material = 1 << 13,
        Spine = 1 << 14,
    }

    /// <summary>
    /// 项目资源导入后处理,自动设置游戏中大部分资源BundleName,对于其依赖资源不做处理
    /// 这样做的好处就是不用每次新增资源时都要手动更新一下所有的BundleName,才能在Editor模式下进行加载
    /// 等到要真正打包的时候在做一次全面的检查操作
    /// </summary>
    //public class GameResPostprocessor : AssetPostprocessor
    //{
    //    private static readonly StringBuilder sb = new StringBuilder();
    //    public static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] moveAssets, string[] movedFromAssetPaths)
    //    {
    //        sb.Length = 0;

    //        UpdateBundleFlag mask = UpdateBundleFlag.Nothing;

    //        foreach (string assetPath in importedAssets)
    //        {
    //            if (assetPath.IsUIRes())
    //            {
    //                mask = mask | UpdateBundleFlag.UI;
    //            }
    //            else if (assetPath.IsAtlasRes())
    //            {
    //                mask = mask | UpdateBundleFlag.Atlas;
    //            }
    //            else if (assetPath.IsFontRes())
    //            {
    //                mask = mask | UpdateBundleFlag.Font;
    //            }
    //            else if (assetPath.IsModelRes())
    //            {
    //                mask = mask | UpdateBundleFlag.Model;
    //            }
    //            else if (assetPath.IsEffectRes())
    //            {
    //                mask = mask | UpdateBundleFlag.Effect;
    //            }
    //            else if (assetPath.IsMap2dRes())
    //            {
    //                mask = mask | UpdateBundleFlag.Map2d;
    //            }
    //            else if (assetPath.IsMap3dRes())
    //            {
    //                mask = mask | UpdateBundleFlag.Map3d;
    //            }
    //            else if (assetPath.IsAudioRes())
    //            {
    //                mask = mask | UpdateBundleFlag.Audio;
    //            }
    //            else if (assetPath.IsTextureRes())
    //            {
    //                mask = mask | UpdateBundleFlag.Texture;
    //            }
    //            else if (assetPath.IsConfigRes())
    //            {
    //                mask = mask | UpdateBundleFlag.Config;
    //            }
    //            else if (assetPath.IsLive2dRes())
    //            {
    //                mask = mask | UpdateBundleFlag.Live2d;
    //            }
    //            else if (assetPath.IsMaterialRes())
    //            {
    //                mask = mask | UpdateBundleFlag.Material;
    //            }
    //        }

    //        var uiCount = (mask & UpdateBundleFlag.UI) != UpdateBundleFlag.UI ? -1 : AssetBundleBuilder.UpdateUI();
    //        var atlasCount = (mask & UpdateBundleFlag.Atlas) != UpdateBundleFlag.Atlas ? -1 : AssetBundleBuilder.UpdateAtlas();
    //        var fontCount = (mask & UpdateBundleFlag.Font) != UpdateBundleFlag.Font ? -1 : AssetBundleBuilder.UpdateFont();
    //        var modelCount = (mask & UpdateBundleFlag.Model) != UpdateBundleFlag.Model ? -1 : AssetBundleBuilder.UpdateModel();
    //        var effCount = (mask & UpdateBundleFlag.Effect) != UpdateBundleFlag.Effect ? -1 : AssetBundleBuilder.UpdateEffect();
    //        var map2dCount = (mask & UpdateBundleFlag.Map2d) != UpdateBundleFlag.Map2d ? -1 : AssetBundleBuilder.UpdateMap2d();
    //        var map3dCount = (mask & UpdateBundleFlag.Map3d) != UpdateBundleFlag.Map3d ? -1 : AssetBundleBuilder.UpdateMap3d();
    //        var audioCount = (mask & UpdateBundleFlag.Audio) != UpdateBundleFlag.Audio ? -1 : AssetBundleBuilder.UpdateAudio();
    //        var textureCount = (mask & UpdateBundleFlag.Texture) != UpdateBundleFlag.Texture ? -1 : AssetBundleBuilder.UpdateTexture();
    //        var configCount = (mask & UpdateBundleFlag.Config) != UpdateBundleFlag.Config ? -1 : AssetBundleBuilder.UpdateConfig();
    //        var live2dCount = (mask & UpdateBundleFlag.Live2d) != UpdateBundleFlag.Live2d ? -1 : AssetBundleBuilder.UpdateLive2d();
    //        var materialCount = (mask & UpdateBundleFlag.Material) != UpdateBundleFlag.Material ? -1 : AssetBundleBuilder.UpdateMaterial();
    //    }
    //}


    public class AssetBundleBuilder : EditorWindow
    {
        public static AssetBundleBuilder Instance;

        //[MenuItem("打包/AssetBundle打包", false, 51)]
        public static void ShowWindow()
        {
            if (Instance == null)
            {
                var window = GetWindow<AssetBundleBuilder>(false, "AssetBundleBuilder", true);
                window.minSize = new Vector2(860f, 660f);
                window.Show();
            }
            else
            {
                Instance.Close();
            }
        }

        private Dictionary<ResGroup, bool> _foldoutDic;
        private static ResConfig _oldResConfig;
        private static ResConfig _curResConfig;
        private static BuildBundleStrategy _buildBundleStrategy;

        private void OnEnable()
        {
            //var st = Stopwatch.StartNew();
            Instance = this;

            _foldoutDic = new Dictionary<ResGroup, bool>();
            var resGroups = Enum.GetValues(typeof(ResGroup));
            foreach (ResGroup flag in resGroups)
            {
                _foldoutDic.Add(flag, EditorPrefs.GetBool("ABFoldOut_" + flag, false));
            }

            var curBuildTarget = EditorUserBuildSettings.activeBuildTarget;
            switch (curBuildTarget)
            {
                case BuildTarget.Android:
                    _selectedCdnPlatformType = CDNPlatformType.Andoird;
                    break;
                case BuildTarget.iOS:
                    _selectedCdnPlatformType = CDNPlatformType.IOS;
                    break;
                default:
                    _selectedCdnPlatformType = CDNPlatformType.Win;
                    break;
            }

            //加载最近一次加载的版本信息
            if (_curResConfig == null)
            {
                string lastResConfigPath = EditorPrefs.GetString("LastResConfigPath", "");
                RefreshResConfigData(LoadResConfig(lastResConfigPath));
            }

            //加载小包资源配置策略
            if (_buildBundleStrategy == null)
            {
                string strategyPath = GetBuildBundleStrategyPath();
                if (File.Exists(strategyPath))
                {
                    _buildBundleStrategy = FileHelper.ReadJsonFile<BuildBundleStrategy>(strategyPath);
                }
                else
                {
                    _buildBundleStrategy = new BuildBundleStrategy();
                }
                RefreshBundleNameData();
            }
            //st.Stop();
            //Debug.LogError(st.ElapsedMilliseconds);
        }

        private void OnDestroy()
        {
            //退出前保存下打包策略配置
            SaveBuildBundleStrategy();

            //保存ResConfigPanel面板操作信息
            if (_foldoutDic != null)
            {
                var resGroups = Enum.GetValues(typeof(ResGroup));
                foreach (ResGroup flag in resGroups)
                {
                    EditorPrefs.SetBool("ABFoldOut_" + flag, _foldoutDic[flag]);
                }
            }

            Instance = null;
        }

        #region Editor UI

        private int _rightTab;
        private static bool _showPrograss = true;
        private bool _slientMode = true;
        private Vector2 _leftContentScroll;
        //标识哪些资源分组需要重新更新BundleName
        private UpdateBundleFlag _updateResGroupMask = UpdateBundleFlag.Everything;

        private void OnGUI()
        {
            EditorGUILayout.Space();
            EditorGUILayout.BeginHorizontal();
            GUILayout.Space(10f);

            EditorGUILayout.BeginVertical(GUILayout.MaxWidth(390f)); //Left Cotent Begin
            _leftContentScroll = EditorGUILayout.BeginScrollView(_leftContentScroll);
            {
                //版本信息
                EditorGUILayout.BeginVertical("HelpBox");
                {
                    EditorGUILayout.BeginHorizontal();
                    GUILayout.Label("版本信息", "BoldLabel");
                    EditorGUILayout.EndHorizontal();
                    EditorGUILayout.Space();

                    EditorGUILayout.BeginHorizontal();
                    {
                        EditorGUILayout.BeginVertical();
                        if (GUILayout.Button("加载Old ResConfig", "LargeButton", GUILayout.Height(40f)))
                        {
                            _oldResConfig = LoadResConfigFilePanel();
                        }
                        GUILayout.Label(GetResConfigInfo(_oldResConfig));
                        EditorGUILayout.EndVertical();

                        EditorGUILayout.BeginVertical();
                        if (GUILayout.Button("加载Cur ResConfig", "LargeButton", GUILayout.Height(40f)))
                        {
                            RefreshResConfigData(LoadResConfigFilePanel(true));
                            _rightTab = 1;
                        }
                        GUILayout.Label(GetResConfigInfo(_curResConfig));
                        EditorGUILayout.EndVertical();
                    }
                    EditorGUILayout.EndHorizontal();
                    EditorGUILayout.Space();
                }
                EditorGUILayout.EndVertical();

                EditorGUILayout.BeginVertical("HelpBox");
                {
                    GUILayout.Label("一键制作补丁", "BoldLabel");

                    _resetAssetbundleName = EditorGUILayout.Toggle("重置所有AssetbundleName", _resetAssetbundleName);
                    _patchOnlyScript = EditorGUILayout.Toggle("只升级Script", _patchOnlyScript);
                    _patchResVersion = EditorGUILayout.IntField("升级ResVersion", _patchResVersion);
                    _patchDllVersion = EditorGUILayout.IntField("升级DllVersion", _patchDllVersion);
                    _svnVersion = EditorGUILayout.IntField("升级SVNVersion", _svnVersion);

                    EditorGUILayout.BeginHorizontal();

                    GUI.color = Color.red;
                    if (GUILayout.Button("制作补丁 ", "LargeButton", GUILayout.Height(40f)))
                    {
                        UpdateVersion();
                    }
                    GUI.color = Color.white;

                    if (GUILayout.Button("制作基础包", "LargeButton", GUILayout.Height(40f)))
                    {
                        MakeBaseVersion();
                    }
                    EditorGUILayout.EndHorizontal();
                    
                    EditorGUILayout.BeginHorizontal();
                    GUI.color = Color.green;
                    if (GUILayout.Button("生成Lua脚本", "LargeButton", GUILayout.Height(40f)))
                    {
                        if (EditorUtility.DisplayDialog("确认", "是否生成Lua脚本并迁移到StreamingAssets", "继续", "取消"))
                        {
                            EditorApplication.delayCall += MakeLuaScript;
                        }
                    }
                    EditorGUILayout.EndHorizontal();


                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.BeginVertical();
                    EditorGUILayout.BeginHorizontal();
                    GUI.color = Color.white;
                    if (GUILayout.Button("生成整包资源+脚本", "LargeButton", GUILayout.Height(30f)))
                    {
                        if (EditorUtility.DisplayDialog("确认", "是否需要把导出资源+脚本迁移到StreamingAssets", "继续", "取消"))
                        {
                            EditorApplication.delayCall += GenerateTotalRes;
                            EditorApplication.delayCall += GeneratePackageScript;
                        }
                    }

					if (GUILayout.Button("迁移整包资源", "LargeButton", GUILayout.Height(30f)))
					{
						if (EditorUtility.DisplayDialog("确认", "是否需要把导出资源迁移到StreamingAssets", "继续", "取消"))
						{
							EditorApplication.delayCall += GenerateTotalRes;
						}
					}
					EditorGUILayout.EndHorizontal();

//					EditorGUILayout.BeginHorizontal();
//                    if (GUILayout.Button("生成小包资源+脚本", "LargeButton", GUILayout.Height(30f)))
//                    {
//                        if (EditorUtility.DisplayDialog("确认", "是否需要把导出资源+脚本迁移到StreamingAssets", "继续", "取消"))
//                        {
//                            EditorApplication.delayCall += GenerateMiniRes;
//                            EditorApplication.delayCall += GeneratePackageScript;
//                        }
//					}
//
//					if (GUILayout.Button("迁移小包资源", "LargeButton", GUILayout.Height(30f)))
//					{
//						if (EditorUtility.DisplayDialog("确认", "是否需要把导出资源迁移到StreamingAssets", "继续", "取消"))
//						{
//							EditorApplication.delayCall += GenerateMiniRes;
//						}
//					}
//					EditorGUILayout.EndHorizontal();
                    EditorGUILayout.EndVertical();

                    GUI.color = Color.green;
                    //if (GUILayout.Button("迁移包内脚本", "LargeButton", GUILayout.Height(62f)))
					if (GUILayout.Button("迁移包内脚本", "LargeButton", GUILayout.Height(30f)))
                    {
                        if (EditorUtility.DisplayDialog("确认", "是否需要把导出脚本迁移到StreamingAssets", "继续", "取消"))
                        {
                            EditorApplication.delayCall += GeneratePackageScript;
                        }
                    }
                    EditorGUILayout.EndHorizontal();
					
                    
                    EditorGUILayout.EndVertical();
                }

                EditorGUILayout.Space();

                //打包选项
                GUI.color = Color.white;
                EditorGUILayout.BeginVertical("HelpBox");
                {
                    GUILayout.Label("打包", "BoldLabel");
                    _updateResGroupMask = (UpdateBundleFlag)EditorGUILayout.EnumMaskField("ResGroup:", _updateResGroupMask);

                    EditorGUILayout.BeginHorizontal();

                    if (GUILayout.Button("更新所有BundleName", "LargeButton", GUILayout.Height(40f)))
                    {
                        if (_updateResGroupMask == UpdateBundleFlag.Nothing) return;

                        if (EditorUtility.DisplayDialog("确认", "是否重新设置所有资源BundleName?", "继续", "取消"))
                        {
                            EditorApplication.delayCall += () =>
                            {
                                UpdateAllBundleName();
                            };
                            _rightTab = 0;
                        }
                    }
                    //EditorGUILayout.Space();

                    if (GUILayout.Button("清空所有BundleName", "LargeButton", GUILayout.Height(40f)))
                    {
                        //int option = EditorUtility.DisplayDialogComplex("确认", "是否清空所有资源BundleName?", "全部清空", "Cancel", "清空未使用的");
                        //if (option != 1)
                        //{
                        EditorApplication.delayCall += () =>
                        {
                            CleanUpBundleName(true);
                        };
                        //}
                    }

                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.Space();

                    if (GUILayout.Button("一键打包资源+脚本", "LargeButton", GUILayout.Height(40f)))
                    {
                        int nextVer = 0;
                        if (_curResConfig == null)
                        {
                            string filePath = EditorUtility.OpenFilePanel("加载版本资源配置信息", GetResConfigRoot(), "json");
                            var match = Regex.Match(filePath, @"resConfig_(\d+)");
                            if (match.Success && match.Groups.Count > 0)
                            {
                                nextVer = int.Parse(match.Groups[1].Value) + 1;
                            }
                        }
                        else
                        {
                            nextVer = _curResConfig.Version + 1;
                        }
                        string tip = nextVer == 0
                            ? "当前版本ResConfig为空,资源版本号将归0,请确认?"
                            : "本次打包资源版本号为:" + nextVer;
                        if (EditorUtility.DisplayDialog("确认", tip, "继续", "取消"))
                        {
                            EditorApplication.delayCall += () =>
                            {
                                BuildAssetBundle(nextVer, _svnVersion);
                                GenerateAndBackupAssetBundle(nextVer, _svnVersion);
                                BuildLuaZip(nextVer);
                            };
                            _rightTab = 1;
                        }
                    }
                    EditorGUILayout.Space();

                    //if (GUILayout.Button("还原当前版本资源到gameres下", "LargeButton", GUILayout.Height(40f)))
                    //{
                    //    if (_curResConfig == null) return;
                    //    if (EditorUtility.DisplayDialog("确认", "是否还原资源版本号为: " + _curResConfig.Version + " 到gameres目录下,\n这将会覆盖打包目录下的manifest文件,请确认?", "继续", "取消"))
                    //    {
                    //        EditorApplication.delayCall += () =>
                    //        {
                    //            RevertBackupToGameRes(_curResConfig);
                    //            GenerateScriptPatch((int)_curResConfig.Version);
                    //            GenerateScriptVersionFile((int)_curResConfig.Version);
                    //        };
                    //    }
                    //}
                }
                EditorGUILayout.EndVertical();

                //生成补丁包选项
                EditorGUILayout.BeginVertical("HelpBox");
                {
                    GUILayout.Label("生成补丁", "BoldLabel");
                    //if (GUILayout.Button("加载所有已生成的所有PatchInfo", "LargeButton", GUILayout.Height(40f)))
                    //{
                    //    LoadAllPatchInfo();
                    //    _rightTab = 2;
                    //}
                    //EditorGUILayout.Space();

                    EditorGUILayout.BeginHorizontal();
                    if (GUILayout.Button("生成OldVer-->CurVer\nPatchInfo", "LargeButton", GUILayout.Height(40f)))
                    {
                        if (_oldResConfig == null)
                        {
                            _oldResConfig = LoadResConfigFilePanel();
                        }

                        GeneratePatchInfo(_oldResConfig, _curResConfig);
                        _rightTab = 2;
                    }

                    if (GUILayout.Button("生成所有版本-->CurVer\nPatchInfo", "LargeButton", GUILayout.Height(40f)))
                    {
                        EditorApplication.delayCall += GenerateAllPatchInfo;
                        _rightTab = 2;
                    }
                    EditorGUILayout.EndHorizontal();
                    EditorGUILayout.Space();

                    if (GUILayout.Button("生成CurVer所有CDN资源+脚本补丁", "LargeButton", GUILayout.Height(40f)))
                    {
                        if (EditorUtility.DisplayDialog("确认", "是否生成当前版本所有CDN资源?", "继续", "取消"))
                        {
                            EditorApplication.delayCall += () =>
                            {
                                GenerateRemoteRes(_curResConfig);
                                GenerateScriptPatch((int)_curResConfig.Version);
                                GenerateScriptVersionFile((int)_curResConfig.Version);
                            };
                        }
                    }
                    EditorGUILayout.Space();
                }
                EditorGUILayout.EndVertical();
                
                EditorGUILayout.EndScrollView();
                EditorGUILayout.EndVertical(); //Left Cotent End

                GUILayout.Space(10f);
                EditorGUILayout.BeginVertical(); //Right Cotent Begin
                {
                    EditorGUILayout.BeginHorizontal();
                    if (GUILayout.Toggle(_rightTab == 0, "BundleNamePanel", "ButtonLeft"))
                        _rightTab = 0;
                    if (GUILayout.Toggle(_rightTab == 1, "ResConfigPanel", "ButtonMid"))
                        _rightTab = 1;
                    if (GUILayout.Toggle(_rightTab == 2, "PatchInfoList", "ButtonMid"))
                        _rightTab = 2;
                    if (GUILayout.Toggle(_rightTab == 3, "MinResList", "ButtonRight"))
                        _rightTab = 3;
                    EditorGUILayout.EndHorizontal();

                    if (_rightTab == 0)
                    {
                        DrawBundleNamePanel();
                    }
                    else if (_rightTab == 1)
                    {
                        DrawResConfigPanel();
                    }
                    else if (_rightTab == 2)
                    {
                        DrawPatchInfoPanel();
                    }
                    else if (_rightTab == 3)
                    {
                        DrawMinResListPanel();
                    }
                }
                EditorGUILayout.EndVertical(); //Right Cotent End

                GUILayout.Space(10f);
                EditorGUILayout.EndHorizontal();
            }
        }

        #endregion

        private bool _patchOnlyScript;
        private bool _resetAssetbundleName = true;
        private int _patchResVersion;
        private int _patchDllVersion;
        private int _svnVersion;

        #region ResConfigPanel

        private string _manifestSearchFilter = "";
        private string _selectedManifestKey;
        private Vector2 _resConfigPanelScroll;
        private Vector2 _resConfigPanelDetailScroll;
        private readonly StringBuilder _bundleManifestInfo = new StringBuilder();
        private static Dictionary<ResGroup, List<string>> _manifestBundleNameGroups; //当前版本资源配置BundleName分组信息

        private static void RefreshResConfigData(ResConfig resConfig)
        {
            _curResConfig = resConfig;
            if (_manifestBundleNameGroups == null)
            {
                _manifestBundleNameGroups = new Dictionary<ResGroup, List<string>>();
                var resGroupEnums = Enum.GetValues(typeof(ResGroup));
                foreach (ResGroup resGroup in resGroupEnums)
                {
                    _manifestBundleNameGroups.Add(resGroup, new List<string>());
                }
            }
            else
            {
                foreach (var resGroupList in _manifestBundleNameGroups.Values)
                {
                    resGroupList.Clear();
                }
            }

            if (_curResConfig != null)
            {
                foreach (var pair in _curResConfig.Manifest)
                {
                    var resGroup = ResConfig.GetResGroupFromBundleName(pair.Key);
                    _manifestBundleNameGroups[resGroup].Add(pair.Key);
                }
            }
        }

        private void DrawResConfigPanel()
        {

            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("打开ResConfig目录", "LargeButton", GUILayout.Height(20f)))
            {
                OpenDirectory(GetResConfigRoot());
            }
            if (GUILayout.Button("打开版本备份目录", "LargeButton", GUILayout.Height(20f)))
            {
                OpenDirectory(GetBackupRoot());
            }
            EditorGUILayout.EndHorizontal();
            // Search field
            GUILayout.BeginHorizontal();
            {
                var after = EditorGUILayout.TextField("", _manifestSearchFilter, "SearchTextField");

                if (GUILayout.Button("", "SearchCancelButton", GUILayout.Width(18f)))
                {
                    after = "";
                    GUIUtility.keyboardControl = 0;
                }

                if (_manifestSearchFilter != null && _manifestSearchFilter != after)
                {
                    _manifestSearchFilter = after;
                }
            }
            GUILayout.EndHorizontal();

            //BundleName列表
            if (_manifestBundleNameGroups != null && _manifestBundleNameGroups.Count > 0)
            {
                var resultDic = new Dictionary<ResGroup, int>(_manifestBundleNameGroups.Count);
                EditorGUILayout.BeginVertical("HelpBox", GUILayout.Height(300f));
                {
                    EditorGUILayout.Space();
                    _resConfigPanelScroll = EditorGUILayout.BeginScrollView(_resConfigPanelScroll);
                    foreach (var pair in _manifestBundleNameGroups)
                    {
                        var resGroup = pair.Key;
                        var buildResList = pair.Value;
                        GUILayout.BeginHorizontal();
                        _foldoutDic[resGroup] = EditorGUILayout.Foldout(_foldoutDic[resGroup], resGroup + " Count: " + buildResList.Count);
                        bool miniRes = IsMiniResType(resGroup);
                        if (!miniRes && _buildBundleStrategy != null)
                        {
                            if (GUILayout.Button("全选", GUILayout.Width(40f)))
                            {
                                if (EditorUtility.DisplayDialog("提示", "将该分组资源全部设置为小包包内资源,请确认?", "确定", "取消"))
                                {
                                    foreach (string resKey in buildResList)
                                    {
                                        _buildBundleStrategy.AddMinResKey(resKey);
                                    }
                                }
                            }
                            if (GUILayout.Button("取消", GUILayout.Width(40f)))
                            {
                                if (EditorUtility.DisplayDialog("提示", "将该分组资源从小包包内资源中移除,请确认?", "确定", "取消"))
                                {
                                    foreach (string resKey in buildResList)
                                    {
                                        _buildBundleStrategy.RemoveMinResKey(resKey);
                                    }
                                }
                            }
                        }
                        GUILayout.EndHorizontal();
                        var hitCount = 0;
                        if (_foldoutDic[resGroup])
                        {
                            for (var i = 0; i < buildResList.Count; ++i)
                            {
                                var bundleName = buildResList[i];
                                if (!string.IsNullOrEmpty(_manifestSearchFilter) &&
                                    bundleName.IndexOf(_manifestSearchFilter, StringComparison.OrdinalIgnoreCase) < 0)
                                    continue;
                                hitCount++;
                                GUILayout.Space(-1f);
                                GUI.backgroundColor = _selectedManifestKey == bundleName
                                    ? Color.white
                                    : new Color(0.8f, 0.8f, 0.8f);
                                GUILayout.BeginHorizontal("AS TextArea", GUILayout.MinHeight(20f));
                                GUI.backgroundColor = Color.white;

                                //编号
                                GUILayout.Label(i.ToString(), GUILayout.Width(40f));

                                if (GUILayout.Button(bundleName, "OL TextField", GUILayout.Height(20f)))
                                {
                                    if (_selectedManifestKey != bundleName)
                                    {
                                        _selectedManifestKey = bundleName;
                                        _bundleManifestInfo.Length = 0;
                                    }
                                }

                                if (!miniRes && _buildBundleStrategy != null)
                                {
                                    var resInfo = _curResConfig.GetResInfo(bundleName);
                                    if (_buildBundleStrategy.minResConfig.ContainsKey(bundleName))
                                    {
                                        GUI.backgroundColor = Color.green;
                                        if (GUILayout.Button("X", GUILayout.Width(22f)))
                                        {
                                            if (EditorUtility.DisplayDialog("提示", "将该资源以及其依赖资源从小包包内资源中移除,请确认?", "确定",
                                                "取消"))
                                            {
                                                RemoveMinResKeySetRecursively(bundleName, resInfo);
                                            }
                                        }
                                        GUI.backgroundColor = Color.white;
                                    }
                                    else
                                    {
                                        if (GUILayout.Button(" ", GUILayout.Width(22f)))
                                        {
                                            if (EditorUtility.DisplayDialog("提示", "将该资源以及其依赖资源添加到小包包内资源中,请确认?", "确定",
                                                "取消"))
                                            {
                                                AddMinResKeySetRecursively(bundleName, resInfo);
                                            }
                                        }
                                    }
                                }

                                GUILayout.EndHorizontal();
                            }
                        }
                        resultDic[resGroup] = hitCount;
                    }
                    EditorGUILayout.EndScrollView();
                    EditorGUILayout.Space();
                }
                EditorGUILayout.EndVertical();

                EditorGUILayout.BeginVertical("HelpBox");
                if (resultDic.Count > 0)
                {
                    var sb = new StringBuilder("Search Result:\n");
                    var index = 0;
                    foreach (var pair in resultDic)
                    {
                        sb.Append(pair.Key + ": " + pair.Value + "/" + _manifestBundleNameGroups[pair.Key].Count + "  ");
                        if (index++ > 3)
                        {
                            index = 0;
                            sb.AppendLine();
                        }
                    }
                    GUILayout.Label(sb.ToString());
                }
                EditorGUILayout.EndVertical();
            }
            else
            {
                GUILayout.Box("ResInfoList is null");
            }

            //绘制选中BundleName详细信息
            _resConfigPanelDetailScroll = DrawResInfoDetailPanel(_selectedManifestKey, _resConfigPanelDetailScroll);
        }

        private Vector2 DrawResInfoDetailPanel(string bundleName, Vector2 scrollPos)
        {
            scrollPos = EditorGUILayout.BeginScrollView(scrollPos, "HelpBox");
            if (_curResConfig != null && !string.IsNullOrEmpty(bundleName))
            {
                var resInfo = _curResConfig.GetResInfo(bundleName);
                if (resInfo != null)
                {
                    string replaceResKey = "";
                    if (_buildBundleStrategy != null)
                        _buildBundleStrategy.replaceResConfig.TryGetValue(bundleName, out replaceResKey);

                    GUILayout.Label(
                        String.Format(
                            "BundleName:{0}\nCRC:{1}\nHash:{2}\nCompressType:{3}\nMD5:{4}\nSize:{5}\nreplaceResKey:{6}\npreload:{7}\n",
                            resInfo.bundleName, resInfo.CRC, resInfo.Hash, resInfo.remoteZipType, resInfo.MD5,
                            EditorUtility.FormatBytes(resInfo.size), replaceResKey, resInfo.preload));

                    GUILayout.Label("=====================================");
                    GUILayout.Label("Dependencies:" + resInfo.Dependencies.Count);
                    foreach (string dependency in resInfo.Dependencies)
                    {
                        GUILayout.BeginHorizontal();
                        GUILayout.Label(dependency);
                        if (GUILayout.Button("选中", GUILayout.Width(50f)))
                        {
                            _selectedManifestKey = dependency;
                            _bundleManifestInfo.Length = 0;

                        }
                        GUILayout.EndHorizontal();
                    }
                    GUILayout.Label("=====================================");

                    if (_bundleManifestInfo.Length > 0)
                    {
                        GUILayout.TextArea(_bundleManifestInfo.ToString());
                    }
                    else
                    {
                        if (GUILayout.Button("查看BundleManifest文件", GUILayout.Height(40f)))
                        {
                            string backupDir = GetBackupDir(_curResConfig);
                            string bundleBackupDir = resInfo.remoteZipType == CompressType.UnityLZMA
                                ? backupDir + "/lzma"
                                : backupDir + "/lz4";
                            var bundleManifestPath = resInfo.GetManifestPath(bundleBackupDir);
                            if (File.Exists(bundleManifestPath))
                            {
                                _bundleManifestInfo.Append(File.ReadAllText(bundleManifestPath));
                            }
                        }
                    }
                }
            }
            EditorGUILayout.EndScrollView();

            return scrollPos;
        }

        #endregion

        #region BundleNamePanel

        private string _projectSearchFilter = "";
        private string _selectedProjectBundleName = "";
        private Vector2 _bundleNamePanelScroll;
        private Vector2 _bundleNamePanelDetailScroll;
        private static Dictionary<ResGroup, List<string>> _projectBundleNameGroups; //当前项目里BundleName分组信息
        private static int _projectBundleNameTotalCount; //当前项目里BundleName总数
        private static HashSet<string> _unusedBundleNameSet; //当前项目里未使用的BundleName集合



        private void UpdateVersion()
        {
            //if (_curResConfig == null)
            //{
            //    if (EditorUtility.DisplayDialog("提示", "未加载当前版本配置信息", "选择加载", "取消"))
            //    {
            //        RefreshResConfigData(LoadResConfigFilePanel(true));
            //    }
            //    return;
            //}

            //string remoteResDir = GetRemoteResRoot(_curResConfig.Version + 1);
            //if (Directory.Exists(remoteResDir))
            //{
            //    if (EditorUtility.DisplayDialog("提示", "当前版本补丁资源已经存在，请先清理", "确定"))
            //    {
            //        return;
            //    }
            //}

            //if (_patchResVersion != _curResConfig.Version + 1)
            //{
            //    string msg = string.Format("资源版本号错误! 当前版本={0} 升级版本={1}", _curResConfig.Version, _patchResVersion);
            //    if (EditorUtility.DisplayDialog("提示", msg, "取消"))
            //    {
            //        return;
            //    }
            //}

            if (_patchDllVersion != 0)
            {
                string filename = string.Format("{0}/dllVersion_{0}", GetExportDllPath(), _patchResVersion);
                if (FileHelper.IsExist(filename))
                {
                    if (EditorUtility.DisplayDialog("Dll版本错误", filename + "已经存在", "取消"))
                    {
                        return;
                    }
                }

                if (_patchDllVersion != GameVersion.dllVersion)
                {
                    string msg = string.Format("Dll版本不对\n升级DllVersion={0}\nGameVersion.dllVersion={1}", _patchDllVersion, GameVersion.dllVersion);
                    if (EditorUtility.DisplayDialog("Dll版本错误", msg, "取消"))
                    {
                        return;
                    }
                }
            }

            string tip = string.Format("请确认版本号");
            if (_patchOnlyScript)
            {
                tip += string.Format("\n只升级Script");
            }
            tip += string.Format("\nResVersion {0} -> {1}", _curResConfig != null ? _curResConfig.Version : 0, _patchResVersion);
            tip += string.Format("\nDllVersion {0}", _patchDllVersion);
            tip += string.Format("\nsvnVersion {0} -> {1}", _curResConfig != null ?_curResConfig.svnVersion : 0, _svnVersion);

            if (EditorUtility.DisplayDialog("制作补丁", tip, "开始制作", " 取消"))
            {
                EditorApplication.delayCall += () =>
                {
                    if (!_patchOnlyScript)
                    {
                        if (_resetAssetbundleName)
                        {
                            CleanUpBundleName(true);
                        }
                        UpdateAllBundleName();
                        BuildAssetBundle(_patchResVersion, _svnVersion);
                    }

                    GenerateAndBackupAssetBundle(_patchResVersion, _svnVersion);
                    GenerateCdnRes(_curResConfig);
                    BuildLuaZip(_patchResVersion);
                    GenerateAllScriptPatch(_patchResVersion);
                    GenerateScriptVersionFile(_patchResVersion);

                    if (_patchDllVersion != 0)
                    {
#if UNITY_STANDALONE_WIN
                        PlayerSettingTool.BuildPCDLL();
#elif UNITY_ANDROID
                        PlayerSettingTool.BuildAndroidDLL();
#endif
                    }
                };
            }
        }

        private void MakeBaseVersion()
        {
            if (_patchResVersion != 0 || _patchDllVersion != 0 || _curResConfig != null)
            {
                if (EditorUtility.DisplayDialog("版本号错误", "请确认版本号全为0，curResConfig为空", "取消"))
                {
                    return;
                }
            }

            string tips = "请注意，制作基础包只适合第一次打包的情况，请确认检查";
            if (EditorUtility.DisplayDialog("制作基础包", tips, "开始制作", " 取消"))
            {
                EditorApplication.delayCall += () =>
                {
                    CleanUpBundleName(true);
                    UpdateAllBundleName();
                    BuildAssetBundle(_patchResVersion, _svnVersion);
					GenerateAndBackupAssetBundle(0, _svnVersion);
                    GenerateCdnRes(_curResConfig);
                    BuildLuaZip(_patchResVersion);
                    GenerateAllScriptPatch(_patchResVersion);
                    GenerateScriptVersionFile(_patchResVersion);

                    if (_patchDllVersion != 0)
                    {
#if UNITY_STANDALONE_WIN
                        PlayerSettingTool.BuildPCDLL();
#elif UNITY_ANDROID
                        PlayerSettingTool.BuildAndroidDLL();
#endif
                    }
                };
            }
        }

		private void MakeLuaScript() {
			if (EditorUtility.DisplayDialog("制作Lua脚本", "===== 制作Lua脚本 =====", "开始制作", " 取消"))
			{
				EditorApplication.delayCall += () =>
				{
					BuildLuaZip(_patchResVersion);
					GenerateAllScriptPatch(_patchResVersion);
					GenerateScriptVersionFile(_patchResVersion);
				};
			}
		}

        private static void RefreshBundleNameData(bool updateMinRes = false)
        {
            if (_projectBundleNameGroups == null)
            {
                _projectBundleNameGroups = new Dictionary<ResGroup, List<string>>();
                var resGroupEnums = Enum.GetValues(typeof(ResGroup));
                foreach (ResGroup resGroup in resGroupEnums)
                {
                    _projectBundleNameGroups.Add(resGroup, new List<string>());
                }
            }
            else
            {
                foreach (var resGroupList in _projectBundleNameGroups.Values)
                {
                    resGroupList.Clear();
                }
            }

            var unusedBundleNames = AssetDatabase.GetUnusedAssetBundleNames();
            _unusedBundleNameSet = new HashSet<string>(unusedBundleNames);

            var bundleNames = AssetDatabase.GetAllAssetBundleNames();
            _projectBundleNameTotalCount = bundleNames.Length;
            foreach (var bundleName in bundleNames)
            {
                var resGroup = ResConfig.GetResGroupFromBundleName(bundleName);
                _projectBundleNameGroups[resGroup].Add(bundleName);

                //更新MiniResStrategy
                if (updateMinRes)
                {
                    if (_unusedBundleNameSet.Contains(bundleName))
                    {
                        //不在使用的BundleName,从小包资源配置策略中移除
                        _buildBundleStrategy.RemoveMinResKey(bundleName);
                    }
                    else
                    {
                        //新增的BundleName默认替代资源为空
                        if (!_buildBundleStrategy.replaceResConfig.ContainsKey(bundleName))
                        {
                            _buildBundleStrategy.replaceResConfig.Add(bundleName, "");
                        }

                        if (IsMiniResType(resGroup))
                        {
                            _buildBundleStrategy.AddMinResKey(bundleName);
                        }
                    }
                }
            }

            //更新完毕,保存一下MiniResStrategy
            if (updateMinRes)
                SaveBuildBundleStrategy();
        }

        private void DrawBundleNamePanel()
        {
            // Search field
            GUILayout.BeginHorizontal();
            {
                var after = EditorGUILayout.TextField("", _projectSearchFilter, "SearchTextField");

                if (GUILayout.Button("", "SearchCancelButton", GUILayout.Width(18f)))
                {
                    after = "";
                    GUIUtility.keyboardControl = 0;
                }

                if (_projectSearchFilter != null && _projectSearchFilter != after)
                {
                    _projectSearchFilter = after;
                }
            }
            GUILayout.EndHorizontal();

            //BundleName列表
            if (_projectBundleNameGroups != null && _projectBundleNameGroups.Count > 0)
            {
                var resultDic = new Dictionary<ResGroup, int>(_projectBundleNameGroups.Count);
                EditorGUILayout.BeginVertical("HelpBox", GUILayout.Height(300f));
                {
                    GUILayout.Label(
                        "Total BundleName:" + _projectBundleNameTotalCount + " Unused BundleName:" +
                        _unusedBundleNameSet.Count);
                    EditorGUILayout.Space();
                    _bundleNamePanelScroll = EditorGUILayout.BeginScrollView(_bundleNamePanelScroll);
                    foreach (var pair in _projectBundleNameGroups)
                    {
                        var resGroup = pair.Key;
                        var buildResList = pair.Value;
                        GUILayout.BeginHorizontal();
                        _foldoutDic[resGroup] = EditorGUILayout.Foldout(_foldoutDic[resGroup], resGroup + " Count: " + buildResList.Count);
                        GUILayout.EndHorizontal();
                        var hitCount = 0;
                        if (_foldoutDic[resGroup])
                        {
                            for (var i = 0; i < buildResList.Count; ++i)
                            {
                                var bundleName = buildResList[i];
                                if (!string.IsNullOrEmpty(_projectSearchFilter) &&
                                    bundleName.IndexOf(_projectSearchFilter, StringComparison.OrdinalIgnoreCase) < 0)
                                    continue;
                                hitCount++;
                                GUILayout.Space(-1f);
                                GUI.backgroundColor = _selectedProjectBundleName == bundleName
                                    ? Color.white
                                    : new Color(0.8f, 0.8f, 0.8f);
                                GUILayout.BeginHorizontal("AS TextArea", GUILayout.MinHeight(20f));
                                GUI.backgroundColor = Color.white;

                                //编号
                                GUILayout.Label(i.ToString(), GUILayout.Width(40f));

                                GUI.color = _unusedBundleNameSet.Contains(bundleName) ? Color.yellow : Color.white;
                                if (GUILayout.Button(bundleName, "OL TextField", GUILayout.Height(20f)))
                                {
                                    _selectedProjectBundleName = bundleName;
                                }
                                GUI.color = Color.white;

                                if (_buildBundleStrategy != null &&
                                    !bundleName.StartsWith(ResGroup.Common.ToString().ToLower()))
                                {
                                    if (_buildBundleStrategy.preloadConfig.ContainsKey(bundleName))
                                    {
                                        GUI.backgroundColor = Color.green;
                                        if (GUILayout.Button("X", GUILayout.Width(22f)))
                                        {
                                            if (EditorUtility.DisplayDialog("提示", "将该资源从预加载列表中移除,请确认?", "确定", "取消"))
                                            {
                                                _buildBundleStrategy.preloadConfig.Remove(bundleName);
                                            }
                                        }
                                        GUI.backgroundColor = Color.white;
                                    }
                                    else
                                    {
                                        if (GUILayout.Button(" ", GUILayout.Width(22f)))
                                        {
                                            if (EditorUtility.DisplayDialog("提示", "将该资源加入到预加载列表中,请确认?", "确定",
                                                "取消"))
                                            {
                                                _buildBundleStrategy.preloadConfig.Add(bundleName, true);
                                            }
                                        }
                                    }
                                }

                                GUILayout.EndHorizontal();
                            }
                        }
                        resultDic[resGroup] = hitCount;
                    }
                    EditorGUILayout.EndScrollView();
                    EditorGUILayout.Space();
                }
                EditorGUILayout.EndVertical();

                EditorGUILayout.BeginVertical("HelpBox");
                if (resultDic.Count > 0)
                {
                    var sb = new StringBuilder("Search Result:\n");
                    var index = 0;
                    foreach (var pair in resultDic)
                    {
                        sb.Append(pair.Key + ": " + pair.Value + "/" + _projectBundleNameGroups[pair.Key].Count + "  ");
                        if (index++ > 3)
                        {
                            index = 0;
                            sb.AppendLine();
                        }
                    }
                    GUILayout.Label(sb.ToString());
                }
                EditorGUILayout.EndVertical();
            }
            else
            {
                GUILayout.Box("ResInfoList is null");
            }

            //绘制选中BundleName详细信息
            _bundleNamePanelDetailScroll = DrawBundleNameDetailPanel(_selectedProjectBundleName,
                _bundleNamePanelDetailScroll);
        }

        private Vector2 DrawBundleNameDetailPanel(string bundleName, Vector2 scrollPos)
        {
            scrollPos = EditorGUILayout.BeginScrollView(scrollPos, "HelpBox");
            if (!string.IsNullOrEmpty(bundleName))
            {
                if (_unusedBundleNameSet != null && _unusedBundleNameSet.Contains(bundleName))
                {
                    GUI.color = Color.yellow;
                    GUILayout.Label("该BundleName未在项目中使用");
                    GUI.color = Color.white;
                }
                GUILayout.Label("=====================================");
                var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundle(bundleName);
                GUILayout.Label("Include Asset Path:" + assetPaths.Length);
                for (var i = 0; i < assetPaths.Length; ++i)
                {
                    EditorGUILayout.BeginHorizontal();
                    if (GUILayout.Button("选中", GUILayout.Width(50f)))
                    {
                        Selection.activeObject = AssetDatabase.LoadMainAssetAtPath(assetPaths[i]);
                    }
                    GUILayout.Label(assetPaths[i]);
                    EditorGUILayout.EndHorizontal();
                }

                GUILayout.Label("=====================================");
                if (_buildBundleStrategy != null)
                {
                    if (!_buildBundleStrategy.minResConfig.ContainsKey(bundleName) && _buildBundleStrategy.replaceResConfig.ContainsKey(bundleName))
                    {
                        _buildBundleStrategy.replaceResConfig[bundleName] = EditorGUILayout.TextField("replaceResKey:",
                            _buildBundleStrategy.replaceResConfig[bundleName]);
                    }
                }
            }
            EditorGUILayout.EndScrollView();
            return scrollPos;
        }

        #endregion

        #region PatchInfo Panel

        private ResPatchInfo _selectedPatchInfo;
        private List<ResPatchInfo> _patchInfoList = new List<ResPatchInfo>();
        private Vector2 _patchInfoListScrollPos;
        private Vector2 _patchInfoPanelScrollPos;
        private string _cdnRoot = "";
        private CDNPlatformType _selectedCdnPlatformType;

        public enum CDNPlatformType
        {
            Andoird,
            IOS,
            RootIOS,
            Win
        }

        private void DrawPatchInfoPanel()
        {
            GUILayout.BeginVertical(GUILayout.MinHeight(300f));
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("打开PatchInfo目录", "LargeButton", GUILayout.Height(20f)))
            {
                OpenDirectory(GetPatchInfoRoot());
            }
            if (GUILayout.Button("清空PatchInfo目录", "LargeButton", GUILayout.Height(20f)))
            {
                if (EditorUtility.DisplayDialog("提示", "清空PatchInfo目录,请确认?", "确定", "取消"))
                {
                    FileHelper.DeleteDirectory(GetPatchInfoRoot(), true);
                }
            }
            EditorGUILayout.EndHorizontal();
            _selectedCdnPlatformType =
                (CDNPlatformType)EditorGUILayout.EnumPopup("CDNRegion:", _selectedCdnPlatformType);
            _cdnRoot = EditorGUILayout.TextField("CDNRoot:", _cdnRoot);

            if (_patchInfoList != null && _patchInfoList.Count > 0)
            {
                _patchInfoListScrollPos = EditorGUILayout.BeginScrollView(_patchInfoListScrollPos);
                for (int i = 0; i < _patchInfoList.Count; ++i)
                {
                    ResPatchInfo patchInfo = _patchInfoList[i];
                    if (patchInfo != null)
                    {
                        GUILayout.Space(-1f);
                        GUI.backgroundColor = _selectedPatchInfo == patchInfo
                            ? Color.white
                            : new Color(0.8f, 0.8f, 0.8f);

                        GUILayout.BeginHorizontal("AS TextArea", GUILayout.MinHeight(20f));

                        GUI.backgroundColor = Color.white;
                        GUILayout.Label(i.ToString(), GUILayout.Width(40f));

                        string content = patchInfo.ToFileName() +
                            (patchInfo.CurVer == patchInfo.EndVer ? "(当前版本PatchInfo)" : "");
                        if (GUILayout.Button(content, "OL TextField", GUILayout.Height(20f)))
                        {
                            _selectedPatchInfo = patchInfo;
                        }
                        GUILayout.EndHorizontal();
                    }
                }
                EditorGUILayout.EndScrollView();
            }
            else
            {
                GUILayout.Box("PatchInfoList is null");
            }
            GUILayout.EndVertical();

            if (_selectedPatchInfo != null)
            {
                _patchInfoPanelScrollPos = EditorGUILayout.BeginScrollView(_patchInfoPanelScrollPos);
                GUILayout.Label(
                    string.Format("CurVer:{0}\nEndVer:{1}\nCurLz4CRC:{2}\nCurLzmaCRC:{3}\nEndLz4CRC:{4}\nEndLzmaCRC:{5}\nTotalFileSize:{6}",
                        _selectedPatchInfo.CurVer,
                        _selectedPatchInfo.EndVer,
                        _selectedPatchInfo.CurLz4CRC,
                        _selectedPatchInfo.CurLzmaCRC,
                        _selectedPatchInfo.EndLz4CRC,
                        _selectedPatchInfo.EndLzmaCRC,
                        EditorUtility.FormatBytes(_selectedPatchInfo.TotalFileSize))
                    );
                GUILayout.Label(string.Format("更新列表:{0}", _selectedPatchInfo.updateList.Count));
                for (int i = 0; i < _selectedPatchInfo.updateList.Count; i++)
                {
                    string info = string.Format("{0} {1}", i, _selectedPatchInfo.updateList[i].bundleName);
                    GUILayout.Label(info);
                }

                GUILayout.Label(string.Format("删除列表:{0}", _selectedPatchInfo.removeList.Count));
                for (int i = 0; i < _selectedPatchInfo.removeList.Count; i++)
                {
                    string info = string.Format("{0} {1}", i, _selectedPatchInfo.removeList[i]);
                    GUILayout.Label(info);
                }
                EditorGUILayout.EndScrollView();
                if (GUILayout.Button("生成当前Patch的Url清单", GUILayout.Height(40f)))
                {
                    GeneratePatchInfoUrlFile(_selectedPatchInfo, _cdnRoot, _selectedCdnPlatformType.ToString().ToLower());
                }
                if (GUILayout.Button("生成当前Patch需要的资源", GUILayout.Height(40f)))
                {
                    if (EditorUtility.DisplayDialog("提示", "导出版本更新资源到patch_resources目录", "确定", "取消"))
                    {
                        GeneratePatchRes(_selectedPatchInfo);
                    }
                }
            }
        }

        #endregion

        #region MinResList Panel

        private Vector2 _minResPanelScrollPos;
        private Vector2 _minResPanelDetailScrollPos;
        private bool _minResFoldOut;
        private bool _replaceResFoldOut;
        private string _selectedMiniResBundleName;
        private string _minResSearchFilter = "";

        private void DrawMinResListPanel()
        {
            if (_buildBundleStrategy == null) return;
            // Search field
            GUILayout.BeginHorizontal();
            {
                var after = EditorGUILayout.TextField("", _minResSearchFilter, "SearchTextField");

                if (GUILayout.Button("", "SearchCancelButton", GUILayout.Width(18f)))
                {
                    after = "";
                    GUIUtility.keyboardControl = 0;
                }

                if (_minResSearchFilter != null && _minResSearchFilter != after)
                {
                    _minResSearchFilter = after;
                }
            }
            GUILayout.EndHorizontal();

            EditorGUILayout.BeginVertical("HelpBox", GUILayout.Height(300f));
            {
                _minResPanelScrollPos = EditorGUILayout.BeginScrollView(_minResPanelScrollPos);

                _minResFoldOut = EditorGUILayout.Foldout(_minResFoldOut,
                    "小包必备资源列表: " + _buildBundleStrategy.minResConfig.Count);
                if (_minResFoldOut)
                {
                    int index = 0;
                    foreach (string bundleName in _buildBundleStrategy.minResConfig.Keys)
                    {
                        if (!string.IsNullOrEmpty(_minResSearchFilter) && bundleName.IndexOf(_minResSearchFilter, StringComparison.OrdinalIgnoreCase) < 0)
                            continue;
                        GUILayout.Space(-1f);
                        GUI.backgroundColor = _selectedMiniResBundleName == bundleName
                            ? Color.white
                            : new Color(0.8f, 0.8f, 0.8f);

                        GUILayout.BeginHorizontal("AS TextArea", GUILayout.MinHeight(20f));

                        GUI.backgroundColor = Color.white;
                        GUILayout.Label(index++.ToString(), GUILayout.Width(40f));

                        if (GUILayout.Button(bundleName, "OL TextField", GUILayout.Height(20f)))
                        {
                            _selectedMiniResBundleName = bundleName;
                        }
                        GUILayout.EndHorizontal();
                    }
                }

                _replaceResFoldOut = EditorGUILayout.Foldout(_replaceResFoldOut,
                    "小包替代资源信息:" + _buildBundleStrategy.replaceResConfig.Count);
                if (_replaceResFoldOut)
                {
                    int index = 0;
                    foreach (var pair in _buildBundleStrategy.replaceResConfig)
                    {
                        string bundleName = pair.Key;
                        if (!string.IsNullOrEmpty(_minResSearchFilter) && bundleName.IndexOf(_minResSearchFilter, StringComparison.OrdinalIgnoreCase) < 0)
                            continue;
                        GUILayout.Space(-1f);
                        GUI.backgroundColor = _selectedMiniResBundleName == bundleName
                            ? Color.white
                            : new Color(0.8f, 0.8f, 0.8f);

                        GUILayout.BeginHorizontal("AS TextArea", GUILayout.MinHeight(20f));

                        GUI.backgroundColor = Color.white;
                        GUILayout.Label(index++.ToString(), GUILayout.Width(40f));

                        if (GUILayout.Button(bundleName + "  ==>  " + pair.Value, "OL TextField", GUILayout.Height(20f)))
                        {
                            _selectedMiniResBundleName = bundleName;
                        }
                        GUILayout.EndHorizontal();
                    }
                }

                EditorGUILayout.EndScrollView();
            }
            EditorGUILayout.EndVertical();

            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("清空MinRes资源列表", GUILayout.Height(40f)))
            {
                if (EditorUtility.DisplayDialog("确认", "是否清空MinRes资源列表？", "清空", "取消"))
                {
                    _buildBundleStrategy.minResConfig.Clear();
                    SaveBuildBundleStrategy();
                }
            }
            if (GUILayout.Button("刷新小包资源配置", GUILayout.Height(40f)))
            {
                if (EditorUtility.DisplayDialog("确认", "是否刷新小包资源配置？", "刷新", "取消"))
                {
                    RefreshBundleNameData(true);
                }
            }
            if (GUILayout.Button("保存小包资源配置", GUILayout.Height(40f)))
            {
                if (EditorUtility.DisplayDialog("确认", "是否保存小包资源配置？", "保存", "取消"))
                {
                    SaveBuildBundleStrategy();
                }
            }
            EditorGUILayout.EndHorizontal();

            //绘制选中ResInfo信息
            _minResPanelDetailScrollPos = DrawBundleNameDetailPanel(_selectedMiniResBundleName,
                _minResPanelDetailScrollPos);
        }

        #endregion

        #region 标记项目资源AssetBundle名

        private void CleanUpBundleName(bool cleanAll)
        {
            AssetDatabase.RemoveUnusedAssetBundleNames();
            if (cleanAll)
            {
                var allBundleNames = AssetDatabase.GetAllAssetBundleNames();
                for (int i = 0; i < allBundleNames.Length; i++)
                {
                    var bundleName = allBundleNames[i];
                    AssetDatabase.RemoveAssetBundleName(bundleName, true);
                    if (_showPrograss)
                        EditorUtility.DisplayProgressBar("移除所有资源BundleName中", string.Format(" {0} / {1} ", i, allBundleNames.Length),
                            i / (float)allBundleNames.Length);
                }
                if (_showPrograss)
                    EditorUtility.ClearProgressBar();
            }

            RefreshBundleNameData();
            AssetDatabase.Refresh();
            Debug.Log(cleanAll ? "清空所有资源BundleName成功" : "清空未使用的BundleName成功");
        }

        private static StringBuilder _bundleNameLogger = new StringBuilder();
        private void UpdateAllBundleName()
        {
            Debug.Log("更新所有AssetBundleName");
            _bundleNameLogger.Length = 0;
            var stopwatch = Stopwatch.StartNew();
            AssetDatabase.RemoveUnusedAssetBundleNames();
            var effCount = (_updateResGroupMask & UpdateBundleFlag.Effect) != UpdateBundleFlag.Effect ? -1 : UpdateEffect(); //effect会引用其他目录贴图，先处理
            var uiCount = (_updateResGroupMask & UpdateBundleFlag.UI) != UpdateBundleFlag.UI ? -1 : UpdateUI();
            var atlasCount = (_updateResGroupMask & UpdateBundleFlag.Atlas) != UpdateBundleFlag.Atlas ? -1 : UpdateAtlas();
            var fontCount = (_updateResGroupMask & UpdateBundleFlag.Font) != UpdateBundleFlag.Font ? -1 : UpdateFont();
            var modelCount = (_updateResGroupMask & UpdateBundleFlag.Model) != UpdateBundleFlag.Model ? -1 : UpdateModel();
            var map2dCount = (_updateResGroupMask & UpdateBundleFlag.Map2d) != UpdateBundleFlag.Map2d ? -1 : UpdateMap2d();
            var map3dCount = (_updateResGroupMask & UpdateBundleFlag.Map3d) != UpdateBundleFlag.Map3d ? -1 : UpdateMap3d();
            var audioCount = (_updateResGroupMask & UpdateBundleFlag.Audio) != UpdateBundleFlag.Audio ? -1 : UpdateAudio();
            var textureCount = (_updateResGroupMask & UpdateBundleFlag.Texture) != UpdateBundleFlag.Texture ? -1 : UpdateTexture();
            var configCount = (_updateResGroupMask & UpdateBundleFlag.Config) != UpdateBundleFlag.Config ? -1 : UpdateConfig();
            var live2dCount = (_updateResGroupMask & UpdateBundleFlag.Live2d) != UpdateBundleFlag.Live2d ? -1 : UpdateLive2d();
            var materialCount = (_updateResGroupMask & UpdateBundleFlag.Material) != UpdateBundleFlag.Material ? -1 : UpdateMaterial();
            //最后才更新公共资源的BundleName,防止被前面流程覆盖掉
            var commonCount = UpdateCommon();

            stopwatch.Stop();
            var elapsed = stopwatch.Elapsed;
            var tips = string.Format(
                    "资源BundleName变更数量\n-1表示跳过该组资源检查\nCommon：{0}\nUI：{1}\nModel：{2}\nEffect：{3}\nMap2d：{4}\nMap3d：{5}\nTexturet:{6}\nAudio:{7}\nConfig:{8}\n",
                    commonCount, uiCount, modelCount, effCount, map2dCount, map3dCount, textureCount, audioCount, configCount);
            Debug.Log(string.Format("更新项目资源的BundleName总耗时:{0:00}:{1:00}:{2:00}:{3:00}\n", elapsed.Hours, elapsed.Minutes, elapsed.Seconds, elapsed.Milliseconds / 10) + tips);
            if (_bundleNameLogger.Length > 0)
            {
                Debug.Log(_bundleNameLogger);
            }
            AssetDatabase.Refresh();
            RefreshBundleNameData(true);
        }

        /// <summary>
        ///     Common类型资源,开始游戏前全部加载进游戏中
        /// </summary>
        /// <returns></returns>
        private int UpdateCommon()
        {
            int changeCount = 0;
            //更新公共资源BundleName
            foreach (string filePath in BuildBundlePath.CommonFilePath)
            {
                var importer = AssetImporter.GetAtPath(filePath);
                if (importer != null)
                {
                    if (importer.UpdateBundleName(importer.GetAssetBundleName(ResGroup.Common)))
                    {
                        changeCount++;
                        _bundleNameLogger.AppendLine("Update Common BundleName:" + filePath);
                    }
                }
            }

            var GUIDs = AssetDatabase.FindAssets("t:shader", BuildBundlePath.ShaderFolder);
            for (int i = 0; i < GUIDs.Length; i++)
            {
                var shaderPath = AssetDatabase.GUIDToAssetPath(GUIDs[i]);
                var shaderImporter = AssetImporter.GetAtPath(shaderPath);
                if (shaderImporter.UpdateBundleName(GameResPath.AllShaderBundleName))
                {
                    changeCount++;
                    _bundleNameLogger.AppendLine("Update CustomShader BundleName:" + shaderPath);
                }
            }
            return changeCount;
        }

        /// <summary>
        /// 分析所有UI资源信息,并设置BundleName
        /// UI资源目录结构规范示例
        /// UI
        ///     Atlas/
        ///         CommonUIAtlas.prefab
        ///     Fonts/
        ///         CommonFont.prefab
        ///     Prefabs/
        ///         BaseDialogue.prefab
        ///     Images/
        ///         dialogue_bg.png
        /// </summary>
        /// <returns></returns>
        public static int UpdateUI()
        {
            var changeCount = 0;
            string[] GUIDs = AssetDatabase.FindAssets("t:Prefab", BuildBundlePath.UIFolder);
            for (var i = 0; i < GUIDs.Length; i++)
            {
                string resPath = AssetDatabase.GUIDToAssetPath(GUIDs[i]);
                if (resPath.IsCommonAsset()) continue;

                var prefabImporter = AssetImporter.GetAtPath(resPath);
                if (prefabImporter.UpdateBundleName(prefabImporter.GetAssetBundleName(ResGroup.UI)))
                {
                    changeCount++;
                    _bundleNameLogger.AppendLine("Update UI BundleName:" + resPath);
                }

                //处理UIPrefab依赖关系
                var dependencies = AssetDatabase.GetDependencies(resPath, false);
                for (var j = 0; j < dependencies.Length; j++)
                {
                    var refPath = dependencies[j];
                    if (refPath.IsCommonAsset()) continue;

                    var refImporter = AssetImporter.GetAtPath(refPath);
                    if (refPath.IsTextureFile() && refPath.IsTextureRes())
                    {
                        //UIPrefab中引用到的贴图都要统一放在CommonTextures目录下
                        //if (refPath.IsTextureRes())
                        //{
                        //    if (refImporter.UpdateBundleName(refImporter.GetAssetBundleName(ResGroup.Texture)))
                        //    {
                                changeCount++;
                                _bundleNameLogger.AppendLine("Update Texture BundleName:" + refPath);
                        //    }
                        //}
                        //else
                        //{
                        //    Debug.LogError(string.Format("<{0}> UIPrefab引用到的图片需要放到GameRes/Texture目录下，请检查:{1}", resPath, refPath));
                        //}
                    }
                    else if (refPath.IsAudioFile())
                    {
						Debug.LogError(string.Format("refpath:{0} | resPath:{1} 中包含了音频资源，UIPrefab中不应包含除Common资源外的其他音频资源，请检查",
                            refPath, resPath));
                    }
                }

                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("处理UIPrefab中", string.Format(" {0} / {1} ", i, GUIDs.Length),
                        i / (float)GUIDs.Length);
            }

            if (_showPrograss)
                EditorUtility.ClearProgressBar();
            return changeCount;
        }

        public static int UpdateAtlas()
        {
            var changeCount = 0;
            var GUIDs = AssetDatabase.FindAssets("t:Prefab", BuildBundlePath.AtlasFolder);
            for (var i = 0; i < GUIDs.Length; i++)
            {
                string resPath = AssetDatabase.GUIDToAssetPath(GUIDs[i]);
                if (resPath.IndexOf("StaticAtlas") > 0)
                    continue;

                var prefabImporter = AssetImporter.GetAtPath(resPath);
                string abname = prefabImporter.GetAssetBundleName(ResGroup.Atlas);
                if (prefabImporter.UpdateBundleName(abname))
                {
                    changeCount++;
                    _bundleNameLogger.AppendLine("Update Atlas BundleName:" + resPath);
                }


                var dependencies = AssetDatabase.GetDependencies(resPath);
                for (var j = 0; j < dependencies.Length; j++)
                {
                    var refPath = dependencies[j];
                    if (refPath.IsTextureFile())
                    {
                        if ((refPath.IndexOf("StaticAtlas") >= 0 && abname.ToLower().IndexOf("ref") >0) || 
                            ((refPath.IndexOf("DynamicAtlas") >= 0 && abname.ToLower().IndexOf("ref") < 0))
                            )
                        {
                            var texImporter = AssetImporter.GetAtPath(refPath);
                            if (texImporter.UpdateBundleName(abname))
                            {
                                changeCount++;
                                _bundleNameLogger.AppendLine("Update AtlasTexture BundleName:" + refPath);
                            }
                        }
                    }

                }

                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("处理UIAtlas中", string.Format(" {0} / {1} ", i, GUIDs.Length), i / (float)GUIDs.Length);
            }

            if (_showPrograss)
                EditorUtility.ClearProgressBar();
            return changeCount;
        }


        public static int UpdateFont()
        {
            var changeCount = 0;
            var GUIDs = AssetDatabase.FindAssets("t:Prefab", BuildBundlePath.FontFolder);
            for (var i = 0; i < GUIDs.Length; i++)
            {
                string resPath = AssetDatabase.GUIDToAssetPath(GUIDs[i]);
                if (resPath.IsCommonAsset()) continue;

                var prefabImporter = AssetImporter.GetAtPath(resPath);
                //MyFont相关资源需要特殊处理,加上表情图集一起打包
                if (resPath.StartsWith("Assets/GameRes/Font/MyFont/"))
                {
                    var dependencies = AssetDatabase.GetDependencies(resPath);
                    foreach (string refPath in dependencies)
                    {
                        if (refPath.StartsWith("Assets/GameRes/Font/MyFont/"))
                        {
                            var importer = AssetImporter.GetAtPath(refPath);
                            if (importer.UpdateBundleName(importer.GetAssetBundleName(ResGroup.Font)))
                            {
                                changeCount++;
                                _bundleNameLogger.AppendLine("Update UIFont BundleName:" + refPath);
                            }
                        }
                    }
                }
                else
                {
                    if (prefabImporter.UpdateBundleName(prefabImporter.GetAssetBundleName(ResGroup.Font)))
                    {
                        changeCount++;
                        _bundleNameLogger.AppendLine("Update Font BundleName:" + resPath);
                    }
                }

                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("处理UIFont中", string.Format(" {0} / {1} ", i, GUIDs.Length),
                        i / (float)GUIDs.Length);
            }

            if (_showPrograss)
                EditorUtility.ClearProgressBar();
            return changeCount;
        }

		public static int UpdateModel()
		{
			var changeCount = 0;
			List<string> ignoreList = new List<string> () {
//				  // 龙人：
//                "model5109",
//                // 雪女：
//                "model5129",
//                // 水君：
//                "model5124",
//                // 龙女：
//                "model5135",
//                // 万年冰魇：
//                "model5139",
//                // 枪天将：
//                "model5125",
//                // 天狗：
//                "model5110",
//                // 真君：
//                "model5136",
//                // 女魁：
//                "model5119",
//                // 鬼帝：
//                "model5126",
			};
			//处理每个模型资源
			var GUIDs = AssetDatabase.FindAssets("t:Prefab", BuildBundlePath.ModelFolder);
			for (var modelIndex = 0; modelIndex < GUIDs.Length; modelIndex++)
			{
				var modelPath = AssetDatabase.GUIDToAssetPath(GUIDs[modelIndex]);
				var modelName = modelPath.ExtractResName();
				if (ignoreList.Contains(modelName)) {
					continue;
				}
				
				var prefabImporter = AssetImporter.GetAtPath(modelPath);
				string prefabBundleName = prefabImporter.GetAssetBundleName(ResGroup.Model);
				//	对预设资源处理,数量++
				if (prefabImporter.UpdateBundleName(prefabBundleName))
				{
					changeCount++;
					_bundleNameLogger.AppendLine("Update Model BundleName:" + modelPath);
				}
				
				//只对 model\weapon 前缀的模型根据依赖关系打包，其它模型全部资源打成一个包
				string[] modelnames = {"model", "weapon"};
				foreach(string name in modelnames) {
					bool bModelDir = modelName.StartsWith("model");
					if (modelName.StartsWith(name))
					{
						//模型关联材质统一打包
						string matDir = Path.GetDirectoryName(modelPath).Replace("/Prefabs", "/Materials");
						if (Directory.Exists(matDir))
						{
							var matGUIDs = AssetDatabase.FindAssets("t:Material", new[] { matDir });
							if (matGUIDs.Length > 0)
							{
								foreach (var matGUID in matGUIDs)
								{
									string matPath = AssetDatabase.GUIDToAssetPath(matGUID);
									var matImporter = AssetImporter.GetAtPath(matPath);
									string matBundleName = prefabBundleName + "_mat";
									if (matImporter.UpdateBundleName(matBundleName))
									{
										changeCount++;
										_bundleNameLogger.AppendLine("Update ModelMat BundleName:" + matPath);
									}
									
									var dependencies = AssetDatabase.GetDependencies(matPath);
									for (var j = 0; j < dependencies.Length; j++)
									{
										var refPath = dependencies[j];
										if (refPath.IsTextureFile() && refPath.IsModelRes())
										{
											var texImporter = AssetImporter.GetAtPath(refPath);
											if (texImporter.UpdateBundleName(matBundleName))
											{
												changeCount++;
												_bundleNameLogger.AppendLine("Update ModelTexture BundleName:" + refPath);
											}
										}
									}
									
									//设置模型材质关联Shader的BundleName
									var matDependencies = AssetDatabase.GetDependencies(matPath, false);
									foreach (string refPath in matDependencies)
									{
										if (refPath.IsShaderFile())
										{
											var shaderImporter = AssetImporter.GetAtPath(refPath);
											if (shaderImporter.UpdateBundleName(GameResPath.AllShaderBundleName))
											{
												changeCount++;
												_bundleNameLogger.AppendLine("Update ModelShader BundleName:" + refPath);
											}
										}
									}
								}
							}
							else if (bModelDir)
							{
								Debug.LogWarning("当前模型关联材质数量为0,请检查:" + modelName);
							}
						}
						else if (bModelDir)
						{
							Debug.LogWarning("当前模型材质目录命名异常,请检查:" + matDir);
						}
						
						//模型关联animator统一打包
						string[] animators = {"/Anim", "/RoleCreate", "/Marry"};
						foreach(string animator in animators) {
							string animDir = Path.GetDirectoryName(modelPath).Replace("/Prefabs", animator);
							if (Directory.Exists(animDir))
							{
								var animatorGUIDs = AssetDatabase.FindAssets("t:AnimatorOverrideController", new[] { animDir });
								foreach (var animatorGUID in animatorGUIDs)
								{
									string animatorPath = AssetDatabase.GUIDToAssetPath(animatorGUID);
									var animatorImporter = AssetImporter.GetAtPath(animatorPath);
									if (animatorImporter.UpdateBundleName(animatorImporter.GetAssetBundleName(ResGroup.Model)))
									{
										changeCount++;
										_bundleNameLogger.AppendLine("Update Animator BundleName:" + animatorPath);
									}
								}
								
							/*
							 * N1 动作全部拆分，每个动作打包为一个AB
							var animGUIDs = AssetDatabase.FindAssets("t:AnimationClip", new[] { animDir });
							foreach (var animGUID in animGUIDs)
							{
								string animPath = AssetDatabase.GUIDToAssetPath(animGUID);
								var importer = AssetImporter.GetAtPath(animPath);
                                string modelId = modelName.Replace("model", ""); 
								if (importer.UpdateBundleName(importer.GetAssetBundleName(ResGroup.Model)+modelId+"_ani"))
								{
									changeCount++;
									_bundleNameLogger.AppendLine("Update Anim BundleName:" + animPath);
								}
							}
							*/
							}
							else if (bModelDir)
							{
								if (animator == "/RoleCreate") continue;
                                if (animator == "/Marry") continue;
								Debug.LogWarning("当前模型动作目录命名异常,请检查:" + animDir);
							}
						}
					}
					
					if (_showPrograss) {
						EditorUtility.DisplayProgressBar("处理模型资源中", string.Format(" {0} / {1} ", modelIndex, GUIDs.Length), modelIndex / (float)GUIDs.Length);
					}
				}
			}
			
			//处理 Template Animator
			string[] animatorTypes = {"CharacterAnim/Base", "RoleCreate/Base", "Marry/Base"};
			foreach(var animatorType in animatorTypes)
			{
				GUIDs = AssetDatabase.FindAssets("t:AnimatorController t:AnimationClip", new string[] { "Assets/GameRes/Model/Template/"+animatorType });
				for (var index = 0; index < GUIDs.Length; index++)
				{
					var path = AssetDatabase.GUIDToAssetPath(GUIDs[index]);
					var importer = AssetImporter.GetAtPath(path);
					if (importer.UpdateBundleName("model/"+animatorType))
					{
						changeCount++;
						_bundleNameLogger.AppendLine("Update AnimatorController BundleName:" + path);
					}
					if (_showPrograss) {
						EditorUtility.DisplayProgressBar("处理AnimatorController资源中", string.Format(" {0} / {1} ", index, GUIDs.Length), index / (float)GUIDs.Length);
					}
				}
			}
			
			if (_showPrograss) {
				EditorUtility.ClearProgressBar();
			}
			return changeCount;
		}

        public static int UpdateEffect()
        {
            var changeCount = 0;
            var GUIDs = AssetDatabase.FindAssets("t:Prefab", BuildBundlePath.EffectFolder);
            for (var effIndex = 0; effIndex < GUIDs.Length; effIndex++)
            {
                var effPath = AssetDatabase.GUIDToAssetPath(GUIDs[effIndex]);
                var prefabImporter = AssetImporter.GetAtPath(effPath);
                if (prefabImporter.UpdateBundleName(prefabImporter.GetAssetBundleName(ResGroup.Effect)))
                {
                    changeCount++;
                    _bundleNameLogger.AppendLine("Update Effect BundleName:" + effPath);
                }

                //处理特效资源材质依赖关系
                var dependencies = AssetDatabase.GetDependencies(effPath);
                for (var effMatIndex = 0; effMatIndex < dependencies.Length; effMatIndex++)
                {
                    var refPath = dependencies[effMatIndex];
                    if (refPath.IsShaderFile())
                    {
                        var shaderImporter = AssetImporter.GetAtPath(refPath);
                        if (shaderImporter.UpdateBundleName(GameResPath.AllShaderBundleName))
                        {
                            changeCount++;
                            _bundleNameLogger.AppendLine("Update EffectShader BundleName:" + refPath);
                        }
                    }
                    else if (refPath.IsTextureFile() && refPath.IsEffectRes())
                    {
                        var texImporter = AssetImporter.GetAtPath(refPath);
                        //string name = Path.GetFileName(refPath);
                        //string bundleName = string.Format("Effect/effecttex_{0}", name.Substring(0, 2));
                        if (texImporter.UpdateBundleName(texImporter.GetAssetBundleName(ResGroup.Effect)))
                        {
                            changeCount++;
                            _bundleNameLogger.AppendLine("Update EffectShader BundleName:" + refPath);
                        }
                    }
                }
                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("处理特效资源中", string.Format(" {0} / {1} ", effIndex, GUIDs.Length),
                        effIndex / (float)GUIDs.Length);
            }
            if (_showPrograss)
                EditorUtility.ClearProgressBar();
            return changeCount;
        }

        public static int UpdateTexture()
        {
			string[] pathArry = {
				"Assets/GameRes/Texture",
				"Assets/GameRes/TextureSpecial",
				"Assets/GameRes/TextureUncompress",
			};
            int changeCount = 0;
			var GUIDs = AssetDatabase.FindAssets("t:Texture", pathArry);
            for (int i = 0; i < GUIDs.Length; i++)
            {
                string resPath = AssetDatabase.GUIDToAssetPath(GUIDs[i]);
                string fileName = Path.GetFileName(resPath);
                if (string.IsNullOrEmpty(fileName)) continue;
                var textureImporter = AssetImporter.GetAtPath(resPath);
                if (textureImporter.UpdateBundleName(textureImporter.GetAssetBundleName(ResGroup.Texture)))
                {
                    changeCount++;
                    _bundleNameLogger.AppendLine("Update Texture BundleName:" + resPath);
                }

                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("处理Texture目录中", String.Format(" {0} / {1} ", i, GUIDs.Length), (float)i / (float)GUIDs.Length);
            }
            return changeCount;

        }

        public static int UpdateMap2d()
        {
            var changeCount = 0;
            //处理2d场景贴图资源
            const string SceneRawDataPath = "Assets/GameRes/Map2d";
            var GUIDs = AssetDatabase.FindAssets("t:Texture", new string[] { SceneRawDataPath });
            for (int i = 0; i < GUIDs.Length; i++)
            {
                string resPath = AssetDatabase.GUIDToAssetPath(GUIDs[i]);
                //if (resPath.IndexOf("tile") >= 0)
                //{
                //    continue;
                //}

                string fileName = Path.GetFileName(resPath);
                if (string.IsNullOrEmpty(fileName)) continue;
                if (fileName.StartsWith("gridRef_")) continue;

                var textureImporter = AssetImporter.GetAtPath(resPath);
                if (textureImporter.UpdateBundleName(textureImporter.GetAssetBundleName(ResGroup.Map2d)))
                {
                    changeCount++;
                    _bundleNameLogger.AppendLine("Update Scene2dTexture BundleName:" + resPath);
                }

                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("处理2d场景Map2d目录中", String.Format(" {0} / {1} ", i, GUIDs.Length), (float)i / (float)GUIDs.Length);
            }

            //处理2d场景透明遮罩图集资源
            GUIDs = AssetDatabase.FindAssets("t:Prefab", new string[] { SceneRawDataPath });
            for (int i = 0; i < GUIDs.Length; i++)
            {
                string resPath = AssetDatabase.GUIDToAssetPath(GUIDs[i]);
                var buildImporter = AssetImporter.GetAtPath(resPath);
                if (buildImporter.UpdateBundleName(buildImporter.GetAssetBundleName(ResGroup.Map2d)))
                {
                    changeCount++;
                    _bundleNameLogger.AppendLine("Update SceneBuildPrefab BundleName:" + resPath);
                }

                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("处理2d场景透明遮罩资源中", String.Format(" {0} / {1} ", i, GUIDs.Length), (float)i / (float)GUIDs.Length);
            }

            GUIDs = AssetDatabase.FindAssets("t:TextAsset", new string[] { SceneRawDataPath });
            for (var i = 0; i < GUIDs.Length; i++)
            {
                var resPath = AssetDatabase.GUIDToAssetPath(GUIDs[i]);
                var configImporter = AssetImporter.GetAtPath(resPath);
                if (configImporter.UpdateBundleName(configImporter.GetAssetBundleName(ResGroup.Map2d)))
                {
                    changeCount++;
                    _bundleNameLogger.AppendLine("Update Config BundleName:" + resPath);
                }

                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("处理配置文件中", string.Format(" {0} / {1} ", i, GUIDs.Length), i / (float)GUIDs.Length);
            }

            if (_showPrograss)
                EditorUtility.ClearProgressBar();
            return changeCount;
        }

        public static int UpdateMap3d()
        {
            var changeCount = 0;
            const string SceneRawDataPath = "Assets/GameRes/Map3d";

            //处理2d场景透明遮罩图集资源
            var GUIDs = AssetDatabase.FindAssets("t:Prefab", new string[] { SceneRawDataPath });
            for (int i = 0; i < GUIDs.Length; i++)
            {
                string resPath = AssetDatabase.GUIDToAssetPath(GUIDs[i]);
                if (resPath.IndexOf("RawData") >= 0)
                {
                    continue;
                }
                string name = Path.GetFileNameWithoutExtension(resPath);

                var buildImporter = AssetImporter.GetAtPath(resPath);
                if (buildImporter.UpdateBundleName(buildImporter.GetAssetBundleName(ResGroup.Map3d)))
                {
                    changeCount++;
                    _bundleNameLogger.AppendLine("Update SceneBuildPrefab BundleName:" + resPath);
                }

                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("处理2d场景透明遮罩资源中", String.Format(" {0} / {1} ", i, GUIDs.Length), (float)i / (float)GUIDs.Length);

                var dependencies = AssetDatabase.GetDependencies(resPath);
                for (var effMatIndex = 0; effMatIndex < dependencies.Length; effMatIndex++)
                {
                    var refPath = dependencies[effMatIndex];
                    if (refPath.IsTextureFile() && refPath.IsMap3dRes())
                    {
                        var shaderImporter = AssetImporter.GetAtPath(refPath);
                        if (shaderImporter.UpdateBundleName(buildImporter.GetAssetBundleName(ResGroup.Map3d) + "_tex"))
                        {
                            changeCount++;
                            _bundleNameLogger.AppendLine("Update EffectShader BundleName:" + refPath);
                        }
                    }
                }
            }

            GUIDs = AssetDatabase.FindAssets("t:TextAsset", new string[] { SceneRawDataPath });
            for (var i = 0; i < GUIDs.Length; i++)
            {
                var resPath = AssetDatabase.GUIDToAssetPath(GUIDs[i]);
                var configImporter = AssetImporter.GetAtPath(resPath);
                if (configImporter.UpdateBundleName(configImporter.GetAssetBundleName(ResGroup.Map3d)))
                {
                    changeCount++;
                    _bundleNameLogger.AppendLine("Update Config BundleName:" + resPath);
                }

                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("处理配置文件中", string.Format(" {0} / {1} ", i, GUIDs.Length), i / (float)GUIDs.Length);
            }

            if (_showPrograss)
                EditorUtility.ClearProgressBar();
            return changeCount;
        }


        public static int UpdateAudio()
        {
            var changeCount = 0;
            //处理音频资源
            var GUIDs = AssetDatabase.FindAssets("t:AudioClip", BuildBundlePath.AudioFolder);
            for (var i = 0; i < GUIDs.Length; i++)
            {
                var resPath = AssetDatabase.GUIDToAssetPath(GUIDs[i]);
                if (resPath.IsCommonAsset()) continue;
                var audioImporter = AssetImporter.GetAtPath(resPath);
                if (audioImporter.UpdateBundleName(audioImporter.GetAssetBundleName(ResGroup.Audio)))
                {
                    changeCount++;
                    _bundleNameLogger.AppendLine("Update Audio BundleName:" + resPath);
                }

                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("处理音频资源中", string.Format(" {0} / {1} ", i, GUIDs.Length),
                        i / (float)GUIDs.Length);
            }
            if (_showPrograss)
                EditorUtility.ClearProgressBar();
            return changeCount;
        }

        public static int UpdateConfig()
        {
            var changeCount = 0;
            //处理配置文件资源
            var GUIDs = AssetDatabase.FindAssets("t:TextAsset", BuildBundlePath.ConfigFolder);
            for (var i = 0; i < GUIDs.Length; i++)
            {
                var resPath = AssetDatabase.GUIDToAssetPath(GUIDs[i]);
                var configImporter = AssetImporter.GetAtPath(resPath);
                if (configImporter.UpdateBundleName(configImporter.GetAssetBundleName(ResGroup.Config)))
                {
                    changeCount++;
                    _bundleNameLogger.AppendLine("Update Config BundleName:" + resPath);
                }

                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("处理配置文件中", string.Format(" {0} / {1} ", i, GUIDs.Length),
                        i / (float)GUIDs.Length);
            }

            //处理静态数据文件
            //#if ENABLE_JSB
            //            var staticDataFiles = Directory.GetFiles("Assets/GameResources/StaticData", "*.jsz.bytes");
            //#else
            //            var staticDataFiles = Directory.GetFiles("Assets/GameResources/StaticData", "*.pbz.bytes");
            //#endif
            //            for (int i = 0; i < staticDataFiles.Length; i++)
            //            {
            //                string file = staticDataFiles[i];
            //                var importer = AssetImporter.GetAtPath(file);
            //                if (importer != null && importer.UpdateBundleName("config/allstaticdata"))
            //                {
            //                    changeCount++;
            //                    _bundleNameLogger.AppendLine("Update Config BundleName:" + importer.assetPath);
            //                }

            //                if (_showPrograss)
            //                    EditorUtility.DisplayProgressBar("处理静态数据中", string.Format(" {0} / {1} ", i, staticDataFiles.Length),
            //                        i / (float)staticDataFiles.Length);
            //            }

            if (_showPrograss)
                EditorUtility.ClearProgressBar();
            return changeCount;
        }

        public static int UpdateLive2d()
        {
            var changeCount = 0;
            //处理bytes文件资源
            var textGUIDs = AssetDatabase.FindAssets("t:TextAsset", BuildBundlePath.Live2dFolder);
            for (var i = 0; i < textGUIDs.Length; i++)
            {
                var resPath = AssetDatabase.GUIDToAssetPath(textGUIDs[i]);
                var importer = AssetImporter.GetAtPath(resPath);
                if (importer.UpdateBundleName(importer.GetAssetBundleName(ResGroup.Live2d)))
                {
                    changeCount++;
                    _bundleNameLogger.AppendLine("Update Live2d BundleName:" + resPath);
                }

                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("处理Live2d Bytes中", string.Format(" {0} / {1} ", i, textGUIDs.Length),
                        i / (float)textGUIDs.Length);
            }

            var textureGUIDs = AssetDatabase.FindAssets("t:Texture", BuildBundlePath.Live2dFolder);
            for (var i = 0; i < textureGUIDs.Length; i++)
            {
                var resPath = AssetDatabase.GUIDToAssetPath(textureGUIDs[i]);
                var importer = AssetImporter.GetAtPath(resPath);
                if (importer.UpdateBundleName(importer.GetAssetBundleName(ResGroup.Live2d)))
                {
                    changeCount++;
                    _bundleNameLogger.AppendLine("Update Live2d BundleName:" + resPath);
                }

                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("处理Live2d Texture中", string.Format(" {0} / {1} ", i, textureGUIDs.Length),
                        i / (float)textureGUIDs.Length);
            }

            if (_showPrograss)
                EditorUtility.ClearProgressBar();
            return changeCount;
        }

        public static int UpdateMaterial()
        {
            var changeCount = 0;
            var matGUIDs = AssetDatabase.FindAssets("t:Material", BuildBundlePath.MaterialFolder);
            for (var i = 0; i < matGUIDs.Length; i++)
            {
                var resPath = AssetDatabase.GUIDToAssetPath(matGUIDs[i]);
                var importer = AssetImporter.GetAtPath(resPath);
                if (importer.UpdateBundleName(importer.GetAssetBundleName(ResGroup.Material)))
                {
                    changeCount++;
                    _bundleNameLogger.AppendLine("Update Material BundleName:" + resPath);
                }

                var dependencies = AssetDatabase.GetDependencies(resPath);
                for (var effMatIndex = 0; effMatIndex < dependencies.Length; effMatIndex++)
                {
                    var refPath = dependencies[effMatIndex];
                    if (refPath.IsShaderFile())
                    {
                        var shaderImporter = AssetImporter.GetAtPath(refPath);
                        if (shaderImporter.UpdateBundleName(GameResPath.AllShaderBundleName))
                        {
                            changeCount++;
                            _bundleNameLogger.AppendLine("Update EffectShader BundleName:" + refPath);
                        }
                    }
                }

                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("处理Material mat中", string.Format(" {0} / {1} ", i, matGUIDs.Length),
                        i / (float)matGUIDs.Length);
            }

            var textureGUIDs = AssetDatabase.FindAssets("t:Texture", BuildBundlePath.MaterialFolder);
            for (var i = 0; i < textureGUIDs.Length; i++)
            {
                var resPath = AssetDatabase.GUIDToAssetPath(textureGUIDs[i]);
                var importer = AssetImporter.GetAtPath(resPath);
                if (importer.UpdateBundleName(importer.GetAssetBundleName(ResGroup.Material)))
                {
                    changeCount++;
                    _bundleNameLogger.AppendLine("Update Material BundleName:" + resPath);
                }

                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("处理Material Texture中", string.Format(" {0} / {1} ", i, textureGUIDs.Length),
                        i / (float)textureGUIDs.Length);
            }
            if (_showPrograss)
                EditorUtility.ClearProgressBar();
            return changeCount;
        }

        #endregion

        #region Build AssetBundle

        private void BuildAssetBundle(int resVer, int svnVer)
        {
            var stopwatch = Stopwatch.StartNew();

            UIAtlasTools.UIAtlasCompressCheck();
            if (EditorUserBuildSettings.activeBuildTarget == BuildTarget.iOS)
				UIAtlasTools.SetAtlasRGBAlphaChannelMaterial ();

            var exportDir = GetExportBundlePath();
            //根据已设置好的BundleName信息生成AssetBundleBuild列表
#if BUNDLE_APPEND_HASH
            var lz4Options = BuildAssetBundleOptions.AppendHashToAssetBundleName |
                             BuildAssetBundleOptions.ChunkBasedCompression;
            var lzmaOptions = BuildAssetBundleOptions.AppendHashToAssetBundleName;
            var uncompressOptions = BuildAssetBundleOptions.UncompressedAssetBundle | uildAssetBundleOptions.AppendHashToAssetBundleName;
#else
            var lz4Options = BuildAssetBundleOptions.ChunkBasedCompression;
            var lzmaOptions = BuildAssetBundleOptions.None;
            var uncompressOptions = BuildAssetBundleOptions.UncompressedAssetBundle;
#endif
            List<AssetBundleBuild> lz4ResList;
            List<AssetBundleBuild> lzmaResList;
            List<AssetBundleBuild> uncompressResList;

            GenerateAssetBundleBuildList(out lz4ResList, out lzmaResList, out uncompressResList);
            BuildBundles(exportDir + "/lz4", lz4ResList, lz4Options);
            BuildBundles(exportDir + "/lzma", lzmaResList, lzmaOptions);
            BuildBundles(exportDir + "/uncompress", uncompressResList, uncompressOptions);
            //打包TileMap
            //string path = Application.dataPath + "/GameRes/TileMap";
            //JPGTexTool.BuildTexture(path);
            //生成该版本ResConfig成功后才备份该版本资源
            //var newResConfig = GenerateResConfig(exportDir, resVer, svnVer);
            //if (newResConfig != null)
            //{
            //    BackupAssetBundle(newResConfig, exportDir);
            //}

            stopwatch.Stop();
            var elapsed = stopwatch.Elapsed;
            if (!_slientMode)
            {
                EditorUtility.DisplayDialog("提示",
                    string.Format("打包项目资源总耗时:{0:00}:{1:00}:{2:00}:{3:00}\n", elapsed.Hours, elapsed.Minutes,
                        elapsed.Seconds, elapsed.Milliseconds / 10), "OK");
            }
            else
            {
                Debug.Log(string.Format("打包项目资源总耗时:{0:00}:{1:00}:{2:00}:{3:00}\n", elapsed.Hours, elapsed.Minutes,
                    elapsed.Seconds, elapsed.Milliseconds / 10));
            }
            AssetDatabase.Refresh();
        }


        private void GenerateAndBackupAssetBundle(int resVer, int svnVer)
        {
            var exportDir = GetExportBundlePath();
			var newResConfig = GenerateResConfig(resVer, svnVer);
            if (newResConfig != null)
            {
                BackupAssetBundle(newResConfig);
            }
            AssetDatabase.Refresh();
        }

        private void GenerateAssetBundleBuildList(out List<AssetBundleBuild> lz4ResList, out List<AssetBundleBuild> lzmaResList, out List<AssetBundleBuild> uncompressResList)
        {
            lz4ResList = new List<AssetBundleBuild>();
            lzmaResList = new List<AssetBundleBuild>();
            uncompressResList = new List<AssetBundleBuild>();
            foreach (var pair in _projectBundleNameGroups)
			{
				var resGroup = pair.Key;
				var bundleNames = pair.Value;
				if(resGroup == ResGroup.TileMap)    //只用于编辑器下加载
					continue;
				if (resGroup == ResGroup.Common)
				{
					foreach (string bundleName in bundleNames)
					{
						var abb = new AssetBundleBuild
						{
							assetBundleName = bundleName,
							assetNames = AssetDatabase.GetAssetPathsFromAssetBundle(bundleName)
						};
						lz4ResList.Add(abb);
						lzmaResList.Add(abb);
					}
				}
				else if (resGroup == ResGroup.Atlas
					|| resGroup == ResGroup.Font
					|| resGroup == ResGroup.Material
					|| resGroup == ResGroup.UI
					|| resGroup == ResGroup.Texture
//					|| resGroup == ResGroup.Model
//					|| resGroup == ResGroup.Effect
//					|| resGroup == ResGroup.Audio
				)
				{
					foreach (string bundleName in bundleNames)
					{
						var abb = new AssetBundleBuild
						{
							assetBundleName = bundleName,
							assetNames = AssetDatabase.GetAssetPathsFromAssetBundle(bundleName)
						};
						lz4ResList.Add(abb);
					}
				}
				else
				{
					foreach (string bundleName in bundleNames)
					{
						var abb = new AssetBundleBuild
						{
							assetBundleName = bundleName,
							assetNames = AssetDatabase.GetAssetPathsFromAssetBundle(bundleName)
						};
						lzmaResList.Add(abb);
					}
				}
			}
		}
		
		private void BuildBundles(string exportDir, List<AssetBundleBuild> abbList, BuildAssetBundleOptions buildOptions)
        {
            CreateDirectory(exportDir);
            BuildPipeline.BuildAssetBundles(exportDir, abbList.ToArray(), buildOptions, EditorUserBuildSettings.activeBuildTarget);
        }

        /// <summary>
        /// 根据Unity打包生成的manifest信息生成自定义的ResConfig信息
        /// </summary>
        private ResConfig GenerateResConfig(int resVer, int svnVer)
        {
			var exportDir = GetExportBundlePath();
            string lz4Root = exportDir + "/lz4";
            string lzmaRoot = exportDir + "/lzma";
            string uncompressRoot = exportDir + "/uncompress";

            string lz4ManifestPath = lz4Root + "/lz4.manifest";
            var lz4Manifest = LoadYAMLObj<RawAssetManifest>(lz4ManifestPath);
            if (lz4Manifest == null)
            {
                Debug.LogError("解析Manifest文件失败:" + lz4ManifestPath);
                return null;
            }

            string lzmaManifestPath = lzmaRoot + "/lzma.manifest";
            var lzmaManifest = LoadYAMLObj<RawAssetManifest>(lzmaManifestPath);
            if (lzmaManifest == null)
            {
                Debug.LogError("解析Manifest文件失败:" + lzmaManifestPath);
                return null;
            }

            //string uncompressManifestPath = lz4Root + "/uncompress.manifest";
            //var uncompress4Manifest = LoadYAMLObj<RawAssetManifest>(uncompressManifestPath);
            //if (uncompress4Manifest == null)
            //{
            //    Debug.LogError("解析Manifest文件失败:" + uncompress4Manifest);
            //    return null;
            //}

            //此次打包的资源ManifestCRC与上个版本一致时,询问用户是否跳过
            bool skip = _curResConfig != null && _curResConfig.lz4CRC == lz4Manifest.CRC;
            if (skip)
            {
                //return null;
                Debug.Log("提示:本次打包资源ManifestCRC与上次一致");
            }

            var newResConfig = new ResConfig
            {
                Version = resVer,
                svnVersion = svnVer,
                lz4CRC = lz4Manifest.CRC,
                lzmaCRC = 0,
                BuildTime = Convert.ToInt64(DateTime.Now.ToString("yyyyMMddHHmmss")),
            };

            //生成UI资源与Common资源ResInfo信息
            foreach (var bundleInfo in lz4Manifest.Manifest.AssetBundleInfos.Values)
            {
                string bundleName = StripHashSuffix(bundleInfo.Name);
                var bundleManifest = LoadYAMLObj<RawBundleManifest>(lz4Root + "/" + bundleName + ".manifest");
                if (bundleManifest != null)
                {
                    var resInfo = new ResInfo
                    {
                        bundleName = bundleName,
                        CRC = bundleManifest.CRC,
                        Hash = bundleManifest.Hashes["AssetFileHash"].Hash,
                        isPackageRes = true,
                    };
                    UpdatePreloadFlag(resInfo);
                    UpdateRemoteZipType(resInfo);
                    //resInfo.remoteZipType = CompressType.UnityLZ4;

                    foreach (string dependency in bundleInfo.Dependencies.Values)
                    {
                        //无需记录Common类的资源依赖,因为这部分资源加载了就不释放了
                        //if (dependency.StartsWith("common/")) continue;
                        resInfo.Dependencies.Add(StripHashSuffix(dependency));
                    }

                    newResConfig.Manifest.Add(bundleName, resInfo);
                }
                else
                {
                    Debug.LogError("解析BundleManifest文件失败:" + bundleInfo.Name);
                    return null;
                }
            }

            //生成SceneTileMap的Resinfo信息
            //string[] tileMaps = Directory.GetFiles(customRoot, "*.json");
            //foreach (string path in tileMaps)
            //{
            //    JPGTexTool.TexConverInfo converInfo =
            //        JsonMapper.ToObject<JPGTexTool.TexConverInfo>(File.ReadAllText(path));
            //    string bundleName = converInfo.bundleName;
            //    var resInfo = new ResInfo
            //    {
            //        bundleName = bundleName,
            //        CRC = converInfo.sourceFileCRC,
            //        remoteZipType = CompressType.CustomTex,
            //    };
            //    newResConfig.Manifest.Add(bundleName, resInfo);
            //    UpdatePreloadFlag(resInfo);
            //}

            //生成其他资源ResInfo信息
            foreach (var bundleInfo in lzmaManifest.Manifest.AssetBundleInfos.Values)
            {
                string bundleName = StripHashSuffix(bundleInfo.Name);
                if (bundleName.StartsWith("common/")) continue;
                var bundleManifest = LoadYAMLObj<RawBundleManifest>(lzmaRoot + "/" + bundleName + ".manifest");
                if (bundleManifest != null)
                {
                    var resInfo = new ResInfo
                    {
                        bundleName = bundleName,
                        CRC = bundleManifest.CRC,
                        Hash = bundleManifest.Hashes["AssetFileHash"].Hash,
                    };
                    UpdatePreloadFlag(resInfo);
                    UpdateRemoteZipType(resInfo);

                    foreach (string dependency in bundleInfo.Dependencies.Values)
                    {
                        //无需记录Common类的资源依赖,因为这部分资源加载了就不释放了
                        //if (dependency.StartsWith("common/")) continue;
                        resInfo.Dependencies.Add(StripHashSuffix(dependency));
                    }

                    if (newResConfig.Manifest.ContainsKey(bundleName))
                        Debug.LogError("ResConfig 字段已经存在: " + bundleName);
                    newResConfig.Manifest.Add(bundleName, resInfo);
                }
                else
                {
                    Debug.LogError("解析BundleManifest文件失败:" + bundleInfo.Name);
                    return null;
                }
            }

            return newResConfig;
        }

        /// <summary>
        /// 根据资源类型更新preload标记
        /// </summary>
        /// <param name="resInfo"></param>
        private void UpdatePreloadFlag(ResInfo resInfo)
        {
            var resGroup = ResConfig.GetResGroupFromBundleName(resInfo.bundleName);
            if (resGroup == ResGroup.Common)
            {
                resInfo.preload = true;
            }
            else if (_buildBundleStrategy.preloadConfig.ContainsKey(resInfo.bundleName))
            {
                resInfo.preload = true;
            }
        }

        /// <summary>
        /// 默认为CustomZip,实际测试发现部分资源压缩后变化不大,所以不采用Zip压缩处理
        /// </summary>
		/// <param name="resInfo"></param>
        private void UpdateRemoteZipType(ResInfo resInfo)
        {
            var resGroup = ResConfig.GetResGroupFromBundleName(resInfo.bundleName);
			if (resGroup == ResGroup.Common
				|| resGroup == ResGroup.Atlas
				|| resGroup == ResGroup.Font
				|| resGroup == ResGroup.Material
				|| resGroup == ResGroup.UI
			    || resGroup == ResGroup.Texture
			    //|| resGroup == ResGroup.Model
			    //|| resGroup == ResGroup.Effect
			    //|| resGroup == ResGroup.Audio
			)
            {
                //不做压缩处理了,统一以Unity原生打包压缩格式来处理
                resInfo.remoteZipType = CompressType.UnityLZ4;
                ////除了UIPrefab,其他UI资源和Common资源都需要用Zip再压缩一遍后再上传CDN,尽量减少资源更新的下载量
                //resInfo.remoteZipType = resGroup == ResGroup.UIPrefab ? CompressType.UnityLZ4 : CompressType.CustomZip;
            }
            else
            {
                resInfo.remoteZipType = CompressType.UnityLZMA;
            }
        }

        private void BackupAssetBundle(ResConfig newResConfig)
        {
            var exportDir = GetExportBundlePath();
            //打包资源完毕,备份当前版本资源到gameres_{CRC}目录
            try
            {
                string lz4ExportRoot = exportDir + "/lz4";
                string lzmaExportRoot = exportDir + "/lzma";
                string tileMapExportRoot = exportDir + "/custom";

                if (newResConfig != null)
                {
                    var backupDir = GetBackupDir(newResConfig);
                    //先删除之前已存在的资源目录
                    if (FileUtil.DeleteFileOrDirectory(backupDir))
                    {
                        Debug.Log("旧版本资源目录已存在,将清空后重新备份:" + backupDir);
                    }
                    string lz4BackupRoot = backupDir + "/lz4";
                    string lzmaBackupRoot = backupDir + "/lzma";
                    Directory.CreateDirectory(lz4BackupRoot);
                    Directory.CreateDirectory(lzmaBackupRoot);

                    //先备份AssetBundleManifest信息
                    FileUtil.CopyFileOrDirectory(lz4ExportRoot + "/lz4", lz4BackupRoot + "/lz4");
                    FileUtil.CopyFileOrDirectory(lz4ExportRoot + "/lz4.manifest", lz4BackupRoot + "/lz4.manifest");

                    FileUtil.CopyFileOrDirectory(lzmaExportRoot + "/lzma", lzmaBackupRoot + "/lzma");
                    FileUtil.CopyFileOrDirectory(lzmaExportRoot + "/lzma.manifest", lzmaBackupRoot + "/lzma.manifest");

                    int finishedCount = 0;
                    //备份该版本资源的Bundle及其manifest文件到备份目录
                    foreach (var resInfo in newResConfig.Manifest.Values)
                    {
                        string bundleExportDir = GetBundleBackupDir(resInfo, exportDir);
                        string bundleBackupDir = GetBundleBackupDir(resInfo, backupDir);

                        var bundleFileInfo = new FileInfo(resInfo.GetExportPath(bundleExportDir));
                        var bundleManifest = resInfo.GetManifestPath(bundleExportDir);
                        if (bundleFileInfo.Exists && File.Exists(bundleManifest))
                        {
                            var backupBundlePath = resInfo.GetABPath(bundleBackupDir);
                            var backupBundleManifest = resInfo.GetManifestPath(bundleBackupDir);
                            Directory.CreateDirectory(Path.GetDirectoryName(backupBundlePath));

                            FileUtil.CopyFileOrDirectory(bundleFileInfo.FullName, backupBundlePath);
                            FileUtil.CopyFileOrDirectory(bundleManifest, backupBundleManifest);

                            //对于压缩类型为CompressType.CustomZip进行压缩备份
                            if (resInfo.remoteZipType == CompressType.CustomZip)
                            {
                                var exportZipPath = resInfo.GetRemotePath(bundleExportDir);
                                if (!File.Exists(exportZipPath))
                                    ZipManager.CompressFile(bundleFileInfo.FullName, exportZipPath);

                                var zipFileInfo = new FileInfo(exportZipPath);
                                if (zipFileInfo.Exists)
                                {
                                    var backupZipPath = resInfo.GetRemotePath(bundleBackupDir);
                                    FileUtil.CopyFileOrDirectory(exportZipPath, backupZipPath);
                                    resInfo.MD5 = MD5Hashing.HashFile(backupZipPath);
                                    resInfo.size = zipFileInfo.Length;
                                }
                                else
                                {
                                    throw new Exception("压缩Bundle异常,请检查:" + bundleFileInfo.FullName);
                                }
                            }
                            else
                            {
                                resInfo.MD5 = MD5Hashing.HashFile(backupBundlePath);
                                resInfo.size = bundleFileInfo.Length;
                            }

                            //统计压缩后该版本资源的总大小
                            newResConfig.TotalFileSize += resInfo.size;
                        }
                        else
                        {
                            throw new Exception(string.Format("打包异常,在打包目录找不到该文件或其Manifest文件: {0} \n ManifestPath:{1} \n bundlePath:{2}", resInfo.bundleName, bundleManifest, bundleFileInfo.FullName));
                        }
                        finishedCount += 1;
                        if (_showPrograss)
                            EditorUtility.DisplayProgressBar("备份AssetBundle中",
                                string.Format(" {0} / {1} ", finishedCount, newResConfig.Manifest.Count),
                                finishedCount / (float)newResConfig.Manifest.Count);
                    }

                    //备份完该版本Bundle资源,保存newResConfig信息
                    string jsonPath = GetResConfigRoot() + "/" + newResConfig.ToFileName();
                    //newResConfig.SaveFile(jsonPath, false);
                    FileHelper.SaveJsonObj(newResConfig, jsonPath, false, true);
                    string jzPath = GetResConfigRoot() + "/" + newResConfig.ToRemoteName();
                    //FileHelper.SaveJsonObj(newResConfig, jzPath, true);
                    newResConfig.SaveFile(jzPath, true);
                    newResConfig.CheckSelfDependencies();
                    newResConfig.CheckAssetBundleName();
                    RefreshResConfigData(newResConfig);
                    EditorPrefs.SetString("LastResConfigPath", jsonPath);

                }
                else
                {
                    throw new Exception("curResConfig is null");
                }
            }
            catch (Exception e)
            {
                Debug.LogError(e.Message);
                EditorUtility.DisplayDialog("提示", "备份当前版本资源失败,详情查看Log!!!", "OK");
            }

            if (_showPrograss)
                EditorUtility.ClearProgressBar();
        }

        #endregion

        #region 小包资源配置策略

        private static void RemoveMinResKeySetRecursively(string resKey, ResInfo resInfo)
        {
            _buildBundleStrategy.RemoveMinResKey(resKey);
            if (resInfo.Dependencies.Count > 0)
            {
                for (int i = 0; i < resInfo.Dependencies.Count; i++)
                {
                    var refResInfo = _curResConfig.GetResInfo(resInfo.Dependencies[i]);
                    if (refResInfo != null)
                    {
                        RemoveMinResKeySetRecursively(resInfo.Dependencies[i], refResInfo);
                    }
                }
            }
        }

        private static void AddMinResKeySetRecursively(string resKey, ResInfo resInfo)
        {
            _buildBundleStrategy.AddMinResKey(resKey);
            if (resInfo.Dependencies.Count > 0)
            {
                for (int i = 0; i < resInfo.Dependencies.Count; i++)
                {
                    var refResInfo = _curResConfig.GetResInfo(resInfo.Dependencies[i]);
                    if (refResInfo != null)
                    {
                        AddMinResKeySetRecursively(resInfo.Dependencies[i], refResInfo);
                    }
                }
            }
        }


        private static bool IsMiniRes(string name, ResGroup resGroup)
        {
            if (name.StartsWith("audio/sound_story"))
                return false;

            return resGroup == ResGroup.Common ||
                   resGroup == ResGroup.UI || resGroup == ResGroup.Atlas || resGroup == ResGroup.Font ||
                    resGroup == ResGroup.Texture ||
                    resGroup == ResGroup.Config ||
                   resGroup == ResGroup.Script;
        }

        private static bool IsMiniResType(ResGroup resGroup)
        {
            return resGroup == ResGroup.Common ||
                   resGroup == ResGroup.UI || resGroup == ResGroup.Atlas || resGroup == ResGroup.Font ||
                   resGroup == ResGroup.Texture ||
                   resGroup == ResGroup.Config ||
                   resGroup == ResGroup.Script;
        }

        private static bool IsMiniResType(ResInfo resInfo)
        {
            var resGroup = ResConfig.GetResGroupFromBundleName(resInfo.bundleName);
            return IsMiniResType(resGroup);
        }

        private static void SaveBuildBundleStrategy()
        {
            if (_buildBundleStrategy == null) return;
            FileHelper.SaveJsonObj(_buildBundleStrategy, GetBuildBundleStrategyPath(), false, true);
        }

        #endregion

        #region 生成StreamingAssets资源

        private void GenerateTotalRes()
        {
            GeneratePackageBundle(false);
        }

        private void GenerateMiniRes()
        {
            GeneratePackageBundle(true);
        }

        /// <summary>
        /// 迁移Bundle到StreamingAssets下
        /// </summary>
        private void GeneratePackageBundle(bool isMiniRes)
        {
            if (_curResConfig == null)
            {
                EditorUtility.DisplayDialog("确认", "当前版本信息为空,请重新确认?", "Yes");
                return;
            }

            //避免textures文件夹被删，先移动目录
            string texturesDir = Application.streamingAssetsPath + "/" + GameResPath.REPLACETEXTURE_ROOT;
            string tempTexturesDir = Application.dataPath + "/" + GameResPath.REPLACETEXTURE_ROOT;

            //FileUtil.DeleteFileOrDirectory(tempTexturesDir);
            FileUtil.MoveFileOrDirectory(texturesDir, tempTexturesDir);

            //先清空StreamingAsset资源目录
            FileUtil.DeleteFileOrDirectory(Application.streamingAssetsPath);
            string packageDir = Application.streamingAssetsPath + "/" + GameResPath.BUNDLE_ROOT;
            Directory.CreateDirectory(packageDir);
            FileUtil.MoveFileOrDirectory(tempTexturesDir, texturesDir);

            var stopwatch = new Stopwatch();
            stopwatch.Start();
            var backupDir = GetBackupDir(_curResConfig);
            var finishedCount = 0;
            var bundleCount = _curResConfig.Manifest.Count;
            long totalFileLength = 0L;
            try
            {
                var miniResConfig = isMiniRes ? new MiniResConfig() : null;
                foreach (var resInfo in _curResConfig.Manifest.Values)
                {
                    //小包模式下,只拷贝必需资源到包内
                    resInfo.isPackageRes = true;
                    if (isMiniRes && !_buildBundleStrategy.minResConfig.ContainsKey(resInfo.bundleName))
                    {
                        resInfo.isPackageRes = false;
                        string replaceKey = "";
                        if (!_buildBundleStrategy.replaceResConfig.TryGetValue(resInfo.bundleName, out replaceKey))
                        {
                            Debug.LogError("该BundleName未设置replaceKey,请检查:" + resInfo.bundleName);
                        }
                        miniResConfig.replaceResConfig.Add(resInfo.bundleName, replaceKey);
                    }

                    if (resInfo.isPackageRes)
                    {
                        string bundleBackupDir = GetBundleBackupDir(resInfo, backupDir);
                        var inputFile = resInfo.GetABPath(bundleBackupDir);
                        if (File.Exists(inputFile))
                        {
                            var outputFile = resInfo.GetABPath(packageDir);
                            var dir = Path.GetDirectoryName(outputFile);
                            totalFileLength += resInfo.size;
                            Directory.CreateDirectory(dir);
                            if ((resInfo.remoteZipType == CompressType.UnityLZ4 || resInfo.remoteZipType == CompressType.UnityLZMA) && (EditorUserBuildSettings.activeBuildTarget == BuildTarget.iOS))
                            {
                                // 随机就好
                                var addByte = (byte) UnityEngine.Random.Range(0, 255);
                                using (var sw = new FileStream(outputFile, FileMode.Create, FileAccess.Write))
                                {
                                    sw.Position = 0;
                                    sw.WriteByte(addByte);
                                    var bytes = FileHelper.ReadAllBytes(inputFile);
                                    sw.Write(bytes, 0, bytes.Length);
                                    sw.Flush();
                                    sw.Close();
                                }
                            }
                            else
                            {
                                FileUtil.CopyFileOrDirectory(inputFile, outputFile);
                            }
                        }
                        else
                        {
                            throw new Exception("生成包内资源异常,不存在该Bundle文件:" + inputFile);
                        }
                    }

                    finishedCount += 1;
                    if (_showPrograss)
                        EditorUtility.DisplayProgressBar("拷贝AssetBundle中",
                            string.Format(" {0} / {1} ", finishedCount, bundleCount), (float)finishedCount / bundleCount);
                }

                if (isMiniRes)
                {
                    //小包模式下,需要生成MiniResConfig到包内
                    FileHelper.SaveJsonObj(miniResConfig, Application.streamingAssetsPath + "/" + GameResPath.MINIRESCONFIG_FILE, true);
                    //FileHelper.SaveJsonObj(miniResConfig, Application.streamingAssetsPath + "/" + GameResPath.MINIRESCONFIG_FILE + ".json", false, true);
                }

                if (EditorUserBuildSettings.activeBuildTarget == BuildTarget.Android ||
                    EditorUserBuildSettings.activeBuildTarget == BuildTarget.StandaloneWindows)
                {
                    //Android和PC需要生成一个空的DllVersion配置信息,等打包完毕后读取包内dll信息再处理
                    var dllVersion = new DllVersion();
                    FileHelper.SaveJsonObj(dllVersion, Application.streamingAssetsPath + "/" + GameResPath.DLLVERSION_FILE, false, true);
                }

                string packageResConfigPath = Path.Combine(Application.streamingAssetsPath, GameResPath.RESCONFIG_FILE);
                _curResConfig.isMiniRes = isMiniRes;
                //FileHelper.SaveJsonObj(_curResConfig, packageResConfigPath, true);
                _curResConfig.SaveFile(packageResConfigPath, true);

                //_curResConfig.SaveJson(packageResConfigPath + ".json");
            }
            catch (Exception e)
            {
                Debug.LogError(e.Message);
                if (_showPrograss)
                    EditorUtility.ClearProgressBar();
                AssetDatabase.Refresh();
                return;
            }

            if (_showPrograss)
                EditorUtility.ClearProgressBar();

            AssetDatabase.Refresh();
            stopwatch.Stop();
            var elapsed = stopwatch.Elapsed;
            string hint = string.Format("迁移资源到StreamingAssets耗时:{0:00}:{1:00}:{2:00}:{3:00}\n包内资源大小为:{4}", elapsed.Hours,
                elapsed.Minutes, elapsed.Seconds, elapsed.Milliseconds / 10, EditorUtility.FormatBytes(totalFileLength));
            if (!_showPrograss && !_slientMode)
            {
                EditorUtility.DisplayDialog("提示", hint, "Yes");
            }

            Debug.Log(hint);
        }

        public static void GeneratePackageScript()
        {
            long curVer = _curResConfig.Version;
            string curFile = GetExportScriptPath() + "/script_" + curVer;
            if (File.Exists(curFile))
            {
                string dstFile = Application.streamingAssetsPath + "/script";
                File.Copy(curFile, dstFile, true);
                Debug.LogFormat("生成脚本 path={0}  version={1}", dstFile, curVer);
            }
            else
            {
                Debug.LogError("找不到脚本文件 " + curFile);
            }
        }

        #endregion

        #region 还原备份资源到打包目录
        /// <summary>
        /// 还原指定资源版本号资源到gameres目录中,如果gameres被清空,可从backup中拷贝过来,减少重新打包资源的时间
        /// </summary>
        /// <param name="resConfig"></param>
        private void RevertBackupToGameRes(ResConfig resConfig)
        {
            if (_curResConfig == null)
            {
                EditorUtility.DisplayDialog("确认", "当前版本信息为空,请重新确认?", "Yes");
                return;
            }

            var stopwatch = Stopwatch.StartNew();
            try
            {
                var exportDir = GetExportBundlePath();
                string lz4ExportRoot = exportDir + "/lz4";
                string lzmaExportRoot = exportDir + "/lzma";
                Directory.CreateDirectory(lz4ExportRoot);
                Directory.CreateDirectory(lzmaExportRoot);

                var backupDir = GetBackupDir(_curResConfig);
                string lz4BackupRoot = backupDir + "/lz4";
                string lzmaBackupRoot = backupDir + "/lzma";


                Debug.Log("exportDir " + exportDir);
                Debug.Log("backupDir " + backupDir);

                //先还原AssetBundleManifest信息
                FileUtil.ReplaceFile(lz4BackupRoot + "/lz4", lz4ExportRoot + "/lz4");
                FileUtil.ReplaceFile(lz4BackupRoot + "/lz4.manifest", lz4ExportRoot + "/lz4.manifest");

                FileUtil.ReplaceFile(lzmaBackupRoot + "/lzma", lzmaExportRoot + "/lzma");
                FileUtil.ReplaceFile(lzmaBackupRoot + "/lzma.manifest", lzmaExportRoot + "/lzma.manifest");

                int finishedCount = 0;
                //还原该版本资源的Bundle及其manifest文件到打包目录
                foreach (var resInfo in resConfig.Manifest.Values)
                {
                    string bundleExportDir = GetBundleBackupDir(resInfo, exportDir);
                    string bundleBackupDir = GetBundleBackupDir(resInfo, backupDir);

                    var bundleFileInfo = new FileInfo(resInfo.GetABPath(bundleBackupDir));
                    var bundleManifest = resInfo.GetManifestPath(bundleBackupDir);
                    if (bundleFileInfo.Exists && File.Exists(bundleManifest))
                    {
                        var exportBundlePath = resInfo.GetExportPath(bundleExportDir);
                        var exportBundleManifest = resInfo.GetManifestPath(bundleExportDir);
                        Directory.CreateDirectory(Path.GetDirectoryName(exportBundlePath));

                        FileUtil.ReplaceFile(bundleFileInfo.FullName, exportBundlePath);
                        FileUtil.ReplaceFile(bundleManifest, exportBundleManifest);

                        //对于压缩类型为CompressType.CustomZip,压缩包还原
                        if (resInfo.remoteZipType == CompressType.CustomZip)
                        {
                            var backupZipPath = resInfo.GetRemotePath(bundleBackupDir);
                            if (File.Exists(backupZipPath))
                            {
                                FileUtil.ReplaceFile(backupZipPath, resInfo.GetRemotePath(bundleExportDir));
                            }
                        }
                    }
                    else
                    {
                        throw new Exception("还原异常,在备份目录找不到该文件或其Manifest文件:" + resInfo.bundleName);
                    }
                    finishedCount += 1;
                    if (_showPrograss)
                        EditorUtility.DisplayProgressBar("还原AssetBundle中",
                            string.Format(" {0} / {1} ", finishedCount, resConfig.Manifest.Count),
                            finishedCount / (float)resConfig.Manifest.Count);
                }
            }
            catch (Exception e)
            {
                Debug.LogError(e.Message);
                EditorUtility.DisplayDialog("提示", "还原当前版本资源失败,详情查看Log!!!", "OK");
            }

            if (_showPrograss)
                EditorUtility.ClearProgressBar();

            stopwatch.Stop();
            var elapsed = stopwatch.Elapsed;
            if (!_slientMode)
            {
                EditorUtility.DisplayDialog("提示",
                    string.Format("还原Bundle资源总耗时:{0:00}:{1:00}:{2:00}:{3:00}\n", elapsed.Hours, elapsed.Minutes,
                        elapsed.Seconds, elapsed.Milliseconds / 10), "OK");
            }
            else
            {
                Debug.Log(string.Format("还原Bundle资源总耗时:{0:00}:{1:00}:{2:00}:{3:00}\n", elapsed.Hours, elapsed.Minutes,
                    elapsed.Seconds, elapsed.Milliseconds / 10));
            }
        }
        #endregion

        #region 生成PatchInfo

        /// <summary>
        /// 加载patchinfo目录下所有版本更新信息
        /// </summary>
        private void LoadAllPatchInfo()
        {
            var patchInfoFiles = Directory.GetFiles(GetPatchInfoRoot());
            _patchInfoList = new List<ResPatchInfo>(patchInfoFiles.Length);
            foreach (string filePath in patchInfoFiles)
            {
                string fileName = Path.GetFileName(filePath);
                //Mac下目录中会带有隐藏的.DS_Store文件
                if (string.IsNullOrEmpty(fileName) || !fileName.StartsWith("patch_"))
                    continue;

                try
                {
                    var patchInfo = FileHelper.ReadJsonFile<ResPatchInfo>(filePath);
                    _patchInfoList.Add(patchInfo);
                }
                catch (Exception e)
                {
                    Debug.LogWarning(e);
                }
            }
            _patchInfoList.Sort(SortByCurVer);
        }

        /// <summary>
        /// 生成历史各版本升级到最新版本的PatchInfo信息
        /// </summary>
        private void GenerateAllPatchInfo()
        {
            if (_curResConfig == null)
                return;

            string resConfigRoot = GetResConfigRoot();
            var configFiles = Directory.GetFiles(resConfigRoot, "*.json");
            _patchInfoList = new List<ResPatchInfo>(configFiles.Length);
            for (int i = 0; i < configFiles.Length; ++i)
            {
                string fileName = Path.GetFileName(configFiles[i]);
                //Mac下目录中会带有隐藏的.DS_Store文件
                if (string.IsNullOrEmpty(fileName) || !fileName.StartsWith("resConfig_"))
                    continue;

                try
                {
                    ResConfig oldResConfig = LoadResConfig(configFiles[i]);
                    GeneratePatchInfo(oldResConfig, _curResConfig);
                }
                catch (Exception e)
                {
                    Debug.LogError(e.Message);
                    return;
                }
                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("生成PatchInfo中", String.Format(" {0} / {1} ", i, configFiles.Length),
                        (float)i / configFiles.Length);
            }
            if (_showPrograss)
                EditorUtility.ClearProgressBar();

            AssetDatabase.Refresh();
        }

        private void GeneratePatchInfo(ResConfig oldResConfig, ResConfig newResConfig)
        {
            if (oldResConfig == null || newResConfig == null)
            {
                ShowNotification(new GUIContent("ResConfig 为空，请检查"));
                return;
            }

            //无需生成当前版本PatchInfo
            if (oldResConfig.Version == newResConfig.Version)
            {
                return;
            }

            ResPatchInfo patchInfo = new ResPatchInfo
            {
                CurVer = oldResConfig.Version,
                CurLz4CRC = oldResConfig.lz4CRC,
                CurLzmaCRC = oldResConfig.lzmaCRC,
                CurTexCRC = oldResConfig.tileTexCRC,
                EndVer = newResConfig.Version,
                EndLz4CRC = newResConfig.lz4CRC,
                EndLzmaCRC = newResConfig.lzmaCRC,
                EndTexCRC = newResConfig.tileTexCRC
            };

            //生成更新列表
            //CRC不为0，且CRC值发生变更的，加入更新列表
            //oldResConfig不存在的，直接加入更新列表
            foreach (var newRes in newResConfig.Manifest)
            {
                if (oldResConfig.Manifest.ContainsKey(newRes.Key))
                {
                    if (oldResConfig.Manifest[newRes.Key].CRC != newRes.Value.CRC)
                    {
                        patchInfo.updateList.Add(newRes.Value);
                        patchInfo.TotalFileSize += newRes.Value.size;
                    }
                }
                else
                {
                    patchInfo.updateList.Add(newRes.Value);
                    patchInfo.TotalFileSize += newRes.Value.size;
                }
            }

            //生成删除列表
            //oldResConfig的key在newResConfig中找不到对应key的，证明该资源已被删除
            foreach (var oldRes in oldResConfig.Manifest)
            {
                if (!newResConfig.Manifest.ContainsKey(oldRes.Key))
                {
                    patchInfo.removeList.Add(oldRes.Key);
                }
            }

            //导出patch配置信息
            string path = Path.Combine(GetPatchInfoRoot(), patchInfo.ToFileName());
            FileHelper.SaveJsonObj(patchInfo, path, false, true);
            int index = _patchInfoList.FindIndex(info =>
            {
                if (info.ToFileName() == patchInfo.ToFileName())
                    return true;

                return false;
            });
            if (index != -1)
            {
                _patchInfoList[index] = patchInfo;
            }
            else
            {
                _patchInfoList.Add(patchInfo);
                _patchInfoList.Sort(SortByCurVer);
            }
        }

        public static int SortByCurVer(ResPatchInfo a, ResPatchInfo b)
        {
            return -a.CurVer.CompareTo(b.CurVer);
        }

        /// <summary>
        /// 根据ResPatchInfo信息生成需要更新的文件列表
        /// </summary>
        private void GeneratePatchInfoUrlFile(ResPatchInfo patchInfo, string cdnRoot, string cdnRegion)
        {
            if (patchInfo == null)
            {
                this.ShowNotification(new GUIContent("ResPatchInfo 为空，请检查"));
                return;
            }

            if (string.IsNullOrEmpty(cdnRoot))
            {
                this.ShowNotification(new GUIContent("cdnRoot为空，请检查"));
                return;
            }

            if (patchInfo.CurVer != patchInfo.EndVer && patchInfo.updateList.Count == 0)
            {
                this.ShowNotification(new GUIContent("资源未发生变更，无需导出PatchInfo Url信息"));
                return;
            }

            var sb = new StringBuilder();
            string bundleRoot = string.Format("{0}/{1}/staticRes/{2}", cdnRoot, cdnRegion, GameResPath.REMOTE_BUNDLE_ROOT);
            //版本号相同导出当前版本所有资源
            if (patchInfo.CurVer == patchInfo.EndVer)
            {
                foreach (var resInfo in _curResConfig.Manifest.Values)
                {
                    sb.AppendLine(resInfo.GetRemotePath(bundleRoot));
                }
            }
            else
            {
                foreach (var resInfo in patchInfo.updateList)
                {
                    sb.AppendLine(resInfo.GetRemotePath(bundleRoot));
                }
            }

            if (sb.Length > 0)
            {
                string filePath = GetPatchInfoUrlConfigFileName(patchInfo, cdnRegion);
                string dir = Path.GetDirectoryName(filePath);
                Directory.CreateDirectory(dir);
                File.WriteAllText(filePath, sb.ToString());

                OpenDirectory(dir);
            }
        }

        public string GetPatchInfoUrlConfigFileName(ResPatchInfo patchInfo, string cdnRegion)
        {
            string exportRoot = GetExportPlatformPath();
            return String.Format("{0}/patch_urlconfig/patch_url_{1}_{2}_{3}.txt", exportRoot, patchInfo.CurVer,
                patchInfo.EndVer, cdnRegion);
        }

        /// <summary>
        /// 根据oldResConfig与curResConfig生成资源更新清单
        /// </summary>
        private void GeneratePatchRes(ResPatchInfo patchInfo)
        {
            if (patchInfo == null)
            {
                this.ShowNotification(new GUIContent("ResPatchInfo 为空，请检查"));
                return;
            }

            if (patchInfo.CurLz4CRC == patchInfo.EndLz4CRC &&
                patchInfo.CurLzmaCRC == patchInfo.EndLzmaCRC &&
                patchInfo.updateList.Count == 0 && patchInfo.removeList.Count == 0)
            {
                this.ShowNotification(new GUIContent("资源未发生变更，无需导出Patch资源"));
                return;
            }

            string backupDir = GetBackupDir(_curResConfig);
            //如果当前目录已存在,询问用户是否需要重新生成
            string patchResDir = GetPatchResRoot(patchInfo);
            if (Directory.Exists(patchResDir))
            {
                if (EditorUtility.DisplayDialog("确认", "当前PatchInfo的补丁资源已生成,请问是否跳过?", "跳过", "重新生成"))
                    return;
            }

            Debug.Log(string.Format("Remove PatchRes Folder:{0}", FileUtil.DeleteFileOrDirectory(patchResDir)));

            Stopwatch stopwatch = new Stopwatch();
            stopwatch.Start();
            int finishedCount = 0;
            //拷贝AssetBundle到PatchRes目录下
            if (patchInfo.updateList.Count > 0)
            {
                foreach (var resInfo in patchInfo.updateList)
                {
                    string bundleBackupDir = resInfo.remoteZipType == CompressType.UnityLZMA ? backupDir + "/lzma" : backupDir + "/lz4";
                    string inputFile = resInfo.GetRemotePath(bundleBackupDir);

                    try
                    {
                        if (File.Exists(inputFile))
                        {
                            string outputFile = resInfo.GetRemotePath(patchResDir);
                            string dir = Path.GetDirectoryName(outputFile);
                            Directory.CreateDirectory(dir);
                            FileUtil.CopyFileOrDirectory(inputFile, outputFile);
                        }
                    }
                    catch (Exception e)
                    {
                        Debug.LogError(e.Message);
                        if (_showPrograss)
                            EditorUtility.ClearProgressBar();
                        AssetDatabase.Refresh();
                        return;
                    }
                    finishedCount += 1;
                    if (_showPrograss)
                        EditorUtility.DisplayProgressBar("拷贝AssetBundle中",
                            string.Format(" {0} / {1} ", finishedCount, patchInfo.updateList.Count),
                            finishedCount / (float)patchInfo.updateList.Count);
                }
                if (_showPrograss)
                    EditorUtility.ClearProgressBar();
            }
            stopwatch.Stop();
            TimeSpan elapsed = stopwatch.Elapsed;
            if (!_showPrograss && !_slientMode)
            {
                EditorUtility.DisplayDialog("提示",
                    string.Format("生成资源更新清单耗时:{0:00}:{1:00}:{2:00}:{3:00}", elapsed.Hours, elapsed.Minutes,
                        elapsed.Seconds,
                        elapsed.Milliseconds / 10), "Yes");
            }
            else
            {
                Debug.Log(string.Format("生成资源更新清单耗时:{0:00}:{1:00}:{2:00}:{3:00}", elapsed.Hours, elapsed.Minutes,
                    elapsed.Seconds, elapsed.Milliseconds / 10));
            }

            AssetDatabase.Refresh();
            OpenDirectory(patchResDir);
        }

        /// <summary>
        /// 生成指定资源版本的所有CDN上的资源,根据ResInfo.remoteZipType字段对原始打包数据进行压缩
        /// </summary>
        /// <param name="resConfig"></param>
        private void GenerateCdnRes(ResConfig resConfig)
        {
            if (resConfig == null)
            {
                this.ShowNotification(new GUIContent("ResConfig 为空，请检查"));
                return;
            }

            string backupDir = GetBackupDir(resConfig);
            string cdnResDir = string.Format("{0}/{1}", GetExportPlatformPath(), GameResPath.REMOTE_BUNDLE_ROOT);

            Stopwatch stopwatch = new Stopwatch();
            stopwatch.Start();
            int finishedCount = 0;

            foreach (var resInfo in resConfig.Manifest.Values)
            {
                string bundleBackupDir = GetBundleBackupDir(resInfo, backupDir);
                string inputFile = resInfo.GetRemotePath(bundleBackupDir);
                try
                {
                    if (File.Exists(inputFile))
                    {
                        string outputFile2 = resInfo.GetRemotePath(cdnResDir);
                        string dir2 = Path.GetDirectoryName(outputFile2);
                        if (!Directory.Exists(dir2))
                        {
                            Directory.CreateDirectory(dir2);
                        }
                        IOHelper.CopyFile(inputFile, outputFile2);
                    }
                    else
                    {
                        throw new Exception("不存在该文件:" + inputFile);
                    }
                }
                catch (Exception e)
                {
                    Debug.LogError(e.Message);
                    if (_showPrograss)
                        EditorUtility.ClearProgressBar();
                    AssetDatabase.Refresh();
                    return;
                }
                finishedCount += 1;
                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("拷贝AssetBundle中",
                        string.Format(" {0} / {1} ", finishedCount, resConfig.Manifest.Count),
                        finishedCount / (float)resConfig.Manifest.Count);
            }
            if (_showPrograss)
                EditorUtility.ClearProgressBar();
            stopwatch.Stop();
            TimeSpan elapsed = stopwatch.Elapsed;
            if (!_showPrograss && !_slientMode)
            {
                EditorUtility.DisplayDialog("提示",
                    string.Format("生成指定资源版本的所有CDN上的资源耗时:{0:00}:{1:00}:{2:00}:{3:00}", elapsed.Hours, elapsed.Minutes,
                        elapsed.Seconds, elapsed.Milliseconds / 10), "Yes");
            }
            else
            {
                Debug.Log(string.Format("生成指定资源版本的所有CDN上的资源耗时:{0:00}:{1:00}:{2:00}:{3:00}", elapsed.Hours,
                    elapsed.Minutes, elapsed.Seconds, elapsed.Milliseconds / 10));
            }

            AssetDatabase.Refresh();
        }

        private void GenerateRemoteRes(ResConfig resConfig)
        {
            if (resConfig == null)
            {
                this.ShowNotification(new GUIContent("ResConfig 为空，请检查"));
                return;
            }

            string backupDir = GetBackupDir(resConfig);
            //如果当前目录已存在,询问用户是否需要重新生成
            string remoteResDir = GetRemoteResRoot(resConfig.Version);
            if (Directory.Exists(remoteResDir))
            {
                Directory.Delete(remoteResDir);
            }

            string cdnResDir = string.Format("{0}/{1}", GetExportPlatformPath(), GameResPath.REMOTE_BUNDLE_ROOT);

            Stopwatch stopwatch = new Stopwatch();
            stopwatch.Start();
            int finishedCount = 0;

            foreach (var resInfo in resConfig.Manifest.Values)
            {
                string bundleBackupDir = GetBundleBackupDir(resInfo, backupDir);
                string inputFile = resInfo.GetRemotePath(bundleBackupDir);

                try
                {
                    if (File.Exists(inputFile))
                    {
                        //复制到remoteres目录
                        string outputFile = resInfo.GetRemotePath(remoteResDir);
                        string dir = Path.GetDirectoryName(outputFile);
                        if (!Directory.Exists(dir))
                        {
                            Directory.CreateDirectory(dir);
                        }
                        IOHelper.CopyFile(inputFile, outputFile);
                    }
                    else
                    {
                        throw new Exception("不存在该文件:" + inputFile);
                    }
                }
                catch (Exception e)
                {
                    Debug.LogError(e.Message);
                    if (_showPrograss)
                        EditorUtility.ClearProgressBar();
                    AssetDatabase.Refresh();
                    return;
                }
                finishedCount += 1;
                if (_showPrograss)
                    EditorUtility.DisplayProgressBar("拷贝AssetBundle中",
                        string.Format(" {0} / {1} ", finishedCount, resConfig.Manifest.Count),
                        finishedCount / (float)resConfig.Manifest.Count);
            }
            if (_showPrograss)
                EditorUtility.ClearProgressBar();
            stopwatch.Stop();
            TimeSpan elapsed = stopwatch.Elapsed;
            if (!_showPrograss && !_slientMode)
            {
                EditorUtility.DisplayDialog("提示",
                    string.Format("生成指定资源版本的所有CDN上的资源耗时:{0:00}:{1:00}:{2:00}:{3:00}", elapsed.Hours, elapsed.Minutes,
                        elapsed.Seconds, elapsed.Milliseconds / 10), "Yes");
            }
            else
            {
                Debug.Log(string.Format("生成指定资源版本的所有CDN上的资源耗时:{0:00}:{1:00}:{2:00}:{3:00}", elapsed.Hours,
                    elapsed.Minutes, elapsed.Seconds, elapsed.Milliseconds / 10));
            }

            AssetDatabase.Refresh();
            //OpenDirectory(remoteResDir);
        }

        #endregion

        #region Helper Func

        //获取resConfig配置信息目录
        public static string GetResConfigRoot()
        {
            return GetExportPlatformPath() + "/" + GameResPath.RESCONFIG_ROOT;
        }

        public static string GetExportBundlePath()
        {
            return GetExportPlatformPath() + "/" + GameResPath.BUNDLE_ROOT;
        }

        public static string GetBackupRoot()
        {
            return GetExportPlatformPath() + "/backup";
        }

        //根据resConfig版本号，获取版本资源导出目录
        public static string GetBackupDir(ResConfig resConfig)
        {
            if (resConfig == null)
                return null;

            return GetBackupRoot() + "/" + GameResPath.BUNDLE_ROOT + "_" + resConfig.Version;
        }

        public static string GetPatchResRoot(ResPatchInfo patchInfo)
        {
            string exportRoot = GetExportPlatformPath();
            return string.Format("{0}/patch_resources/patch_{1}_{2}", exportRoot, patchInfo.CurVer, patchInfo.EndVer);
        }

        public static string GetRemoteResRoot(int version)
        {
            string exportRoot = GetExportPlatformPath();
            return string.Format("{0}/remoteres/remoteres_{1}", exportRoot, version);
        }

        //获取patch信息目录
        public static string GetPatchInfoRoot()
        {
            return GetExportPlatformPath() + "/patchinfo";
        }

        public static string GetBuildBundleStrategyPath()
        {
            return GameResPath.EXPORT_FOLDER + "/buildBundleStrategy.json";
        }

        private static string GetExportScriptPath()
        {
            return GetExportPlatformPath() + "/script";
        }

        private static string GetExportDllPath()
        {
            return GetExportPlatformPath() + "/dll";
        }

        public static string GetExportPlatformPath()
        {
            string platformRoot;
            if (EditorUserBuildSettings.activeBuildTarget == BuildTarget.Android)
            {
                platformRoot = GameResPath.EXPORT_FOLDER + "/android";
            }
            else if (EditorUserBuildSettings.activeBuildTarget == BuildTarget.iOS)
            {
                platformRoot = GameResPath.EXPORT_FOLDER + "/ios";
            }
            else
            {
                platformRoot = GameResPath.EXPORT_FOLDER + "/win";
            }
            return platformRoot;
        }

        private static void CreateDirectory(string dir)
        {
            if (!Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }
        }

        public static void OpenDirectory(string path)
        {
            if (EditorUtility.DisplayDialog("确认", "是否打开导出资源目录？", "打开", "取消"))
            {
                var dir = Path.GetFullPath(path);
                if (Directory.Exists(dir))
                    Process.Start(dir);
                else
                {
                    EditorUtility.DisplayDialog("提示", "不存在:" + path + " 目录", "OK");
                }
            }
        }

        public static T LoadYAMLObj<T>(string path)
        {
            using (var sr = new StreamReader(path))
            {
                var yamlParser = new YamlDotNet.Serialization.DeserializerBuilder();
                return yamlParser.Build().Deserialize<T>(sr);
            }
        }

        public static string StripHashSuffix(string bundleName)
        {
#if BUNDLE_APPEND_HASH
            int index = bundleName.LastIndexOf('_');
            if (index > 0)
            {
                return bundleName.Substring(0, index);
            }
            return bundleName;
#else
            return bundleName;
#endif
        }

        private static ResConfig LoadResConfigFilePanel(bool saveHistory = false)
        {
            string dir = GetResConfigRoot();
            Directory.CreateDirectory(dir);
            string filePath = EditorUtility.OpenFilePanel("加载版本资源配置信息", dir, "json");
            var resConfig = LoadResConfig(filePath);
            if (saveHistory)
            {
                EditorPrefs.SetString("LastResConfigPath", filePath);
            }

            return resConfig;
        }

        private static ResConfig LoadResConfig(string filePath)
        {
            if (!string.IsNullOrEmpty(filePath) && File.Exists(filePath))
            {
                byte[] bytes = FileHelper.ReadAllBytes(filePath);
                var resConfig = FileHelper.ReadJsonFile<ResConfig>(filePath);
                return resConfig;
            }
            return null;
        }

        /// <summary>
        ///     unixTimestamp单位为毫秒
        /// </summary>
        /// <param name="unixTimestamp"></param>
        /// <returns></returns>
        public static DateTime UnixTimeStampToDateTime(long unixTimestamp)
        {
            DateTime dateTime = new DateTime(1970, 1, 1, 0, 0, 0, 0);
            return dateTime.AddTicks(unixTimestamp * 10000).ToLocalTime();
        }

        /// <summary>
        ///     返回的unixTimestamp单位为毫秒
        /// </summary>
        /// <param name="dateTime"></param>
        /// <returns></returns>
        public static long DateTimeToUnixTimestamp(DateTime dateTime)
        {
            return (dateTime - new DateTime(1970, 1, 1, 0, 0, 0, 0).ToLocalTime()).Ticks / 10000;
        }

        public static string GetResConfigInfo(ResConfig resConfig)
        {
            return resConfig == null
                ? "ResConfig is null"
                : string.Format(
                    "Version:{0}\nSVNVersion:{1}\nlz4CRC:{2}\nlzmaCRC:{3}\nBuildTime:{4}\nCompressType:{5}\nTotalFileSize:{6}\nCount:{7}",
                    resConfig.Version,
                    resConfig.svnVersion,
                    resConfig.lz4CRC,
                    resConfig.lzmaCRC,
                    resConfig.BuildTime,
                    resConfig.compressType,
                    EditorUtility.FormatBytes(resConfig.TotalFileSize),
                    resConfig.Manifest.Count);
        }

        #endregion


        public void BuildLuaZip(int version)
        {
            string srcDir = Application.dataPath + "/Lua";
			for(int i = 0; i < 2; i++) {
				string dstFile = i == 0? GetExportScriptPath() + "/script" : GetExportScriptPath() + "/script_" + version;
				string dstDir = Path.GetDirectoryName(dstFile);
				if (!Directory.Exists(dstDir))
				{
					Directory.CreateDirectory(dstDir);
				}
				
				LuaScript scriptPack = new LuaScript();
				scriptPack.LoadFromDir(srcDir);
				scriptPack.SaveToFile(dstFile, version);
				//Debug.Log(string.Format("打包脚本成功 path={0} 版本号={1}", dstFile, version));
			}
        }

        public void GenerateScriptPatch(int version)
        {
            if (version <= 0)
                return;

            bool error = false;

            StringBuilder builder = new StringBuilder();
            for (int i = version - 1; i < version; i++)
            {
                int curVer = i;
                int nextVer = i + 1;

                string curFile = GetExportScriptPath() + "/script_" + curVer;
                string nextFile = GetExportScriptPath() + "/script_" + nextVer;

                LuaScript curZip = LuaScript.CreataFrom(curFile);
                if (curZip == null)
                {
                    error = true;
                    Debug.LogError("创建Luazip错误  " + curFile);
                    continue;
                }

                LuaScript nextZip = LuaScript.CreataFrom(nextFile);
                if (nextZip == null)
                {
                    error = true;
                    Debug.LogError("创建Luazip错误  " + nextFile);
                    continue;
                }

                string patchFile = GetExportScriptPath() + "/patch_" + nextVer;
                LuaScript patch = LuaScript.MakePatch(curZip, nextZip);
                patch.SaveToFile(patchFile);

                //builder.AppendFormat("生成脚本补丁成功 patch={0}\n", nextVer);
            }

            if (!error)
            {
                Debug.Log(builder.ToString());
            }
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        public void GenerateAllScriptPatch(int version)
        {
            bool error = false;
            StringBuilder builder = new StringBuilder();

            string scriptDir = GetExportScriptPath();
            string[] files = Directory.GetFiles(scriptDir);
            List<int> versionList = new List<int>();
            string prefix = "script_";
            for (int i = 0; i < files.Length; i++)
            {
                string name = Path.GetFileNameWithoutExtension(files[i]);
                if(name.StartsWith(prefix))
                {
                    int ver = Convert.ToInt16(name.Substring(prefix.Length, name.Length - prefix.Length));
                    versionList.Add(ver);
                }
            }
            versionList.Sort();

            for(int i = 1; i < versionList.Count; i++)
            {
                int curVer = versionList[i - 1];
                int nextVer = versionList[i];

                string curFile = GetExportScriptPath() + "/script_" + curVer;
                string nextFile = GetExportScriptPath() + "/script_" + nextVer;

                LuaScript curZip = LuaScript.CreataFrom(curFile);
                if (curZip == null)
                {
                    error = true;
                    Debug.LogError("创建Luazip错误  " + curFile);
                    continue;
                }

                LuaScript nextZip = LuaScript.CreataFrom(nextFile);
                if (nextZip == null)
                {
                    error = true;
                    Debug.LogError("创建Luazip错误  " + nextFile);
                    continue;
                }

                string patchFile = string.Format("{0}/patch_{1}_{2}", GetExportScriptPath(), curVer, nextVer);
                LuaScript patch = LuaScript.MakePatch(curZip, nextZip);
                patch.SaveToFile(patchFile);
                //builder.AppendFormat("生成脚本补丁成功 patch={0}\n", nextVer);
            }
            if (!error)
            {
                Debug.Log("生成所有脚本补丁 当前版本=" + version);
            }
        }

        public void GenerateScriptVersionFile(int version)
        {
            StringBuilder builder = new StringBuilder();
            ScriptVersion scriptVersion = new ScriptVersion();
            string scriptDir = GetExportScriptPath();

            scriptVersion.Patchs = new Dictionary<string, ScriptInfo>();
            string[] files = Directory.GetFiles(scriptDir, "patch_*");
            List<string> fileList = new List<string>(files);
            fileList.Sort();
            for (int i = 0; i < fileList.Count; i++)
            {
                string filename = fileList[i];
                byte[] data = FileHelper.ReadAllBytes(filename);
                ScriptInfo info = new ScriptInfo();
                info.name = Path.GetFileNameWithoutExtension(filename);
                info.size = data.Length;
                info.md5 = MD5Hashing.HashBytes(data);
                scriptVersion.Patchs.Add(info.name, info);
                builder.AppendLine(string.Format("{0} md5={1}", info.name, info.md5));
            }

            scriptVersion.Scripts = new Dictionary<string, ScriptInfo>();
            files = Directory.GetFiles(scriptDir, "script_*");
            fileList = new List<string>(files);
            fileList.Sort();
            string prefix = "script_";
            for (int i = 0; i < fileList.Count; i++)
            {
                string filename = fileList[i];
                string name = Path.GetFileNameWithoutExtension(filename);
                int ver = Convert.ToInt16(name.Substring(prefix.Length, name.Length - prefix.Length));
                byte[] data = FileHelper.ReadAllBytes(filename);
                ScriptInfo info = new ScriptInfo();
                info.name = name;
                info.size = data.Length;
                info.md5 = MD5Hashing.HashBytes(data);
                scriptVersion.Scripts.Add(name, info);
                builder.AppendLine(string.Format("{0} md5={1}", info.name, info.md5));
            }

            Debug.Log(builder.ToString());
            FileHelper.SaveJsonObj(scriptVersion, GetExportScriptPath() + "/scriptVersion.json", false, true);
        }


        public static void BuildWinTest()
        {
            int version = 9999;
            if (AssetBundleBuilder.Instance == null)
            {
                AssetBundleBuilder.ShowWindow();
            }
            AssetBundleBuilder.Instance.CleanUpBundleName(true);
            AssetBundleBuilder.Instance.UpdateAllBundleName();
            AssetBundleBuilder.Instance.BuildAssetBundle(9999, 0);
            AssetBundleBuilder.Instance.GenerateAndBackupAssetBundle(9999, 0);
            AssetBundleBuilder.Instance.GeneratePackageBundle(false);


            string srcDir = Application.dataPath + "/Lua";
            string dstFile = Application.streamingAssetsPath + "/script";
            string dstDir = Path.GetDirectoryName(dstFile);
            LuaScript scriptPack = new LuaScript();
            scriptPack.LoadFromDir(srcDir);
            scriptPack.SaveToFile(dstFile, 9999);

            string outputPath = string.Format("Build/Build.exe");
            string outputDir = Path.GetDirectoryName(outputPath);

            //FileHelper.DeleteDirectory(outputDir, true);
            //FileHelper.CreateDirectory(outputDir);
            var buildoption = BuildOptions.ShowBuiltPlayer;
            //if (_developmentBuild)
            //{
            //    buildoption = buildoption | BuildOptions.AllowDebugging | BuildOptions.ConnectWithProfiler |
            //                  BuildOptions.Development;
            //}
            string res = BuildPipeline.BuildPlayer(PlayerSettingTool.FindEnabledEditorScenes(), outputPath, BuildTarget.StandaloneWindows, buildoption);
            if (res.Length > 0)
            {
                throw new Exception("BuildPlayer failure: " + res);
            }

        }

        public static string GetBundleBackupDir(ResInfo resInfo, string backupDir)
        {
            if (resInfo.remoteZipType == CompressType.UnityLZMA)
            {
                return backupDir + "/lzma";
            }
            else if (resInfo.remoteZipType == CompressType.CustomTex)
            {
                return backupDir + "/custom";
            }
            else
            {
                return backupDir + "/lz4";
            }
        }
    }
}
