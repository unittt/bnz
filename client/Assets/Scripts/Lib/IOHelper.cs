using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using LuaInterface;
using UnityEngine;

public class IOHelper
{
    public static string[] GetFiles(string path)
    {
        if (string.IsNullOrEmpty(path))
        {
            return null;
        }
        path = path.Replace("\\", "/");
        try
        {
            return Directory.GetFiles(path);
        }
        catch (Exception e)
        {
            Debug.LogError(e.Message);
            return null;
        }
    }

    public static bool Exists(string path)
    {
        if (string.IsNullOrEmpty(path))
        {
            return false;
        }
        return File.Exists(path) || Directory.Exists(path);
    }

    public static void Delete(string path)
    {
        try
        {
            if (File.Exists(path))
            {
                File.Delete(path);
            }
            else if (Directory.Exists(path))
            {
                Directory.Delete(path, true);
            }
        }
        catch (Exception e)
        {
            Debug.LogError(string.Format("Delete Error {0}", path));
            Debug.LogError(e.Message);
        }
    }

    public static void Copy(string srcPath, string dstPath)
    {
        if (!File.Exists(srcPath))
        {
            return;
        }
        try
        {
            string folder = Path.GetDirectoryName(dstPath);
            if (!Directory.Exists(folder))
            {
                Directory.CreateDirectory(folder);
            }
            File.Copy(srcPath, dstPath, true);
        }
        catch (Exception e)
        {
            Debug.LogError(string.Format("Copy Error {0} {1}", srcPath, dstPath));
            Debug.LogError(e.Message);
        }
    }

    public static void Move(string srcPath, string dstPath)
    {
        string folder = Path.GetDirectoryName(dstPath);
        try
        {
            if (!Directory.Exists(folder))
            {
                Directory.CreateDirectory(folder);
            }
            if (File.Exists(srcPath))
            {
				if (File.Exists(dstPath))
				{
					File.Delete(dstPath);
				}
				else
				{
					File.Move(srcPath, dstPath);
				}
            }
            else if (Directory.Exists(srcPath))
            {
                Directory.Move(srcPath, dstPath);
            }
        }
        catch (Exception e)
        {
            Debug.LogError(string.Format("Move Error {0} {1}", srcPath, dstPath));
            Debug.LogError(e.Message);
        }
    }


    public static void CopyFile(string srcPath, string dstPath)
    {
        if (string.IsNullOrEmpty(srcPath)
            || string.IsNullOrEmpty(dstPath))
        {
            return;
        }
        if (!File.Exists(srcPath))
        {
            return;
        }
        try
        {
            using (FileStream writer = File.Open(dstPath, FileMode.Create, FileAccess.Write))
            using (FileStream reader = File.Open(srcPath, FileMode.Open, FileAccess.Read))
            {
                byte[] buffer = new byte[1024];
                int count = 0;
                while ((count = reader.Read(buffer, 0, 1024)) != 0)
                {
                    writer.Write(buffer, 0, count);
                }
            }
        }
        catch (Exception e)
        {
            Debug.LogError(string.Format("CopyFile Error {0} {1}", srcPath, dstPath));
            Debug.LogError(e.Message);
        }
    }

    public static void CreateDirectory(string path)
    {
        if (string.IsNullOrEmpty(path) || Directory.Exists(path))
        {
            return;
        }
        try
        {
            Directory.CreateDirectory(path);
        }
        catch (Exception e)
        {
            Debug.LogError(string.Format("CreateDirectory Error {0}", path));
            Debug.LogError(e.Message);
        }
    }

    public static void ClearDirectory(string path)
    {
        if (string.IsNullOrEmpty(path) || !Directory.Exists(path))
        {
            return;
        }
        try
        {
            string[] files = Directory.GetFiles(path);
            for (int i = 0; i < files.Length; ++i)
            {
                File.Delete(files[i]);
            }
            string[] dirs = Directory.GetDirectories(path);
            for (int i = 0; i < dirs.Length; ++i)
            {
                Directory.Delete(dirs[i], true);
            }
        }
        catch (Exception e)
        {
            Debug.LogError(string.Format("ClearDirectory Fail {0}", path));
            Debug.LogError(e.Message);
        }
    }

    public static void CopyDirectory(string srcPath, string dstPath)
    {
        if (string.IsNullOrEmpty(srcPath) || string.IsNullOrEmpty(dstPath)|| !Directory.Exists(srcPath))
        {
            return;
        }
        srcPath = srcPath.Replace("\\", "/");
        dstPath = dstPath.Replace("\\", "/");
        if (srcPath[srcPath.Length - 1] != '/')
        {
            srcPath = srcPath + "/";
        }
        if (dstPath[dstPath.Length - 1] != '/')
        {
            dstPath = dstPath + "/";
        }
        try
        {
            string[] files = Directory.GetFiles(srcPath, "*", SearchOption.AllDirectories);
            for (int i = 0; i < files.Length; ++i)
            {
                files[i] = files[i].Replace("\\", "/");
                string filePath = files[i].Replace(srcPath, dstPath);
                string dir = Path.GetDirectoryName(filePath);
                if (!Directory.Exists(dir))
                {
                    Directory.CreateDirectory(dir);
                }
                CopyFile(files[i], filePath);
            }
        }
        catch (Exception e)
        {
            Debug.LogError(string.Format("CopyDirectory Error {0} {1}", srcPath, dstPath));
            Debug.LogError(e.Message);
        }
    }

}
