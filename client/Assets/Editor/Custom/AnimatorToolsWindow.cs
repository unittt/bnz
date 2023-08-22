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


public class AnimatorToolsWindow : EditorWindow
{
    private static readonly string characterPath = "Assets/GameRes/Model/Character";
    private static readonly string templatepath = "Assets/GameRes/Model/Template/CharacterAnim/Animator.overrideController";
	private static readonly string templatepath2 = "Assets/GameRes/Model/Template/CharacterAnim/Animator_2.overrideController";
	private static readonly string templatepathwp = "Assets/GameRes/Model/Template/CharacterAnim/Animator_wp.overrideController";
    private static readonly string marryAnimatorPath = "Assets/GameRes/Model/Template/Marry/Marry.overrideController";
    private string modelStr = "";
    static Dictionary<string, string> replaceDict = new Dictionary<string, string>();
    //不检查模型列表
    static Dictionary<string, bool> notCheckModelList = new Dictionary<string, bool>();


    [MenuItem("工具/Animator工具", false, 61)]
    public static void OpenAnimatorTools()
    {
        notCheckModelList.Clear();
        notCheckModelList.Add("8225", true);
        notCheckModelList.Add("8226", true);

        if (replaceDict.Count == 0)
        {
            replaceDict.Add("magic", "attack1");
            replaceDict.Add("attack2", "attack1");
            replaceDict.Add("attack3", "attack1");
            replaceDict.Add("attack4", "attack1");
			replaceDict.Add("attack5", "attack1");
			replaceDict.Add("attack6", "attack1");
			replaceDict.Add("attack7", "attack1");
			replaceDict.Add("attack8", "attack1");
			replaceDict.Add("attack9", "attack1");
			replaceDict.Add("idleWar", "idleCity");
			replaceDict.Add("runWar", "run");
			replaceDict.Add("show2", "show");
        }

        AnimatorToolsWindow window = (AnimatorToolsWindow)EditorWindow.GetWindow(typeof(AnimatorToolsWindow));
        window.Show();
    }

    public void CreateOne(string sModel)
    {
        if (notCheckModelList.ContainsKey(sModel))
            return;
        var dir = string.Format("{0}/{1}/Anim/", characterPath, sModel);
        var anims = System.IO.Directory.GetFiles(dir, "*.anim", 0);
        var list = new List<string>();
        list.Add("");
        foreach (var anim in anims)
        {
            var animName = System.IO.Path.GetFileNameWithoutExtension(anim);
            var splts = animName.Split('_');
            if (splts.Length == 2)
            {
                list.Add('_' + splts[1]);
            }
        }
        foreach (var sub in list)
		{
            CreateOne(sModel, sub, 2);
            CreateOne(sModel, sub, 1);
        }
    }

	public void CreateOne(string sModel, string sub, int index)
    {
		string tPath = index == 1 ? templatepath : templatepath2;
		AnimatorOverrideController ori = AssetDatabase.LoadAssetAtPath(tPath, typeof(AnimatorOverrideController)) as AnimatorOverrideController;
        AnimatorOverrideController animator = GameObject.Instantiate<AnimatorOverrideController>(ori);

        AnimationClipPair[] newclips = new AnimationClipPair[animator.clips.Length];
        if (animator != null)
        {
            for (int i = 0; i < animator.clips.Length; i++)
            {
                AnimationClipPair clipPair = animator.clips[i];
                string animOverridePath = string.Format("{0}/{1}/Anim/{2}{3}.anim", characterPath, sModel, clipPair.originalClip.name, sub);
                AnimationClip clipOverride = AssetDatabase.LoadAssetAtPath(animOverridePath, typeof(AnimationClip)) as AnimationClip;

                if (clipOverride == null)
                {
                    if (replaceDict.ContainsKey(clipPair.originalClip.name))
                    {
                        string p = string.Format("{0}/{1}/Anim/{2}{3}.anim", characterPath, sModel, replaceDict[clipPair.originalClip.name], sub);
                        clipOverride = AssetDatabase.LoadAssetAtPath(p, typeof(AnimationClip)) as AnimationClip;
                        Debug.Log("找到替换" + clipPair.originalClip.name + ".anim");
                    }
                    if (clipOverride == null && sub != "")
                    {
                        animOverridePath = string.Format("{0}/{1}/Anim/{2}.anim", characterPath, sModel, clipPair.originalClip.name);
                        clipOverride = AssetDatabase.LoadAssetAtPath(animOverridePath, typeof(AnimationClip)) as AnimationClip;
                    }
                    if (clipOverride == null)
                    {
                        Debug.Log("缺少" + clipPair.originalClip.name + ".anim");
                    }

                }
                clipPair.overrideClip = clipOverride;
                newclips[i] = clipPair;
            }
            animator.clips = newclips;
			string savePath = string.Format("{0}/{1}/Anim/Animator{2}{3}.overrideController", characterPath, sModel, sModel, index==1? "":"_"+index);
            AssetDatabase.DeleteAsset(savePath);
            AssetDatabase.CreateAsset(animator, savePath);

			if (sub == "")
			{
				var path = string.Format("{0}/{1}/Prefabs/model{2}.prefab", characterPath, sModel, sModel);
				GameObject oldGo = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
				GameObject go = UnityEngine.Object.Instantiate(oldGo);
                var replaceceAnimator = go.GetMissingComponent<Animator>() as Animator;
				replaceceAnimator.runtimeAnimatorController = animator;
				PrefabUtility.ReplacePrefab(go, oldGo);
				UnityEngine.Object.DestroyImmediate(oldGo);
				UnityEngine.Object.DestroyImmediate(go);
				Debug.Log("导出完成" + sModel);
			}

        }

    }

    public void ExportBindNode(string sModel)
    {
        var path = string.Format("{0}/{1}/Prefabs/model{2}.prefab", characterPath, sModel, sModel);
        GameObject oldGo = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
        GameObject go = UnityEngine.Object.Instantiate(oldGo);
        var dict = new Dictionary<int, Transform> ();
        FindInChilds(go.transform, ref dict, (Transform t) =>
        {
            var match = "Bip001 Prop";
            var index = t.name.IndexOf(match);
            if (index >= 0)
            {
                var sub = t.name.Substring(index+match.Length);
                var i = int.Parse(sub);
                if  (i> 0)
                {
                    return i;
                }
            }
            return  -1;
         });
        var container = go.GetMissingComponent<GameObjectContainer>();
        foreach(KeyValuePair<int, Transform> kvp in dict)
        {
            var p = kvp.Value.gameObject.transform;
            var gameObejct = new GameObject();
            gameObejct.name = "mount_" + kvp.Key;
            gameObejct.transform.SetParent(p, true);
            container.Add(kvp.Key, gameObejct, true);
        }
        PrefabUtility.ReplacePrefab(go, oldGo);
        UnityEngine.Object.DestroyImmediate(oldGo);
        UnityEngine.Object.DestroyImmediate(go);
        Debug.Log("导出完成" + sModel);
    }

    public delegate int FilterFunc(Transform t);
    public void FindInChilds(Transform t, ref Dictionary<int, Transform> dict, FilterFunc f)
    {
        if (t.childCount == 0)
        {
            return;
        }
        for (int i = 0; i <= t.childCount - 1; i++)
        {
            var child = t.GetChild(i);
            var key = f(child);
            if (key > 0)
            {
                dict.Add(key, child);
            }
            FindInChilds(child, ref dict, f);
        }
    }

    void OnGUI()
    {
        modelStr = EditorGUILayout.TextField("模型编号", modelStr);
        if (GUILayout.Button("生成Animator"))
        {
            CreateOne(modelStr);
        }

        if (GUILayout.Button("生成全部模型Animator"))
        {
			if (EditorUtility.DisplayDialog("提示", "你确定要导出全部模型吗？ ", "确定", "取消"))
			{
				var dirs = Directory.GetDirectories(Application.dataPath + "/GameRes/Model/Character");
				foreach (var sOne in dirs)
				{
					int pos = sOne.IndexOf("/Character");
					string sModel = sOne.Substring(pos + "/Character/".Length);
					CreateOne(sModel);
				}
			}
        }

        if (GUILayout.Button("生成结婚Animator"))
        {
            CreateMarryAnimator(modelStr);
        }

		GUILayout.Label("导出绑定节点", EditorStyles.boldLabel);
		if (GUILayout.Button("导出绑定节点"))
		{
			ExportBindNode(modelStr);
		}

        GUILayout.Label("更新动作时间", EditorStyles.boldLabel);
        if (GUILayout.Button("导出"))
        {
            EditorUtil.RunLuaFunc("editorgui.GenAnimTimeData");
        }

		GUILayout.Label("生成动作文件", EditorStyles.boldLabel);
        if (GUILayout.Button("生成组合动作文件"))
        {
            EditorUtil.RunLuaFunc("editorgui.GenAllCombActAnim");
		}
		
		GUILayout.Label("生成音效文件", EditorStyles.boldLabel);
		if (GUILayout.Button("生成音效文件"))
		{
			EditorUtil.RunLuaFunc("editorgui.GenAudioPath");
		}
        
        GUILayout.Label("检查法术文件", EditorStyles.boldLabel);
        if (GUILayout.Button("检查法术文件"))
        {
            EditorUtil.RunLuaFunc("editorgui.CheckMagicFiles");
        }
    }

    public void CreateMarryAnimator(string sModel)
    {
        var dir = string.Format("{0}/{1}/Marry/", characterPath, sModel);
        if (!System.IO.Directory.Exists(dir))
        {
            return;
        }
        var commDir = string.Format("{0}/{1}/Anim/", characterPath, sModel);
        var anims = System.IO.Directory.GetFiles(dir, "*.anim", 0);

        var oriAnimator = AssetDatabase.LoadAssetAtPath(marryAnimatorPath, typeof(AnimatorOverrideController)) as AnimatorOverrideController;
        var animator = GameObject.Instantiate<AnimatorOverrideController>(oriAnimator);

        int len = animator.clips.Length;
        var newClips = new AnimationClipPair[len];
        if (animator != null)
        {
            for (int i = 0; i < len; i++)
            {
                var clip = animator.clips[i];
                string clipPath;
                string clipName = clip.originalClip.name;
                string pathStr;
                if (clipName.StartsWith("marry"))
                {
                    pathStr = "{0}/{1}/Marry/{2}.anim";
                }
                else {
                    pathStr = "{0}/{1}/Anim/{2}.anim";
                }
                clipPath = string.Format(pathStr, characterPath, sModel, clipName);
                var clipOverride = AssetDatabase.LoadAssetAtPath(clipPath, typeof(AnimationClip)) as AnimationClip;
                clip.overrideClip = clipOverride;
                newClips[i] = clip;
            }
            animator.clips = newClips;
            string savePath = string.Format("{0}/{1}/Marry/Marry{2}.overrideController", characterPath, sModel, sModel);
            AssetDatabase.DeleteAsset(savePath);
            AssetDatabase.CreateAsset(animator, savePath);
        }
    }
}


