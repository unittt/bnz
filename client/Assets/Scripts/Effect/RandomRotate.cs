using UnityEngine;
using System.Collections;

public class RandomRotate : MonoBehaviour {
	 
	public float minX;
	public float maxX;
	public float minY;
	public float maxY;
	public float minZ;
	public float maxZ;

	public bool open = true;


	void OnEnable()
	{   
		if (open)
		{
			var x = Random.Range(minX, maxX);
			var y = Random.Range(minY, maxY);
			var z = Random.Range(minZ, maxZ);
			transform.localEulerAngles = new Vector3(x, y, z);
		}

	} 
	
	void Start () {
	}
	

	void Update () {
		
	}
}
