using System;
using System.Collections;
using System.Collections.Generic;
using Pathfinding;
using LuaInterface;
using UnityEngine;
using LITJson;

public class Map3DConfig
{
    public int mapid;
}


public class Map3DHeightData
{
	public Dictionary<string, Dictionary<string, string>> data = new Dictionary<string, Dictionary<string, string>>();
	public Vector3 minPos = Vector3.zero;
	public Vector3 maxPos = Vector3.zero;
	public float step = 0.35f;
	public float GetHeight(float x, float z)
	{
		if (x < minPos.x || x > maxPos.x || z < minPos.z || z > maxPos.z)
		{
			return 0f;
		}
		
		float nearX = minPos.x + Mathf.Round((x - minPos.x)/step) * step;
		Dictionary<string, string> dict;
		string s = nearX.ToString("F2");
		if (data.TryGetValue(nearX.ToString("F2"), out dict))
		{
			float nearZ = minPos.z + Mathf.Round((z - minPos.z) / step) * step;
			string heightString;
			if (dict.TryGetValue(nearZ.ToString("F2"), out heightString))
			{
				return float.Parse(heightString);
			}
		}
		
		return 0f;
	}
}


public class Map3D: MonoBehaviour
{
    public static Map3D CurrentMap
    {
        get;
        private set;
    }

    private LuaFunction luaLoadCallback;
    private Map3DConfig mapConfig;

    private GameObject mapGo;
    private Transform mapTrans;
    private Transform modelTrans;

    private bool loadModelDone = false;
    private bool loadLightmapDone = false;
    
	private Map3DHeightData heightData;

    public int xGrid;
    public int yGrid;
    public float graphSize;

    private Vector2 offset;

    //public int mapWidth
    //{
    //    get;
    //    private set;
    //}

    //public int mapHeight
    //{
    //    get;
    //    private set;
    //}

    //public Vector3 mapCenter
    //{
    //    get;
    //    private set;
    //}

    public int mapid
    {
        get;
        private set;
    }

    public int lightmapid
    {
        get;
        private set;
    }

	public void Release()
    {
        if (CurrentMap == this)
        {
            CurrentMap = null;
            Map3DLightmap.ResetRender();
        }
    }

    public void LoadAsync(int mapid, int lightmapid, bool loadnav, LuaFunction callback)
    {
        this.mapid = mapid;
        this.lightmapid = lightmapid;
        CurrentMap = this;
        StartCoroutine(StartLoadAsync(loadnav, callback));
    }

    private IEnumerator StartLoadAsync(bool loadnav, LuaFunction callback)
    {
        LoadMapConfig();
        if (loadnav)
        {
			LoadHeightData();
            LoadMapNav();
        }
        LoadMapModelAsync();
        LoadLightmap(lightmapid);

        yield return null;
        if (callback != null)
        {
            callback.Call(100);
            callback.Dispose();
        }
        
    }

    private void LoadMapConfig()
    {
        string path = string.Format("Map3d/{0}/map3d_config_{0}.bytes", mapid);
        object asset = ResourceManager.Load(path);
        if (asset != null)
        {
            TextAsset textAsset = asset as TextAsset;
            if (textAsset != null)
            {
                mapConfig = JsonMapper.ToObject<Map3DConfig>(textAsset.text);
            }
        }
        else
        {
            Debug.LogError(string.Format("加载{0}错误", path));
        }
    }

    private void LoadMapNav()
    {
        string path = string.Format("Map3d/{0}/map3d_nav_{0}.bytes", mapid);
        object asset = ResourceManager.Load(path);
        if (asset != null)
        {
            TextAsset data = asset as TextAsset;
            if (data != null)
            {
                AstarPath.active.astarData.DeserializeGraphs(data.bytes);
                GridGraph graph = AstarPath.active.astarData.gridGraph;
                xGrid = graph.width;
                yGrid = graph.depth;
                graphSize = graph.nodeSize;

                offset = new Vector2(graph.width / 2 - graph.center.x, graph.depth / 2 - graph.center.y);
            }
            else
            {
                Debug.LogError("地图加载错误 " + path);
            }
        }
        else
        {
            Debug.LogError("地图加载错误 " + path);
        }
    }

    private void LoadMapModelAsync()
    {
        loadModelDone = false;
        string path = string.Format("Map3d/{0}/map3d_{1}.prefab", mapid, mapid);
        object asset = ResourceManager.Load(path);
        if (asset != null)
        {
            GameObject mapPrefab = asset as GameObject;
            GameObject go = GameObject.Instantiate<GameObject>(mapPrefab);
            go.name = "Model";
            modelTrans = go.transform;
            modelTrans.localPosition = mapPrefab.transform.localPosition;
            modelTrans.localRotation = mapPrefab.transform.localRotation;
            modelTrans.parent = gameObject.transform;
        }
    }


    private void LoadLightmap(int index)
    {
        loadLightmapDone = false;
        string path = string.Format("Map3d/{0}/lightmap_{0}_{1}.prefab", mapid, lightmapid);
        object asset = ResourceManager.Load(path);
        if (asset != null)
        {
            GameObject mapPrefab = asset as GameObject;
            Map3DLightmapData data = mapPrefab.GetComponent<Map3DLightmapData>();
            Map3DLightmap.LoadLightmap(data, modelTrans);
        }
    }

	private void LoadHeightData()
	{
		string path = string.Format("Map3d/{0}/map3d_height_{0}.bytes", mapid);
		object asset = ResourceManager.Load(path);
		if (asset != null)
		{
			TextAsset textAsset = asset as TextAsset;
			if (textAsset != null)
			{
				heightData = JsonMapper.ToObject<Map3DHeightData>(textAsset.text);
				return;
			}
		}
		heightData = null;
	}

    public List<GridMapTransferData> GetTransferList()
    {
        return new List<GridMapTransferData>();
    }

    public Vector3 World2GridPos(Vector3 pos)
    {
        float x = (int)((pos.x + offset.x) / graphSize);
        float z = (int)((pos.z + offset.y) / graphSize);
        return new Vector3(x, 0, z);
    }

    public bool IsWalkable(int x, int y)
    {
        if (x >= 0 && x < xGrid && y >= 0 && y < yGrid)
        {
            GridGraph graph = AstarPath.active.graphs[0] as GridGraph;
            int index = y * xGrid + x;
            GridNode node = graph.nodes[index];
            return node.Walkable && (node.Tag == 0);
        }
        return false;
    }

    public bool IsLinePath(Vector3 startPos, Vector3 endPos)
    {
        Vector3 startGridPos = World2GridPos(startPos);
        Vector3 endGridPos = World2GridPos(endPos);
        int dis = (int)Vector3.Distance(startGridPos, endGridPos);
        dis = Mathf.Max(dis, 1);
        int x, z;
        for (int i = 1; i <= dis; i++)
        {
            Vector3 pos = Vector3.Lerp(startGridPos, endGridPos, 1.0f * i / dis);
            x = (int)pos.x;
            z = (int)pos.z;
            
            if (!IsWalkable(x, z))
            {
                return false;
            }
        }
        return true;
    }

	public float GetHeight(float x, float z)
	{
		if (heightData != null)
		{
			return heightData.GetHeight(x, z);
		}
		return 0f;
	}
}