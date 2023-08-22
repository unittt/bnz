using System;
using UnityEngine;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using LITJson;
using UnityEditor;
using AssetPipeline;

public class UIConfig
{
    public string Name;
    public int Format = -1;
}


public class UIAtlasTools
{
    public const string ConfigPath = "Assets/GameRes/Atlas/AtlasConfig.json";
    private static string[] AtlasFolders = { "Assets/GameRes/Atlas" };


    [MenuItem("优化工具/图集/检查图集压缩格式")]
    public static void UIAtlasCompressCheckMenu()
    {
        UIAtlasCompressCheck();
    }

    [MenuItem("优化工具/图集/生成图集RGB和Alpha通道贴图")]
    private static void SeperateAtlasRGBAlphaTexureMenu()
    {
        if (EditorUtility.DisplayDialog("处理确认", "是否确认分离图集贴图?", "确认", "取消"))
        {
            SeperateAtlasRGBAlphaTexure();
        }
    }

    [MenuItem("优化工具/图集/设置图集通道分离材质")]
    private static void SetAtlasRGBAlphaChannelMaterialMenu()
    {
        if (EditorUtility.DisplayDialog("处理确认", "是否处理图集通道分离材质?", "确认", "取消"))
        {
            SetAtlasRGBAlphaChannelMaterial();
        }
    }

    public static Dictionary<string, UIConfig> ReloadConfig()
    {
        Dictionary<string, UIConfig> configDict = new Dictionary<string, UIConfig>();
        string text = AssetDatabase.LoadAssetAtPath<TextAsset>(ConfigPath).text;
        Debug.Log(text);
        var tList = JsonMapper.ToObject<List<UIConfig>>(AssetDatabase.LoadAssetAtPath<TextAsset>(ConfigPath).text);
        foreach (var config in tList)
        {
            configDict[config.Name] = config;
        }
        return configDict;
    }


    public static void UIAtlasCompressCheck()
    {
        Dictionary<string, UIConfig> configDict = ReloadConfig();

        var GUIDs = AssetDatabase.FindAssets("t:Material", BuildBundlePath.AtlasFolder);
        for (var i = 0; i < GUIDs.Length; i++)
        {
            string resPath = AssetDatabase.GUIDToAssetPath(GUIDs[i]);

            string texPath = resPath.Replace(".mat", ".png");
            string texFileName = Path.GetFileName(texPath);
            string nakeName = Path.GetFileNameWithoutExtension(texFileName);
            TextureImporter importer = TextureImporter.GetAtPath(texPath) as TextureImporter;
            if (importer != null)
            {
                if (configDict.ContainsKey(nakeName))
                {
                    if ((int)importer.textureFormat != configDict[nakeName].Format)
                    {
                        importer.textureFormat = (TextureImporterFormat)Enum.ToObject(typeof(TextureImporterFormat), configDict[nakeName].Format);
                        importer.SaveAndReimport();
                        Debug.LogError(string.Format("修改{0}压缩格式 = {1}", nakeName, importer.textureFormat));
                    }
                }
                else
                {
                    if (importer.textureFormat != TextureImporterFormat.AutomaticCompressed)
                    {
                        importer.textureFormat = (TextureImporterFormat)Enum.ToObject(typeof(TextureImporterFormat), TextureImporterFormat.AutomaticCompressed);
                        importer.SaveAndReimport();
                        Debug.Log(string.Format("注意：修改{0}压缩格式 = AutomaticCompressed", nakeName));
                    }
                }
            }
            else
            {
                Debug.Log(string.Format("找不到图集{0}对应名字贴图{1}", resPath, texPath));
            }
        }
    }

    private static void SeperateAtlasRGBAlphaTexure()
    {
        Dictionary<string, UIConfig> configDict = ReloadConfig();

        string[] guids = AssetDatabase.FindAssets("t:Material", AtlasFolders);// Directory.GetFiles(Application.dataPath, "*.*", SearchOption.AllDirectories);

        foreach (string guid in guids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            Material material = UnityEditor.AssetDatabase.LoadMainAssetAtPath(path) as Material;
            if (material == null)
            {
                Debug.LogError("无效材质路径: " + path);
                continue;
            }

            string texturePath = path.Replace(".mat", ".png");
            Texture mainTex = UnityEditor.AssetDatabase.LoadMainAssetAtPath(texturePath) as Texture;
            if (mainTex == null)
            {
                Debug.LogError("找不到材质对应同名贴图: " + texturePath);
                continue;
            }

            SeperateOneAtlasRGBAlphaTexure(texturePath);
        }
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    public static bool SeperateOneAtlasRGBAlphaTexure(string texPath)
    {
        string mainTexPath = string.Empty;
        string alphaTexPath;
        Texture2D sourcetex = null;

        string assetRelativePath = GetRelativeAssetPath(texPath);
        byte[] sourcebytes = File.ReadAllBytes(assetRelativePath);

        sourcetex = new Texture2D(0, 0);
        sourcetex.LoadImage(sourcebytes, false);
        Color[] colors2rdLevel = sourcetex.GetPixels();

        int width, rawWidth, height, rawHegiht;
        width = rawWidth = sourcetex.width;
        height = rawHegiht = sourcetex.height;

        width = height = Mathf.Max(rawWidth, rawHegiht);
        Texture2D rgbTex = new Texture2D(width, height, TextureFormat.RGB24, false);
        rgbTex.SetPixels(
            0,
            rawHegiht >= rawWidth ? 0 : height - rawHegiht,
            rawWidth,
            rawHegiht,
            sourcetex.GetPixels());

        byte[] bytes = rgbTex.EncodeToPNG();
        mainTexPath = GetRGBTexPath(texPath);

        File.WriteAllBytes(mainTexPath, bytes);
        if (rgbTex != null)
        {
            ReImportAsset(mainTexPath, rgbTex.width, rgbTex.height);
            Debug.Log("图集通道分离 : " + mainTexPath);
        }
        else
        {
            Debug.LogError("MainTex数据错误: " + mainTexPath);
        }

        
        Color[] colorsAlpha = new Color[colors2rdLevel.Length];
        bool bAlphaExist = false;
        for (int i = 0; i < colors2rdLevel.Length; ++i)
        {
            colorsAlpha[i].r = colors2rdLevel[i].a;
            colorsAlpha[i].g = colors2rdLevel[i].a;
            colorsAlpha[i].b = colors2rdLevel[i].a;

            if (!Mathf.Approximately(colors2rdLevel[i].a, 1.0f))
            {
                bAlphaExist = true;
            }
        }


        var alphaTex = new Texture2D(width, height, TextureFormat.RGB24, false);
        alphaTex.SetPixels(0,
            rawHegiht >= rawWidth ? 0 : height - rawHegiht,
            rawWidth,
            rawHegiht,
            colorsAlpha);
        alphaTex.Apply();


        byte[] alphabytes = alphaTex.EncodeToPNG();
        alphaTexPath = GetAlphaTexPath(texPath);
        File.WriteAllBytes(alphaTexPath, alphabytes);
        if (alphaTex != null)
        {
            ReImportAsset(alphaTexPath, alphaTex.width, alphaTex.height);
            Debug.Log("图集通道分离 : " + alphaTexPath);
        }
        else
        {
            Debug.LogError("AlphaTex数据错误: " + alphaTexPath);
        }

        return true;

    }

    static void ReImportAsset(string path, int width, int height)
    {
        try
        {
            AssetDatabase.ImportAsset(path);
        }
        catch
        {
            Debug.LogError("Import Texture failed: " + path);
            return;
        }

        TextureImporter importer = null;
        try
        {
            importer = (TextureImporter)TextureImporter.GetAtPath(path);
        }
        catch
        {
            Debug.LogError("Load Texture failed: " + path);
            return;
        }
        if (importer == null)
        {
            return;
        }
        importer.maxTextureSize = Mathf.Max(width, height);
        importer.anisoLevel = 0;
        importer.isReadable = false;  //increase memory cost if readable is true
        importer.textureFormat = TextureImporterFormat.AutomaticCompressed;
        importer.textureType = TextureImporterType.Advanced;
        importer.filterMode = FilterMode.Bilinear;
        importer.mipmapEnabled = false;
        importer.alphaIsTransparency = true;
        AssetDatabase.ImportAsset(path);
    }


    static string GetRGBTexPath(string _texPath)
    {
        return GetTexPath(_texPath, "_RGB_x2.");
    }

    static string GetAlphaTexPath(string _texPath)
    {
        return GetTexPath(_texPath, "_Alpha_x2.");
    }

    static string GetTexPath(string _texPath, string _texRole)
    {
        string dir = System.IO.Path.GetDirectoryName(_texPath);
        string filename = System.IO.Path.GetFileNameWithoutExtension(_texPath);
        string result = dir + "/" + filename + _texRole + "png";
        return result;
    }

    static string GetRelativeAssetPath(string _fullPath)
    {
        _fullPath = _fullPath.Replace("\\", "/");
        int idx = _fullPath.IndexOf("Assets");
        string assetRelativePath = _fullPath.Substring(idx);
        return assetRelativePath;
    }

    private static bool IsRGBA32Atlas(string path)
    {
        foreach (UIConfig one in configDict.Values)
        {
            string name = Path.GetFileNameWithoutExtension(path);
            if(name == one.Name)
            {
                return true;
            }
        }
        return false;
    }

    private static Dictionary<string, UIConfig> configDict;

    public static void SetAtlasRGBAlphaChannelMaterial()
    {
        configDict = ReloadConfig();
        string[] guids = AssetDatabase.FindAssets("t:Material", AtlasFolders);
        foreach (string guid in guids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);

            Material material = UnityEditor.AssetDatabase.LoadMainAssetAtPath(path) as Material;
            if (material == null)
            {
                Debug.LogError("无效材质路径: " + path);
                continue;
            }

            if(IsRGBA32Atlas(path))
            {
                material.shader = Shader.Find("Unlit/Transparent Colored");
                string pngFile = path.Replace(".mat", ".png");
                Texture mainTex = UnityEditor.AssetDatabase.LoadMainAssetAtPath(pngFile) as Texture;
                if (mainTex != null)
                {
                    material.SetTexture("_MainTex", mainTex);
                }
                else
                {
                    Debug.LogError("找不到资源 " + pngFile);
                }
            }
            else
            {
                material.shader = Shader.Find("Unlit/Transparent RGB Alpha");
                string mainTexPath = GetRGBTexPath(path);
                string alphaTexPath = GetAlphaTexPath(path);

                Texture mainTex = UnityEditor.AssetDatabase.LoadMainAssetAtPath(mainTexPath) as Texture;
                if (mainTex != null)
                {
                    material.SetTexture("_MainTex", mainTex);
                }
                else
                {
                    Debug.LogError("找不到资源 " + mainTexPath);
                    continue;
                }

                Texture alphaTex = UnityEditor.AssetDatabase.LoadMainAssetAtPath(alphaTexPath) as Texture;
                if (alphaTex != null)
                {
                    material.SetTexture("_AlphaTex", alphaTex);
                }
                else
                {
                    Debug.LogError("找不到资源 " + alphaTexPath);
                    continue;
                }
            }
        }
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }
}
