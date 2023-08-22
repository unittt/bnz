using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;


public class TextureTools: AssetPostprocessor
{
    //设置model texture纹理属性
    public void OnPostprocessTexture(Texture2D texture)
    {
        //模型贴图
        if (assetPath.IndexOf("Assets/GameRes/Model/Character/") >= 0)
        {
            TextureImporter importer = (TextureImporter)TextureImporter.GetAtPath(assetPath);
            importer.textureType = TextureImporterType.Advanced;
            importer.spriteImportMode = SpriteImportMode.None;
            importer.wrapMode = TextureWrapMode.Clamp;
            importer.mipmapEnabled = false;
            importer.isReadable = false;
            importer.anisoLevel = -1;
            importer.filterMode = FilterMode.Bilinear;
            importer.textureFormat = TextureImporterFormat.AutomaticCompressed;
        }

        if (assetPath.IndexOf("Assets/GameRes/Atlas/") >= 0)
        {
            TextureImporter importer = (TextureImporter)TextureImporter.GetAtPath(assetPath);
            importer.textureType = TextureImporterType.Advanced;
            importer.spriteImportMode = SpriteImportMode.None;
            importer.alphaIsTransparency = true;
            importer.wrapMode = TextureWrapMode.Repeat;
            importer.mipmapEnabled = false;
            importer.anisoLevel = -1;
            importer.filterMode = FilterMode.Bilinear;
        }

        if (assetPath.IndexOf("Assets/GameRes/Map2d/") >= 0)
        {
            //ConverMapTileToJPG(assetPath);

            TextureImporter importer = (TextureImporter)TextureImporter.GetAtPath(assetPath);
            importer.textureType = TextureImporterType.Advanced;
            importer.spriteImportMode = SpriteImportMode.None;
            importer.alphaIsTransparency = true;
            importer.wrapMode = TextureWrapMode.Clamp;
            importer.mipmapEnabled = false;
            importer.anisoLevel = -1;
            importer.filterMode = FilterMode.Bilinear;
        }

        if (assetPath.IndexOf("Assets/GameRes/Map3d/") >= 0)
        {
            TextureImporter importer = (TextureImporter)TextureImporter.GetAtPath(assetPath);
            importer.textureType = TextureImporterType.Advanced;
            importer.spriteImportMode = SpriteImportMode.None;
            importer.alphaIsTransparency = true;
            importer.wrapMode = TextureWrapMode.Repeat;
            importer.mipmapEnabled = false;
            importer.anisoLevel = -1;
            importer.filterMode = FilterMode.Bilinear;
        }

        if (assetPath.IndexOf("Assets/GameRes/Texture/Photo") >= 0)
        {
            TextureImporter importer = (TextureImporter)TextureImporter.GetAtPath(assetPath);
            importer.textureType = TextureImporterType.Advanced;
            importer.npotScale = TextureImporterNPOTScale.None;
            importer.spriteImportMode = SpriteImportMode.None;
            importer.alphaIsTransparency = true;
            importer.wrapMode = TextureWrapMode.Clamp;
            importer.mipmapEnabled = false;
            importer.isReadable = false;
            importer.anisoLevel = -1;
            importer.filterMode = FilterMode.Bilinear;
            importer.textureFormat = TextureImporterFormat.AutomaticTruecolor;
        }
        else if(assetPath.IndexOf("Texture/") >= 0)
        {
            TextureImporter importer = (TextureImporter)TextureImporter.GetAtPath(assetPath);
            importer.textureType = TextureImporterType.Advanced;
            importer.spriteImportMode = SpriteImportMode.None;
            importer.alphaIsTransparency = true;
            importer.wrapMode = TextureWrapMode.Clamp;
            importer.mipmapEnabled = false;
            importer.isReadable = false;
            importer.anisoLevel = -1;
            importer.filterMode = FilterMode.Bilinear;
            importer.textureFormat = TextureImporterFormat.AutomaticCompressed;
        }
        else if (assetPath.IndexOf("TextureSpecial/") >= 0)
        {
            TextureImporter importer = (TextureImporter)TextureImporter.GetAtPath(assetPath);
            importer.textureType = TextureImporterType.Advanced;
            importer.spriteImportMode = SpriteImportMode.None;
            //importer.alphaIsTransparency = true;
            importer.wrapMode = TextureWrapMode.Clamp;
            importer.mipmapEnabled = false;
            //importer.isReadable = false;
            importer.anisoLevel = -1;
            //importer.filterMode = FilterMode.Bilinear;
            //importer.textureFormat = TextureImporterFormat.AutomaticCompressed;
        }
        else if (assetPath.IndexOf("TextureUncompress/") >= 0)
        {
            TextureImporter importer = (TextureImporter)TextureImporter.GetAtPath(assetPath);
            importer.textureType = TextureImporterType.Advanced;
            importer.spriteImportMode = SpriteImportMode.None;
            importer.alphaIsTransparency = true;
            importer.wrapMode = TextureWrapMode.Clamp;
            importer.npotScale = TextureImporterNPOTScale.None;
            importer.mipmapEnabled = false;
            importer.isReadable = false;
            importer.anisoLevel = -1;
            importer.filterMode = FilterMode.Bilinear;
            importer.textureFormat = TextureImporterFormat.AutomaticTruecolor;
        }
    }
    
    public static void ConverMapTileToJPG(string filePath)
    {
        //string filePath = texConverInfo.filePath;
        byte[] pngBytes = File.ReadAllBytes(filePath);
        if (!JPGTexTool.CheckIsPNG(pngBytes))
            return;
        Texture2D pngTexture2D = new Texture2D(0, 0);
        pngTexture2D.LoadImage(pngBytes);

        string path = filePath.Replace(".png", ".bytes").Replace("tilemap_", "jpg_");
        string dir = Path.GetDirectoryName(path);
        if(!Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }

        byte[] jpgBytes = pngTexture2D.EncodeToJPG(75);
        File.WriteAllBytes(path, jpgBytes);
        //string json = JsonMapper.ToJson(texConverInfo);
        //string jsonFileName = Path.GetFileName(jpgFilePath + ".json");
        //File.WriteAllText(Path.Combine(GetExportPath(), jsonFileName), json);
    }

    private static IEnumerable<string> GetSelectAssets<T>(string typeName) where T : UnityEngine.Object
    {
        string[] guids = Selection.assetGUIDs;
        List<string> assetsGuids = new List<string>();
        string filter = string.Format("t:{0}", typeName);
        foreach (string guid in guids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            if (File.Exists(path))
            {
                T asset = AssetDatabase.LoadAssetAtPath<T>(path);
                if (asset != null)
                {
                    assetsGuids.Add(guid);
                }
            }
            else
            {
                string[] modelGuids = AssetDatabase.FindAssets(filter, new string[] { path });
                assetsGuids.AddRange(modelGuids);
            }
        }
        IEnumerable<string> modelGuidss = assetsGuids.Distinct();
        return modelGuidss;
    }

    private static IEnumerable<string> GetSelectTexture()
    {
        return GetSelectAssets<Texture>("Texture");
    }

    public static void StripSelectTextureAlpha()
    {
        var enumerable = GetSelectTexture().Select(item => AssetDatabase.GUIDToAssetPath(item));
        foreach (var path in enumerable)
        {
            Texture2D texture = new Texture2D(0, 0);
            texture.LoadImage(File.ReadAllBytes(path));
            if (texture.format == TextureFormat.RGB24)
                continue;

            Color32[] color32 = texture.GetPixels32();
            if (!color32.All(item => item.a == 255))
            {
                Texture2D newTexture2D = new Texture2D(texture.width, texture.height, TextureFormat.RGB24, false);
                newTexture2D.SetPixels32(color32);
                File.WriteAllBytes(Path.ChangeExtension(path, ".png"), newTexture2D.EncodeToPNG());
                UnityEngine.Object.DestroyImmediate(newTexture2D);
            }
            UnityEngine.Object.DestroyImmediate(texture);
        }
        AssetDatabase.Refresh();
    }
}

