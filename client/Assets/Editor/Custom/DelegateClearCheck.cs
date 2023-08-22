using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using System;
using System.Linq;
using Object = UnityEngine.Object;
using System.Text;
public class DelegateClearCheck 
{
    private const string EventMatch = @"((private(\s)+)|(public(\s)+))?event(\s)+(?<class>[\w\.\<\>\s\,]+)(\s)+(?<field>[\w]+)(\s+)?;";
    private const string EventClearMatch = DelegateClearMatch;

    private const string DelegateTypeMatch = @"((private(\s)+)|(public(\s)+))?delegate(\s)+(?<returnClass>[\w\.\<\>\s\,]+)(\s)+(?<Delegate>[\w]+)(\s+)?\((?<param>[\w\s\,]+)?\)(\s+)?\;";
    private const string DelegateMatch = @"((private(\s)+)|(public(\s)+))?(Class)(\s)+(?<field>[\w]+)(\s+)?;";
    private const string DelegateClearMatch = @"field(\s+)?=(\s+)?null(\s+)?;";

    private const string ActionDelegateMatch = @"((private(\s)+)|(public(\s)+))?(?<class>((System(\s+)?\.)?(\s+)?Action(\s+)?(\<(\s+)?[\w\s\,]+\>)?))(\s)+(?<field>[\w]+)(\s+)?;";
    private const string ActionClearMatch = DelegateClearMatch;

    private const string ListMatch = @"((private(\s)+)|(public(\s)+))?List\<(?<class>[\w\.\<\>\s\,]+)\>(\s)+(?<field>[\w]+)(\s+)?;";
    private const string ListClearMatch = @"field(\s+)?.(\s+)?Clear(\s+)?\((\s+)?\)(\s+)?\;";
    private const string ListClearMatch2 = @"field(\s+)?.(\s+)?=(\s+)?null(\s+)?;";

    private const string OnDestroyMatch =
@"void(\s+)OnDestroy(\s*)(\()(\s*)(\))(\s*)
(
	(
		(?'Open'\{)
		([^\{\}]+)
	)+
	(
		(?'-Open'\})
		([^\{\}]*)
	)+
)+
(?(Open)(?!))";

    private static readonly string[] MyGameScriptsPath = new []
    {
        "Assets/Standard Assets/GameFramework",
        "Assets/Standard Assets/NGUI",
        "Assets/Standard Assets/Components"
    };


    [MenuItem("Tools/CodeCheck/DelegateClearCheck")]
    private static void Check()
    {
        DelegateClearCheck check = new DelegateClearCheck();
        check.BeginCheckGameEvent();
        check.OutFile();
        SaveAndRefreshU3D();
    }

    private StringBuilder outFile = new StringBuilder();
    private string curFileName;
    private void BeginCheckGameEvent()
    {
        IEnumerable<string> allScriptPath = null;
        foreach (string directory in MyGameScriptsPath)
        {
            if (allScriptPath == null)
                allScriptPath = GetAllCodeFilesInDirectory(directory);
            else
                allScriptPath = allScriptPath.Concat(GetAllCodeFilesInDirectory(directory));
        }
        
        int i = 0;
        foreach (string path in allScriptPath)
        {
            //if (EditorUtility.DisplayCancelableProgressBar(string.Format("CheckEvent {0}/{1}", i, count), path, (float)i / (float)count))
            //    break;
            string allContent = File.ReadAllText(path);
            curFileName = Path.GetFileName(path);
            CheckFile(allContent);
            i++;
        }
        EditorUtility.ClearProgressBar();
    }

    private void CheckFile(string allContent)
    {
        string onDestroyFun = string.Empty;
        Match match = Regex.Match(allContent, OnDestroyMatch, RegexOptions.IgnorePatternWhitespace);
        if (match.Success)
            onDestroyFun = match.Value;

        CheckList(allContent, onDestroyFun);
        CheckDelegate(allContent, onDestroyFun);
        CheckActionDelegate(allContent, onDestroyFun);
        CheckEvent(allContent, onDestroyFun);
    }

    private void CheckList(string allContent, string onDestroy)
    {
        MatchCollection matches = Regex.Matches(allContent, ListMatch);
        foreach (Match match in matches)
        {
            string field = match.Groups["field"].Value;
            string matchClear = ListClearMatch.Replace("field", field);
            if (Regex.IsMatch(onDestroy, matchClear) == false && Regex.IsMatch(onDestroy, ListClearMatch2.Replace("field", field)) == false)
                AddOutFileMessage("{0},{1}\n", curFileName, field);
        }
    }

    private void CheckDelegate(string allContent, string onDestroy)
    {
        MatchCollection typeMatches = Regex.Matches(allContent, DelegateTypeMatch);
        foreach (Match typeMatch in typeMatches)
        {
            string delegateClass = typeMatch.Groups["Delegate"].Value;
            string delegateMatch = DelegateMatch.Replace("Class", delegateClass);
            MatchCollection delegates = Regex.Matches(allContent, delegateMatch);
            foreach (Match delegateItem in delegates)
            {
                string field = delegateItem.Groups["field"].Value;
                if(Regex.IsMatch(onDestroy, DelegateClearMatch.Replace("field", field)) == false)
                    AddOutFileMessage("{0},{1}\n", curFileName, field);
            }
        }
    }
    private void CheckActionDelegate(string allContent, string onDestroy)
    {
        MatchCollection actionMatches = Regex.Matches(allContent, ActionDelegateMatch);
        foreach (Match actionMatch in actionMatches)
        {
            string field = actionMatch.Groups["field"].Value;
            if (Regex.IsMatch(onDestroy, ActionClearMatch.Replace("field", field)) == false)
                AddOutFileMessage("{0},{1}\n", curFileName, field);
        }
    }
    private void CheckEvent(string allContent, string onDestroy)
    {
        MatchCollection matches = Regex.Matches(allContent, EventMatch);
        foreach (Match match in matches)
        {
            string field = match.Groups["field"].Value;
            if(Regex.IsMatch(onDestroy, EventClearMatch.Replace("field", field)) == false)
                AddOutFileMessage("{0},{1}\n", curFileName, field);
        }
    }

    private void AddOutFileMessage(string format, object arg0, object arg1)
    {
        string str = string.Format(format, arg0, arg1);
        if (ignorList.Contains(str.Replace("\n", String.Empty)) == false)
        {
            outFile.Append(str);
        }

    }
    private void OutFile()
    {
        File.WriteAllText("Assets/DelegateClearCheck.csv", outFile.ToString());
    }

    #region 辅助方法
    public static List<string> GetAllCodeFilesInDirectory(string pDirectory, string pInvalidPathKeyWord = "")
    {
        return GetAllFilesInDirectory(pDirectory, ".cs", pInvalidPathKeyWord);
    }
    public static List<string> GetAllFilesInDirectory(string pDirectory, string pSuffix, string pInvalidPathKeyWordPattern = "", string pFileNamePattern = "", bool pIncludeSubDir = true)
    {
        if (string.IsNullOrEmpty(pDirectory))
            return null;
        List<string> tResult = null;
        List<string> tFilePaths = GetFiles(pDirectory, pIncludeSubDir);
        if (null != tFilePaths)
        {
            tResult = new List<string>();
            string tFilePath;
            for (int tCounter = 0, tLen = tFilePaths.Count; tCounter < tLen; tCounter++)
            {
                tFilePath = tFilePaths[tCounter];
                if (string.IsNullOrEmpty(tFilePath))
                    continue;
                if (Regex.IsMatch(tFilePath, ".meta"))
                    continue;
                if (!string.IsNullOrEmpty(pInvalidPathKeyWordPattern))
                {
                    if (Regex.IsMatch(tFilePath, pInvalidPathKeyWordPattern))
                        continue;
                }
                if (tFilePath.LastIndexOf(pSuffix) != tFilePath.Length - pSuffix.Length)
                    continue;
                if (!string.IsNullOrEmpty(pFileNamePattern))
                {
                    if (!Regex.IsMatch(tFilePath, pFileNamePattern))
                        continue;
                }
                tResult.Add(tFilePath);
            }
        }
        return tResult;
    }
    public static List<string> GetFiles(string pDir, bool pIncludeSubDir = true)
    {
        List<string> tFileInfoList = new List<string>();
        if (Directory.Exists(pDir))
        {
            DirectoryInfo tDirectoryInfo = new DirectoryInfo(pDir);
            if (null != tDirectoryInfo)
            {
                FileInfo[] tFileInfos = tDirectoryInfo.GetFiles();
                if (null != tFileInfos)
                {
                    FileInfo tFileInfo;
                    for (int tCounter = 0, tLen = tFileInfos.Length; tCounter < tLen; tCounter++)
                    {
                        tFileInfo = tFileInfos[tCounter];
                        if (null != tFileInfo)
                            tFileInfoList.Add(tFileInfo.FullName);
                    }
                }
                if (pIncludeSubDir)
                {
                    DirectoryInfo[] tDirectoryInfos = tDirectoryInfo.GetDirectories();
                    if (null != tDirectoryInfos)
                    {
                        List<string> tFileInfoList2 = new List<string>();
                        DirectoryInfo tFileInfo;
                        for (int tCounter = 0, tLen = tDirectoryInfos.Length; tCounter < tLen; tCounter++)
                        {
                            tFileInfo = tDirectoryInfos[tCounter];
                            if (null != tFileInfo)
                            {
                                tFileInfoList2 = GetFiles(tFileInfo.FullName);
                                if (null != tFileInfoList2 && tFileInfoList2.Count > 0)
                                {
                                    tFileInfoList.AddRange(tFileInfoList2);
                                }
                            }
                        }
                    }
                }
            }
        }
        return tFileInfoList;
    }
    public static void SaveAndRefreshU3D()
    {
        EditorApplication.SaveAssets();
        AssetDatabase.Refresh();
        //UnityEditor.SceneManagement.EditorSceneManager.SaveOpenScenes();
    }
    #endregion

    private readonly string[] ignorList = new[]
    {
        "AssetManager.cs,_cdnUrls",
        "AssetManager.cs,_logMessageHandler",
        "AssetManager.cs,_loadErrorHandler",
        "AssetManager.cs,OnBeginResUpdate",
        "AssetManager.cs,OnFinishResUpdate",
        "AssetManager.cs,OnMinResUpdateBegin",
        "AssetManager.cs,OnMinResUpdateFinish",
        "AssetManager.cs,OnBeginLoadScene",
        "AssetManager.cs,OnBeginResUpdate",
        "AssetManager.cs,OnFinishResUpdate",
        "AssetManager.cs,OnMinResUpdateBegin",
        "AssetManager.cs,OnMinResUpdateFinish",
        "AssetManager.cs,OnBeginLoadScene",
        "AtlasManager.cs,removeList",
        "FileHelper.cs,mErrorCallback",
        "FileHelper.cs,mFinishCallback",
        "ResInfo.cs,Dependencies",
        "ResInfo.cs,updateList",
        "ResInfo.cs,removeList",
        "ZipProxy.cs,mFinishCallback",
        "SdkMessageScript.cs,OnSdkCallbackInfo",
        "HaConnector.cs,_tryPorts",
        "HaConnector.cs,callBack_Send",
        "HaConnector.cs,callBack_Send",
        "HaConnector.cs,callBack_Disconnect",
        "HaConnector.cs,OnLeaveEvent",
        "HaConnector.cs,OnMessageEvent",
        "HaConnector.cs,OnJoinEvent",
        "HaConnector.cs,OnServiceEvent",
        "HaConnector.cs,OnTimeOutEvent",
        "HaConnector.cs,OnCloseEvent",
        "HaConnector.cs,OnLoginState",
        "HaConnector.cs,OnStateEvent",
        "EventObject.cs,services",
        "ServiceQueryResponseInstruction.cs,services",
        "QiNiuSaveFileThreadTask.cs,_onPutFinished",
        "QiNiuSaveFileThreadTask.cs,_onPutFinished",
        "ThreadManager.cs,_targetAction",
        "ThreadManager.cs,_finishedAction",
        "BMGlyph.cs,kerning",
        "UITextList.cs,mParagraphs",
    };
}
