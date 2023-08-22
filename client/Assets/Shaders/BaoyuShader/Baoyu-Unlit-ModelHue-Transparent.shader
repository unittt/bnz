
Shader "Baoyu/Unlit/ModelHue_Transparent"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Texture", 2D) = "black" {}
        _MutateTex("Mutate", 2D) = "black"{}
        _MaskTex("Mask", 2D) = "black"{}
        _blendFactorR("Blend Factor",Range(0,1.0)) = 0
        _blendFactorG("Blend Factor",Range(0,1.0)) = 0
        _blendFactorB("Blend Factor",Range(0,1.0)) = 0
    }

    SubShader
    {
        Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" }

        Pass
        {
            Lighting Off
            Fog{ Mode Off }
            ZTest LEqual
            ZWrite On
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct VertInput
            {
                float4 vertex	: POSITION;
                float2 texcoord	: TEXCOORD0;
            };

            struct v2f {
                half4  pos : SV_POSITION;
                half2  uv : TEXCOORD0;
            };

            v2f vert(VertInput v)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            float4 _Color;
            sampler2D _MainTex;
            sampler2D _MutateTex;
            sampler2D _MaskTex;

            fixed _blendFactorR;
            fixed _blendFactorG;
            fixed _blendFactorB;

            uniform fixed4x4 _RHueShift;
            uniform fixed4x4 _GHueShift;
            uniform fixed4x4 _BHueShift;

            fixed4 frag(v2f i) :COLOR
            {
                fixed4 origin = tex2D(_MainTex, i.uv);
                fixed4 mask = tex2D(_MaskTex, i.uv);
                fixed4 mutate = tex2D(_MutateTex, i.uv);

                fixed4 mutateColor = mul(_RHueShift,lerp(origin,mutate,_blendFactorR))*mask.r
                                    + mul(_GHueShift,lerp(origin,mutate,_blendFactorG))*mask.g
                                    + mul(_BHueShift,lerp(origin,mutate,_blendFactorB))*mask.b
                                    + origin*(1 - mask.r - mask.g - mask.b);

                return fixed4(mutateColor.rgb, _Color.a);
            }
            ENDCG
        }
    }
    //Fallback "VertexLit"
}
