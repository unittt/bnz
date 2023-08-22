using System;
using System.IO;
using System.Text;
using System.Runtime.InteropServices;
using UnityEngine;

public class WinConsole
{
    private static Stream consoleWriter;

#if !UNITY_EDITOR && UNITY_STANDALONE_WIN
    [DllImport("kernel32.dll")]
    public static extern bool FreeConsole();

    [DllImport("kernel32.dll")]
    public static extern bool AllocConsole();
#endif

    public static void Init()
    {
#if !UNITY_EDITOR && UNITY_STANDALONE_WIN
        AllocConsole();
        consoleWriter = Console.OpenStandardOutput();
#endif
    }

    public static void Release()
    {
#if !UNITY_EDITOR && UNITY_STANDALONE_WIN
        if(consoleWriter != null)
        {
            FreeConsole();
        }
#endif
    }

    public static void Log(string msg)
    {
        if(consoleWriter != null)
        {
            msg += "\n";
            Console.ForegroundColor = ConsoleColor.Gray;
            byte[] data = Encoding.Default.GetBytes(msg);
            consoleWriter.Write(data, 0, data.Length);
            consoleWriter.Flush();
        }
    }

    public static void LogError(string msg)
    {
        if(consoleWriter != null)
        {
            msg += "\n";
            Console.ForegroundColor = ConsoleColor.DarkRed;
            byte[] data = Encoding.Default.GetBytes(msg);
            consoleWriter.Write(data, 0, data.Length);
            consoleWriter.Flush();
        }
    }

}