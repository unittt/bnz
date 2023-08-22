using System.Collections.Generic;
using UnityEngine;

public class GridMapConfig
{
    public string id;
    public int xTile;
    public int yTile;

    public List<GridMapEffectData> fgEffectList = new List<GridMapEffectData>();
    public List<GridMapEffectData> bgEffectList = new List<GridMapEffectData>();
    public List<GridMapEffectData> tfEffectList = new List<GridMapEffectData>();
    public List<GridMapTransferData> transferList = new List<GridMapTransferData>();
}

public class GridMapEffectData
{
    public string name;
    public Vector2 pos;
    public Vector3 rotation;
    public Vector3 scale;
}

public class GridMapTransferData
{
    public int idx;
    public Vector2 pos;
    public Vector2 size;
}