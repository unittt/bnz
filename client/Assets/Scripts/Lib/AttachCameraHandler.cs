using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class AttachCameraHandler : MonoBehaviour {
	public Camera camera;

	public Camera bgCamera;

	public List<Camera> attachCameras = new List<Camera>();
	// Use this for initialization
	void Start () {
	}

	public Camera NewAttachCamera(int layerMask, int depth)
	{
		if (camera == null)
		{
			camera = this.transform.GetComponent<Camera>();
			bgCamera = camera;
		}
		GameObject go = new GameObject();
		
		go.transform.parent = this.transform;
		Camera attachCamra = go.AddComponent<Camera>();
		attachCamra.CopyFrom(camera);
		attachCamra.depth = depth;

		if (depth < bgCamera.depth)
		{
			bgCamera.clearFlags = CameraClearFlags.Depth;
			bgCamera = attachCamra;
		}
		else
		{
			attachCamra.clearFlags = CameraClearFlags.Depth;
		}
		attachCamra.cullingMask = layerMask;
		attachCameras.Add(attachCamra);
		go.name = "attachCamera" + attachCameras.Count;
		return attachCamra;
	}

	public void SetRect(Rect rect)
	{
		foreach (var cam in attachCameras)
		{
			cam.rect = rect;
		}
	}
	public void SetEnabled(bool enabled)
	{
		foreach (var cam in attachCameras)
		{
			cam.enabled = enabled;
		}
	}

	public void SetFieldOfView(int fieldOfView)
	{
		foreach (var cam in attachCameras)
		{
			cam.fieldOfView = fieldOfView;
		}
	}

	public void SetBackgroudColor(Color backgroundColor)
	{
		bgCamera.backgroundColor = backgroundColor;
	}

	public Color GetBackgroundColor()
	{
		return bgCamera.backgroundColor;
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
