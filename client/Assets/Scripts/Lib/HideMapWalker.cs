using UnityEngine;
using System.Collections;

public class HideMapWalker:MonoBehaviour
{

	public void ActiveAllRender(bool isActive)
	{
		var renderArray = gameObject.transform.GetComponentsInChildren<Renderer> (true);
		foreach (var render in renderArray) {
			render.enabled = isActive;
		}
			
		var boxColliderArray = gameObject.transform.GetComponentsInChildren<Collider> (true);
		foreach (var collider in boxColliderArray) {
			collider.enabled = isActive;

		}
	}
}


