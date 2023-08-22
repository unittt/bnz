using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using UnityEngine;
using UnityEditor;
public class ExportWrapWindow : EditorWindow
{
    string myString = "";

    public static void Init()
    {
        ExportWrapWindow window = (ExportWrapWindow)EditorWindow.GetWindow(typeof(ExportWrapWindow));
        window.Show();
    }

    void ExportWrap(Type t)
    {
        ToLuaMenu.BindType[] typeList = new ToLuaMenu.BindType[1];
        typeList[0] = new ToLuaMenu.BindType(t);
        ToLuaMenu.BindType[] list = ToLuaMenu.GenBindTypes(typeList);
        for (int i = 0; i < list.Length; i++)
        {
            ToLuaExport.Clear();
            ToLuaExport.className = list[i].name;
            ToLuaExport.type = list[i].type;
            ToLuaExport.isStaticClass = list[i].IsStatic;
            ToLuaExport.baseType = list[i].baseType;
            ToLuaExport.wrapClassName = list[i].wrapName;
            ToLuaExport.libClassName = list[i].libName;
            ToLuaExport.extendList = list[i].extendList;
            ToLuaExport.Generate(CustomSettings.saveDir);
        }
        Debug.Log("导出类" + myString);
        AssetDatabase.Refresh();
    }

    void OnGUI()
    {
        GUILayout.Label("输入类名: namespace.class", EditorStyles.boldLabel);
        GUILayout.Label("比如: UnityEngine.Vector3", EditorStyles.boldLabel);
        myString = EditorGUILayout.TextField("Text Field", myString);

        if (GUILayout.Button("生成wrap"))
        {
            string name = null;
            Type t = null;
            name = string.Format("{0}, UnityEngine, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null", myString);
            t = Type.GetType(name);
            if(t != null)
            {
                ExportWrap(t);
                return;
            }

            name = string.Format("{0}, Assembly-CSharp, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null", myString);
            t = Type.GetType(name);
            if (t != null)
            {
                ExportWrap(t);
                return;
            }

            name = string.Format("{0}, Assembly-CSharp-firstpass, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null", myString);
            t = Type.GetType(name);
            if (t != null)
            {
                ExportWrap(t);
                return;
            }

            name = string.Format("{0}, UnityEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null", myString);
            t = Type.GetType(name);
            if (t != null)
            {
                ExportWrap(t);
                return;
            }
            Debug.LogError("找不到类" + myString);
        }
    }
}