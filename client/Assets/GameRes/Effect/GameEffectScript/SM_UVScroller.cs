using UnityEngine;
using System.Collections;

public class SM_UVScroller : MonoBehaviour 
{
    public int targetMaterialSlot = 0;
    public float speedX = 0.5f;
    public float speedY = 0.5f;

    private float timeWentX = 0;
    private float timeWentY = 0;
    private Renderer renderer;

	void Start ()
    {
	    renderer = GetComponent<Renderer>();
	}
	
	void Update () 
    {
	    timeWentY += Time.deltaTime * speedY;
        timeWentX += Time.deltaTime * speedX;
        renderer.materials[targetMaterialSlot].SetTextureOffset ("_MainTex", new Vector2(timeWentX, timeWentY));
	}

}