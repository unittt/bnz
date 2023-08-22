using AssetPipeline;
using System.IO;
using UnityEngine;

public class GameVersion
{
    public static int frameworkVersion = 5; //框架版本，谨改

    public static int dllVersion = 6; //dll版本

    public static int ConfigResVersion    //res版本
    {
        get
        {
            if(AssetUpdate.Instance.CurResConfig != null)
            {
                return AssetUpdate.Instance.CurResConfig.Version;
            }
            return 0;
        }
    }

    public static int ConfigSvnVersion    //svn版本
    {
        get
        {
            if (AssetUpdate.Instance.CurResConfig != null)
            {
                return AssetUpdate.Instance.CurResConfig.svnVersion;
            }
            return 0;
        }
    }


    public static string AppVersion
    {
        get
        {
            return Application.version;
        }
    }

    public static string ResVersion
    {
        get
        {
            return string.Format("1.{0}.{1}.{2}", frameworkVersion, dllVersion, ConfigResVersion);
        }
    }

    public static string LocalAppVersion
    {
        get
        {
            string path = Path.Combine(Application.streamingAssetsPath, "resConfig.jz");
            byte[] bytes = FileHelper.ReadAllBytes(path);
            if (bytes == null)
            {
                Debug.LogError(string.Format("Load url:{0}\nerror", path));
            }
            ResConfig resConfig = ResConfig.ReadFile(bytes, true);

           return string.Format("1.{0}.{1}.{2}", frameworkVersion, dllVersion, resConfig.Version);
        }
    }

    public static int LocalSvnVersion
    {
        get
        {
            string path = Path.Combine(Application.streamingAssetsPath, "resConfig.jz");
            byte[] bytes = FileHelper.ReadAllBytes(path);
            if (bytes == null)
            {
                Debug.LogError(string.Format("Load url:{0}\nerror", path));
            }
            ResConfig resConfig = ResConfig.ReadFile(bytes, true);

            return resConfig.svnVersion;
        }
    }

    //public static string GetBanhao()
    //{
    //    return "";//新广出审[2016]336号\nISBN 978-7-89988-587-1\n文网游备字[2016]M-RPG 033号
    //}

}

