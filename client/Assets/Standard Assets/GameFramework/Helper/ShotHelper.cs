using System;
using System.Collections.Generic;
using System.Collections;
using Pathfinding;
using UnityEngine;
using LuaInterface;
using LITJson;

public class ShotHelper : MonoBehaviour {

	public  void Capture(Camera cam, LuaFunction callback )
	{
		StartCoroutine (CaptureCamera(cam, callback));
	}

	public IEnumerator  CaptureCamera(Camera camera, LuaFunction callback)  
	{  
		yield return new WaitForEndOfFrame ();
		float factor = 0.2f;
		Rect rect = new Rect ();
		rect.width = Screen.width;
		rect.height = Screen.height;
		RenderTexture rt = new RenderTexture((int)(rect.width * factor), (int)(rect.height * factor), 0);  
		camera.targetTexture = rt;  
		var tempMask = camera.cullingMask;
		camera.cullingMask = 1 << 8;
		camera.Render();   
		RenderTexture.active = rt;   
		Texture2D screenShot = new Texture2D((int)(rect.width * factor), (int)(rect.height * factor), TextureFormat.RGB24,false);  

		screenShot.ReadPixels(rect, 0, 0);
		screenShot.Apply();
  
		camera.targetTexture = null; 
		RenderTexture.active = null; 

		camera.cullingMask = tempMask;

		if (callback != null)
		{
			callback.BeginPCall();
			callback.Push(screenShot);
			callback.PCall();
			callback.EndPCall();
		}

	} 
}
