using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using AssetPipeline;
using UnityEditor;

[CustomEditor(typeof(AssetManager))]
public class AssetManagerInspector : Editor
{
    private AssetManager _mgr;
    private static string _searchFilter = "";
    private string _selectedBundleName = "";
    private Vector2 _bundleNameScroll;
    void OnEnable()
    {
        _mgr = target as AssetManager;
    }

    public override void OnInspectorGUI()
    {
        if (_mgr == null)
            return;

        //_mgr.AutoUpgrade = (AssetUpdate.AutoUpgradeType)EditorGUILayout.EnumPopup(_mgr.AutoUpgrade);

        var abInfoDic = _mgr.abInfoDic;
        if (abInfoDic == null) return;

        // Search field
        GUILayout.BeginHorizontal();
        {
            var after = EditorGUILayout.TextField("", _searchFilter, "SearchTextField");

            if (GUILayout.Button("", "SearchCancelButton", GUILayout.Width(18f)))
            {
                after = "";
                GUIUtility.keyboardControl = 0;
            }

            if (_searchFilter != null && _searchFilter != after)
            {
                _searchFilter = after;
            }
        }
        GUILayout.EndHorizontal();

        GUILayout.Label("abInfoDic Count: " + abInfoDic.Count);
        _bundleNameScroll = EditorGUILayout.BeginScrollView(_bundleNameScroll);

        List<string> nameList = new List<string>(abInfoDic.Keys);
        nameList.Sort();
        foreach (string bundleName in nameList)
        {
            var abInfo = abInfoDic[bundleName];
            if (!string.IsNullOrEmpty(_searchFilter) && bundleName.IndexOf(_searchFilter, StringComparison.OrdinalIgnoreCase) < 0)
                continue;

            if (abInfo.assetBundle == null)
                continue;

            GUILayout.Space(-1f);
            GUI.backgroundColor = _selectedBundleName == bundleName
                ? Color.white
                : new Color(0.8f, 0.8f, 0.8f);
            GUILayout.BeginHorizontal("AS TextArea", GUILayout.MinHeight(20f));
            GUI.backgroundColor = Color.white;

            string name = string.Format("{0} load:{1} ref:{2}", abInfo.bundleName, abInfo.loadingCount, abInfo.refCount);


            if (GUILayout.Button(name, "OL TextField", GUILayout.Height(20)))
            {
                _selectedBundleName = bundleName;
            }

            int count = abInfo.refBundles.Count ;
            if (count > 0)
            {
                if (GUILayout.Button(count.ToString(), GUILayout.Width(40f)))
                {
                    string content = "";
                    foreach (KeyValuePair<string, int> one in abInfo.refBundles)
                    {
                        content += one.Key + ",";
                    }
                    Debug.LogError(abInfo.bundleName + " : " + content);
                }
            }
            GUILayout.EndHorizontal();
        }
        EditorGUILayout.EndScrollView();
    }
}
