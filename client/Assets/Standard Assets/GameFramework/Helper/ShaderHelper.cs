using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using AssetPipeline;

public class ShaderHelper
{
    public static Shader Find(string name)
    {
#if UNITY_EDITOR
        return Shader.Find(name);
#else
        return AssetManager.Instance.FindShader(name);
#endif
    }
}

