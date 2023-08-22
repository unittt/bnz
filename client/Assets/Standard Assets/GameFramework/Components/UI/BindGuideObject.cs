using UnityEngine;
using System.Collections;

public class BindGuideObject : MonoBehaviour {

    public int guideId = 0;
	void Start () {
	    if (0 == guideId)
        {
            GameDebug.LogError("未定义引导ID");
        } 
    }
	
    public int GetGuideId()
    {   
        return guideId;
    }
}
