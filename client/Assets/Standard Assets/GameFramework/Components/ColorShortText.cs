using UnityEngine;
using System.Collections;
using System.Collections.Generic;


public class ColorShortText : MonoBehaviour 
{
    public Color[] colorArray = new Color[26];
    public Dictionary<char, Color> colors = new Dictionary<char, Color>();
    public static ColorShortText Instance
    {
        get;
        set;
    }

    void Start()
    {
        Instance = this;
        for (int i = 0; i < colorArray.Length; i++)
        {
            if (colorArray[i] != Color.clear)
            {
                colors[(char)('A' + i)] = colorArray[i];
            }
        }
    }
}
