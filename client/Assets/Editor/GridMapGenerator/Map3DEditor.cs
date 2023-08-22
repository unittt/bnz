using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using Pathfinding;
using System.Text;
using LITJson;

public class Map3DEditor : EditorWindow
{
    private static Map3DEditor _window;
    public static int mapID;
    public static int lightMapID = 1;

    private static Map3DConfig mapConfig;
    private static AstarPath astarPath;
    private static GameObject curMapGo;
    private static GameObject curDataGo;

    private static GameObject mapGo
    {
        get
        {
            if (curMapGo == null)
            {
                string name = string.Format("Scene_{0}_{1}", mapID, lightMapID);
                curMapGo = GameObject.Find(name);
            }
            if (curMapGo == null)
            {
                Debug.LogErrorFormat("找不到场景对象：Scene_{0}_{1}", mapID, lightMapID);
            }
            return curMapGo;
        }
    }

    private static int mapWidth;
    private static int mapHeight;
    private static Vector3 mapCenter;
    private static float mapNodeSize;

    private static bool bExportServerData = true;
    private static bool bExportLightmapData = true;
    private static bool bExportModelData = true;

    [MenuItem("地图/3D地图编辑器", false, 52)]
    static void Init()
    {
        _window = (Map3DEditor)EditorWindow.GetWindow(typeof(Map3DEditor));
        _window.Show();
        _window.minSize = new Vector2(400, 300);
        _window.titleContent = new GUIContent("3D地图编辑器");
    }

    public void OnDestroy()
    {
        Release();
    }

    public void Release()
    {
        if (astarPath != null)
        {
            GameObject.DestroyImmediate(astarPath.gameObject);
        }
        if (curDataGo != null)
        {
            GameObject.DestroyImmediate(curDataGo);
        }
        //DestroyKeyPointText();
    }


    void OnGUI()
    {
        mapID = EditorGUILayout.IntField("地图ID", mapID);
        lightMapID = EditorGUILayout.IntField("光照贴图ID", lightMapID);

        GUILayout.BeginArea(new Rect(50, 50, 200, 400));
        //GUILayout.Label(new GUIContent("地图分块处理"));
        if (GUILayout.Button("打开Astar数据"))
        {
            if (mapGo == null)
                return;

            OpenMap();
        }

		GUILayout.Space(20);
		if (GUILayout.Button("生成高度数据"))
		{
			if (mapGo == null)
				return;
			CreateHeightData();
		}
		
        GUILayout.Space(20);
        bExportModelData = GUILayout.Toggle(bExportModelData, new GUIContent("导出地图模型"));
        bExportLightmapData = GUILayout.Toggle(bExportLightmapData, new GUIContent("导出光照数据"));
        //bExportEffectData = GUILayout.Toggle(bExportEffectData, new GUIContent("导出特效数据"));
        if (GUILayout.Button("开始处理"))
        {
            if (mapGo == null)
                return;

            OpenMap();
            if (bExportModelData)
            {
                CreateModelPrefab();
            }

            if (bExportLightmapData)
            {
                CreateModelLightmapData();
                SaveMapConfig();
            }

            AssetDatabase.Refresh();
        }
        GUILayout.EndArea();
    }

    public static void OpenMap()
    {
        //InitDirectory();
        LoadMapData();
        LoadAstarData();
    }

    public static void LoadAstarData()
    {
        GameObject go = GameObject.Find("AstarPath");
        if (go != null)
        {
            GameObject.DestroyImmediate(go);
        }

        go = new GameObject("AstarPath");
        astarPath = go.AddComponent<AstarPath>();
        astarPath.showNavGraphs = false;
        AstarPath.active = astarPath;
        astarPath.astarData = new AstarData();
        TextAsset graphData = AssetDatabase.LoadAssetAtPath(string.Format("Assets/GameRes/Map3d/{0}/map3d_nav_{0}.bytes", mapID), typeof(TextAsset)) as TextAsset;
        if (graphData != null)
        {
            astarPath.astarData.DeserializeGraphs(graphData.bytes);
            GridGraph gridGrpah = astarPath.astarData.graphs[0] as GridGraph;
            if (gridGrpah != null)
            {
                gridGrpah.collision.diameter = 2.0f;
                mapWidth = gridGrpah.Width;
                mapHeight = gridGrpah.Depth;
                mapCenter = gridGrpah.center;
                mapNodeSize = gridGrpah.nodeSize;
                Debug.Log(string.Format("读取地图{0} graph成功 type=GridGraph size= {1}x{2}", mapID, mapWidth, mapHeight));
            }
        }
        else
        {
            Debug.LogError(string.Format("读取地图{0} graph.bytes失败 请创建", mapID));
        }
    }

    private static void LoadMapData()
    {
        if (curDataGo != null)
        {
            GameObject.DestroyImmediate(curDataGo);
            curDataGo = null;
        }

        string path = string.Format("Assets/GameRes/Map3d/{0}/map3d_config_{0}.bytes", mapID);
        TextAsset config = AssetDatabase.LoadAssetAtPath(path, typeof(TextAsset)) as TextAsset;

        if (config != null)
        {
            mapConfig = JsonMapper.ToObject<Map3DConfig>(config.text);
        }
        else
        {
            mapConfig = new Map3DConfig();
        }
        mapConfig.mapid = mapID;

    }


    private static void CreateModelPrefab()
    {
        Transform modelTrans = mapGo.transform.Find("Model");
        if(modelTrans == null)
        {
            Debug.LogError("找不到Model节点");
        }
		var clone = UnityEngine.GameObject.Instantiate(mapGo);
		for(var i=0; i<clone.transform.childCount-1; i++ )
		{
			var child = clone.transform.GetChild(i);
			if (child.gameObject.activeSelf == false)
				UnityEngine.GameObject.DestroyImmediate(child.gameObject);	
		}
			
        string path = string.Format("Assets/GameRes/Map3d/{0}/map3d_{0}.prefab", mapID);
		ReplacePrefab(clone.gameObject, path);
		//UnityEngine.GameObject.DestroyImmediate(clone.gameObject);

        Debug.Log("保存地图模型 " + path);
    }

    private static void SaveMapConfig()
    {
        string path = string.Format("Assets/GameRes/Map3d/{0}/map3d_config_{0}.bytes", mapID);
        FileHelper.SaveJsonObj(mapConfig, path);
        Debug.Log("保存地图配置 " + path);
    }

    private static void ReplacePrefab(GameObject go, string path)
    {
        MakeSureFileDirExists(path);
        NGUITools.SetLayer(go, GetLayer());
        Object obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject));
        if (obj == null)
        {
            PrefabUtility.CreatePrefab(path, go, ReplacePrefabOptions.ReplaceNameBased);
        }
        else
        {
            PrefabUtility.ReplacePrefab(go, obj, ReplacePrefabOptions.ReplaceNameBased);
        }
    }

    public static int GetLayer()
    {   
        if(6000 <= mapID && mapID < 7000)
        {
            return LayerMask.NameToLayer("House");
        }
        else if (5000 <= mapID && mapID < 6000)
        {
			return LayerMask.NameToLayer("MapTerrain");
        }
        return LayerMask.NameToLayer("Default");
    }

    public static void MakeSureFileDirExists(string path)
    {
        path = path.Replace("\\", "/");
        int pos = path.LastIndexOf("/");
        if (pos > 0)
        {
            string dirName = path.Substring(0, pos);
            if (!string.IsNullOrEmpty(dirName) && !Directory.Exists(dirName))
            {
                Directory.CreateDirectory(dirName);
            }
        }
    }

    private static void CreateModelLightmapData()
    {
        GameObject go = new GameObject("lightmapData " + mapID);
        Map3DLightmapData lightData = go.AddComponent<Map3DLightmapData>();

        List<Map3DModelLightData> modelLightList = new List<Map3DModelLightData>();
        MeshRenderer[] meshRenders = mapGo.transform.GetComponentsInChildren<MeshRenderer>(true);
        for (int i = 0; i < meshRenders.Length; ++i)
        {
            Map3DModelLightData data = new Map3DModelLightData();
            data.index = meshRenders[i].lightmapIndex;
            data.scaleOffset = meshRenders[i].lightmapScaleOffset;
            modelLightList.Add(data);
        }

        List<Texture2D> nearTextureList = new List<Texture2D>();
        List<Texture2D> farTextureList = new List<Texture2D>();
        for(int i = 0; i < LightmapSettings.lightmaps.Length; i++)
        {
            if(LightmapSettings.lightmaps[i].lightmapNear != null)
            {
                nearTextureList.Add(LightmapSettings.lightmaps[i].lightmapNear);
            }
            if (LightmapSettings.lightmaps[i].lightmapFar != null)
            {
                farTextureList.Add(LightmapSettings.lightmaps[i].lightmapFar);
            }
        }

        lightData.nearTextureList = nearTextureList;
        lightData.farTextureList = farTextureList;
        lightData.modelLightList = modelLightList;


        lightData.renderData = new Map3DRenderData();
        Map3DRenderData renderData = lightData.renderData;
        renderData.ambientEquatorColor = RenderSettings.ambientEquatorColor;
        renderData.ambientGroundColor = RenderSettings.ambientGroundColor;
        renderData.ambientIntensity = RenderSettings.ambientIntensity;
        renderData.ambientLight = RenderSettings.ambientLight;
        renderData.ambientMode = RenderSettings.ambientMode;
        renderData.ambientSkyColor = RenderSettings.ambientSkyColor;
        renderData.defaultReflectionResolution = RenderSettings.defaultReflectionResolution;

        renderData.fog = RenderSettings.fog;
        renderData.fogColor = RenderSettings.fogColor;
        renderData.fogDensity = RenderSettings.fogDensity;
        renderData.fogEndDistance = RenderSettings.fogEndDistance;
        renderData.fogMode = RenderSettings.fogMode;
        renderData.fogStartDistance = RenderSettings.fogStartDistance;
        renderData.haloStrength = RenderSettings.haloStrength;

        string path = string.Format("Assets/GameRes/Map3d/{0}/lightmap_{0}_{1}.prefab", mapID, lightMapID);
        ReplacePrefab(go, path);
        GameObject.DestroyImmediate(go);
    }

	private void CreateHeightData()
	{
		OpenMap();
		var graph = astarPath.graphs[0] as GridGraph;
		if (graph == null)
		{
			return;
		}
		Vector3 minPos = new Vector3(graph.center.x - graph.width / 2, 0, graph.center.z - graph.depth / 2);
		Vector3 maxPos = new Vector3(graph.center.x + graph.width / 2, 0, graph.center.z + graph.depth / 2);

		minPos = RoundVector(astarPath.transform.InverseTransformPoint(minPos));
		maxPos = RoundVector(astarPath.transform.InverseTransformPoint(maxPos));

		Map3DHeightData data = new Map3DHeightData();
		data.minPos = minPos;
		data.maxPos = maxPos;
		int mask = LayerMask.GetMask(new string[1] { "MapTerrain" });
		for (float x = minPos.x; x <= maxPos.x; x += data.step)
		{
			for (float z = minPos.z; z <= maxPos.z; z += data.step)
			{
				Vector3 rayPos = new Vector3(x, 99, z);
				rayPos = RoundVector(astarPath.transform.TransformPoint(rayPos));
				RaycastHit hitInfo;
				Ray ray = new Ray(rayPos, -astarPath.transform.up);
				if (Physics.Raycast(ray, out hitInfo, float.MaxValue, mask))
				{
					var key = x.ToString("F2");
					if (data.data.ContainsKey(key) == false)
					{
						data.data[key] = new Dictionary<string, string>();
					}
					data.data[key][z.ToString("F2")] = hitInfo.point.y.ToString("F3");
				}

			}
		}
		string path = string.Format("Assets/GameRes/Map3d/{0}/map3d_height_{0}.bytes", mapID);
		FileHelper.SaveJsonObj(data, path);
		Debug.Log("高度数据生成完毕!!!");
	}

	public Vector3 RoundVector(Vector3 v, int i=2)
	{
		v.x = (float)System.Math.Round((double)v.x, i);
		v.y = (float)System.Math.Round((double)v.y, i);
		v.z = (float)System.Math.Round((double)v.z, i);
		return v;
	}
}