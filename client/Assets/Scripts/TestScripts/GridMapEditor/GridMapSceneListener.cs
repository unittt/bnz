using System;
using UnityEngine;
using System.Collections;

public class GridMapSceneListener : MonoBehaviour
{
    public static Action onApplicationQuit;
    void OnApplicationQuit()
    {
        if (onApplicationQuit != null)
            onApplicationQuit();
    }
}
