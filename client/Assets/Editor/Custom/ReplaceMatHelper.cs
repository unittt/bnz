using UnityEngine;
using System.Collections;
using UnityEditor;

public class ReplaceMatHelper{
	// Use this for initialization
	static public void Run () {
		string[] paths = {
							   "Assets/GameRes/Model",
		};
		Shader shader = AssetDatabase.LoadAssetAtPath<Shader>("Assets/Shaders/BaoyuShader/Baoyu-Unlit-Model-Transparent.shader");
		var textGUIDs = AssetDatabase.FindAssets("t:Material", paths);
		// for (var i = 0; i < textGUIDs.Length; i++)
		// {
		// 	var resPath = AssetDatabase.GUIDToAssetPath(textGUIDs[i]);
		// 	var mat = AssetDatabase.LoadAssetAtPath<Material>(resPath);
		// 	var matClone = UnityEngine.GameObject.Instantiate<Material>(mat);
		// 	matClone.shader = shader;
		// 	matClone.SetFloat("_Outline", 0.01f);
		// 	Color c = new Color(36f/255f, 24f/255f, 22f/255f);
		// 	matClone.SetColor("_OutlineColor", c);
		// 	AssetDatabase.DeleteAsset(resPath);
		// 	AssetDatabase.CreateAsset(matClone, resPath);
		// }
		AssetDatabase.Refresh();
	}
}
