using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using UEObject = UnityEngine.Object;

public class AnimationClipData
{
	public string path;
	public AnimationClip clip;

	public AnimationClipData(string _path, AnimationClip _clip)
	{
		path = _path;
		clip = _clip;
	}
}

public class CheckResourceTools
{
    [MenuItem("Check Resource/CheckAllAnimationClips")]
    public static void CheckAllAnimationClips()
    {
        string[] allAssetPaths = AssetDatabase.GetAllAssetPaths();
        List<AnimationClipData> clips = new List<AnimationClipData>();
        foreach (string path in allAssetPaths)
        {
            if (path.EndsWith(".fbx") || path.EndsWith(".FBX"))
            {
                UEObject[] objs = AssetDatabase.LoadAllAssetsAtPath(path);
                foreach (UEObject obj in objs)
                {
                    if (obj is AnimationClip)
                    {
                        AnimationClip clip = obj as AnimationClip;
                        clips.Add(new AnimationClipData(string.Format("{0} - {1}", path, clip.name), clip));
                    }
                }
            }
            if (path.EndsWith(".anim") || path.EndsWith(".ANIM"))
            {
                UEObject obj = AssetDatabase.LoadAssetAtPath<UEObject>(path);
                if (obj is AnimationClip)
                {
                    clips.Add(new AnimationClipData(path, obj as AnimationClip));
                }
            }
        }

        foreach (AnimationClipData clipData in clips)
        {
            AnimationClip clip = clipData.clip;
            AnimationClipCurveData[] datas = AnimationUtility.GetAllCurves(clip);
            bool clipIsEmpty = true;
            foreach (AnimationClipCurveData data in datas)
            {
                if (data.curve.keys == null || data.curve.keys.Length == 0)
                {
                    continue;
                }
                else
                {
                    clipIsEmpty = false;
                    break;
                }
            }
            if (clipIsEmpty)
            {
                Debug.Log(clipData.path);
            }
        }
    }
}