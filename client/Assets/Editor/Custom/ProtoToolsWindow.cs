using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using System.IO;
using System.Text;
using SimpleJson;
using System.Diagnostics;
using System.Text.RegularExpressions;
using Debug = UnityEngine.Debug;

public class ProtoToolsWindow : EditorWindow
{
    private static readonly string SETTING_FILE = Application.dataPath + "/Editor/setting.json";
    private static readonly string clientProtoPath = Application.dataPath + "/Lua/proto/";
    private static string serverProtoPath;

	
    public static void OpenProtoTools()
    {
        ProtoToolsWindow window = (ProtoToolsWindow)EditorWindow.GetWindow(typeof(ProtoToolsWindow));
        window.Show();
        LoadSetting();
    }

    void OnGUI()
    {
        GUILayout.Label("服务端ProtoPath", EditorStyles.boldLabel);
        serverProtoPath = EditorGUILayout.TextField("Text Field", serverProtoPath);

        if (GUILayout.Button("复制proto"))
        {
            CopyPtroto();
            SaveSetting();
        }

        GUILayout.Label("生成net文件", EditorStyles.boldLabel);
        if(GUILayout.Button("根据proto生成net"))
        {
            GenerateAllProto();
            //GenerateNetFile("scene");
        }

        GUILayout.Label("update", EditorStyles.boldLabel);
        if (GUILayout.Button("update"))
        {
            SvnUpdate();
            CopyPtroto();
            SaveSetting();
            GenerateAllProto();
            //GenerateNetFile("scene");
        }
    }

    public static void SvnUpdate()
    {
       ProcessCommand("svn", "update " + serverProtoPath);
    }

    public static void ProcessCommand(string command,string argument)
    {
        System.Diagnostics.ProcessStartInfo info = new System.Diagnostics.ProcessStartInfo(command);
        info.Arguments = argument;
        info.CreateNoWindow = true;
        info.ErrorDialog = true;
        info.UseShellExecute = false;

        if (info.UseShellExecute)
        {
            info.RedirectStandardOutput = false;
            info.RedirectStandardError = false;
            info.RedirectStandardInput = false;
        }
        else
        {
            info.RedirectStandardOutput = true;
            info.RedirectStandardError = true;
            info.RedirectStandardInput = true;
            info.StandardOutputEncoding = System.Text.UTF8Encoding.UTF8;
            info.StandardErrorEncoding = System.Text.UTF8Encoding.UTF8;
        }

        System.Diagnostics.Process process = System.Diagnostics.Process.Start(info);
        if (!info.UseShellExecute)
        {
            Debug.Log(process.StandardOutput);
            Debug.Log(process.StandardError);
        }

        process.WaitForExit();
        process.Close();
    }

    public static void CopyPtroto()
    {
        if (string.IsNullOrEmpty(serverProtoPath))
        {
            Debug.LogError("服务端ProtoPath为空");
            return;
        }

        IOHelper.CopyDirectory(serverProtoPath, clientProtoPath);
        if (File.Exists(clientProtoPath + "netdefines.lua"))
        {
            Debug.Log(clientProtoPath + "netdefines.lua");
            Debug.Log(Application.dataPath + "/Lua/Logic/net/netdefines.lua");
            File.Replace(clientProtoPath + "netdefines.lua", Application.dataPath + "/Lua/net/netdefines.lua", null);
        }
        Debug.Log("复制Proto完成");
    }


    public class S2CProto
    {
        public string title;
        public List<string> keys = new List<string>();
        public List<string> explains = new List<string>();
    }

    public class S2CMessage
    {
        public string title;
        public List<string> keys = new List<string>();
        public List<string> todo = new List<string>();
    }

    public static List<S2CProto> ReadProto(string path)
    {
        List<S2CProto> msgList = new List<S2CProto>();
        string[] lines = {};
        if (File.Exists(path))
        {
            lines = File.ReadAllLines(path);
        }
        else
        {
            Debug.Log("文件不存在"+path);
            return msgList;
        }

        S2CProto msg = new S2CProto();
        for (int i = 0; i < lines.Length; i++)
        {
            string line = lines[i];
            string trimLine = line.Trim();

            if (trimLine.StartsWith("message"))
            {
                msg = new S2CProto();
                line = line.Replace("{", "");
                string[] args = line.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                msg.title = args[1];
				if (trimLine.EndsWith("}"))
				{
					msgList.Add(msg);
				}
            }
			else if ((!trimLine.StartsWith("//") || (!trimLine.StartsWith("/*") && !trimLine.EndsWith("*/"))) && trimLine.IndexOf(";") > 0 && trimLine.IndexOf("=") > 0)
			{
				line = line.Replace("=", " = ");
                line = line.Replace("	", " ");
                string[] args = line.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
				msg.keys.Add(args[2].Trim(new char[] { ' ', '='}));
                string explainStr = "";
                var match = Regex.Match(trimLine, @"(//(?<explain>.*))|(/\*(?<explain>.*)\*/)");
                if (match.Groups["explain"].Value != "")
                {
					explainStr = " --" + match.Groups["explain"].Value.Trim();
                }
                msg.explains.Add(explainStr);
            }
			else if (trimLine.IndexOf("}") >= 0 && !trimLine.StartsWith("/*") && !trimLine.EndsWith("*/"))
            {
				msgList.Add(msg);
            }
        }
        return msgList;
    }

    public static string ReadS2CMessageReserve(string path)
    {
        StringBuilder sb = new StringBuilder();
        if (!File.Exists(path))
            return null;

        string[] lines = File.ReadAllLines(path);

        bool start = false;
        for(int i = 0; i < lines.Length; i++)
        {
            if (lines[i] == "--Reserve Start--")
            {
                start = true;
            }
            else if (lines[i] == "--Reserve End--")
            {
                start = false;
                sb.AppendLine(lines[i]);
            }

            if(start)
            {
                sb.AppendLine(lines[i]);
            }
        }
        return sb.ToString();
    }


    public static Dictionary<string, S2CMessage> ReadS2CMessage(string path)
    {
        Dictionary<string, S2CMessage> msgDict = new Dictionary<string, S2CMessage>();
        if (!File.Exists(path))
            return msgDict;

        string[] lines = File.ReadAllLines(path);
        bool isTodoStart = false;
        S2CMessage msg = new S2CMessage();
        for (int i = 0; i < lines.Length; i++)
        {
            string line = lines[i];
            if (line.StartsWith("function"))
            {
                msg = new S2CMessage();
                isTodoStart = false;
                string[] args = line.Split(new char[] { ' ', '(', ')' }, StringSplitOptions.RemoveEmptyEntries);
                msg.title = args[1];
                msg.keys.Add(line);
            }
            else if (line.StartsWith("end"))
            {
                isTodoStart = false;
                msgDict[msg.title] = msg;
            }
            else if (line.IndexOf("todo") >= 0)
            {
                isTodoStart = true;
            }
            else
            {
                if (isTodoStart) 
                {
                    msg.todo.Add(line);
                }
            }
        }
        return msgDict;
    }

    public static void GenerateAllProto()
    {
        string path = Application.dataPath + "/Lua/proto/server/";
        string[] files = Directory.GetFiles(path);
        StringBuilder sb = new StringBuilder();
        string defineFile = string.Format("{0}/Lua/net/net.lua", Application.dataPath);
        string[] lines = File.ReadAllLines(defineFile);
        for (int i = 0; i < lines.Length;i++ )
        {
            string line = lines[i];
            sb.AppendLine(line);
            if (line.IndexOf("auto") >=0)
            {
                break;
            }

        }
        for(int i = 0; i < files.Length; i++)
        { 
            if(files[i].EndsWith(".proto"))
            {
                string name = Path.GetFileNameWithoutExtension(files[i]);
                sb.AppendLine(string.Format("net{0} = require \"net.net{1}\"", name, name));
                GenerateNetFile(name);
            }
        }
        File.WriteAllText(defineFile, sb.ToString());
    }

    public static string GenerateNetFile(string pbname)
    {
        string c2sFile = string.Format("{0}/Lua/proto/client/{1}.proto", Application.dataPath, pbname);
        string s2cFile = string.Format("{0}/Lua/proto/server/{1}.proto", Application.dataPath,  pbname);
        string netFile = string.Format("{0}/Lua/net/net{1}.lua", Application.dataPath,  pbname);

        List<S2CProto> c2sProtoList = ReadProto(c2sFile);
        List<S2CProto> s2cProtoList = ReadProto(s2cFile);
        Dictionary<string, S2CMessage> s2cMessageDcit = ReadS2CMessage(netFile);
        string reserveText = ReadS2CMessageReserve(netFile);

        StringBuilder sb = new StringBuilder();
        sb.Append("module(..., package.seeall)\n\n");
        if(!string.IsNullOrEmpty(reserveText))
        {
            sb.Append(reserveText);
            sb.AppendLine();
        }

        sb.Append("--GS2C--\n\n");

        for (int i = 0; i < s2cProtoList.Count; i++)
        {
            S2CProto pbmsg = s2cProtoList[i];
            string title = pbmsg.title;
            if (title.Contains("GS2C"))
            {
                sb.AppendLine("function " + title + "(pbdata)");
                S2CProto msg = s2cProtoList[i];
                for (int j = 0; j < msg.keys.Count; j++)
                {
                    sb.AppendLine(string.Format("\tlocal {0} = pbdata.{1}{2}", msg.keys[j], msg.keys[j], msg.explains[j]));
                }
                sb.AppendLine("\t--todo");
                if (s2cMessageDcit.ContainsKey(title))
                {
                    var oldMsg = s2cMessageDcit[title];
                    if (oldMsg != null)
                    {
                        for (int todoIdx = 0; todoIdx < oldMsg.todo.Count; todoIdx++)
                        {
                            sb.AppendLine(oldMsg.todo[todoIdx]);
                        }
                    }
                }
                sb.AppendLine("end");
                sb.AppendLine("");
            }
            else
            {
            }

        }

        sb.Append("\n--C2GS--\n\n");
        for (int i = 0; i < c2sProtoList.Count; i++)
        {
            S2CProto pbmsg = c2sProtoList[i];
            string title = pbmsg.title;
            if (title.Contains("C2GS"))
            {
                S2CProto msg = c2sProtoList[i];
                string s = "function " + title + "(";
                for (int j = 0; j < msg.keys.Count; j++)
                {
                    s += msg.keys[j] + ", ";
                }
                if (s.EndsWith(", "))
                    s = s.Substring(0, s.Length - 2);
                s += ")";
                sb.AppendLine(s);
                sb.AppendLine("\tlocal t = {");
                for (int j = 0; j < msg.keys.Count; j++)
                {
                    sb.AppendLine(string.Format("\t\t{0} = {0},", msg.keys[j]));
                }

                sb.AppendLine("\t}");
                sb.AppendLine(string.Format("\tg_NetCtrl:Send(\"{0}\", \"{1}\", t)", pbname, msg.title));
                sb.AppendLine("end");
                sb.AppendLine("");
            }
        }

        Debug.Log("生成文件 " + netFile);
        File.WriteAllText(netFile, sb.ToString());
        return netFile;
    }


    public static void LoadSetting()
    {
        if (!File.Exists(SETTING_FILE))
        {
            File.CreateText(SETTING_FILE);
            return;
        }

        string desc = File.ReadAllText(SETTING_FILE);
        if(string.IsNullOrEmpty(desc))
            return;
        Debug.Log("Load setting.json内容: " + desc);

        JsonObject dict = Json.DeserializeObject(desc) as JsonObject;
        if(dict.ContainsKey("serverProtoPath"))
        {
            serverProtoPath = dict["serverProtoPath"].ToString(); 
        }
    }

    public static void SaveSetting()
    {
        string desc = File.ReadAllText(SETTING_FILE);
        JsonObject dict;
        try
        {
            dict = Json.DeserializeObject(desc) as JsonObject;
        }
        catch(Exception)
        {
            dict = new JsonObject();
        }
        if (serverProtoPath != null)
        {
            dict["serverProtoPath"] = serverProtoPath;
        }

        string content = Json.SerializeObject(dict);
        Debug.Log("Save setting.json内容: " + content);

        File.WriteAllText(SETTING_FILE, content);
    }

}


