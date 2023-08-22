using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using AssetPipeline;
using LITJson;
using Pathfinding;
using Pathfinding.Serialization;
//using tk2dEditor.SpriteCollectionEditor;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;
using Path = System.IO.Path;
using UnityEditor.SceneManagement;

public class GridMapTexturePostprocessor : AssetPostprocessor
{
    [MenuItem("地图/地图资源格式处理/Off", false, 15)]
    public static void DisableGridMapTexturePostprocess()
    {
        EditorPrefs.SetBool("GridMapTexturePostprocessToggle", false);
    }

    [MenuItem("地图/地图资源格式处理/Off", true, 15)]
    public static bool DisableGridMapTexturePostprocessState()
    {
        return EditorPrefs.GetBool("GridMapTexturePostprocessToggle", true);
    }

    [MenuItem("地图/地图资源格式处理/On", false, 20)]
    public static void EnableGridMapTexturePostprocess()
    {
        EditorPrefs.SetBool("GridMapTexturePostprocessToggle", true);
    }

    [MenuItem("地图/地图资源格式处理/On", true, 20)]
    public static bool EnableGridMapTexturePostprocessState()
    {
        return !EditorPrefs.GetBool("GridMapTexturePostprocessToggle", true);
    }

    private void OnPreprocessTexture()
    {
        if (!EditorPrefs.GetBool("GridMapTexturePostprocessToggle", true)) return;
        TextureImporter textureImporter = (TextureImporter)assetImporter;
        if (textureImporter == null) return;

        if (!assetPath.StartsWith("Assets/GameRes/Map2d")) return;

        string fileName = Path.GetFileName(assetPath);
        if (string.IsNullOrEmpty(fileName)) return;

        if (fileName.StartsWith("minimap_"))
        {
            textureImporter.textureType = TextureImporterType.Advanced;
            textureImporter.spriteImportMode = SpriteImportMode.None;
            textureImporter.mipmapEnabled = false;
            textureImporter.textureFormat = TextureImporterFormat.ARGB16;
            textureImporter.npotScale = TextureImporterNPOTScale.None;
        }
        else if (fileName.StartsWith("gridRef_"))
        {
            textureImporter.textureType = TextureImporterType.Advanced;
            textureImporter.npotScale = TextureImporterNPOTScale.None;
            textureImporter.isReadable = true;
            textureImporter.mipmapEnabled = false;
            textureImporter.wrapMode = TextureWrapMode.Clamp;
            textureImporter.filterMode = FilterMode.Point;
            textureImporter.textureFormat = TextureImporterFormat.AutomaticTruecolor;
        }
        else
        {
            string folderName = Path.GetFileName(Path.GetDirectoryName(assetPath));

            if (folderName.StartsWith("tilemap_"))
            {
                textureImporter.textureType = TextureImporterType.Advanced;
                textureImporter.spriteImportMode = SpriteImportMode.None;
                textureImporter.wrapMode = TextureWrapMode.Clamp;
                textureImporter.mipmapEnabled = false;
                textureImporter.anisoLevel = -1;
                textureImporter.textureFormat = TextureImporterFormat.AutomaticCompressed;
            }
            else if (folderName.StartsWith("fgbuild_") ||
                     folderName.StartsWith("bgbuild_"))
            {
                TextureImporterSettings texSettings = new TextureImporterSettings();
                textureImporter.ReadTextureSettings(texSettings);
                //texSettings.spriteAlignment = (int)SpriteAlignment.Center;
                texSettings.spriteMode = (int)SpriteImportMode.None;
                texSettings.readable = false;
                texSettings.mipmapEnabled = false;
                texSettings.maxTextureSize = 2048;
                texSettings.aniso = -1;
                textureImporter.SetTextureSettings(texSettings);

                textureImporter.textureType = TextureImporterType.Advanced;
                textureImporter.wrapMode = TextureWrapMode.Clamp;
                textureImporter.npotScale = TextureImporterNPOTScale.None;
                textureImporter.alphaIsTransparency = true;
                textureImporter.spritePackingTag = "";
                textureImporter.ClearPlatformTextureSettings("Andriod");
                textureImporter.ClearPlatformTextureSettings("iPhone");
                textureImporter.textureFormat = TextureImporterFormat.Automatic16bit;

                ////以贴图文件名作为PackingTag,因为如果需要使用Unity的Android RGB+Alpha通道分离的ETC压缩格式必须打到一个图集里才可以
                //textureImporter.spritePackingTag = Path.GetFileNameWithoutExtension(assetPath);
                //textureImporter.textureFormat = TextureImporterFormat.AutomaticCompressed;
                //textureImporter.SetAllowsAlphaSplitting(true);
                //textureImporter.SetPlatformTextureSettings("Android", 2048, TextureImporterFormat.ETC_RGB4, true);
                //textureImporter.SetPlatformTextureSettings("iPhone", 2048, TextureImporterFormat.PVRTC_RGBA4, true);
            }
        }
    }
}

public class GridMapGenerator : EditorWindow
{
    public const string SceneRawDataPath = "Assets/GameRes/Map2d";
    public const string GridEffectEditorScene = "Assets/Scene/GridMapEffectEditor.unity";
    public const string NavDataRoot = "Assets/GameRes/Map2d/ConfigData";
    //public const string ServerNavDataRoot = "Assets/GameRes/Map2d/ServerNavData";
    public const string ConfigRoot = "Assets/GameRes/Map2d/ConfigData";
    public static GridMapGenerator Instance;
    private string _curSceneId;
    private Vector2 _scrollPos;

	public enum GridEditorType {
        Nothing = 0,
        NpcArea = 1,
        TouchEffect = 2,
    }
    public GridEditorType gridEditorType = GridEditorType.Nothing;

    [MenuItem("地图/2D地图编辑工具")]
    public static void ShowWindow()
    {
        if (Instance == null)
        {
            var window = GetWindow<GridMapGenerator>(false, "GridMapGenerator", true);
            window.minSize = new Vector2(460f, 600f);
            window.Show();
            window.Setup();
        }
        else
        {
            Instance.Close();
        }
    }

    private void Setup()
    {
        Instance = this;
        _curSceneId = EditorPrefs.GetString("GridMapGeneratorId", "");
    }

    private void OnDestroy()
    {
        EditorPrefs.SetString("GridMapGeneratorId", _curSceneId);
        Instance = null;
    }

    private void OnSceneQuit()
    {
        SaveEffectConfig(_curSceneConfig);
    }

    private void OnGUI()
    {
        EditorGUILayout.Space();
        _curSceneId = EditorGUILayout.TextField("2d场景Id:", _curSceneId);
        _scrollPos = EditorGUILayout.BeginScrollView(_scrollPos);
        //	寻路信息编辑 ==================================================
        EditorGUILayout.Space();
        //生成寻路信息子面板
        EditorGUILayout.BeginVertical("HelpBox", GUILayout.Width(450f));
        {
			EditorGUILayout.BeginHorizontal();
			GUILayout.Label("2D场景寻路信息编辑", "BoldLabel");
			_savaNpcArea = GUILayout.Toggle(_savaNpcArea, "重新产生Npc生成区域，给策划用的");
			EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("编辑寻路信息", "LargeButton", GUILayout.Height(50f)))
            {
                if (ValidateSceneOpen() && SetupAstarPath())
                {
                    gridEditorType = GridEditorType.Nothing;
                    LoadScene(_curSceneId);
                    if (BrushTool != null)
                    {
                        Selection.activeGameObject = BrushTool.gameObject;
                        BrushTool.EndEditMode(false);
                    }
                    if (AreaTool != null)
                    {
                        Selection.activeGameObject = AreaTool.gameObject;
                        AreaTool.EndEditMode(false);
                        AreaTool.Clear();
                    }
                }
            }

			string btnName = _savaNpcArea? "重新产生Npc生成区域" : "生成寻路信息";
			if (GUILayout.Button(btnName, "LargeButton", GUILayout.Height(50f)))
            {
                if (ValidateSceneOpen() && SetupAstarPath())
                {
                    SerializeNavData();
                    LoadScene(_curSceneId);
                }
            }
            EditorGUILayout.EndHorizontal();
            //if (GUILayout.Button("生成透明遮罩Prefab", "LargeButton", GUILayout.Height(50f)))
            //{
            //    if (EditorUtility.DisplayDialog("提示", "生成透明遮罩Prefab过程中会卡顿,是否继续?", "Yes", "No"))
            //    {
            //        GenerateAllBuildPrefabs();
            //    }
            //}
            //EditorGUILayout.Space();
            //EditorGUILayout.BeginHorizontal();
            //if (GUILayout.Button("生成透明遮罩图集", "LargeButton", GUILayout.Height(50f), GUILayout.Width(250f)))
            //{
            //    if (EditorUtility.DisplayDialog("提示", "生成透明遮罩图集过程中会卡顿,是否继续?", "Yes", "No"))
            //    {
            //        GenerateAllBuildInfo();
            //    }
            //}
            //EditorGUILayout.BeginVertical();
            //if (GUILayout.Button("打开前景遮罩图集", "LargeButton", GUILayout.Height(25f)))
            //{
            //    OpenSpriteCollectionEditor(string.Format("{0}/{1}/fgbuild_{1}/fgbuild_{1}_atlas.prefab",
            //        SceneRawDataPath, _curSceneId));
            //}
            //if (GUILayout.Button("打开背景遮罩图集", "LargeButton", GUILayout.Height(25f)))
            //{
            //    OpenSpriteCollectionEditor(string.Format("{0}/{1}/bgbuild_{1}/bgbuild_{1}_atlas.prefab",
            //        SceneRawDataPath, _curSceneId));
            //}
            //EditorGUILayout.EndVertical();
            //EditorGUILayout.EndHorizontal();
            //EditorGUILayout.Space();
        }
        EditorGUILayout.EndVertical();

        //	特效信息编辑=================================================
        EditorGUILayout.Space();
        //2d场景特效配置编辑子面板
        EditorGUILayout.BeginVertical("HelpBox", GUILayout.Width(450f));
        {

            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("2d场景特效信息编辑", "BoldLabel");
            _hideTileGo = GUILayout.Toggle(_hideTileGo, "隐藏Tile");
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("加载场景", "LargeButton", GUILayout.Height(50f)))
            {
                if (ValidateSceneOpen())
                {
                    gridEditorType = GridEditorType.Nothing;
                    if (EditorApplication.isPlaying)
                    {
                        if (SetupEffectSceneConfig())
                        {
                            LoadAllEffect(_curSceneConfig);
                            LoadAllBuilding(_curSceneConfig);
                            LoadAllTransfer(_curSceneConfig);
                        }
                    }
                    else
                    {
                        if (EditorUtility.DisplayDialog("提示", "必须处于运行状态下才可编辑,是否运行?", "Yes"))
                        {
                            EditorApplication.isPaused = false;
                            EditorApplication.isPlaying = true;
                        }
                    }
                }
            }

            GUI.enabled = _curSceneConfig != null;
            if (GUILayout.Button("保存配置", "LargeButton", GUILayout.Height(50f)))
            {
                if (EditorApplication.isPlaying)
                {
                    SaveEffectConfig(_curSceneConfig);
                }
                SaveTransferConfig(_curSceneConfig);
                AssetDatabase.Refresh();

            }
            GUI.enabled = true;
            EditorGUILayout.EndHorizontal();
        }
        EditorGUILayout.EndVertical();

        //	Npc生成信息编辑===============================================
        EditorGUILayout.Space();
        //	Npc生成信息子面板
        EditorGUILayout.BeginVertical("HelpBox", GUILayout.Width(450f));
        {
            bool isNpcAreaType = gridEditorType == GridEditorType.NpcArea;
            string tip = isNpcAreaType ? "(注意：编辑状态下不可切换场景)" : "";
            GUILayout.Label("2D场景Npc生成信息编辑" + tip, "BoldLabel");
            EditorGUILayout.BeginHorizontal();
            string btnStr = isNpcAreaType ? "退出编辑区域" : "编辑Npc区域";
            if (GUILayout.Button(btnStr, "LargeButton", GUILayout.Height(50f)))
            {
                if (isNpcAreaType)
                {
                    gridEditorType = GridEditorType.Nothing;
                }
                else if (ValidateSceneOpen() && SetupAstarPath())
                {
                    gridEditorType = GridEditorType.NpcArea;
                    LoadScene(_curSceneId);
                    if (true || !AreaTool._inEditMode)
                    {
                        ShowNotification(new GUIContent("提示：切换场景，请先退出编辑模式"));
                        string dataPath = string.Format("{0}/npc_area_{1}.bytes", ConfigRoot, _curSceneId);
                        AreaTool.textAssetData = AssetDatabase.LoadAssetAtPath<TextAsset>(dataPath);
                        Selection.activeGameObject = AreaTool.gameObject;
                        AreaTool.EndEditMode(false);
                        CreateConfigFiles("npc_area", _curSceneId);
                        AreaTool.BeginEditMode();
                        Repaint();
                    }
                }
            }

            if (GUILayout.Button("生成Npc区域", "LargeButton", GUILayout.Height(50f)))
            {
                if (ValidateSceneOpen() && SetupAstarPath())
                {
                    bool save = EditorUtility.DisplayDialog("提示", "正在退出编辑模式，是否保存数据?", "Yes", "No");
                    AreaTool.EndEditMode(save);
                    Repaint();
                }
            }
            EditorGUILayout.EndHorizontal();
        }
        EditorGUILayout.EndVertical();

        //	Npc新区域生成信息编辑===============================================
        EditorGUILayout.Space();
        //	Npc新区域生成信息子面板
        EditorGUILayout.BeginVertical("HelpBox", GUILayout.Width(450f));
        {
            bool isNpcAreaType = gridEditorType == GridEditorType.NpcArea;
            string tip = isNpcAreaType ? "(注意：编辑状态下不可切换场景)" : "";
            GUILayout.Label("2D场景Npc新区域生成信息编辑" + tip, "BoldLabel");
            EditorGUILayout.BeginHorizontal();
            string btnStr = isNpcAreaType ? "退出编辑区域" : "编辑Npc区域";
            if (GUILayout.Button(btnStr, "LargeButton", GUILayout.Height(50f)))
            {
                if (isNpcAreaType)
                {
                    gridEditorType = GridEditorType.Nothing;
                }
                else if (ValidateSceneOpen() && SetupAstarPath())
                {
                    gridEditorType = GridEditorType.NpcArea;
                    LoadScene(_curSceneId);
                    if (true || !AreaTool._inEditMode)
                    {
                        ShowNotification(new GUIContent("提示：切换场景，请先退出编辑模式"));
                        string dataPath = string.Format("{0}/npc_area_new_{1}.bytes", ConfigRoot, _curSceneId);
                        AreaTool.textAssetData = AssetDatabase.LoadAssetAtPath<TextAsset>(dataPath);
                        Selection.activeGameObject = AreaTool.gameObject;
                        AreaTool.EndEditMode(false);
                        CreateConfigFiles("npc_area_new", _curSceneId);
                        AreaTool.BeginEditMode();
                        Repaint();
                    }
                }
            }

            if (GUILayout.Button("生成Npc新区域", "LargeButton", GUILayout.Height(50f)))
            {
                if (ValidateSceneOpen() && SetupAstarPath())
                {
                    bool save = EditorUtility.DisplayDialog("提示", "正在退出编辑模式，是否保存数据?", "Yes", "No");
                    AreaTool.EndEditMode(save);
                    Repaint();
                }
            }
            EditorGUILayout.EndHorizontal();
        }
        EditorGUILayout.EndVertical();

        //	地图点击特效信息编辑===============================================
        EditorGUILayout.Space();
		//	地图点击特效信息子面板
        EditorGUILayout.BeginVertical("HelpBox", GUILayout.Width(450f));
        {
            bool isNpcAreaType = gridEditorType == GridEditorType.TouchEffect;
            string tip = isNpcAreaType ? "(注意：编辑状态下不可切换场景)" : "";
            GUILayout.Label("2D场景地图点击特效信息编辑" + tip, "BoldLabel");
            EditorGUILayout.BeginHorizontal();
            string btnStr = isNpcAreaType ? "退出编辑场景特效" : "编辑场景点击特效";
            if (GUILayout.Button(btnStr, "LargeButton", GUILayout.Height(50f)))
            {
                if (isNpcAreaType)
                {
                    gridEditorType = GridEditorType.Nothing;
                }
                else if (ValidateSceneOpen() && SetupAstarPath())
                {
                    gridEditorType = GridEditorType.TouchEffect;
                    LoadScene(_curSceneId);
                    if (true || !AreaTool._inEditMode)
                    {
                        ShowNotification(new GUIContent("提示：切换场景，请先退出编辑模式"));
                        string dataPath = string.Format("{0}/touch_effect_{1}.bytes", ConfigRoot, _curSceneId);
                        AreaTool.textAssetData = AssetDatabase.LoadAssetAtPath<TextAsset>(dataPath);
                        Selection.activeGameObject = AreaTool.gameObject;
                        AreaTool.EndEditMode(false);
                        CreateConfigFiles("touch_effect", _curSceneId);
                        AreaTool.BeginEditMode();
                        Repaint();
                    }
                }
            }

            if (GUILayout.Button("保存点击特效信息", "LargeButton", GUILayout.Height(50f)))
            {
                if (ValidateSceneOpen() && SetupAstarPath())
                {
                    bool save = EditorUtility.DisplayDialog("提示", "正在退出编辑模式，是否保存数据?", "Yes", "No");
                    AreaTool.EndEditMode(save);
                    Repaint();
                }
            }
            EditorGUILayout.EndHorizontal();
        }
		EditorGUILayout.EndVertical();
		
		//	地图擂台信息编辑===============================================
		EditorGUILayout.Space();
		//	地图擂台信息子面板
		EditorGUILayout.BeginVertical("HelpBox", GUILayout.Width(450f));
		{
			bool isNpcAreaType = gridEditorType == GridEditorType.TouchEffect;
			string tip = isNpcAreaType ? "(注意：编辑状态下不可切换场景)" : "";
            GUILayout.Label("2D场景地图擂台信息编辑" + tip, "BoldLabel");
			EditorGUILayout.BeginHorizontal();
			string btnStr = isNpcAreaType ? "退出编辑擂台范围" : "编辑场景擂台范围";
			if (GUILayout.Button(btnStr, "LargeButton", GUILayout.Height(50f)))
			{
				if (isNpcAreaType)
				{
					gridEditorType = GridEditorType.Nothing;
				}
				else if (ValidateSceneOpen() && SetupAstarPath())
				{
					gridEditorType = GridEditorType.TouchEffect;
					LoadScene(_curSceneId);
					if (true || !AreaTool._inEditMode)
					{
						ShowNotification(new GUIContent("提示：切换场景，请先退出编辑模式"));
						string dataPath = string.Format("{0}/arena_{1}.bytes", ConfigRoot, _curSceneId);
						AreaTool.textAssetData = AssetDatabase.LoadAssetAtPath<TextAsset>(dataPath);
						Selection.activeGameObject = AreaTool.gameObject;
						AreaTool.EndEditMode(false);
						CreateConfigFiles("arena", _curSceneId);
						AreaTool.BeginEditMode();
						Repaint();
					}
				}
			}

            if (GUILayout.Button("保存地图擂台信息", "LargeButton", GUILayout.Height(50f)))
			{
				if (ValidateSceneOpen() && SetupAstarPath())
				{
					bool save = EditorUtility.DisplayDialog("提示", "正在退出编辑模式，是否保存数据?", "Yes", "No");
					AreaTool.EndEditMode(save);
					Repaint();
				}
			}
			EditorGUILayout.EndHorizontal();
		}
		EditorGUILayout.EndVertical();

        //	地图跳舞活动信息编辑===============================================
        EditorGUILayout.Space();
        //	地图跳舞信息子面板
        EditorGUILayout.BeginVertical("HelpBox", GUILayout.Width(450f));
        {
            bool isNpcAreaType = gridEditorType == GridEditorType.TouchEffect;
            string tip = isNpcAreaType ? "(注意：编辑状态下不可切换场景)" : "";
            GUILayout.Label("2D场景地图跳舞信息编辑" + tip, "BoldLabel");
            EditorGUILayout.BeginHorizontal();
            string btnStr = isNpcAreaType ? "退出编辑舞台范围" : "编辑场景舞台范围";
            if (GUILayout.Button(btnStr, "LargeButton", GUILayout.Height(50f)))
            {
                if (isNpcAreaType)
                {
                    gridEditorType = GridEditorType.Nothing;
                }
                else if (ValidateSceneOpen() && SetupAstarPath())
                {
                    gridEditorType = GridEditorType.TouchEffect;
                    LoadScene(_curSceneId);
                    if (true || !AreaTool._inEditMode)
                    {
                        ShowNotification(new GUIContent("提示：切换场景，请先退出编辑模式"));
                        string dataPath = string.Format("{0}/dance_{1}.bytes", ConfigRoot, _curSceneId);
                        AreaTool.textAssetData = AssetDatabase.LoadAssetAtPath<TextAsset>(dataPath);
                        Selection.activeGameObject = AreaTool.gameObject;
                        AreaTool.EndEditMode(false);
                        CreateConfigFiles("dance", _curSceneId);
                        AreaTool.BeginEditMode();
                        Repaint();
                    }
                }
            }

            if (GUILayout.Button("保存地图跳舞信息", "LargeButton", GUILayout.Height(50f)))
            {
                if (ValidateSceneOpen() && SetupAstarPath())
                {
                    bool save = EditorUtility.DisplayDialog("提示", "正在退出编辑模式，是否保存数据?", "Yes", "No");
                    AreaTool.EndEditMode(save);
                    Repaint();
                }
            }
            EditorGUILayout.EndHorizontal();
        }
        EditorGUILayout.EndVertical();

        //	地图踩水信息编辑===============================================
        EditorGUILayout.Space();
        //	地图踩水信息子面板
        EditorGUILayout.BeginVertical("HelpBox", GUILayout.Width(450f));
        {
            bool isNpcAreaType = gridEditorType == GridEditorType.TouchEffect;
            string tip = isNpcAreaType ? "(注意：编辑状态下不可切换场景)" : "";
            GUILayout.Label("2D场景地图踩水点信息编辑" + tip, "BoldLabel");
            EditorGUILayout.BeginHorizontal();
            string btnStr = isNpcAreaType ? "退出编辑踩水范围" : "编辑场景踩水范围";
            if (GUILayout.Button(btnStr, "LargeButton", GUILayout.Height(50f)))
            {
                if (isNpcAreaType)
                {
                    gridEditorType = GridEditorType.Nothing;
                }
                else if (ValidateSceneOpen() && SetupAstarPath())
                {
                    gridEditorType = GridEditorType.TouchEffect;
                    LoadScene(_curSceneId);
                    if (true || !AreaTool._inEditMode)
                    {
                        ShowNotification(new GUIContent("提示：切换场景，请先退出编辑模式"));
                        string dataPath = string.Format("{0}/water_{1}.bytes", ConfigRoot, _curSceneId);
                        AreaTool.textAssetData = AssetDatabase.LoadAssetAtPath<TextAsset>(dataPath);
                        Selection.activeGameObject = AreaTool.gameObject;
                        AreaTool.EndEditMode(false);
                        CreateConfigFiles("water", _curSceneId);
                        AreaTool.BeginEditMode();
                        Repaint();
                    }
                }
            }

            if (GUILayout.Button("保存地图踩水信息", "LargeButton", GUILayout.Height(50f)))
            {
                if (ValidateSceneOpen() && SetupAstarPath())
                {
                    bool save = EditorUtility.DisplayDialog("提示", "正在退出编辑模式，是否保存数据?", "Yes", "No");
                    AreaTool.EndEditMode(save);
                    Repaint();
                }
            }
            EditorGUILayout.EndHorizontal();
        }
        EditorGUILayout.EndVertical();

        //	地图踩水路线信息编辑===============================================
        EditorGUILayout.Space();
        //	地图踩水路线信息子面板
        EditorGUILayout.BeginVertical("HelpBox", GUILayout.Width(450f));
        {
            bool isNpcAreaType = gridEditorType == GridEditorType.TouchEffect;
            string tip = isNpcAreaType ? "(注意：编辑状态下不可切换场景)" : "";
            GUILayout.Label("2D场景地图踩水路线信息编辑" + tip, "BoldLabel");
            EditorGUILayout.BeginHorizontal();
            string btnStr = isNpcAreaType ? "退出编辑踩水路线范围" : "编辑踩水路线范围";
            if (GUILayout.Button(btnStr, "LargeButton", GUILayout.Height(50f)))
            {
                if (isNpcAreaType)
                {
                    gridEditorType = GridEditorType.Nothing;
                }
                else if (ValidateSceneOpen() && SetupAstarPath())
                {
                    gridEditorType = GridEditorType.TouchEffect;
                    LoadScene(_curSceneId);
                    if (true || !AreaTool._inEditMode)
                    {
                        ShowNotification(new GUIContent("提示：切换场景，请先退出编辑模式"));
                        string dataPath = string.Format("{0}/waterline_{1}.bytes", ConfigRoot, _curSceneId);
                        AreaTool.textAssetData = AssetDatabase.LoadAssetAtPath<TextAsset>(dataPath);
                        Selection.activeGameObject = AreaTool.gameObject;
                        AreaTool.EndEditMode(false);
                        CreateConfigFiles("waterline", _curSceneId);
                        AreaTool.BeginEditMode();
                        Repaint();
                    }
                }
            }

            if (GUILayout.Button("保存踩水路线信息", "LargeButton", GUILayout.Height(50f)))
            {
                if (ValidateSceneOpen() && SetupAstarPath())
                {
                    bool save = EditorUtility.DisplayDialog("提示", "正在退出编辑模式，是否保存数据?", "Yes", "No");
                    AreaTool.EndEditMode(save);
                    Repaint();
                }
            }
            EditorGUILayout.EndHorizontal();
        }
        MarryGUILayout();
        EditorGUILayout.EndVertical();
        EditorGUILayout.EndScrollView();
    }

    //  结婚区域编辑
    private void MarryGUILayout()
    {
        EditorGUILayout.Space();
        EditorGUILayout.BeginVertical("HelpBox", GUILayout.Width(450f));
        bool isNpcAreaType = gridEditorType == GridEditorType.TouchEffect;
        string tip = isNpcAreaType ? "(注意：编辑状态下不可切换场景)" : "";
        GUILayout.Label("结婚区域编辑" + tip, "BoldLabel");
        EditorGUILayout.BeginHorizontal();
        string btnStr = isNpcAreaType ? "退出编辑结婚区域" : "编辑结婚区域";
        if (GUILayout.Button(btnStr, "LargeButton", GUILayout.Height(50f)))
        {
            if (isNpcAreaType)
            {
                gridEditorType = GridEditorType.Nothing;
            }
            else if (ValidateSceneOpen() && SetupAstarPath())
            {
                gridEditorType = GridEditorType.TouchEffect;
                LoadScene(_curSceneId);
                if (true || !AreaTool._inEditMode)
                {
                    ShowNotification(new GUIContent("提示：切换场景，请先退出编辑模式"));
                    string dataPath = string.Format("{0}/marry_{1}.bytes", ConfigRoot, _curSceneId);
                    AreaTool.textAssetData = AssetDatabase.LoadAssetAtPath<TextAsset>(dataPath);
                    Selection.activeGameObject = AreaTool.gameObject;
                    AreaTool.EndEditMode(false);
                    CreateConfigFiles("marry", _curSceneId);
                    AreaTool.BeginEditMode();
                    Repaint();
                }
            }
        }

        if (GUILayout.Button("保存结婚区域信息", "LargeButton", GUILayout.Height(50f)))
        {
            if (ValidateSceneOpen() && SetupAstarPath())
            {
                bool save = EditorUtility.DisplayDialog("提示", "正在退出编辑模式，是否保存数据?", "Yes", "No");
                AreaTool.EndEditMode(save);
                Repaint();
            }
        }
        EditorGUILayout.EndHorizontal();
    }

    private void CreateConfigFiles(string typeName = "npc_area", string sceneID = "1010")
    {
		string resPath = ConfigRoot + "/" + typeName + "_" + sceneID + ".bytes";
		if (!File.Exists(resPath))
		{
	        StringBuilder sb = new StringBuilder();
	        for (int y = 0; y < AreaTool.gridRef.height; y++)
	        {
	            for (int x = 0; x < AreaTool.gridRef.width; x++)
	            {
	                sb.Append((char)('0'));
	            }
	            sb.Append('\n');
	        }
	        sb.Remove(sb.Length - 1, 1);
	        FileStream fs = new FileStream(resPath, FileMode.OpenOrCreate);
	        fs.Write(new byte[10], 0, 0);
	        fs.Close();
	        File.WriteAllText(resPath, sb.ToString());
	        AssetDatabase.Refresh();
		}
        AreaTool.textAssetData = AssetDatabase.LoadAssetAtPath<TextAsset>(resPath);
    }

    private bool ValidateSceneOpen()
    {
        bool inTestScene = EditorSceneManager.GetActiveScene().path == GridEffectEditorScene;

        if (!inTestScene && EditorUtility.DisplayDialog("提示", "需要打开2d测试场景才能生成2d场景寻路数据,是否继续?", "Yes", "No"))
        {
            EditorApplication.isPaused = false;
            EditorApplication.isPlaying = false;
            EditorSceneManager.OpenScene(GridEffectEditorScene);
        }
        SetupSceneObjReference();
        return inTestScene;
    }

    private void SetupSceneObjReference()
    {
        //打开生成测试场景时,设置场景对象引用
        Selection.activeGameObject = GameObject.Find("AstarPath");
        CleanUp();
    }

    /// <summary>
    ///     验证当前输入场景Id是否正确
    /// </summary>
    /// <returns></returns>
    private bool ValidateSceneId(string sceneId)
    {
        if (string.IsNullOrEmpty(sceneId)) return false;

        if (Directory.Exists(SceneRawDataPath + "/" + sceneId))
        {
            return true;
        }
        return false;
    }

    //清理场景上冗余对象,GridEffectEditorScene意外保存时会残留一下冗余对象
    private void CleanUp()
    {
        DisposeScene();
        CleanUpEffect();
        CleanUpBuilding();
        CleanUpTransfer();
        _curSceneConfig = null;
    }

    private GridMapConfig LoadGridMapConfig(string sceneId)
    {
        GridMapConfig config = null;
        var configPath = string.Format("{0}/se_config_{1}.bytes", ConfigRoot, sceneId);
        TextAsset testAstset = AssetDatabase.LoadAssetAtPath(configPath, typeof(TextAsset)) as TextAsset;
        if (testAstset != null)
        {
            config = JsonMapper.ToObject<GridMapConfig>(testAstset.text);
        }

        if (config == null)
        {
            config = new GridMapConfig();
            config.id = sceneId;
        }

        return config;
    }

    private void SaveGridMapConfig(GridMapConfig config)
    {
        var configPath = string.Format("{0}/se_config_{1}.bytes", ConfigRoot, config.id);
        FileHelper.SaveJsonObj(config, configPath, false);
    }

    #region 生成寻路数据

    private Texture2D _gridRef;

    private GridMapBrushTool _brushTool;
    public GridMapBrushTool BrushTool
    {
        get
        {
            if (_brushTool == null)
            {
                var go = GameObject.Find("GridMapBrushTool");
                if (go == null)
                {
                    go = new GameObject("GridMapBrushTool");
                }
                _brushTool = go.GetMissingComponent<GridMapBrushTool>();
            }
            return _brushTool;
        }
    }


    private GridMapAreaTool _AreaTool;
    public GridMapAreaTool AreaTool
    {
        get
        {
            if (_AreaTool == null)
            {
                var go = GameObject.Find("GridMapAreaTool");
                if (go == null)
                {
                    go = new GameObject("GridMapAreaTool");
                }

                _AreaTool = go.GetMissingComponent<GridMapAreaTool>();
            }
            return _AreaTool;
        }
    }


    /// <summary>
    ///     设置AstarPath参数
    /// </summary>
    /// <returns></returns>
    private bool SetupAstarPath()
    {
        if (!ValidateSceneId(_curSceneId)) return false;
        if (AstarPath == null) return false;

        if (AstarPath.graphs.Length == 0)
        {
            AstarPath.astarData.AddGraph(typeof(GridGraph));
        }

        GridGraph gridGraph = AstarPath.graphs[0] as GridGraph;
        if (gridGraph == null)
        {
            Debug.LogError("AstarPath gridGraph is null.");
            return false;
        }

        string path = string.Format("{0}/{1}/gridRef_{1}.png", SceneRawDataPath, _curSceneId);
        _gridRef = AssetDatabase.LoadAssetAtPath(path, typeof(Texture2D)) as Texture2D;
        if (_gridRef == null)
        {
            Debug.LogError("加载gridRef贴图失败 " + path);
            return false;
        }

        BrushTool.gridRef = _gridRef;
        AreaTool.gridRef = _gridRef;

        //AstarPath.scanOnStartup = false;
        //AstarPath.astarData.cacheStartup = true;

        gridGraph.nodeSize = 0.32f;
        gridGraph.Width = _gridRef.width;
        gridGraph.Depth = _gridRef.height;
        gridGraph.UpdateSizeFromWidthDepth();

        gridGraph.center = Vector3.zero -
                           (GridGraphEditor.RoundVector3(gridGraph.matrix.MultiplyPoint3x4(new Vector3(0, 0, 0))) -
                            gridGraph.center);
        gridGraph.rotation = new Vector3(-90f, 0f, 0f);

        gridGraph.textureData.enabled = true;
        gridGraph.textureData.source = _gridRef;
        gridGraph.textureData.channels[0] = GridGraph.TextureData.ChannelUse.Tag;
        gridGraph.textureData.factors[0] = 0;
        gridGraph.textureData.channels[1] = GridGraph.TextureData.ChannelUse.Tag;
        gridGraph.textureData.factors[1] = 1;
        gridGraph.textureData.channels[2] = GridGraph.TextureData.ChannelUse.Transparent;
        gridGraph.textureData.factors[2] = 1;
        gridGraph.textureData.channels[4] = GridGraph.TextureData.ChannelUse.WalkablePenalty;
        gridGraph.textureData.factors[4] = BrushTool.threshold * 3;
        return true;
    }

    /// <summary>
    ///     生成NavData信息
    /// </summary>
    private void SerializeNavData()
    {
        AstarPathEditor.MenuScan();

        var serializeSettings = new SerializeSettings { nodes = true };
        var bytes = AstarPath.astarData.SerializeGraphs(serializeSettings);

//        AstarPath.astarData.data_cachedStartup = null;
//        AstarPath.astarData.file_cachedStartup = SaveNavData(bytes);

		//	生成01文件
		if (_savaNpcArea)
		{
			GenerateServerNavData();
			return;
		}
        SaveNavData(bytes);
        EditorUtility.DisplayDialog("提示", "生成<" + _curSceneId + ">成功", "Yes");


        _curSceneConfig = LoadGridMapConfig(_curSceneId);
        _curSceneConfig.xTile = AstarPath.astarData.gridGraph.Width / 8;
        _curSceneConfig.yTile = AstarPath.astarData.gridGraph.Depth / 8;
        SaveGridMapConfig(_curSceneConfig);

        AssetDatabase.Refresh();
    }

    private TextAsset SaveNavData(byte[] bytes)
    {
        string path = NavDataRoot + "/" + "nav_" + _curSceneId + ".bytes";

        if (!Directory.Exists(NavDataRoot))
            Directory.CreateDirectory(NavDataRoot);

        File.WriteAllBytes(path, bytes);
        AssetDatabase.ImportAsset(path);

        var textAsset = AssetDatabase.LoadAssetAtPath(path, typeof(TextAsset)) as TextAsset;
        return textAsset;
    }

    /// <summary>
    ///     生成服务器用寻路信息
    /// </summary>
    private void GenerateServerNavData()
    {
        var gridGraph = AstarPath.astarData.gridGraph;
        if (gridGraph == null) 
            return;

        GraphNode preNode = null;
        var sb = new StringBuilder();

        gridGraph.GetNodes(node =>
        {
            //x:y:1
            var v3 = (Vector3)node.position;
			if (preNode != null && preNode.position.y != node.position.y)
			{
				sb.Append('\n');
			}

			if (node.Walkable)
			{
				if (node.Tag == 0)
				{
					// 可以走,就肯定能飞
					sb.Append((char)'1');
				}
				else if (node.Tag == 1)
				{
					// 可以飞,不能走
					sb.Append('2');
				}
				else
				{
					// 默认
					sb.Append('1');
				}
			}
			else
			{
				// 不可走
				sb.Append((char)'0');
			}

            preNode = node;
            return true;
        });

//        sb.Remove(sb.Length - 1, 1);

		string[] lines = sb.ToString().Split('\n');
		var lineData = new StringBuilder();
		for(int i = lines.Length - 1; i >= 0; i--) {
			for (int k = 0; k < lines[i].Length; k ++) {
				lineData.Append((char)lines[i][k]);
			}
			lineData.Append('\n');
		}
		lineData.Remove (lineData.Length - 1, 1);

		string bytepath = NavDataRoot + "/" + "npc_area_" + _curSceneId + ".bytes";
		if (!Directory.Exists(NavDataRoot))
			Directory.CreateDirectory(NavDataRoot);

		Debug.Log("生成Npc随机生成信息数据 " + bytepath + "\n" + sb.ToString());
		File.WriteAllText(bytepath, lineData.ToString());
    }

    #endregion

    #region 预览2d场景地图

    private AstarPath _astarPath;
    private GameObject _sceneRoot;
    private GameObject _target;
    private GameObject _player;
    private GameObject _sceneCam;
    private bool _hideTileGo = true;
	private bool _savaNpcArea = false;

    public AstarPath AstarPath
    {
        get
        {
            if (_astarPath == null)
            {
                _astarPath = AstarPath.active;
            }
            return _astarPath;
        }
    }

    public GameObject SceneRoot
    {
        get
        {
            if (_sceneRoot == null)
            {
                _sceneRoot = GameObject.Find("SceneRoot");
            }
            return _sceneRoot;
        }
    }

    public GameObject Target
    {
        get
        {
            if (_target == null)
            {
                _target = GameObject.Find("_Target");
            }
            return _target;
        }
    }

    public GameObject Player
    {
        get
        {
            if (_player == null)
            {
                _player = GameObject.Find("_Player");
            }
            return _player;
        }
    }

    public GameObject SceneCam
    {
        get
        {
            if (_sceneCam == null)
            {
                _sceneCam = GameObject.Find("tk2dCamera");
            }
            return _sceneCam;
        }
    }

    private List<SpriteRenderer> _activeSpriteList = new List<SpriteRenderer>();
    private Queue<SpriteRenderer> _inactiveSpritePool = new Queue<SpriteRenderer>();
    private const float SpriteTile = 2.56f;
    private int _maxSizeX;
    private int _maxSizeY;

    private void LoadScene(string newSceneId)
    {
        if (string.IsNullOrEmpty(newSceneId)) return;

        string navDataPath = string.Format("{0}/nav_{1}.bytes", ConfigRoot, newSceneId);
        TextAsset navData = AssetDatabase.LoadAssetAtPath<TextAsset>(navDataPath);
        if (navData != null)
        {
            CleanUpScene();
            AstarPath.astarData.DeserializeGraphs(navData.bytes);
            _maxSizeX = AstarPath.astarData.gridGraph.Width / 8;
            _maxSizeY = AstarPath.astarData.gridGraph.Depth / 8;

            Debug.Log("地图格子大小: " + _maxSizeX + "," + _maxSizeY);

            for (int h = 0; h < _maxSizeY; h++)
            {
                for (int w = 0; w < _maxSizeX; w++)
                {
                    SpawnSprite(newSceneId, w, h);
                }
            }

            Target.transform.localPosition = new Vector3(_maxSizeX * SpriteTile / 2, _maxSizeY * SpriteTile / 2, 0);
            Player.transform.localPosition = new Vector3(_maxSizeX * SpriteTile / 2, _maxSizeY * SpriteTile / 2, 0);
            SceneCam.transform.localPosition = new Vector3(_maxSizeX * SpriteTile / 2,
                _maxSizeY * SpriteTile / 2, -500);

            Debug.Log("加载地图数据 " + navDataPath);
        }
        else
        {
            Debug.LogError("加载寻路数据失败或者不存在:" + navDataPath);
        }
    }

    private void CleanUpScene()
    {
        foreach (var sprite in _activeSpriteList)
        {
            if (sprite != null)
            {
                DisposeSprite(sprite);
                sprite.gameObject.SetActive(false);
                _inactiveSpritePool.Enqueue(sprite);
            }
        }
        _activeSpriteList.Clear();
    }

    /// <summary>
    ///     清空所有生成的Sprite对象,并移除SceneRoot下的所有子节点
    /// </summary>
    private void DisposeScene()
    {
        CleanUpScene();
        foreach (var sprite in _inactiveSpritePool)
        {
            DestroyImmediate(sprite.gameObject);
        }
        _inactiveSpritePool.Clear();

        SceneRoot.RemoveChildren();
    }

    private void DisposeSprite(SpriteRenderer spriteRenderer)
    {
        if (spriteRenderer == null) return;

        if (spriteRenderer.sprite != null)
        {
            Resources.UnloadAsset(spriteRenderer.sprite.texture);
            spriteRenderer.sprite = null;
        }
    }


    private SpriteRenderer SpawnSprite(string sceneId, int w, int h)
    {
        SpriteRenderer sprite = null;
        //直接使用缓存池对象返回
        if (_inactiveSpritePool.Count > 0)
        {
            sprite = _inactiveSpritePool.Dequeue();
            sprite.gameObject.SetActive(true);
        }
        else
        {
            GameObject go = NGUITools.AddChild(SceneRoot);
            if (_hideTileGo)
                go.hideFlags = HideFlags.HideInHierarchy;
            sprite = go.AddComponent<SpriteRenderer>();
        }

        UpdateTile(sprite, sceneId, w, h);
        _activeSpriteList.Add(sprite);
        return sprite;
    }

    private void UpdateTile(SpriteRenderer renderer, string sceneId, int w, int h)
    {
        string spriteName = "tile_" + sceneId + "_" + w + "_" + h;
        renderer.name = spriteName;
        float halfSize = SpriteTile / 2f;
        renderer.transform.localPosition = new Vector3(SpriteTile * w, SpriteTile * h, 0);
        renderer.transform.localScale = Vector3.one;

        string assetPath =
            string.Format("Assets/GameRes/Map2d/{0}/tilemap_{0}/{1}.png", sceneId,
                spriteName);

        Vector2 pos = renderer.transform.localPosition;
        var tex = AssetDatabase.LoadAssetAtPath<Texture2D>(assetPath);
        if (tex != null)
        {
            renderer.sprite = Sprite.Create(tex, new Rect(Vector2.zero, new Vector2(256, 256)), Vector2.zero);
        }
        else
        {
            Debug.LogError("加载图块失败:" + assetPath);
        }
    }

    #endregion

    #region 预览2d场景特效,建筑

    private GameObject _fgEffectLayer;
    private GameObject _bgEffectLayer;
    private GameObject _fgBuildLayer;
    private GameObject _bgBuildLayer;
    private GameObject _transferLayer;
    private GameObject _tfEffectLayer;

    public GameObject FgEffectLayer
    {
        get
        {
            if (_fgEffectLayer == null)
            {
                _fgEffectLayer = GameObject.Find("SceneFgEffectLayer");
            }
            return _fgEffectLayer;
        }
    }

    public GameObject BgEffectLayer
    {
        get
        {
            if (_bgEffectLayer == null)
            {
                _bgEffectLayer = GameObject.Find("SceneBgEffectLayer");
            }
            return _bgEffectLayer;
        }
    }

    public GameObject TfEffectLayer
    {
        get
        {
            if (_tfEffectLayer == null)
            {
                _tfEffectLayer = GameObject.Find("SceneTfEffectLayer");
            }
            return _tfEffectLayer;
        }
    }

    public GameObject FgBuildLayer
    {
        get
        {
            if (_fgBuildLayer == null)
            {
                _fgBuildLayer = GameObject.Find("SceneFgBuildingLayer");
            }
            return _fgBuildLayer;
        }
    }

    public GameObject BgBuildLayer
    {
        get
        {
            if (_bgBuildLayer == null)
            {
                _bgBuildLayer = GameObject.Find("SceneBgBuildingLayer");
            }
            return _bgBuildLayer;
        }
    }

    public GameObject TransferLayer
    {
        get
        {
            if (_transferLayer == null)
            {
                _transferLayer = GameObject.Find("TransferLayer");
            }
            return _transferLayer;
        }
    }

    private GridMapConfig _curSceneConfig;

    private bool SetupEffectSceneConfig()
    {
        if (!ValidateSceneId(_curSceneId)) return false;

        if (FgEffectLayer == null
            || BgEffectLayer == null
            || FgBuildLayer == null
            || BgBuildLayer == null)
        {
            Debug.LogError("找不到对应的层节点");
            return false;
        }
        _curSceneConfig = LoadGridMapConfig(_curSceneId);
        GridMapSceneListener.onApplicationQuit = OnSceneQuit;
        return true;
    }

    public const string SCENE2d_EFFECT_PATH = "Assets/GameRes/Effect/Scene";
    public void LoadAllEffect(GridMapConfig config)
    {
        LoadScene(config.id);

        CleanUpEffect();
        // for (int i = 0, len = config.fgEffectList.Count; i < len; i++)
        // {
        //     GridMapEffectData data = config.fgEffectList[i];
        //     string name = "Assets/GameRes/" + data.name;
        //     Object preb = AssetDatabase.LoadAssetAtPath<GameObject>(name);
        //     GameObject fgEffectGo = Instantiate(preb) as GameObject;
        //     if (fgEffectGo != null)
        //     {
        //         Transform fgEffectTrans = fgEffectGo.transform;
        //         fgEffectTrans.parent = FgEffectLayer.transform;
        //         fgEffectTrans.localPosition = data.pos;
        //         fgEffectTrans.eulerAngles = data.rotation;
        //         fgEffectTrans.localScale = data.scale;
        //         fgEffectGo.name = preb.name;
        //     }
        // }

        // for (int i = 0, len = config.bgEffectList.Count; i < len; i++)
        // {
        //     GridMapEffectData data = config.bgEffectList[i];
        //     string name = "Assets/GameRes/" + data.name;
        //     Object preb = AssetDatabase.LoadAssetAtPath<GameObject>(name);
        //     GameObject bgEffectGo = Instantiate(preb) as GameObject;
        //     if (bgEffectGo != null)
        //     {
        //         Transform bgEffectTrans = bgEffectGo.transform;
        //         bgEffectTrans.parent = BgEffectLayer.transform;
        //         bgEffectTrans.localPosition = data.pos;
        //         bgEffectTrans.eulerAngles = data.rotation;
        //         bgEffectTrans.localScale = data.scale;
        //         bgEffectGo.name = preb.name;
        //     }
        // }
        LoadEffectList(config.fgEffectList, BgEffectLayer);
        LoadEffectList(config.bgEffectList, FgEffectLayer);
        LoadEffectList(config.tfEffectList, TfEffectLayer);
    }

    private void CleanUpEffect()
    {
        BgEffectLayer.RemoveChildren();
        FgEffectLayer.RemoveChildren();
        TfEffectLayer.RemoveChildren();
    }

    private void  LoadEffectList(List<GridMapEffectData> effDataList, GameObject EffectLayerObj)
    {
        for (int i = 0, len = effDataList.Count; i < len; i++)
        {
            GridMapEffectData data = effDataList[i];
            string name = "Assets/GameRes/" + data.name;
            Object preb = AssetDatabase.LoadAssetAtPath<GameObject>(name);
            GameObject go = Instantiate(preb) as GameObject;
            if (go != null)
            {
                Transform trans = go.transform;
                trans.parent = EffectLayerObj.transform;
                trans.localPosition = data.pos;
                trans.eulerAngles = data.rotation;
                trans.localScale = data.scale;
                go.name = preb.name;
            }
        }
    }

    public void SaveTransferConfig(GridMapConfig gridMapConfig)
    {
        if (gridMapConfig == null) return;
        int count = TransferLayer.transform.childCount;
        gridMapConfig.transferList = new List<GridMapTransferData>();
        for (int i = 0; i < count; i++)
        {
            Transform node = TransferLayer.transform.GetChild(i);
            int idx = 0;
            if (!int.TryParse(node.name, out idx))
            {
                Debug.LogError("传送点只能用数字命名 " + node.name);
                continue;
            }

            BoxCollider bc = node.GetComponent<BoxCollider>();
            if (bc != null)
            {
                GridMapTransferData data = new GridMapTransferData
                {
                    idx = idx,
                    pos = node.position,
                    size = node.localScale,
                };
                gridMapConfig.transferList.Add(data);
            }
            else
            {
                Debug.LogError("找不到boxcollider: " + node.name);
            }
        }
        SaveGridMapConfig(gridMapConfig);
        AssetDatabase.Refresh();
    }

    public void SaveEffectConfig(GridMapConfig gridMapConfig)
    {
        if (gridMapConfig == null) return;
        // int fgCount = FgEffectLayer.transform.childCount;
        // gridMapConfig.fgEffectList = new List<GridMapEffectData>(fgCount);
        // for (int i = 0; i < fgCount; i++)
        // {
        //     Transform node = FgEffectLayer.transform.GetChild(i);
        //     var guids = AssetDatabase.FindAssets("t:Prefab " + node.name, new[] { SCENE2d_EFFECT_PATH });
        //     if (guids.Length > 0)
        //     {
        //         string assetPath = AssetDatabase.GUIDToAssetPath(guids[0]);
        //         if (assetPath.StartsWith("Assets/GameRes/"))
        //             assetPath = assetPath.Substring("Assets/GameRes/".Length);

        //         GridMapEffectData data = new GridMapEffectData
        //         {
        //             name = assetPath,
        //             pos = node.localPosition,
        //             rotation = node.localEulerAngles,
        //             scale = node.localScale
        //         };
        //         gridMapConfig.fgEffectList.Add(data);
        //     }
        //     else
        //     {
        //         Debug.LogError("找不到该Prefab:" + node.name);
        //     }
        // }

        // int bgCount = BgEffectLayer.transform.childCount;
        // gridMapConfig.bgEffectList = new List<GridMapEffectData>(bgCount);
        // for (int i = 0; i < bgCount; i++)
        // {
        //     Transform node = BgEffectLayer.transform.GetChild(i);
        //     var guids = AssetDatabase.FindAssets("t:Prefab " + node.name, new[] { SCENE2d_EFFECT_PATH });
        //     if (guids.Length > 0)
        //     {
        //         string assetPath = AssetDatabase.GUIDToAssetPath(guids[0]);
        //         if (assetPath.StartsWith("Assets/GameRes/"))
        //             assetPath = assetPath.Substring("Assets/GameRes/".Length);

        //         GridMapEffectData data = new GridMapEffectData
        //         {
        //             name = assetPath,
        //             pos = node.localPosition,
        //             rotation = node.localEulerAngles,
        //             scale = node.localScale
        //         };
        //         gridMapConfig.bgEffectList.Add(data);
        //     }
        //     else
        //     {
        //         Debug.LogError("找不到该Prefab:" + node.name);
        //     }
        // }
        // 
        gridMapConfig.fgEffectList = GetEffectDataList(FgEffectLayer);
        gridMapConfig.bgEffectList = GetEffectDataList(BgEffectLayer);
        gridMapConfig.tfEffectList = GetEffectDataList(TfEffectLayer);

        SaveGridMapConfig(gridMapConfig);
        AssetDatabase.Refresh();
    }

    private List<GridMapEffectData> GetEffectDataList(GameObject goLayer)
    {
        int cnt = goLayer.transform.childCount;
        List<GridMapEffectData> effDataList = new List<GridMapEffectData>(cnt);
        for (int i = 0; i < cnt; i++)
        {
            Transform node = goLayer.transform.GetChild(i);
            var guids = AssetDatabase.FindAssets("t:Prefab " + node.name, new[] { SCENE2d_EFFECT_PATH });
            if (guids.Length > 0)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(guids[0]);
                if (assetPath.StartsWith("Assets/GameRes/"))
                    assetPath = assetPath.Substring("Assets/GameRes/".Length);
                GridMapEffectData data = new GridMapEffectData
                {
                    name = assetPath,
                    pos = node.localPosition,
                    rotation = node.localEulerAngles,
                    scale = node.localScale,
                };
                effDataList.Add(data);
            }
            else
            {
                Debug.LogError("找不到该Prefab:" + node.name);
            }
        }
        return effDataList;
    }


    private void CleanUpTransfer()
    {
        TransferLayer.RemoveChildren();
    }

    private void LoadAllTransfer(GridMapConfig config)
    {
        CleanUpTransfer();

        List<GridMapTransferData> transferList = config.transferList;
        for (int i = 0; i < transferList.Count; i++)
        {
            GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cube.name = transferList[i].idx.ToString();
            cube.transform.position = transferList[i].pos;
            cube.transform.localScale = transferList[i].size;
            cube.transform.rotation = Quaternion.identity;
            cube.transform.parent = TransferLayer.transform;
        }

    }

    private void LoadAllBuilding(GridMapConfig config)
    {
        CleanUpBuilding();

        //LoadBuildPrefabs(config.id, config.fgBuildingList, "fgbuild", FgBuildLayer);
        //LoadBuildPrefabs(config.id, config.bgBuildingList, "bgbuild", BgBuildLayer);
        //LoadBuilding(config.fgBuildingList, "fgbuild", FgBuildLayer);
        //LoadBuilding(config.bgBuildingList, "bgbuild", BgBuildLayer);
    }

    //private void LoadBuildPrefabs(string sceneId, List<GridMapBuildData> buildDatas, string prefix, GameObject root)
    //{
    //    if (buildDatas.Count > 0)
    //    {
    //        string prefabRoot = string.Format("{0}/{1}/{2}_{1}/Prefabs/", SceneRawDataPath, sceneId, prefix);
    //        foreach (var buildData in buildDatas)
    //        {
    //            string prefabPath = prefabRoot + buildData.name + ".prefab";
    //            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
    //            var go = root.AddChild(prefab);
    //            go.transform.localPosition = buildData.pos;
    //            var spr = go.GetComponent<SpriteRenderer>();
    //            if (spr != null)
    //            {
    //                spr.color = new Color(1f, 1f, 1f, 0.5f);
    //            }
    //        }
    //    }
    //}

    //private void LoadBuilding(List<GridMapBuildData> buildDatas, string prefix, GameObject root)
    //{
    //    if (buildDatas != null && buildDatas.Count > 0)
    //    {
    //        string atlasPath = string.Format("{0}/{1}/{2}_{1}/{2}_{1}_atlas_Data/{2}_{1}_atlasdata.prefab",
    //            SceneRawDataPath, _curSceneId, prefix);
    //        var atlasDataPrefab = AssetDatabase.LoadAssetAtPath(atlasPath, typeof(GameObject)) as GameObject;
    //        var sprCol = atlasDataPrefab.GetComponent<tk2dSpriteCollectionData>();
    //        if (sprCol != null)
    //        {
    //            for (int i = 0; i < buildDatas.Count; i++)
    //            {
    //                var buildData = buildDatas[i];
    //                var go = NGUITools.AddChild(root);
    //                go.name = buildData.name;
    //                var sprite = go.AddComponent<tk2dSprite>();
    //                sprite.cachedTransform.localPosition = buildData.pos;
    //                sprite.SetSprite(sprCol, i);
    //                sprite.Build();
    //            }
    //        }
    //        else
    //        {
    //            Debug.LogError("加载Build图集失败:" + atlasPath);
    //        }
    //    }
    //}

    private void CleanUpBuilding()
    {
        BgBuildLayer.RemoveChildren();
        FgBuildLayer.RemoveChildren();
    }
    #endregion

    #region 生成透明遮罩图集以及配置数据

    //[MenuItem("GameResource/ConvertBox2dToPoly2d", false, 10)]
    //public static void ConvertBox2dToPoly2d()
    //{
    //    var curGo = Selection.activeGameObject;
    //    if (curGo == null) return;
    //    var box2d = curGo.GetComponent<BoxCollider2D>();
    //    if (box2d == null)
    //    {
    //        EditorUtility.DisplayDialog("提示", "获取不到BoxCollider2D组件,请检查!", "OK");
    //        return;
    //    }

    //    var poly2d = curGo.GetComponent<PolygonCollider2D>();
    //    if (poly2d == null)
    //    {
    //        poly2d = curGo.AddComponent<PolygonCollider2D>();
    //    }
    //    var halfSize = box2d.size / 2f;
    //    var offset = box2d.offset;
    //    float xmin = offset.x - halfSize.x;
    //    float xmax = offset.x + halfSize.x;
    //    float ymin = offset.y - halfSize.y;
    //    float ymax = offset.y + halfSize.y;
    //    var points = new Vector2[4];
    //    points[0] = new Vector2(xmin, ymax);
    //    points[1] = new Vector2(xmax, ymax);
    //    points[2] = new Vector2(xmax, ymin);
    //    points[3] = new Vector2(xmin, ymin);
    //    poly2d.points = points;

    //    Object.DestroyImmediate(box2d);
    //}

    private void GenerateAllBuildPrefabs()
    {
        if (!ValidateSceneId(_curSceneId)) return;

        var fgBuildInfo = AssetDatabase.LoadAssetAtPath(string.Format("{0}/{1}/fgbuild_{1}/fgbuild_{1}.json",
            SceneRawDataPath, _curSceneId), typeof(TextAsset)) as TextAsset;
        var bgBuildInfo = AssetDatabase.LoadAssetAtPath(string.Format("{0}/{1}/bgbuild_{1}/bgbuild_{1}.json",
            SceneRawDataPath, _curSceneId), typeof(TextAsset)) as TextAsset;

        var gridMapConfig = LoadGridMapConfig(_curSceneId);
        //获取GridMapConfig,并且清空之前设置的位置信息
        //if (gridMapConfig.fgBuildingList != null)
        //    gridMapConfig.fgBuildingList.Clear();
        //if (gridMapConfig.bgBuildingList != null)
        //    gridMapConfig.bgBuildingList.Clear();

        //GenerateBuildPrefab(fgBuildInfo, gridMapConfig.fgBuildingList);
        //GenerateBuildPrefab(bgBuildInfo, gridMapConfig.bgBuildingList);

        SaveGridMapConfig(gridMapConfig);

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        EditorUtility.DisplayDialog("提示", "生成透明遮罩Prefab成功", "Yes");
    }

    //private void GenerateBuildPrefab(TextAsset buildInfo, List<GridMapBuildData> buildDatas)
    //{
    //    if (buildInfo == null) return;
    //    var rectDic = JsonMapper.ToObject<Dictionary<string, Rect>>(buildInfo.text);
    //    if (rectDic == null)
    //    {
    //        Debug.LogError(buildInfo.name + " 格式异常解析出错!");
    //        return;
    //    }

    //    string folderPath = Path.GetDirectoryName(AssetDatabase.GetAssetPath(buildInfo));
    //    string prefabDir = folderPath + "/Prefabs";
    //    Directory.CreateDirectory(prefabDir);

    //    foreach (var pair in rectDic)
    //    {
    //        string spriteName = pair.Key;
    //        Rect rect = pair.Value;
    //        var buildData = new GridMapBuildData
    //        {
    //            name = spriteName,
    //            pos = new Vector2(rect.x / 100 + rect.width / 200, rect.y / 100 - rect.height / 200),
    //            width = rect.width,
    //            height = rect.height
    //        };
    //        buildDatas.Add(buildData);

    //        string prefabPath = prefabDir + "/" + spriteName + ".prefab";
    //        GameObject buildPrefab;
    //        if (!File.Exists(prefabPath))
    //        {
    //            GameObject go = new GameObject(spriteName);
    //            buildPrefab = PrefabUtility.ReplacePrefab(go, PrefabUtility.CreateEmptyPrefab(prefabPath),
    //                ReplacePrefabOptions.ConnectToPrefab);
    //            DestroyImmediate(go);
    //        }
    //        else
    //        {
    //            buildPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
    //        }
    //        buildPrefab.transform.localPosition = Vector3.zero;
    //        var sprite = AssetDatabase.LoadAssetAtPath<Sprite>(folderPath + "/" + spriteName + ".png");
    //        if (sprite != null)
    //        {
    //            var spr = buildPrefab.GetMissingComponent<SpriteRenderer>();
    //            spr.sprite = sprite;

    //            //现在不用碰撞体做检测了,所以直接禁用掉
    //            var box2d = buildPrefab.GetComponent<BoxCollider2D>();
    //            if (box2d != null)
    //            {
    //                box2d.enabled = false;
    //            }

    //            var poly2d = buildPrefab.GetComponent<PolygonCollider2D>();
    //            if (poly2d != null)
    //            {
    //                poly2d.enabled = false;
    //            }

    //            ////默认添加BoxCollider2D,如果手动替换了PolygonCollider2D,则不添加BoxCollider2D
    //            //var poly2d = buildPrefab.GetComponent<PolygonCollider2D>();
    //            //if (poly2d == null)
    //            //{
    //            //    var box2d = buildPrefab.GetMissingComponent<BoxCollider2D>();
    //            //    //碰撞体坐标修正
    //            //    //box2d.offset = Vector2.zero;
    //            //}
    //            //else
    //            //{
    //            //    //碰撞体坐标修正
    //            //    //var points = poly2d.points;
    //            //    //float halfW = sprite.rect.width / 200;
    //            //    //float halfH = sprite.rect.height / 200;
    //            //    //for (int i = 0; i < points.Length; i++)
    //            //    //{
    //            //    //    Vector2 pos = points[i];
    //            //    //    pos.x -= halfW;
    //            //    //    pos.y += halfH;
    //            //    //    points[i] = pos;
    //            //    //}
    //            //    //poly2d.points = points;
    //            //}
    //        }
    //    }
    //}

    //private void GenerateAllBuildInfo()
    //{
    //    if (!ValidateSceneId(_curSceneId)) return;

    //    var fgBuildInfo = AssetDatabase.LoadAssetAtPath(string.Format("{0}/{1}/fgbuild_{1}/fgbuild_{1}.json",
    //        SceneRawDataPath, _curSceneId), typeof(TextAsset)) as TextAsset;
    //    var bgBuildInfo = AssetDatabase.LoadAssetAtPath(string.Format("{0}/{1}/bgbuild_{1}/bgbuild_{1}.json",
    //        SceneRawDataPath, _curSceneId), typeof(TextAsset)) as TextAsset;

    //    var gridMapConfig = LoadGridMapConfig(_curSceneId);
    //    //获取GridMapConfig,并且清空之前设置的位置信息
    //    gridMapConfig.fgBuildingList.Clear();
    //    gridMapConfig.bgBuildingList.Clear();

    //    GenerateBuildInfo(fgBuildInfo, gridMapConfig.fgBuildingList);
    //    GenerateBuildInfo(bgBuildInfo, gridMapConfig.bgBuildingList);

    //    SaveGridMapConfig(gridMapConfig);

    //    AssetDatabase.SaveAssets();
    //    AssetDatabase.Refresh();

    //    EditorUtility.DisplayDialog("提示", "生成透明遮罩图集成功", "Yes");
    //}

    //private void GenerateBuildInfo(TextAsset buildInfo, List<GridMapBuildData> buildDatas)
    //{
    //    if (buildInfo == null) return;
    //    var rectDic = JsonMapper.ToObject<Dictionary<string, Rect>>(buildInfo.text);
    //    if (rectDic == null)
    //    {
    //        Debug.LogError(buildInfo.name + " 格式异常解析出错!");
    //        return;
    //    }

    //    string folderPath = Path.GetDirectoryName(AssetDatabase.GetAssetPath(buildInfo));
    //    string prefabPath = folderPath + "/" + buildInfo.name + "_atlas.prefab";
    //    tk2dSpriteCollection spriteCollection = null;
    //    if (!File.Exists(prefabPath))
    //    {
    //        GameObject go = new GameObject();
    //        spriteCollection = go.AddComponent<tk2dSpriteCollection>();
    //        spriteCollection.version = tk2dSpriteCollection.CURRENT_VERSION;
    //        tk2dEditorUtility.SetGameObjectActive(go, false);

    //        var atlasPrefab = PrefabUtility.ReplacePrefab(go, PrefabUtility.CreateEmptyPrefab(prefabPath),
    //            ReplacePrefabOptions.ConnectToPrefab);
    //        if (atlasPrefab != null)
    //        {
    //            spriteCollection = atlasPrefab.GetComponent<tk2dSpriteCollection>();
    //            // Select object
    //            Selection.activeObject = atlasPrefab;
    //        }
    //        DestroyImmediate(go);
    //    }
    //    else
    //    {
    //        var atlasPrefab = AssetDatabase.LoadAssetAtPath(prefabPath, typeof(Object)) as GameObject;
    //        if (atlasPrefab != null)
    //        {
    //            spriteCollection = atlasPrefab.GetComponent<tk2dSpriteCollection>();
    //            // Select object
    //            Selection.activeObject = atlasPrefab;
    //        }
    //    }

    //    if (spriteCollection == null) return;

    //    spriteCollection.physicsEngine = tk2dSpriteDefinition.PhysicsEngine.Physics2D;
    //    spriteCollection.textureCompression = tk2dSpriteCollection.TextureCompression.Compressed;

    //    var spriteCollectionProxy = new SpriteCollectionProxy(spriteCollection);
    //    float pixelsPerMeter = spriteCollection.sizeDef.pixelsPerMeter;

    //    foreach (var pair in rectDic)
    //    {
    //        string spriteName = pair.Key;
    //        Rect rect = pair.Value;
    //        var buildData = new GridMapBuildData
    //        {
    //            name = spriteName,
    //            pos = new Vector2(rect.x / pixelsPerMeter, rect.y / pixelsPerMeter)
    //        };
    //        buildDatas.Add(buildData);

    //        var spriteTexture =
    //            AssetDatabase.LoadAssetAtPath(folderPath + "/" + spriteName + ".png", typeof(Texture2D)) as Texture2D;
    //        if (spriteTexture != null)
    //        {
    //            tk2dSpriteCollectionDefinition spriteDef = null;
    //            //已经加入的取原来的数据,否则new一个新的加入
    //            int index = spriteCollectionProxy.FindSpriteBySource(spriteTexture);
    //            if (index != -1)
    //            {
    //                spriteDef = spriteCollectionProxy.textureParams[index];
    //            }
    //            else
    //            {
    //                int slot = spriteCollectionProxy.FindOrCreateEmptySpriteSlot();
    //                spriteDef = spriteCollectionProxy.textureParams[slot];
    //            }

    //            spriteDef.name = spriteName;
    //            spriteDef.texture = spriteTexture;
    //            spriteDef.anchor = tk2dSpriteCollectionDefinition.Anchor.UpperLeft;
    //            spriteDef.dice = true;
    //            spriteDef.diceUnitX = 32;
    //            spriteDef.diceUnitY = 32;
    //            spriteDef.colliderType = tk2dSpriteCollectionDefinition.ColliderType.BoxTrimmed;

    //            //初次生成时需要初始化一下polyColliderIslands的数据
    //            //if (spriteDef.polyColliderIslands == null
    //            //    || spriteDef.polyColliderIslands.Length == 0
    //            //    || !spriteDef.polyColliderIslands[0].IsValid())
    //            //{
    //            //    spriteDef.polyColliderIslands = new tk2dSpriteColliderIsland[1];
    //            //    spriteDef.polyColliderIslands[0] = new tk2dSpriteColliderIsland();
    //            //    spriteDef.polyColliderIslands[0].connected = true;
    //            //    int w = spriteTexture.width;
    //            //    int h = spriteTexture.height;

    //            //    Vector2[] p = new Vector2[4];
    //            //    p[0] = new Vector2(0, 0);
    //            //    p[1] = new Vector2(0, h);
    //            //    p[2] = new Vector2(w, h);
    //            //    p[3] = new Vector2(w, 0);
    //            //    spriteDef.polyColliderIslands[0].points = p;
    //            //}
    //        }
    //    }

    //    spriteCollectionProxy.DeleteUnusedData();
    //    spriteCollectionProxy.CopyToTarget();
    //    tk2dSpriteCollectionBuilder.ResetCurrentBuild();
    //    if (!tk2dSpriteCollectionBuilder.Rebuild(spriteCollection))
    //    {
    //        EditorUtility.DisplayDialog("Failed to commit sprite collection",
    //            "Please check the console for more details.", "Ok");
    //    }
    //    spriteCollectionProxy.CopyFromSource();
    //}

    //private void OpenSpriteCollectionEditor(string prefabPath)
    //{
    //    var prefab = AssetDatabase.LoadAssetAtPath(prefabPath, typeof(GameObject)) as GameObject;
    //    try
    //    {
    //        var spriteCollection = prefab.GetComponent<tk2dSpriteCollection>();
    //        tk2dSpriteCollectionEditorPopup v = EditorWindow.GetWindow(typeof(tk2dSpriteCollectionEditorPopup), false, "SpriteCollection") as tk2dSpriteCollectionEditorPopup;
    //        v.SetGenerator(spriteCollection);
    //        v.Show();
    //    }
    //    catch (Exception)
    //    {
    //        EditorUtility.DisplayDialog("提示", "加载图集失败:" + prefabPath, "OK");
    //    }
    //}
    #endregion
}