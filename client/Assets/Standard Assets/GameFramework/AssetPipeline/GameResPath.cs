using System;
using System.IO;
using UnityEngine;


/// <summary>
/// GameResPath主要负责所有资源相关的路径的定义和处理
/// </summary>
public static class GameResPath
{
    // 常用文件
    public const string STATICCONFIG_FILE = "staticconfig.txt";
    public const string SERVER_FILE = "server.txt";
    public const string NOTICE_FILE = "notice.txt";
    public const string VERSIONCONFIG_FILE = "versionConfig.json";
    public const string DLLVERSION_FILE = "dllVersion.json";
    public const string RESCONFIG_FILE = "resConfig.jz";
    public const string MINIRESCONFIG_FILE = "miniResConfig.jz";
    public const string SCRIPT_FILE = "script";
    public const string DATA_SCRIPT_FILE = "data";

    // 常用本地文件夹
    public const string MANAGER_BACKUP_ROOT = "BackupDll";
    public const string MANAGER_ROOT = "Managed";
    public const string BUNDLE_ROOT = "gameres";
    public const string REPLACETEXTURE_ROOT = "Textures";

    // 远程文件夹
    public const string DLL_VERSION_ROOT = "dll";
    public const string DLL_FILE_ROOT = "dll";
    public const string RESCONFIG_ROOT = "resconfig";
    public const string SCRIPT_ROOT = "script";
    public const string REMOTE_BUNDLE_ROOT = "res";
    public const string SCRIPT_VERSION_ROOT = "scriptversion";

    // 本地打包用文件夹
    public const string EXPORT_FOLDER = "_GameBundles";

    // 特殊的AB
    public const string AllShaderBundleName = "common/allshader";


    public static string cachePersistentDataPath = null;
    public static string cachePackageResUrlRoot = null;
    public static string cachePackageBundleUrlRoot = null;
    public static string cachePackageBundleRoot = null;
    public static string cacheBundleRoot = null;

    /// <summary>
    /// 编辑器下返回工程根目录
    /// </summary>
    /// <returns></returns>
    public static string appRoot
    {
        get
        {
            if (Application.isEditor)
            {
                return Path.GetDirectoryName(Application.dataPath);
            }

            return Application.dataPath;
        }
    }

    #region 包外资源路径
    /// <summary>
    /// PC平台特殊处理,为了删除游戏时可以连带更新资源一起删除
    /// </summary>
    public static string persistentDataPath
    {
        get
        {
            if (cachePersistentDataPath == null)
            {
                if (Application.platform == RuntimePlatform.WindowsPlayer || Application.platform == RuntimePlatform.WindowsEditor)
                {
                    cachePersistentDataPath = Application.dataPath + "/persistentAssets";
                }
                else
                {
                    cachePersistentDataPath = Application.persistentDataPath;
                }
            }
            return cachePersistentDataPath;
        }
    }


    private static string _androidDllRoot;

    /// <summary>
    /// 更新后的dll存放目录
    /// </summary>
    public static string dllRoot
    {
        get
        {
            if (Application.platform == RuntimePlatform.Android)
            {
                if (_androidDllRoot == null)
                {
                    // libmono.so 写死了，就不重新生成了
                    _androidDllRoot = PlatformAPI.GetAndroidInternalPersistencePath() + "/" + "dlls";
                }

                return _androidDllRoot;
            }

            return persistentDataPath + "/" + MANAGER_ROOT;
        }
    }


    public static string dllBackupRoot
    {
        get
        {
            return persistentDataPath + "/" + MANAGER_BACKUP_ROOT;
        }
    }

    /// <summary>
    /// 包外Bundle资源根目录
    /// </summary>
    public static string bundleRoot
    {
        get 
        { 
            if(cacheBundleRoot == null)
            {
                cacheBundleRoot = persistentDataPath + "/" + BUNDLE_ROOT;
            }
            return cacheBundleRoot;
        }
    }
    #endregion

    #region 包内资源路径
    /// <summary>
    /// 包内Bundle资源根目录
    /// </summary>
    public static string packageBundleRoot
    {
        get 
        {
            if (cachePackageBundleRoot == null)
            {
                cachePackageBundleRoot = Application.streamingAssetsPath + "/" + BUNDLE_ROOT; 
            }
            return cachePackageBundleRoot;
        }
    }
    /// <summary>
    /// 包内Bundle资源 gameres 目录URL路径,使用WWW加载时需要用到
    /// </summary>
    public static string packageBundleUrlRoot
    {
        get 
        {
            if (cachePackageBundleUrlRoot == null)
            {
                cachePackageBundleUrlRoot = string.Concat(packageResUrlRoot, '/', BUNDLE_ROOT);
            }
            return cachePackageBundleUrlRoot;
        }
    }
    /// <summary>
    /// 包内Bundle资源根目录URL路径,使用WWW加载时需要用到
    /// </summary>
    public static string packageResUrlRoot
    {
        get
        {
            if (cachePackageResUrlRoot == null)
            {
                if (Application.platform == RuntimePlatform.Android)
                {
                    cachePackageResUrlRoot = Application.streamingAssetsPath;
                }
                else
                {
                    cachePackageResUrlRoot = GetLocalFileUrl(Application.streamingAssetsPath);
                }
            }
            return cachePackageResUrlRoot;
        }
    }
    #endregion

    /// <summary>
    /// 根据不同平台生成对应本地文件的Url,Window下需要使用file:///
    /// </summary>
    /// <param name="filePath"></param>
    /// <returns></returns>
    public static string GetLocalFileUrl(string filePath)
    {
        if (Application.platform == RuntimePlatform.WindowsEditor ||
            Application.platform == RuntimePlatform.WindowsPlayer)
        {
            return "file:///" + filePath;

        }

        return "file://" + filePath;
    }

}

