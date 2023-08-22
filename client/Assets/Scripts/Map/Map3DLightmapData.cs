using SimpleJson;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;


[System.Serializable]
public class Map3DRenderData
{
    public LightmapsMode lightmapMode;
    public UnityEngine.Rendering.AmbientMode ambientMode;
    public Color ambientLight;
    public float ambientIntensity;
    public Color ambientEquatorColor;
    public Color ambientGroundColor;
    public Color ambientSkyColor;
    public int defaultReflectionResolution;

    public bool fog;
    public Color fogColor;
    public float fogDensity;
    public float fogEndDistance;
    public FogMode fogMode;
    public float fogStartDistance;
    public float haloStrength;
}

[System.Serializable]
public class Map3DModelLightData
{
    public int index;
    public Vector4 scaleOffset;
}

public class Map3DLightmapData : MonoBehaviour
{
    public Map3DRenderData renderData;
    public List<Texture2D> nearTextureList = new List<Texture2D>();
    public List<Texture2D> farTextureList = new List<Texture2D>();
    public List<Map3DModelLightData> modelLightList = new List<Map3DModelLightData>();
}