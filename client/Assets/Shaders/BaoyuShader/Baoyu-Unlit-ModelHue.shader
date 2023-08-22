
Shader "Baoyu/Model/ModelHue"
{
    Properties
    {
        _MainTex("Texture", 2D) = "black" {}
        _MutateTex("Mutate", 2D) = "black"{}
        _MaskTex("Mask", 2D) = "black"{}
        _blendFactorR("Blend FactorR",Range(0,1.0)) = 0
        _blendFactorG("Blend FactorG",Range(0,1.0)) = 0
        _blendFactorB("Blend FactorB",Range(0,1.0)) = 0
        _blendFactorA("Blend FactorA",Range(0,1.0)) = 0
        _Alpha("Color", Color) = (1,1,1,1)
        _ColorAlpha("colorAlpha", Color) = (1,1,1,1)

        [HideInInspector]_RHueShift1("_RHueShift1", vector) = (1,0,0,0)
        [HideInInspector]_RHueShift2("_RHueShift2", vector) = (0,1,0,0)
        [HideInInspector]_RHueShift3("_RHueShift3", vector) = (0,0,1,0)

        [HideInInspector]_GHueShift1("_GHueShift1", vector) = (1,0,0,0)
        [HideInInspector]_GHueShift2("_GHueShift2", vector) = (0,1,0,0)
        [HideInInspector]_GHueShift3("_GHueShift3", vector) = (0,0,1,0)

        [HideInInspector]_BHueShift1("_BHueShift1", vector) = (1,0,0,0)
        [HideInInspector]_BHueShift2("_BHueShift2", vector) = (0,1,0,0)
        [HideInInspector]_BHueShift3("_BHueShift3", vector) = (0,0,1,0)

        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("CullModel", int) = 2
        [space(50)]
        [Toggle(RIM_COLOR)] _rimColor("Rim Color Enable", int) = 0
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimWidth ("Rim Width", Range(0, 1)) = 0

        [HideInInspector]_rColor("_rColor", Color) = (1,1,1,1)
        [HideInInspector]_gColor("_gColor", Color) = (1,1,1,1)
        [HideInInspector]_bColor("_bColor", Color) = (1,1,1,1)
        [HideInInspector]_aColor("_aColor", Color) = (1,1,1,1)


    }

    SubShader
    {
        Tags {"Queue" = "AlphaTest+10" "IgnoreProjector" = "True" }

        Pass
        {
            Cull [_Cull]
            ZTest LEqual
            ZWrite On
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature RIM_COLOR
            #include "UnityCG.cginc"

            struct VertInput
            {
                half4 vertex	: POSITION;
                half2 texcoord	: TEXCOORD0;
            #ifdef RIM_COLOR
                fixed3 normal : NORMAL;
            #endif
            };

            struct v2f {
                half4  pos : SV_POSITION;
                half2  uv : TEXCOORD0;
            #ifdef RIM_COLOR
                fixed3 color : COLOR;
            #endif
            };
            #ifdef RIM_COLOR
            uniform fixed4 _RimColor;
            uniform fixed _RimWidth;
            #endif
            v2f vert(VertInput v)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = v.texcoord;
                #ifdef RIM_COLOR
                fixed3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
                fixed dotProduct = 1 - dot(v.normal, viewDir);
                o.color = smoothstep(1 - _RimWidth, 1, dotProduct);
                o.color *= _RimColor;
                #endif
                return o;
            }

            sampler2D _MainTex;
            sampler2D _MutateTex;
            sampler2D _MaskTex;

            fixed _blendFactorR;
            fixed _blendFactorG;
            fixed _blendFactorB;
            fixed _blendFactorA;

            fixed4 _RHueShift1;
            fixed4 _RHueShift2;
            fixed4 _RHueShift3;

            fixed4 _GHueShift1;
            fixed4 _GHueShift2;
            fixed4 _GHueShift3;

            fixed4 _BHueShift1;
            fixed4 _BHueShift2;
            fixed4 _BHueShift3;

            float4 _Alpha;
            float4 _rColor;
            float4 _gColor;
            float4 _bColor;
            float4 _aColor;

            float4 _ColorAlpha;

            fixed4 frag(v2f i) :COLOR
            {
                fixed4 origin = tex2D(_MainTex, i.uv);
                fixed4 mask = tex2D(_MaskTex, i.uv);
                fixed4 mutate = tex2D(_MutateTex, i.uv);
                fixed4 temp = fixed4(0,0,0,1);
                fixed4x4 _RHueShift = fixed4x4(
                    _RHueShift1,
                    _RHueShift2,
                    _RHueShift3,
                    temp
                );
                fixed4x4 _GHueShift = fixed4x4(
                    _GHueShift1,
                    _GHueShift2,
                    _GHueShift3,
                    temp
                );
                fixed4x4 _BHueShift = fixed4x4(
                    _BHueShift1,
                    _BHueShift2,
                    _BHueShift3,
                    temp
                );

         

                fixed4 mutateColor = _rColor *lerp(origin,mutate,_blendFactorR)*mask.r
                                    + _gColor *lerp(origin,mutate,_blendFactorG)*mask.g
                                    + _bColor *lerp(origin,mutate,_blendFactorB)*mask.b
                                    + _aColor *lerp(origin,mutate,_blendFactorA)*mask.a
                                    + origin*(1 - mask.r - mask.g - mask.b - mask.a);
                #ifdef RIM_COLOR
                mutateColor.rgb += i.color;
                #endif

                mutateColor.r = clamp(mutateColor.r,0,1);
                mutateColor.g = clamp(mutateColor.g,0,1);
                mutateColor.b = clamp(mutateColor.b,0,1);

                return fixed4(mutateColor.rgb, _Alpha.a) * _ColorAlpha;
            }
            ENDCG
        }
    }
    //Fallback "VertexLit"
}
