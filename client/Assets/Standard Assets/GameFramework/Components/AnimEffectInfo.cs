using System;
using UnityEngine;

public class AnimEffectInfo
{
	public GameObject gameObject = null;
	public string path = "";
	public int offset = 0;

	public AnimEffectInfo(GameObject go, string path, int offset = 0)
	{
		this.gameObject = go;
		this.path = path;
		this.offset = offset;
	}
}
