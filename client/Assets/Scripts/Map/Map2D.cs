using System;
using System.Collections.Generic;
using System.Collections;
using Pathfinding;
using UnityEngine;
using LuaInterface;
using LITJson;
using AssetPipeline;

public class Map2D : MonoBehaviour
{
    public static Map2D CurrentMap
    {
        get;
        private set;
    }

    public static float cameraHalfHeight = 5;
    public static float cameraHalfWidth = 5;

    public int mapId;
    public float width;  //meter
    public float height;
    public int xTile;   //分块数量
    public int yTile;
    public int xGrid;   //astar grid
    public int yGrid;
    public float graphSize;

    public int gridPixel = 256;

    private Map2DEffectManager effectManager;
    private GridMapConfig mapConfig;
    private GameObject mapGo;
    private Transform mapTrans;
    private Map2DTile[,] tiles;
    private int curFrame = 0;
    private int loadFrame = 0;
    private int unloadFrame = 0;
    private bool initDone = false;
	private Dictionary<double, List<Vector3>> cachePathDict = new Dictionary<double, List<Vector3>>();
	private Dictionary<double, int> seekRecordDict = new Dictionary<double, int> ();
	private List<double> clearPathRecord = new List<double>();

    public bool isReleased
    {
        private set;
        get;
    }

    public LuaFunction luaCallback;

	public static bool isActiveMapEffect = false;

    public void Release()
    {
        ClearCachePath();

        if (tiles != null)
        {
            for (int i = 0; i < tiles.GetLength(0); ++i)
            {
                for (int j = 0; j < tiles.GetLength(1); ++j)
                {
                    if (tiles[i, j] != null)
                    {
                        tiles[i, j].Recycle();
                    }
                }
            }
            tiles = null;
        }
        if (effectManager != null)
        {
            effectManager.Release();
            effectManager = null;
        }
        if (CurrentMap == this)
        {
            CurrentMap = null;
        }
        if (mapGo != null)
        {
            GameObject.Destroy(mapGo);
            mapGo = null;
            mapTrans = null;
        }
        isReleased = true;
    }

    public void CallLateUpdate(Vector3 pos, bool loadAll)
    {
        if (!initDone)
            return;

        curFrame++;

        UnloadTile(pos, 1.3f);
		LoadTileAsync(pos, loadAll? 1.0f :1.2f, loadAll);
        //if (curFrame - unloadFrame >= 30)
        //{
        //    unloadFrame = curFrame;
        //    UpdateEffect(pos, 1.5f);
        //}
    }

    private Coroutine coroutine;

    public void LoadAsync(int mapid, Vector3 pos, LuaFunction callback)
    {
        mapGo = gameObject;
        mapTrans = transform;
        this.mapId = mapid;
        if (this.luaCallback != null)
        {
            this.luaCallback.Dispose();
        }
        this.luaCallback = callback;

        if (coroutine != null)
        {
            StopCoroutine(coroutine);
        }
        coroutine = StartCoroutine(StartLoadAsync(pos));
    }

    private IEnumerator StartLoadAsync(Vector3 pos)
    {
        LoadMapConfig();
        LoadMapNav();
        // 摄像机跟随会更新地图，不需要在这里加载多一次
        // EnterMapLoadTile(pos, 1.0f, true);

        LoadMapEffect();
        initDone = true;
        CurrentMap = this;

        yield return null;
        if (luaCallback != null)
        {
            luaCallback.Call();
        }
    }

    public void Load(int mapid, Vector3 pos)
    {
        mapGo = gameObject;
        mapTrans = transform;
        this.mapId = mapid;

        LoadMapConfig();
        LoadMapNav();
        LoadTileAsync(pos, 1.0f, true);
        LoadMapEffect();
        initDone = true;
        CurrentMap = this;
    }

    private bool isLoadMapConfig;

    private void LoadMapConfig()
    {
        if (isLoadMapConfig)
            return;
        isLoadMapConfig = true;

        string path = string.Format("Map2d/ConfigData/se_config_{0}.bytes", mapId);
        object asset = ResourceManager.Load(path);
        if (asset != null)
        {
            TextAsset textAsset = asset as TextAsset;
            if (textAsset != null)
            {
                mapConfig = JsonMapper.ToObject<GridMapConfig>(textAsset.text);
                xTile = mapConfig.xTile;
                yTile = mapConfig.yTile;
                width = xTile * gridPixel * 1.0f / 100;
                height = yTile * gridPixel * 1.0f / 100;
                tiles = new Map2DTile[xTile, yTile];
                Resources.UnloadAsset(textAsset);
            }
        }
        else
        {
            Debug.LogError(string.Format("加载{0}错误", path));
        }
    }

    private bool isLoadMapNav;
    private void LoadMapNav()
    {
        if (isLoadMapNav)
            return;
        isLoadMapNav = true;

        string path = string.Format("Map2d/ConfigData/nav_{0}.bytes", mapId);
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
                mapTrans.position = new Vector3(1.28f, 1.28f, 100f);

                BoxCollider bc = mapGo.AddComponent<BoxCollider>();
                bc.size = new Vector3(width, height);
                bc.center = new Vector3(width / 2 - 1.28f, height / 2 - 1.28f);
                Resources.UnloadAsset(data);
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

    private void LoadTileAsync(Vector3 pos, float ratio, bool loadAll)
    {
        float halfHeight = cameraHalfHeight * ratio;
        float halfWidth = cameraHalfWidth * ratio;

        int minx = Mathf.Max(Mathf.FloorToInt((pos.x - halfWidth) * 100 / gridPixel), 0);
        int maxx = Mathf.Min(Mathf.FloorToInt((pos.x + halfWidth) * 100 / gridPixel), xTile - 1);
        int miny = Mathf.Max(Mathf.FloorToInt((pos.y - halfHeight ) * 100 / gridPixel), 0);
        int maxy = Mathf.Min(Mathf.FloorToInt((pos.y + halfHeight) * 100 / gridPixel), yTile - 1);

        //Debug.Log(string.Format("{0} {1} {2} {3} = {4} {5} camera={6}", minx, maxx, miny, maxy, cameraHalfHeight, cameraHalfWidth, pos));
        for (int x = minx; x <= maxx; x++)
        {
            for (int y = miny; y <= maxy; y++)
            {

                Map2DTile tile = tiles[x, y];
                if (tile == null)
                {
                    LoadOneTile(x, y);
                    if (!loadAll)
                    {
                        return;
                    }
                }
            }
        }
    }

    private void UnloadTile(Vector3 pos, float ratio)
    {
        float halfHeight = cameraHalfHeight * ratio;
        float halfWidth = cameraHalfWidth * ratio;
        int minx = Mathf.Max(Mathf.FloorToInt((pos.x - halfWidth) * 100 / gridPixel), 0);
        int maxx = Mathf.Min(Mathf.FloorToInt((pos.x + halfWidth) * 100 / gridPixel), xTile - 1);
        int miny = Mathf.Max(Mathf.FloorToInt((pos.y - halfHeight) * 100 / gridPixel), 0);
        int maxy = Mathf.Min(Mathf.FloorToInt((pos.y + halfHeight) * 100 / gridPixel), yTile - 1);

        for (int x = 0; x < tiles.GetLength(0); x++)
        {
            for (int y = 0; y < tiles.GetLength(1); y++)
            {
                Map2DTile tile = tiles[x, y];
                if (tile != null)
                {
                    if (!(x >= minx && x <= maxx && y >= miny && y <= maxy))
                    {
                        tile.Recycle();
                        tiles[x, y] = null;
                        break;
                    }
                }
            }
        }
    }


    private Map2DTile GetTile(int x, int y)
    {
        Map2DTile tile = tiles[x, y];
        if (tile == null)
        {
            tile = Map2DTile.Get();
            tile.cacheGameObject.name = string.Format("{0}_{1}", x, y);
            tile.cacheTransform.parent = mapTrans;
            tile.cacheTransform.localRotation = Quaternion.Euler(0, 0f, 0f);
            tile.cacheTransform.localScale = new Vector3(2.56f, 2.56f, 2.56f);
            tile.cacheTransform.localPosition = new Vector3(2.56f * x, 2.56f * y, 0f);
            tiles[x, y] = tile;
        }
        return tile;
    }

    private void LoadOneTile(int x, int y)
    {
        Map2DTile tile = GetTile(x, y);
        string path = string.Format("Map2d/{0}/tilemap_{0}/tile_{1}_{2}_{3}.png", mapId, mapId, x, y);
        // 异步加载表现太差，改协程分两帧
        // OnLoadAssetCallback cb = (object asset, LoadErrorCode error)=>{
        //     if (asset != null)
        //     {
        //         Texture2D texture = asset as Texture2D;
        //         if (texture != null)
        //         {
        //             texture.wrapMode = TextureWrapMode.Clamp;
        //             tile.SetTexture(texture);
        //     }
        // }
            
        // };
        
        // ResourceManager.LoadAsync(path, cb);
        object asset = ResourceManager.Load(path);
        if (asset != null)
        {
            Texture2D texture = asset as Texture2D;
            if (texture != null)
            {
                texture.wrapMode = TextureWrapMode.Clamp;
                tile.SetTexture(texture);
            }
        }
    }

    private bool isLoadMapEffect;

    public void LoadMapEffect()
    {
        if (isLoadMapEffect)
            return;
        isLoadMapEffect = true;

        effectManager = new Map2DEffectManager(mapId, mapGo);
		effectManager.SetMapEffectNodeActive (isActiveMapEffect);
        if (mapConfig != null)
        {
			effectManager.LoadBgEffect(mapConfig.bgEffectList);
			effectManager.LoadFgEffect(mapConfig.fgEffectList);
			effectManager.LoadTgEffect(mapConfig.tfEffectList);
        }
    }

    public Vector2 World2GridPos(Vector2 pos)
    {
        Vector2 gridPos;
        gridPos.x = (int)(pos.x / graphSize);
        gridPos.y = (int)(pos.y / graphSize);
        return gridPos;
    }
	
    public bool IsInMapArea(float fx, float fy)
    {
        int x = (int)(fx / graphSize);
        int y = (int)(fy / graphSize);
        return x >= 0 && x < xGrid && y >= 0 && y < yGrid;
    }

    public bool IsWalkable(int x, int y)
    {
        if (x >= 0 && x < xGrid && y >= 0 && y < yGrid)
        {
            GridGraph graph = AstarPath.active.graphs[0] as GridGraph;
            int index = y * xGrid + x;
            GridNode node = graph.nodes[index];
            if (index >= 0 && index < graph.nodes.Length)
            {
                return node.Walkable && (node.Tag == 0);
            }
        }
        return false;
    }

    public bool IsWalkable(float fx, float fy)
    {
        int x = (int)(fx / graphSize);
        int y = (int)(fy / graphSize);
        if (x >= 0 && x < xGrid && y >= 0 && y < yGrid)
        {
            GridGraph graph = AstarPath.active.graphs[0] as GridGraph;
            int index = y * xGrid + x;
            if (index >= 0 && index < graph.nodes.Length)
            {
                GridNode node = graph.nodes[index];
                return node.Walkable && (node.Tag == 0);
            }
        }
        return false;
    }

    public Vector2 GetNearWalkablePos(float posx, float posy)
    {
        int dir = 1;
        int x = 0;
        int y = 0;
        Vector2 nearPos = new Vector2(-1, -1);
        if(IsWalkable(x + posx, y + posy))
        {
            nearPos.x = x + posx;
            nearPos.y = y + posy;
            return nearPos;
        }
        int count = 1;
        while(count < 256)
        {
            if(dir == 1)
            {
                x++;
            }else if(dir == 2){
                y--;
            }else if(dir == 3){
                x--;
            }else if(dir == 4){
                y++;
            }
            if(IsTurnPos(x, y))
            {
                dir = dir%4 + 1;
            }
            if(IsWalkable(x + posx, y + posy))
            {
                nearPos.x = x + posx;
                nearPos.y = y + posy;
                return nearPos;
            }
            count = count + 1;
        }
        return nearPos;
    }

    private bool IsTurnPos(int x, int y)
    {
        if(x >= 1)
        {
            return x + y == 0 || y - x == -1;
        }else if(x <= 1){
            return x + y == 0 || y - x == 0;
        }
        return false;
    }

    public bool IsTransparent(float fx, float fy)
    {
        int x = (int)(fx / graphSize);
        int y = (int)(fy / graphSize);
        if (x >= 0 && x < xGrid && y >= 0 && y < yGrid)
        {
            GridGraph graph = AstarPath.active.graphs[0] as GridGraph;
            int index = y * xGrid + x;
            if(index >= 0 && index < graph.nodes.Length)
            {
                GridNode node = graph.nodes[index];
                return node.Transparent;
            }
        }
        return false;
    }


    public bool IsLinePath(Vector3 startPos, Vector3 endPos)
    {
        Vector2 startGridPos = World2GridPos(startPos);
        Vector2 endGridPos = World2GridPos(endPos);
        int dis = (int)Vector3.Distance(startGridPos, endGridPos);
        dis = Mathf.Max(dis, 1);
        int x, y;
        for (int i = 1; i <= dis; i++)
        {
            Vector3 pos = Vector3.Lerp(startGridPos, endGridPos, 1.0f * i / dis);
            x = (int)pos.x;
            y = (int)pos.y;
            if (!IsWalkable(x, y))
            {
                return false;
            }
        }
        return true;
    }

    public void PrintMapData()
    {
        System.Text.StringBuilder builder = new System.Text.StringBuilder();
        GridGraph graph = AstarPath.active.graphs[0] as GridGraph;
        Debug.Log("length " + graph.nodes.Length + " " + xGrid + " " + yGrid);
        for (int y = 0; y < yGrid; y++)
        {
            for (int x = 0; x < xGrid; x++)
            {
                int index = (yGrid - y - 1) * xGrid + x;
                if (graph.nodes[index].Transparent)
                    builder.Append("1");
                else
                    builder.Append("0");
            }
            builder.Append("\n");
        }
        Debug.Log(builder.ToString());
    }

    public int GetPos2Transfer(Vector2 pos)
    {
        if (mapConfig == null)
            return 0;

        List<GridMapTransferData> transferList = mapConfig.transferList;
        for (int i = 0; i < transferList.Count; i++)
        {
            GridMapTransferData data = transferList[i];
            if ((data.pos.x - data.size.x / 2 <= pos.x && pos.x <= data.pos.x + data.size.x / 2) &&
                (data.pos.y - data.size.y / 2 <= pos.y && pos.y <= data.pos.y + data.size.y / 2))
            {
                return data.idx;
            }
        }
        return 0;
    }

    public List<GridMapTransferData> GetTransferList()
    {
        if (mapConfig != null)
        {
            return mapConfig.transferList;
        }
        return null;
    }

	public void SetMapEffectGoActive(bool show)
	{
		if (effectManager != null)
		{
			effectManager.SetMapEffectGoActive(show);
		}
	}

	public void SetMapEffectNodeActive(bool active)
	{
		isActiveMapEffect = active;
		if (effectManager != null) {
			effectManager.SetMapEffectNodeActive(active);
		}
	}
		

	public List<Vector3> GetCachePath(int[] posArray)
	{
		double key = GetPathKey (posArray);
		if (!cachePathDict.ContainsKey (key))
			return null;
		List<Vector3> path = this.cachePathDict [key];
		return path;
	}

	public double GetPathKey(int[] posArray)
	{
		double key = posArray[0] + posArray[1] * Math.Pow(10.0, 2.0) + posArray[2] * Math.Pow(10.0, 4.0) + posArray[3] * Math.Pow(10.0, 6.0) + mapId * Math.Pow(10.0, 8.0);
		return key;
	}

	public void AddSeekRecord(int[]posArray, List<Vector3> path)
    {
		double key = GetPathKey (posArray);
        int cnt = 1;
        if (seekRecordDict.ContainsKey (key))
			cnt = Math.Max(seekRecordDict[key] + 1, 3);
        seekRecordDict[key] = cnt;

		if(cnt > 2)
			AddCachePath(key, path);
    }

    public void AddCachePath(double key, List<Vector3> path)
    {
        if (cachePathDict.ContainsKey (key)) {
            return;
        }
        List<Vector3> cachePath = new List<Vector3> ();
        for (int i = 0; i < path.Count; i++)
        {
            Vector3 point = new Vector3 ();
            point.x = path [i].x;
            point.y = path [i].y;
            point.z = path [i].z;
            cachePath.Add (point);
        }
        this.cachePathDict.Add (key, cachePath);
        //主场景复用性高不需要移除
        if (mapId != 1010) 
        {
            clearPathRecord.Add (key);
        }
    }

    public void ClearCachePath()
    {
		// Debug.Log ("clearCachePath");
		seekRecordDict.Clear ();
		double key;
		for (int i = 0; i < clearPathRecord.Count; i++) 
		{
			key = clearPathRecord [i];
			if (key > 0)
			{
				cachePathDict [key].Clear ();
				cachePathDict.Remove (key);
			}
		}
		clearPathRecord.Clear();
    }
}
