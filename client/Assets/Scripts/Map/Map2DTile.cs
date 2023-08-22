using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using AssetPipeline;


public class Map2DTile
{
    public static GameObject mapTileGo;
    public static Transform mapTileTrans;
    public static GameObject tilePrefab;
    private static Stack<Map2DTile> cacheTiles = new Stack<Map2DTile>();

    public static Map2DTile Get()
    {
        if (mapTileGo == null)
        {
            mapTileGo = new GameObject("MapTile");
            mapTileGo.SetActive(false);
            mapTileTrans = mapTileGo.transform;
            mapTileGo.transform.position = new Vector3(1.28f, 1.28f, 100);
        }

        Map2DTile tile = null;
        if (cacheTiles.Count > 0)
        {
            tile = cacheTiles.Pop();
            tile.Reinit();
        }
        else
        {
            if (tilePrefab == null)
            {
                string path = string.Format("Map2d/grid/mapgrid.prefab");
                object asset = ResourceManager.Load(path);
                if (asset != null)
                {
                    Map2DTile.tilePrefab = asset as GameObject;
                }
            }
            GameObject go = GameObject.Instantiate<GameObject>(tilePrefab);
            tile = new Map2DTile(go);
        }
        return tile;
    }


    public Transform cacheTransform
    {
        get;
        private set;
    }

    public GameObject cacheGameObject
    {
        get;
        private set;
    }

    public bool isDone
    {
        get;
        private set;
    }

    private Material mat;

    public Map2DTile(GameObject go)
    {
        cacheGameObject = go;
        cacheTransform = go.transform;
        cacheTransform.parent = mapTileGo.transform;
        MeshRenderer render = go.GetComponent<MeshRenderer>();
        mat = render.material;
        isDone = false;
    }

    public void Reinit()
    {
        isDone = false;
        //cacheGameObject.SetActive(true);
    }


    public void Release()
    {
        Texture tex = mat.GetTexture("_MainTex");
        if (tex != null)
        {
            GameObject.Destroy(tex);
        }
        GameObject.Destroy(cacheGameObject);
        cacheTransform = null;
        cacheGameObject = null;
        mat = null;
    }

    public void SetTexture(Texture texture)
    {
        isDone = texture != null;
        mat.SetTexture("_MainTex", texture);
    }

    public void Recycle()
    {
        cacheTransform.parent = mapTileTrans;
        isDone = false;
        Texture tex = mat.GetTexture("_MainTex");
        if(tex != null)
        {
            Resources.UnloadAsset(tex);
        }
        mat.SetTexture("_MainTex", null);
        if (cacheGameObject != null)
        {
            //cacheGameObject.SetActive(false);
            cacheTiles.Push(this);
        }
    }

}
