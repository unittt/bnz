using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;

[CustomEditor(typeof(GameObjectContainer))]
public class GameObjectContainerEditor : Editor
{
    private HashSet<int> widgetIds = new HashSet<int>();

    public override void OnInspectorGUI()
    {
        widgetIds.Clear();
        GameObjectContainer container = target as GameObjectContainer;

        ShowInputField(container);
        ShowButton(container);

        if (GUI.changed)
        {
            EditorUtility.SetDirty(target);
        }
    }

    private void ShowInputField(GameObjectContainer container)
    {
        if (container == null || container.objectArray == null)
        {
            return;
        }
        bool idConflict = false;
        bool widgetEmpty = false;
        for (int i = 0; i < container.objectArray.Length; ++i)
        {
            EditorGUILayout.BeginHorizontal();
            GameObjectIndex goIndex = container.objectArray[i];
            if (goIndex == null)
            {
                int id = EditorGUILayout.IntField(i + 1);
                GameObject go = (GameObject)EditorGUILayout.ObjectField(null, typeof(GameObject), true);
                goIndex = new GameObjectIndex(id, go);
                container.objectArray[i] = goIndex;
            }
            else
            {
                if (goIndex.id == 0)
                {
                    goIndex.id = i + 1;
                }
                goIndex.id = EditorGUILayout.IntField(goIndex.id);
                goIndex.gameObject = (GameObject)EditorGUILayout.ObjectField(goIndex.gameObject, typeof(GameObject), true);
            }
            if (goIndex != null)
            {
                if (widgetIds.Contains(goIndex.id))
                {
                    idConflict = true;
                }
                else
                {
                    widgetIds.Add(goIndex.id);
                }

            }
            if (goIndex == null || goIndex.gameObject == null)
            {
                widgetEmpty = true;
            }
            EditorGUILayout.EndHorizontal();
        }
        if (idConflict)
        {
            EditorGUILayout.HelpBox("请注意，UI控件的ID冲突", MessageType.Warning);
        }
        else if (widgetEmpty)
        {
            EditorGUILayout.HelpBox("请注意，UI控件的GameObject没有设置", MessageType.Warning);
        }
    }

    private void ShowButton(GameObjectContainer container)
    {
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("添加"))
        {
            if (container.objectArray == null)
            {
                container.objectArray = new GameObjectIndex[1];
            }
            else
            {
                GameObjectIndex[] tmpArray = new GameObjectIndex[container.objectArray.Length + 1];
                Array.Copy(container.objectArray, tmpArray, container.objectArray.Length);
                container.objectArray = tmpArray;
            }
        }
        if (GUILayout.Button("删除"))
        {
            if (container.objectArray == null || container.objectArray.Length == 1)
            {
                container.objectArray = null;
            }
            else
            {
                GameObjectIndex[] tmpArray = new GameObjectIndex[container.objectArray.Length - 1];
                Array.Copy(container.objectArray, tmpArray, tmpArray.Length);
                container.objectArray = tmpArray;
            }
        }

        if (GUILayout.Button("整理"))
        {
            if (container.objectArray == null || container.objectArray.Length == 1)
            {
                container.objectArray = null;
            }
            else
            {
                List<GameObjectIndex> list = new List<GameObjectIndex>(container.objectArray);
                list.Sort((a, b) =>
                {
                    return a.id - b.id;
                });
                container.objectArray = list.ToArray();
            }
        }

        EditorGUILayout.EndHorizontal();

    }
}
