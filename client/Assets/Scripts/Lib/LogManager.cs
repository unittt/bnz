using System;
using System.IO;
using System.Collections;
using System.Diagnostics;
using UnityEngine;

public class LogManager
{
    private readonly int ERROR_FILE_MAX_SIZE = 1024 * 1024;
    private string LOG_PATH;
    
    private StreamWriter logWriter;
    private StreamWriter errorWriter;
    private  bool winConsole = false;

    public static LogManager Instance
    {
        get;
        private set;
    }

    public static void CreateInsatnce(bool console)
    {
        if (Instance != null)
        {
            return;
        }
        Instance = new LogManager(console);
    }

    public LogManager(bool console)
    {
        LOG_PATH = Path.Combine(GameResPath.persistentDataPath, "Log");
        
        if(!Directory.Exists(LOG_PATH))
        {
            Directory.CreateDirectory(LOG_PATH);
        }

#if UNITY_STANDALONE_WIN
        winConsole = console;
        if (winConsole)
        {
            WinConsole.Init();
        }
#endif

        LuaMain.Instance.StartCoroutine(ChangeLogFile(60*60));
        Application.logMessageReceived += OnMessageReceived;
    }

    public void Release()
    {
        Application.logMessageReceived -= OnMessageReceived;

        if (logWriter != null)
        {
            logWriter.Close();
            logWriter = null;
        }
        if (errorWriter != null)
        {
            errorWriter.Close();
            errorWriter = null;
        }

        if (winConsole)
        {
            WinConsole.Release();
        }
    }

    private void OnMessageReceived(string msg, string stackTrace, LogType logType)
    {
        if (string.IsNullOrEmpty(msg))
            return;

        if (logType == LogType.Error || logType == LogType.Exception)
        {
            if (winConsole)
            {
                WinConsole.LogError(msg);
            }
            ReceiveLog(msg);
            ReceiveError(msg, stackTrace);
        }
        else
        {
            if (winConsole)
            {
                WinConsole.Log(msg);
            }
            ReceiveLog(msg);
        }
    }

    private void ReceiveLog(string msg)
    {
        if (logWriter == null)
        {
            logWriter = CreateLogWriter();
        }

        try
        {
            logWriter.WriteLine(msg);
            logWriter.Flush();
        }
        catch (System.Exception)
        {
            if (logWriter != null)
            {
                logWriter.Close();
            }
        }
    }

    private void ReceiveError(string msg, string stackTrace)
    {
        if (errorWriter == null)
        {
            errorWriter = CreateErrorWriter();
        }

        try
        {
            errorWriter.WriteLine(msg);

            if (!string.IsNullOrEmpty(stackTrace))
            {
                errorWriter.WriteLine(stackTrace);
                if (winConsole)
                {
                    WinConsole.LogError(stackTrace);
                }
            }
            errorWriter.WriteLine("");
            errorWriter.Flush();
        }
        catch (System.Exception)
        {
            if (errorWriter != null)
            {
                errorWriter.Close();
            }
        }
    }


    private StreamWriter CreateLogWriter()
    {
        StreamWriter streamWriter = null;
        string logPath = string.Format("{0}/{1}.log", LOG_PATH, DateTime.Now.ToString("yyyyMMdd_HHmm"));
        int index = 1;
        string path = logPath;
        while(streamWriter == null)
        {
            try
            {
                if(File.Exists(path))
                {
                    streamWriter = File.AppendText(path);
                }
                else
                {
                    streamWriter = File.CreateText(path);
                }
            }
            catch(Exception)
            {
                path = string.Format("{0}_{1}", logPath, index);
                index++;
            }
        }
        return streamWriter;
    }

    private StreamWriter CreateErrorWriter()
    {
        StreamWriter streamWriter = null;
        string path = string.Format("{0}/{1}.err", LOG_PATH, DateTime.Now.ToString("yyyyMMdd_HH"));
        try
        {
            if(File.Exists(path))
            {
                FileInfo info = new FileInfo(path);
                if (info.Length > ERROR_FILE_MAX_SIZE)
                {
                    File.Delete(path);
                    streamWriter = File.CreateText(path);
                }
                else
                {
                    streamWriter = File.AppendText(path);
                }
            }
            else
            {
                streamWriter = File.CreateText(path);
            }
        }
        catch(Exception)
        {
            streamWriter = null;
        }
        return streamWriter;
    }

    private IEnumerator ChangeLogFile(int seconds)
    {
        while(true)
        {
            yield return new WaitForSeconds(seconds);
            if(logWriter != null)
            {
                logWriter.Close();
            }
            logWriter = CreateLogWriter();
        }
    }
}
