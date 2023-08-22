using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using YamlDotNet.Serialization;

namespace AssetPipeline
{
    public static class BuildBundlePath
    {
        public static HashSet<string> CommonFilePath = new HashSet<string>
        {
        };

        public static string[] ShaderFolder =
        {
            "Assets/Standard Assets/NGUI/Resources"
        };

		public static string[] AnimatorTemplateFloder = 
		{
			 "Assets/GameRes/Model/Template"
		};

        public static string[] UIFolder =
        {
            "Assets/GameRes/UI"
        };

        public static string[] AtlasFolder =
        {
            "Assets/GameRes/Atlas"
        };
        public static string[] FontFolder =
        {
            "Assets/GameRes/Font"
        };

        public static string[] TextureFolder =
        {
            "Assets/GameRes/Texture",
			"Assets/GameRes/TextureSpecial",
			"Assets/GameRes/TextureUncompress",
        };
        
        public static string[] Map2dFolder =
        {
            "Assets/GameRes/Map2d",
        };

        public static string[] Map3dFolder =
        {
            "Assets/GameRes/Map3d",
        };

        //模型资源目录
        public static string[] ModelFolder =
        {
            "Assets/GameRes/Model",
        };
        //特效资源目录
        public static string[] EffectFolder =
        {
            "Assets/GameRes/Effect",
        };

        //音频资源目录
        public static string[] AudioFolder =
        {
           "Assets/GameRes/Audio"
        };

        //配置资源目录
        public static string[] ConfigFolder =
        {
            "Assets/GameRes/Config",
        };

		//live2d资源目录
		public static string[] Live2dFolder =
        {
            "Assets/GameRes/Live2d",
        };

		//material资源目录
		public static string[] MaterialFolder =
        {
            "Assets/GameRes/Material",
        };

        //spine资源目录
        public static string[] SpineFolder =
        {
             "Assets/GameRes/Spine",
        };

        public static bool IsCommonAsset(this string path)
        {
            return CommonFilePath.Contains(path);
        }

        public static bool IsUIRes(this string path)
        {
            return UIFolder.Any(path.StartsWith);
        }

        public static bool IsAtlasRes(this string path)
        {
            return AtlasFolder.Any(path.StartsWith);
        }

        public static bool IsFontRes(this string path)
        {
            return FontFolder.Any(path.StartsWith);
        }

        public static bool IsTextureRes(this string path)
        {
            return TextureFolder.Any(path.StartsWith);
        }


        public static bool IsMap2dRes(this string path)
        {
            return Map2dFolder.Any(path.StartsWith);
        }

        public static bool IsMap3dRes(this string path)
        {
            return Map3dFolder.Any(path.StartsWith);
        }

        public static bool IsLive2dRes(this string path)
        {
            return Live2dFolder.Any(path.StartsWith);
        }

        public static bool IsModelRes(this string path)
        {
            return ModelFolder.Any(path.StartsWith);
        }

        public static bool IsEffectRes(this string path)
        {
            return EffectFolder.Any(path.StartsWith);
        }

        public static bool IsMaterialRes(this string path)
        {
            return MaterialFolder.Any(path.StartsWith);
        }

        public static bool IsAudioRes(this string path)
        {
            return AudioFolder.Any(path.StartsWith);
        }

        public static bool IsConfigRes(this string path)
        {
            return ConfigFolder.Any(path.StartsWith);
        }

        public static bool IsPrefabFile(this string path)
        {
            return path.EndsWith(".prefab", StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsConfigFile(this string path)
        {
            return path.EndsWith(".bytes", StringComparison.OrdinalIgnoreCase)
                   || path.EndsWith(".json", StringComparison.OrdinalIgnoreCase)
                   || path.EndsWith(".txt", StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsAudioFile(this string path)
        {
            return path.EndsWith(".ogg", StringComparison.OrdinalIgnoreCase)
                   || path.EndsWith(".mp3", StringComparison.OrdinalIgnoreCase)
                   || path.EndsWith(".wav", StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsTextureFile(this string path)
        {
            return path.EndsWith(".png", StringComparison.OrdinalIgnoreCase)
                   || path.EndsWith(".jpg", StringComparison.OrdinalIgnoreCase)
                   || path.EndsWith(".tga", StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsShaderFile(this string path)
        {
            return path.EndsWith(".shader");
        }

		public static bool IsAnimFile(this string path)
		{
			return path.EndsWith(".anim");
		}

        public static bool UpdateBundleName(this AssetImporter importer, string bundleName)
        {
            bundleName = bundleName.ToLower();
            var oldBundleName = importer.assetBundleName;
            if (oldBundleName != bundleName)
            {
                importer.SetAssetBundleNameAndVariant(bundleName, null);
                return true;
            }
            return false;
        }

		public static string NextFloderName(this string path, string search)
		{
			int index = path.IndexOf(search);
			if (index > 0)
			{
				var res = path.Substring(index + search.Length);
				int index2 = res.IndexOf("/");
				if (index2 > 0)
				{
					return res.Substring(0, index2);
				}
			}
			return "";
		}

        /// <summary>
        /// 注意:同一资源分组下的资源名不能重复,然后根据资源分组生成BundleName
        /// 例如:MainUIView.prefab --> ui/mainuiview
        /// </summary>
        /// <param name="importer"></param>
        /// <param name="resGroup"></param>
        /// <returns></returns>
        public static string GetAssetBundleName(this AssetImporter importer, ResGroup resGroup)
        {
            string assetName = Path.GetFileNameWithoutExtension(importer.assetPath);
            string bundleName = assetName.ToLower();
            if (resGroup == ResGroup.None) 
                return bundleName;

            bundleName = resGroup.ToString().ToLower() + "/" + bundleName;
            return bundleName;
        }

        public static string GetAssetBundleName(this AssetImporter importer, ResGroup resGroup, string bundleName)
        {
            return resGroup.ToString().ToLower() + "/" + bundleName;
        }

        public static string ExtractResName(this string path, bool removeExtension = true)
        {
            return removeExtension ? Path.GetFileNameWithoutExtension(path) : Path.GetFileName(path);
        }
    }

    /// <summary>
    /// 导出小包配置策略,定义了如何生成MiniResConfig信息
    /// </summary>
    public class BuildBundleStrategy
    {
        public Dictionary<string, string> replaceResConfig; //策划自定义小包替代资源信息
        public Dictionary<string, string> minResConfig; //小包必需资源信息
        public Dictionary<string, bool> preloadConfig; //预加载资源配置

        public BuildBundleStrategy()
        {
            replaceResConfig = new Dictionary<string, string>();
            minResConfig = new Dictionary<string, string>();
            preloadConfig = new Dictionary<string, bool>();
        }

        public void AddMinResKey(string bundleName)
        {
            minResConfig[bundleName] = "";
        }

        public void RemoveMinResKey(string bundleName)
        {
            minResConfig.Remove(bundleName);
        }
    }

    /// <summary>
    /// Unity打包Bundle后生成的总资源清单YAML文件对应数据类
    /// </summary>
    public class RawAssetManifest
    {
        public int ManifestFileVersion { get; set; }
        public uint CRC { get; set; }

        [YamlMember(Alias = "AssetBundleManifest")]
        public RawBundleManifest Manifest { get; set; }

        public class RawBundleManifest
        {
            public Dictionary<string, RawBundleInfo> AssetBundleInfos { get; set; }

            public class RawBundleInfo
            {
                public string Name { get; set; }
                public Dictionary<string, string> Dependencies { get; set; }
            }
        }
    }

    /// <summary>
    /// Unity打包Bundle后每个Bundle对应YAML文件的数据类
    /// </summary>
    public class RawBundleManifest
    {
        public int ManifestFileVersion { get; set; }
        public uint CRC { get; set; }
        public Dictionary<string, HashInfo> Hashes { get; set; }
        public int HashAppended { get; set; }
        public List<object> ClassTypes { get; set; }
        public List<string> Assets { get; set; }
        public List<string> Dependencies { get; set; }

        public class HashInfo
        {
            public int serializedVersion { get; set; }
            public string Hash { get; set; }
        }
    }
}