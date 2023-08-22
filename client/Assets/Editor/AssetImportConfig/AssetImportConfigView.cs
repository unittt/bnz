using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using LITJson;
using UnityEngine;
using UnityEditor;

namespace AssetImport
{
    public class AssetImportConfigView : EditorWindow
    {
        public static AssetImportConfigView Instance;

        [MenuItem("Tools/AssetImportSetting", false, 120)]
        public static void ShowWindow()
        {
            if (Instance == null)
            {
                Instance = GetWindow<AssetImportConfigView>(false, "AssetImportSetting", true);
                Instance.minSize = new Vector2(872f, 680f);
                Instance.Show();
                Instance.Setup();
            }
            else
            {
                Instance.Close();
                Instance = null;
            }
        }

        private AssetImportConfig assetImportConfig;
        private string searchFilter;
        private AssetType selectAssetType;
        private AssetImportHelperBase helper;
        private IEnumerable<string> assets;
        private void Setup()
        {
            assetImportConfig = AssetImportConfig.LoadConfig();
            changeConfigAssets = new HashSet<string>();
        }
        private Vector2 assetScroll;
        private string selectAssetPath;
        private bool selectAssetIsDefault;
        private bool selectAssetChangeConfig;
        private HashSet<string> changeConfigAssets; 
        void OnGUI()
        {
            GUILayout.BeginHorizontal();
            {
                selectAssetType = (AssetType)EditorGUILayout.EnumPopup(selectAssetType);
            }
            GUILayout.EndHorizontal();
            // Search field
            GUILayout.BeginHorizontal();
            {
                var after = EditorGUILayout.TextField("", searchFilter, "SearchTextField");

                if (GUILayout.Button("", "SearchCancelButton", GUILayout.Width(18f)))
                {
                    after = string.Empty;
                    GUIUtility.keyboardControl = 0;
                }
                if (searchFilter != after)
                {
                    searchFilter = after;
                }
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            {
                if (GUILayout.Button("查找所有资源", GUILayout.Height(50f)))
                {
                    GetAllAssets();
                }
                if (GUILayout.Button("重新设置所有资源配置", GUILayout.Height(50f)))
                {
                    SetAllConfig();
                }
                if (GUILayout.Button("保存配置", GUILayout.Height(50f)))
                {
                    SaveConfig();
                }
            }
            GUILayout.EndHorizontal();

            EditorGUILayout.BeginVertical("HelpBox", GUILayout.Height(250f));
            {
                assetScroll = EditorGUILayout.BeginScrollView(assetScroll);
                if (assets != null)
                {
                    int i = 0;
                    foreach (var path in assets)
                    {
                        string fileName = Path.GetFileNameWithoutExtension(path);
                        if (helper != null )
                        {
                            bool isDefault;
                            helper.GetAssetConfig(assetImportConfig, path, out isDefault);
                            if (!isDefault)
                                fileName = fileName.Insert(0, "!");
                        }
                        i++;
                        
                        if (!string.IsNullOrEmpty(searchFilter) && !MatchFilter(fileName))
                            continue;
                        GUI.backgroundColor = selectAssetPath == path ? Color.white : new Color(0.8f, 0.8f, 0.8f);
                        GUILayout.BeginHorizontal("AS TextArea", GUILayout.MinHeight(20f));
                        {
                            GUILayout.Label(i.ToString(), GUILayout.Width(40f));
                            if (GUILayout.Button(fileName, "OL TextField", GUILayout.Height(20f)) && path != selectAssetPath)
                            {
                                selectAssetPath = path;
                                selectAssetChangeConfig = false;
                            }
                            if (selectAssetPath == path)
                            {
                                if (selectAssetIsDefault)
                                {
                                    GUI.backgroundColor = Color.green;
                                    if (GUILayout.Button("Add", GUILayout.Width(50f)))
                                        AddConfig();
                                }
                                else
                                {
                                    GUI.backgroundColor = Color.red;
                                    if (GUILayout.Button("X", GUILayout.Width(22f)))
                                        RemoveConfig();
                                }
                            }
                            GUI.backgroundColor = Color.white;
                        }
                        GUILayout.EndHorizontal();
                        GUI.backgroundColor = Color.white;
                        
                    }
                }

                EditorGUILayout.EndScrollView();
            }
            EditorGUILayout.EndVertical();
            EditorGUILayout.BeginVertical("HelpBox");
            selectAssetIsDefault = true;
            if (selectAssetPath != null && helper != null)
            {
                var itemConfig = helper.GetAssetConfig(assetImportConfig, selectAssetPath, out selectAssetIsDefault);
                EditorGUI.BeginChangeCheck();
                EditorGUI.BeginDisabledGroup(selectAssetIsDefault);
                helper.DrawAssetConfigGUI(itemConfig);
                EditorGUI.EndDisabledGroup();
                selectAssetChangeConfig |= EditorGUI.EndChangeCheck();
                Selection.activeObject = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(selectAssetPath);
                if(selectAssetChangeConfig)
                    changeConfigAssets.Add(selectAssetPath);
            }
            EditorGUILayout.EndVertical();
        }

        private void GetAllAssets()
        {
            if (selectAssetType == AssetType.None)
            {
                ShowNotification(new GUIContent("请选择有效的资源类型"));
                return;
            }
            helper = (AssetImportHelperBase)Assembly.GetExecutingAssembly().CreateInstance(selectAssetType.GetType().Namespace + "." + selectAssetType + AssetImportHelperBase.suffix);
            assets = helper.GetAllAsset()
                        .OrderBy(item => Path.GetFileNameWithoutExtension(item));
        }

        private void AddConfig()
        {
            if (selectAssetPath != null && helper != null)
            {
                assetImportConfig.GetAtlasConfig(selectAssetType).Add(Path.GetFileNameWithoutExtension(selectAssetPath), helper.GetDefaultConfig());
                changeConfigAssets.Add(selectAssetPath);
            }
        }

        private void RemoveConfig()
        {
            if (selectAssetPath != null && helper != null)
            {
                assetImportConfig.GetAtlasConfig(selectAssetType).Remove(Path.GetFileNameWithoutExtension(selectAssetPath));
                changeConfigAssets.Add(selectAssetPath);
            }

        }
        private void SaveConfig()
        {
            assetImportConfig.SaveConfig();
            if (changeConfigAssets.Count > 0)
            {
                AssetImportPost.OnPostprocessAllAssets(changeConfigAssets.ToArray(), new string[0], new string[0], new string[0]);
                changeConfigAssets.Clear();
            }
            ShowNotification(new GUIContent("保存成功"));
        }

        private void SetAllConfig()
        {
            assetImportConfig.SaveConfig();

            AssetImportPost.OnPostprocessAllAssets(assets.ToArray(), new string[0], new string[0], new string[0]);
            changeConfigAssets.Clear();
            ShowNotification(new GUIContent("设置成功"));
        }

        private bool MatchFilter(string fileName)
        {
            //键入全是小写时 搜索不区分大小写。
            string fileNameLower = searchFilter == searchFilter.ToLower() ? fileName.ToLower() : fileName;
            int index = 0;
            foreach (char c in searchFilter)
            {
                index = fileNameLower.IndexOf(c, index);
                if (index == -1)
                    return false;
                else
                    index++;
            }
            return true;
        }
    }
}

