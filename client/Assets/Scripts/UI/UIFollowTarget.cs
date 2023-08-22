using UnityEngine;
using System.Collections;

public class UIFollowTarget : MonoBehaviour {

	public GameObject target;

	public GameObject layer;


	// Use this for initialization
	void Start () {

		if (gameObject.transform.parent != null) {

			if (gameObject.transform.parent.parent != null) {

				layer = gameObject.transform.parent.parent.gameObject;

			}

		}
			
	}

	public void SetTarget(GameObject obj)
	{
		target = obj;
	}
	
	// Update is called once per frame
	void LateUpdate () {

		if (target != null ) {

			Vector3 wp = target.transform.position;
			Vector3 lp = layer.transform.InverseTransformPoint (wp);
			//Vector3 gp = gameObject.transform.localPosition;
			//gp.x = lp.x;
			//gp.y = lp.y;

			gameObject.transform.localPosition = lp;


		}


	
	}
}
