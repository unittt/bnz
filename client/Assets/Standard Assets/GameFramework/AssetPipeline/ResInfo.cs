using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace AssetPipeline
{
	public class ServerData
	{
		string name;
		string ver;
		string url;
	}

	public class ServerInfo
	{
		public string name;
		public List<ServerData> datalist;
	}

    public class StaticConfig
    {
        public string masterCdnUrl;
        public string slaveCdnUrl;
        public string srcCdnUrl;
		public Dictionary<string, List<ServerData>> centerServer;
		public Dictionary<string, string> channelVersion;
        public string demiSdkUrl;
        public string paySwitch;
    }

    public class VersionConfig
    {
        //游戏引擎框架版本号,用来标识当前框架版本是否需要整包替换更新
        //例如Android下jar包无法热更,还有IOS的dll无法更新时,根据这个版本号来提示用户需要整包更新
        public int frameworkVer;
        //标记当前游戏服最新dll版本号,只有PC和Android会用到
        public int dllVersion;
        //标记当前游戏服最新资源版本号
        public int resVersion;
        //是否强制更新
        public bool forceUpdate = true;
        //版本更新帮助页面
        public string helpUrl = "";

        public int scriptVersion
        {
            get
            {
                return resVersion;
            }
        }

		public string ResVersion
		{
            get
            {
                return string.Format("{0}.{1}.{2}", frameworkVer, dllVersion, resVersion);
            }
        }

        public static string GetTestFileName()
        {
            return "versionConfigTest.json";
        }

        public static string GetFileName()
        {
            return "versionConfig.json";
        }

        public override string ToString()
        {
            return "frameworkVer: " + frameworkVer +
                "\ndllVersion: " + dllVersion +
                "\nresVersion: " + resVersion +
                "\nforceUpdate: " + forceUpdate;
        }
    }


    public class DllInfo
    {
        public string dllName;
        public string MD5;
        public long size;

        public string ToFileName()
        {
            return dllName + "_" + MD5 + ".dll";
        }
    }

    public class DllVersion
    {
        public long Version;
        public Dictionary<string, DllInfo> Manifest;

        public DllVersion()
        {
            Manifest = new Dictionary<string, DllInfo>();
        }

        public string ToFileName()
        {
            return "dllVersion_" + Version + ".json";
        }

        public string ToFileName(int ver)
        {
            return "dllVersion_" + ver + ".json";
        }


        public static string GetFileName(long version)
        {
            return "dllVersion_" + version + ".json";
        }
    }

    public class ScriptInfo
    {
        public string name;
        public long size;
        public string md5;
    }


    public class ScriptVersion
    {
        public Dictionary<string, ScriptInfo> Patchs;
        public Dictionary<string, ScriptInfo> Scripts; 
       
        public static string GetFileName()
        {
            return "scriptVersion.json";
        }

        public List<int> GetPatchList(int curVer, int newVer)
        {
            string prefix = "script_";
            List<int> versionList = new List<int>();
            foreach(string key in Scripts.Keys)
            {
                if(key.StartsWith(prefix))
                {
                    int ver = -1;
                    int.TryParse(key.Substring(prefix.Length, key.Length - prefix.Length), out ver);
                    if(ver >= curVer && ver <= newVer)
                    {
                        versionList.Add(ver);
                    }
                }
            }
            versionList.Sort();
            if(versionList.Count >= 2 &&  versionList[0] == curVer && versionList[versionList.Count - 1] == newVer)
            {
                return versionList;
            }
            else
            {
                return null;
            }
        }
    }

    public enum CompressType
    {
        Raw = 0,
        UnityLZMA = 1,
        UnityLZ4 = 2,
        CustomZip = 10,
        CustomLZMA = 11,
        CustomLZ4 = 12,
        CustomTex = 13,
    }

    /// <summary>
    /// 对于资源分组标识,根据分组标识导出到不同目录
    /// </summary>
    public enum ResGroup
    {
        None = 0,
        Common = 1,
        Map2d = 2,
        Map3d = 3,
        Audio = 4,
        Config = 5,
        Script = 6,
        Scene = 7,
		Live2d = 8,
        UI = 10,
        Atlas = 11,
        Font = 12,
        Texture = 14,
		Material = 15, 

        Model = 20,
        Effect = 30,
        TileMap = 40,
    }

    /// <summary>
    /// 记录了游戏资源的配置信息，用于资源打包和加载资源处理资源的依赖关系
    /// </summary>
    public class ResInfo
    {
        //项目内BundleName
        public string bundleName;
        //当前资源包CRC值
        //注:相同的资源使用不同的压缩方式打包时,计算出的CRC是一样的
        public uint CRC;
        //当前资源包Hash128值
        //注:如果现在打包Android资源,但是贴图的PC平台导入配置修改了,会导致Hash变化,但是打包出来的CRC是一样的
        //简单来说就是Hash变了,CRC可能不变,但Hash不变,CRC也不会变
        public string Hash;
        //标记Bundle文件放在CDN上的压缩类型,不是指打包Bundle时的压缩类型
        //如果是使用LZ4或不压缩方式打包资源,需要再用Zip压缩一遍,上传给CDN,这样可以有效减少用户的下载数据总量
        public CompressType remoteZipType;
        //记录资源包文件MD5值(压缩后)
        public string MD5;
        //记录资源包文件文件大小(压缩后)
        public long size;
        //标记该资源为包内资源,小包或者更新过的资源都将置为false
        public bool isPackageRes;
        //标记该资源包是否需要预加载
        public bool preload;
        //当前资源包依赖资源包key列表
        public List<string> Dependencies;

        public ResInfo()
        {
            remoteZipType = CompressType.UnityLZ4;
            Dependencies = new List<string>();
        }

        public string loadPath
        {
            get
            {
                if (isPackageRes)
                {
                    return GetABPath(GameResPath.packageBundleRoot);
                }
                else
                {
                    return GetABPath(GameResPath.bundleRoot);
                }
            }
        }

        internal const ulong ASSETBUNDLE_OFFSET = 1;

        public ulong bundleOffset
        {
            get
            {
#if UNITY_IPHONE    // || UNITY_EDITOR
                if (isPackageRes)
                {
                    return ASSETBUNDLE_OFFSET;
                }
#endif
                return  0;
            }

        }

        public string GetABPath(string dir)
        {
#if BUNDLE_APPEND_HASH
            return string.Format("{0}/{1}_{2}", dir, bundleName, Hash);
#else
            return string.Format("{0}/{1}_{2}", dir, bundleName, CRC);
#endif
        }

        public string GetRemotePath(string dir)
        {
            if (remoteZipType == CompressType.CustomZip)
                return GetABPath(dir) + ".zip";
            return GetABPath(dir);
        }

        public string GetManifestPath(string dir)
        {
            if (remoteZipType == CompressType.CustomTex)
                return dir + "/" + Path.ChangeExtension(bundleName, ".json");
            else
                return dir + "/" + bundleName + ".manifest";
        }

        public string GetExportPath(string dir)
        {
#if BUNDLE_APPEND_HASH
            return dir + "/" + bundleName + "_" + Hash;
#else
            return dir + "/" + bundleName;
#endif
        }
    }

    public class ResConfig
    {
        //记录本次打包版本号,版本号根据上一个版本进行递增
        public int Version;

        //SVN版本
        public int svnVersion;

        //记录本次打包资源的资源清单CRC值
        public uint lz4CRC;
        public uint lzmaCRC;
        public uint tileTexCRC;
        //记录该版本资源打包时间
        public long BuildTime;
        //资源压缩类型
        public CompressType compressType;
        //记录了AssetBundle文件的总大小（单位：byte）
        public long TotalFileSize;
        //标记当前资源是否是小包,从小包升级为整包后该标记置为false
        public bool isMiniRes;
        //以资源名_ResType为key
        public Dictionary<string, ResInfo> Manifest;


        public void SaveFile(string path, bool compress)
        {
            byte[] fileBytes = SerializeToMemoryStream();
            if (compress)
            {
                byte[] bytes = ZipLibUtils.Compress(fileBytes);
                FileHelper.WriteAllBytes(path, bytes);
            }
            else
            {
                FileHelper.WriteAllBytes(path, fileBytes);
            }
        }

        public void SaveJson(string path)
        {
            FileHelper.SaveJsonObj(this, path, false, true);
        }

        internal byte[] SerializeToMemoryStream()
        {
            MemoryStream memoryStream = new MemoryStream();
            BinaryWriter binaryWriter = new BinaryWriter(memoryStream, Encoding.UTF8);
            string ver = "ver1";
            binaryWriter.Write(ver);
            binaryWriter.Write(Version);
            binaryWriter.Write(svnVersion);
            binaryWriter.Write(lz4CRC);
            binaryWriter.Write(lzmaCRC);
            binaryWriter.Write(BuildTime);
            binaryWriter.Write((int)compressType);
            binaryWriter.Write(TotalFileSize);
            binaryWriter.Write(isMiniRes);
            binaryWriter.Write(Manifest.Count);

            foreach (KeyValuePair<string, ResInfo> keyValuePair in Manifest)
            {
                ResInfo info = keyValuePair.Value;
                binaryWriter.Write(info.bundleName);
                binaryWriter.Write(info.CRC);
                binaryWriter.Write(info.Hash ?? string.Empty);
                binaryWriter.Write((int)info.remoteZipType);
                binaryWriter.Write(info.MD5);
                binaryWriter.Write(info.size);
                binaryWriter.Write(info.isPackageRes);
                binaryWriter.Write(info.preload);
                binaryWriter.Write(info.Dependencies.Count);
                for (int j = 0; j < info.Dependencies.Count; j++)
                {
                    binaryWriter.Write(info.Dependencies[j]);
                }
            }

            return memoryStream.ToArray();
        }

        public static ResConfig ReadFile(byte[] bytes, bool isComporess)
        {
            if (isComporess)
            {
                bytes = ZipLibUtils.Uncompress(bytes);
            }
            MemoryStream memoryStream = new MemoryStream(bytes, false);
            memoryStream.Position = 0;
            BinaryReader binaryReader = new BinaryReader(memoryStream, Encoding.UTF8);
            
            ResConfig config = new ResConfig();
            string ver = binaryReader.ReadString();
            config.Version = binaryReader.ReadInt32();
            config.svnVersion = binaryReader.ReadInt32();
            config.lz4CRC = binaryReader.ReadUInt32();
            config.lzmaCRC = binaryReader.ReadUInt32();
            config.BuildTime = binaryReader.ReadInt64();
            config.compressType = (CompressType) binaryReader.ReadInt32();
            config.TotalFileSize = binaryReader.ReadInt64();
            config.isMiniRes = binaryReader.ReadBoolean();
            int resCount = binaryReader.ReadInt32();
            config.Manifest = new Dictionary<string, ResInfo>(resCount);
            
            for (int i = 0; i < resCount; i++)
            {
                ResInfo info = new ResInfo();
                info.bundleName = binaryReader.ReadString();
                info.CRC = binaryReader.ReadUInt32();
                info.Hash = binaryReader.ReadString();
                info.remoteZipType = (CompressType)binaryReader.ReadInt32();
                info.MD5 = binaryReader.ReadString();
                info.size = binaryReader.ReadInt64();
                info.isPackageRes = binaryReader.ReadBoolean();
                info.preload = binaryReader.ReadBoolean();
                int dependCount = binaryReader.ReadInt32();
                info.Dependencies = new List<string>(dependCount);
                for (int j = 0; j < dependCount; j++)
                {
                    info.Dependencies.Add(binaryReader.ReadString());
                }
                config.Manifest.Add(info.bundleName, info);
            }
            return config;
        }

        public ResConfig()
        {
            compressType = CompressType.UnityLZ4;
            Manifest = new Dictionary<string, ResInfo>();
        }

        public ResInfo GetResInfo(string key)
        {
            if (Manifest.ContainsKey(key))
                return Manifest[key];
            return null;
        }

        public string ToFileName()
        {
            return "resConfig_" + Version + ".json";
        }

        public string ToRemoteName()
        {
            return "resConfig_" + Version + ".jz";
        }


        public static string GetRemoteFile(long version)
        {
            return "resConfig_" + version + ".jz";
        }

        /// <summary>
        /// 从BundleName获取对应的ResGroup
        /// </summary>
        /// <param name="bundleName"></param>
        /// <returns></returns>
        public static ResGroup GetResGroupFromBundleName(string bundleName)
        {
            if (!bundleName.Contains("/")) return ResGroup.None;

            var resGroupEnums = Enum.GetValues(typeof(ResGroup));
            return resGroupEnums.Cast<ResGroup>().FirstOrDefault(resGroup => bundleName.StartsWith(resGroup.ToString().ToLower()));
        }


        //检查AB包名字
        public void CheckAssetBundleName()
        {
            foreach (var item in Manifest)
            {
                string name = item.Key;
                if (name.Contains(" "))
                {
                    Debug.LogError("检查AssetBundleName包含空格 " + name);
                }
            }
        }

        //检查依赖自引用
        public void CheckSelfDependencies()
        {
            foreach(var item in Manifest)
            {
                string name = item.Key;
                ResInfo resInfo = item.Value;
                HashSet<string> set = new HashSet<string>();
                for (int i = 0; i < resInfo.Dependencies.Count; i++)
                {
                    string bundleName = resInfo.Dependencies[i];
                    List<string> allDependencies = new List<string>();
                    GetDependenciesRecursive(bundleName, ref set);
                }

                foreach(string dependName in set)
                {
                    if(dependName == name)
                    {
                        Debug.LogError("检查Assetbundle引用错误 " + dependName);
                    }
                }
            }
        }

        private void GetDependenciesRecursive(string bundleName, ref HashSet<string> dependencies)
        {
            var resInfo = GetResInfo(bundleName);
            if (resInfo != null)
            {
                foreach (string dependency in resInfo.Dependencies)
                {
                    if(!dependencies.Contains(dependency))
                    {
                        dependencies.Add(dependency);
                        GetDependenciesRecursive(dependency, ref dependencies);
                    }
                }
            }
        }

        public List<string> GetAllDependencies(string bundleName)
        {
            var deps = new List<string>();
            GetDependenciesRecursive(bundleName, ref deps);
            return deps;
        }
        private void GetDependenciesRecursive(string bundleName, ref List<string> dependencies)
        {
            var resInfo = GetResInfo(bundleName);
            if (resInfo != null)
            {
                foreach (string dependency in resInfo.Dependencies)
                {
                    GetDependenciesRecursive(dependency, ref dependencies);
                    dependencies.Add(dependency);
                }
            }
        }

        public List<string> GetDirectDependencies(string bundleName)
        {
            var resInfo = GetResInfo(bundleName);
            if (resInfo != null)
            {
                return new List<string>(resInfo.Dependencies);
            }
            return null;
        }
    }

    /// <summary>
    /// 游戏资源更新清单，每次资源更新时，先下载patchInfo来确认哪些资源需要更新，更新完资源之后，与本地ResConfig合并生成最新的版本资源信息
    /// </summary>
    public class ResPatchInfo
    {
        //当前版本号
        public int CurVer;
        public int CurSvnVer;
        public uint CurLz4CRC;
        public uint CurLzmaCRC;
        public uint CurTexCRC;
        //升级后的最终版本号
        public int EndVer;
        public int EndSvnVer;
        public uint EndLz4CRC;
        public uint EndLzmaCRC;
        public uint EndTexCRC;
        //记录了AssetBundle文件的总大小（单位：byte）
        public long TotalFileSize;
        //需要更新的文件列表
        public List<ResInfo> updateList;
        //需要清除的文件列表
        public List<string> removeList;

        public ResPatchInfo()
        {
            updateList = new List<ResInfo>();
            removeList = new List<string>();
        }

        public string ToFileName()
        {
            return "patch_" + CurVer + "_" + EndVer + ".json";
        }
    }

    /// <summary>
    /// 小包资源配置,标记了ResConfig中哪些资源为包内资源,哪些资源为游戏时下载资源
    /// </summary>
    public class MiniResConfig
    {
        //存放小包缺失资源的Key,以及其替代资源信息
        public Dictionary<string, string> replaceResConfig = new Dictionary<string, string>();
    }
}
