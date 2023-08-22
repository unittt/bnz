using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ICSharpCode.SharpZipLib.Core;
using ICSharpCode.SharpZipLib.Zip;

public class LuaZip
{
    private static byte[] buffer = new byte[1024];
    private static int TAG_COUNT = 4;

    public static byte[] LoadFile(string name)
    {
        string path = string.Format("{0}/data/{1}", GameResPath.persistentDataPath, name);
		if (FileHelper.IsExist(path))
		{
			byte[] data = FileHelper.ReadAllBytes(path);
			if (data != null && data.Length > TAG_COUNT)
			{
				MemoryStream stream = new MemoryStream(data, TAG_COUNT, data.Length - TAG_COUNT);
				ZipFile luaZipFile = new ZipFile(stream);
				ZipEntry theEntry = luaZipFile.GetEntry(name);
				if (theEntry != null)
				{
					Stream zipStream = luaZipFile.GetInputStream(theEntry);
					MemoryStream stream2 = new MemoryStream();
					StreamUtils.Copy(zipStream, stream2, buffer);
					byte[] bytes = stream2.ToArray();
					return bytes;
				}
			}
		}

        return null;
    }


    public static void DumpAllFile()
    {
        string srcdir = GameResPath.persistentDataPath + "/data/";
        string dstdir = GameResPath.persistentDataPath + "/dataout/";
        if (Directory.Exists(dstdir))
        {
            Directory.Delete(dstdir, true);
        }
        Directory.CreateDirectory(dstdir);

        string[] files = Directory.GetFiles(srcdir);
        for(int i = 0; i < files.Length; i++)
        {
            string name = Path.GetFileNameWithoutExtension(files[i]);
            byte[] data = LoadFile(name);
            if(data == null)
            {
                GameDebug.LogError("导出导表文件错误 " + name);
            }
            else
            {
                string dstFile = dstdir + name;
                FileHelper.WriteAllBytes(dstFile, data);
            }
        }
    }

}

