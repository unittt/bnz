using System;
using System.Collections;
using System.IO;
using System.Text;

public class FileHandler
{
    private static byte[] tempBuffer = new byte[1024];

    private StreamReader textReader;
    private StreamWriter textWriter;
    private FileStream byteReader;
    private FileStream byteWriter;

    public static FileHandler CreateText(string path)
    {
        if (string.IsNullOrEmpty(path))
        {
            return null;
        }
        string dir = Path.GetDirectoryName(path);
        if (!Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }
        if (File.Exists(path))
        {
            File.Delete(path);
        }
        FileHandler handler = new FileHandler();
        handler.textWriter = File.CreateText(path);
        return handler;
    }

    public static FileHandler CreateByte(string path)
    {
        if (string.IsNullOrEmpty(path))
        {
            return null;
        }
        string dir = Path.GetDirectoryName(path);
        if (!Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }
        FileHandler handler = new FileHandler();
        handler.byteWriter = File.Open(path, FileMode.Create, FileAccess.Write);
        return handler;
    }

    public static FileHandler OpenText(string path)
    {
        if (string.IsNullOrEmpty(path) || !File.Exists(path))
        {
            return null;
        }
        FileHandler handler = new FileHandler();
        handler.textReader = File.OpenText(path);
        return handler;
    }

    public static FileHandler AppendText(string path)
    {
        if (string.IsNullOrEmpty(path))
        {
            return null;
        }
        if (!File.Exists(path))
        {
            return null;
        }
        FileHandler handler = new FileHandler();
        handler.textWriter = File.AppendText(path);
        return handler;
    }

    public static FileHandler OpenByte(string path)
    {
        if (string.IsNullOrEmpty(path))
        {
            return null;
        }
        string dir = Path.GetDirectoryName(path);
        if (!Directory.Exists(dir) || !File.Exists(path))
        {
            return null;
        }
        FileHandler handler = new FileHandler();
        handler.byteReader = File.Open(path, FileMode.Open, FileAccess.Read);
        return handler;
    }

    public string ReadText()
    {
        if (textReader == null)
        {
            return null;
        }
        return textReader.ReadToEnd();
    }

    public byte[] ReadByte()
    {
        if (byteReader == null)
        {
            return null;
        }
        
        byte[] data = new byte[byteReader.Length];
        int count = 0;
        int pos = 0;
        while ((count = byteReader.Read(tempBuffer, 0, 1024)) != 0)
        {
            Array.Copy(tempBuffer, 0, data, pos, count);
            pos += count;
        }
        return data;
    }

    public string ReadCompressText()
    {
        byte[] data = ReadByte();
        if(data != null)
        {
            byte[] uncompressData = ZipLibUtils.Uncompress(data);
            return Encoding.UTF8.GetString(uncompressData);
        }
        return null;
    }

    public void WriteText(string str)
    {
        if (string.IsNullOrEmpty(str) || textWriter == null)
        {
            return;
        }
        textWriter.Write(str);
        textWriter.Flush();
    }

    public void WriteByte(byte[] data)
    {
        if (data == null || byteWriter == null)
        {
            return;
        }
        byteWriter.Write(data, 0, data.Length);
        byteWriter.Flush();
    }

    public void WriteCompressText(string str)
    {
        if (string.IsNullOrEmpty(str) || textWriter == null)
        {
            return;
        }

        byte[] data = Encoding.UTF8.GetBytes(str);
        byte[] compressData = ZipLibUtils.Compress(data);
        byteWriter.Write(compressData, 0, compressData.Length);
        byteWriter.Flush();
    }

    public void Close()
    {
        if (textReader != null)
        {
            textReader.Close();
            textReader = null;
        }
        if (textWriter != null)
        {
            textWriter.Close();
            textWriter = null;
        }
        if (byteReader != null)
        {
            byteReader.Close();
            byteReader = null;
        }
        if (byteWriter != null)
        {
            byteWriter.Close();
            byteWriter = null;
        }
    }
}
