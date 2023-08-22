using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;

[CustomEditor(typeof(AnimEffect))]
public class AnimEffectEditor : Editor
{
	public AnimEffect animEffect;
    public override void OnInspectorGUI()
    {
		animEffect = target as AnimEffect;

		animEffect.animName = EditorGUILayout.TextField("动作名", animEffect.animName);

		int effectLen = EditorGUILayout.IntField("特效数量", animEffect.EffectLength);
		if (animEffect.EffectLength != effectLen)
		{
			animEffect.EffectLength = effectLen;
		}
		ShowEffectInfo();

		int soundLen = EditorGUILayout.IntField("音效数量", animEffect.SoundLength);
		if (animEffect.SoundLength != soundLen)
		{
			animEffect.SoundLength = soundLen;
		}
		ShowSoundInfo();
    }

	private void ShowEffectInfo()
	{
		for (int i = 0; i < animEffect.EffectLength; i++)
		{
			AnimEffectInfo effectInfo = animEffect.effectArray[i];
			EditorGUILayout.BeginHorizontal();
			EditorGUIUtility.labelWidth = 50f;
			effectInfo.gameObject = (GameObject)EditorGUILayout.ObjectField("挂载点", effectInfo.gameObject, typeof(GameObject), true, GUILayout.Width(180f));
			EditorGUIUtility.labelWidth = 50f;
			var path = EditorGUILayout.TextField("特效路径", effectInfo.path, GUILayout.Width(320f));
			if (GUILayout.Button("选择", GUILayout.Width(32f)))
			{
				var tempPath = EditorUtility.OpenFilePanel("选择特效", Application.dataPath+"/GameRes/Effect/Anim/", "prefab");
				if (tempPath.Length != 0)
				{
					path = tempPath.Replace(Application.dataPath + "/GameRes/", "");
					effectInfo.path = path;
				}
			}
			effectInfo.path = path;
			EditorGUILayout.EndHorizontal();
			animEffect.effectArray[i] = effectInfo;
		}
	}

	private void ShowSoundInfo()
	{
		for (int i = 0; i < animEffect.SoundLength; i++)
		{
			AnimEffectInfo effectInfo = animEffect.soundArray[i];
			EditorGUILayout.BeginHorizontal();
			EditorGUIUtility.labelWidth = 50f;
			effectInfo.offset = (int)EditorGUILayout.IntField("时间偏移", effectInfo.offset, GUILayout.Width(180f));
			EditorGUIUtility.labelWidth = 50f;
			var path = EditorGUILayout.TextField("音效路径", effectInfo.path, GUILayout.Width(320f));
			if (GUILayout.Button("选择", GUILayout.Width(32f)))
			{
				var tempPath = EditorUtility.OpenFilePanel("选择音效", Application.dataPath+"/GameRes/Audio/Sound/War/", "ogg");
				if (tempPath.Length != 0)
				{
					path = tempPath.Replace(Application.dataPath + "/GameRes/", "");
					effectInfo.path = path;
				}
			}
			effectInfo.path = path;
			EditorGUILayout.EndHorizontal();
			animEffect.soundArray[i] = effectInfo;
		}
	}
}
