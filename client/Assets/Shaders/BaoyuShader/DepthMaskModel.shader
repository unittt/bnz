Shader "Depth Mask Model"
{
    SubShader
    {

        Tags {"Queue" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha

        Lighting Off
        ZWrite On
        ZTest Always

        Pass
        {
            Color(0,1,0,0)
        }
    }
}
