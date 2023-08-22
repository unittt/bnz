Shader "Depth Mask Complex"
{
    SubShader
    {
//    	"Opaque+100"
        Tags {"Queue" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha

        Lighting Off
        ZWrite On
        ZTest Less

        Pass
        {
            Color(0,1,0,0)
        }
    }
}