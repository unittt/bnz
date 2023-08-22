using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class Map3DLightmap
{
    public bool loadAmbient = false;
    public bool loadFog = false;


    public static void LoadLightmap(Map3DLightmapData data, Transform trans)
    {
        LoadLightmapTexture(data);
        LoadLightmapModel(data, trans);
        LoadRender(data);
    }

    public static void LoadLightmapTexture(Map3DLightmapData data)
    {
        int count = Mathf.Max(data.nearTextureList.Count, data.farTextureList.Count);
        LightmapData[] lightmapData = new LightmapData[count];
        for (int i = 0; i < lightmapData.Length; i++)
        {
            lightmapData[i] = new LightmapData();
        }

        for (int i = 0; i < data.nearTextureList.Count; i++)
        {
            lightmapData[i].lightmapNear = data.nearTextureList[i];
        }

        for (int i = 0; i < data.farTextureList.Count; i++)
        {
            lightmapData[i].lightmapFar = data.farTextureList[i];
        }

        LightmapSettings.lightmaps = lightmapData;
    }

    public static void LoadLightmapModel(Map3DLightmapData data, Transform trans)
    {
        List<Map3DModelLightData> modelLightData = data.modelLightList;
        MeshRenderer[] meshRenders = trans.GetComponentsInChildren<MeshRenderer>(true);
        if (modelLightData.Count == meshRenders.Length)
        {
            for (int i = 0; i < meshRenders.Length; ++i)
            {
                meshRenders[i].lightmapIndex = modelLightData[i].index;
                meshRenders[i].lightmapScaleOffset = modelLightData[i].scaleOffset;
            }
        }
    }

    public static void ResetRender()
    {
        LightmapSettings.lightmaps = null;
        LightmapSettings.lightmapsMode = LightmapsMode.NonDirectional;

        RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
        RenderSettings.ambientLight = Color.white;
        RenderSettings.ambientIntensity = 1.0f;
        RenderSettings.fog = false;
    }


    public static void LoadRender(Map3DLightmapData data)
    {
        Map3DRenderData renderData = data.renderData;
        RenderSettings.ambientEquatorColor = renderData.ambientEquatorColor;
        RenderSettings.ambientGroundColor = renderData.ambientGroundColor;
        RenderSettings.ambientIntensity = renderData.ambientIntensity;
        RenderSettings.ambientLight = renderData.ambientLight;
        RenderSettings.ambientMode = renderData.ambientMode;
        RenderSettings.ambientSkyColor = renderData.ambientSkyColor;
        RenderSettings.defaultReflectionResolution = renderData.defaultReflectionResolution;

        RenderSettings.fog = renderData.fog;
        RenderSettings.fogColor = renderData.fogColor;
        RenderSettings.fogDensity = renderData.fogDensity;
        RenderSettings.fogEndDistance = renderData.fogEndDistance;
        RenderSettings.fogMode = renderData.fogMode;
        RenderSettings.fogStartDistance = renderData.fogStartDistance;
        RenderSettings.haloStrength = renderData.haloStrength;
    }
}
