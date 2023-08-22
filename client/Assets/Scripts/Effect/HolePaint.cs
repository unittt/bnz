using UnityEngine;
using System.Collections;

public class HolePaint : MonoBehaviour 
{
    public Texture2D mTexture;
	void Start () 
    {
        mTexture = new Texture2D(5, 6);
        transform.GetComponent<Renderer>().material.SetTexture("_SliceGuide", mTexture);
        for (int y = 0; y < mTexture.height; ++y) 
	    {
		    for (int x = 0; x < mTexture.width; ++x) 
		    {
			    mTexture.SetPixel (x, y, Color.white);
		    }
	    }
	    mTexture.Apply();
	}
	
	void Update () 
    {
	    if (!Input.GetMouseButton (0)) return;
	
	    RaycastHit hit;
	    if (!Physics.Raycast (UICamera.mainCamera.ScreenPointToRay(Input.mousePosition), out hit)) return;
	
	    Renderer renderer = hit.collider.GetComponent<Renderer>();
	    var meshCollider = hit.collider as MeshCollider;
	    if (renderer == null || renderer.sharedMaterial == null ||mTexture == null || meshCollider == null) return;
	
	    Texture2D tex = mTexture;
	    var pixelUV = hit.textureCoord;
	    pixelUV.x *= tex.width;
	    pixelUV.y *= tex.height;
	
	    // add black spot, which is then transparent in the shader
	    tex.SetPixel((int)pixelUV.x, (int)pixelUV.y, Color.black);
	    tex.Apply();
	}
}
