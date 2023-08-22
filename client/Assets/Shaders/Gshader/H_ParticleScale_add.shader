// Shader created with Shader Forge v1.05 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.05;sub:START;pass:START;ps:flbk:,lico:1,lgpr:1,nrmq:1,limd:1,uamb:True,mssp:True,lmpd:False,lprd:False,rprd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,rpth:0,hqsc:True,hqlp:False,tesm:0,blpr:2,bsrc:0,bdst:0,culm:0,dpts:2,wrdp:False,dith:0,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:True;n:type:ShaderForge.SFN_Final,id:3962,x:33189,y:32888,varname:node_3962,prsc:2|emission-5180-OUT;n:type:ShaderForge.SFN_TexCoord,id:5471,x:30735,y:32926,varname:node_5471,prsc:2,uv:0;n:type:ShaderForge.SFN_Add,id:5627,x:31711,y:32622,varname:node_5627,prsc:2|A-5507-R,B-3188-OUT;n:type:ShaderForge.SFN_Subtract,id:5690,x:31326,y:32766,varname:node_5690,prsc:2|A-5507-R,B-4003-OUT;n:type:ShaderForge.SFN_Vector1,id:4003,x:31147,y:32888,varname:node_4003,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Divide,id:3188,x:31529,y:32766,varname:node_3188,prsc:2|A-5690-OUT,B-8381-OUT;n:type:ShaderForge.SFN_Lerp,id:4041,x:31927,y:32848,varname:node_4041,prsc:2|A-5627-OUT,B-4003-OUT,T-8381-OUT;n:type:ShaderForge.SFN_VertexColor,id:9304,x:31147,y:32962,varname:node_9304,prsc:2;n:type:ShaderForge.SFN_Clamp01,id:4290,x:32145,y:32848,varname:node_4290,prsc:2|IN-4041-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:2857,x:32507,y:33056,ptovrint:False,ptlb:XY_Switch,ptin:_XY_Switch,varname:node_2857,prsc:2,on:False|A-8880-OUT,B-755-OUT;n:type:ShaderForge.SFN_Add,id:1846,x:31690,y:33133,varname:node_1846,prsc:2|A-6181-G,B-2741-OUT;n:type:ShaderForge.SFN_Subtract,id:4482,x:31305,y:33277,varname:node_4482,prsc:2|A-6181-G,B-6744-OUT;n:type:ShaderForge.SFN_Vector1,id:6744,x:31128,y:33436,varname:node_6744,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Divide,id:2741,x:31508,y:33277,varname:node_2741,prsc:2|A-4482-OUT,B-240-OUT;n:type:ShaderForge.SFN_VertexColor,id:5527,x:31128,y:33541,varname:node_5527,prsc:2;n:type:ShaderForge.SFN_ComponentMask,id:5507,x:31032,y:32622,varname:node_5507,prsc:2,cc1:0,cc2:1,cc3:-1,cc4:-1|IN-5471-UVOUT;n:type:ShaderForge.SFN_ComponentMask,id:6181,x:31032,y:33147,varname:node_6181,prsc:2,cc1:0,cc2:1,cc3:-1,cc4:-1|IN-5471-UVOUT;n:type:ShaderForge.SFN_Lerp,id:4093,x:31895,y:33358,varname:node_4093,prsc:2|A-1846-OUT,B-6744-OUT,T-240-OUT;n:type:ShaderForge.SFN_Clamp01,id:1940,x:32138,y:33358,varname:node_1940,prsc:2|IN-4093-OUT;n:type:ShaderForge.SFN_Tex2d,id:1832,x:32731,y:33056,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_1832,prsc:2,tex:71ad0adb34e794648bb8b7925a837752,ntxv:0,isnm:False|UVIN-2857-OUT;n:type:ShaderForge.SFN_Append,id:8880,x:32320,y:32726,varname:node_8880,prsc:2|A-4290-OUT,B-5507-G;n:type:ShaderForge.SFN_Append,id:755,x:32314,y:33296,varname:node_755,prsc:2|A-6181-R,B-1940-OUT;n:type:ShaderForge.SFN_Color,id:4851,x:32731,y:32812,ptovrint:False,ptlb:MainColor,ptin:_MainColor,varname:node_4851,prsc:2,glob:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:5180,x:32965,y:33028,varname:node_5180,prsc:2|A-4851-RGB,B-1832-RGB,C-1832-A,D-5527-RGB,E-4219-OUT;n:type:ShaderForge.SFN_Divide,id:8381,x:31415,y:32994,varname:node_8381,prsc:2|A-9304-A,B-9489-OUT;n:type:ShaderForge.SFN_Vector1,id:9489,x:31147,y:33091,varname:node_9489,prsc:2,v1:2;n:type:ShaderForge.SFN_Divide,id:240,x:31335,y:33569,varname:node_240,prsc:2|A-5527-A,B-2038-OUT;n:type:ShaderForge.SFN_Vector1,id:2038,x:31128,y:33702,varname:node_2038,prsc:2,v1:2;n:type:ShaderForge.SFN_ValueProperty,id:4219,x:32729,y:33301,ptovrint:False,ptlb:TexPower,ptin:_TexPower,varname:node_4219,prsc:2,glob:False,v1:1;proporder:4851-1832-2857-4219;pass:END;sub:END;*/

Shader "Gshader/G_ParticleScale_add" {
    Properties {
        _MainColor ("MainColor", Color) = (0.5,0.5,0.5,1)
        _MainTex ("MainTex", 2D) = "white" {}
        [MaterialToggle] _XY_Switch ("XY_Switch", Float ) = 0
        _TexPower ("TexPower", Float ) = 1
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "ForwardBase"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One
            ZWrite Off
            
            Fog {Mode Off}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            //#pragma multi_compile_fwdbase
            //#pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            //#pragma target 2.0
            uniform fixed _XY_Switch;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _MainColor;
            uniform float _TexPower;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
/////// Vectors:
////// Lighting:
////// Emissive:
                float2 node_5507 = i.uv0.rg;
                float node_4003 = 0.5;
                float node_8381 = (i.vertexColor.a/2.0);
                float2 node_6181 = i.uv0.rg;
                float node_6744 = 0.5;
                float node_240 = (i.vertexColor.a/2.0);
                float2 _XY_Switch_var = lerp( float2(saturate(lerp((node_5507.r+((node_5507.r-node_4003)/node_8381)),node_4003,node_8381)),node_5507.g), float2(node_6181.r,saturate(lerp((node_6181.g+((node_6181.g-node_6744)/node_240)),node_6744,node_240))), _XY_Switch );
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(_XY_Switch_var, _MainTex));
                float3 emissive = (_MainColor.rgb*_MainTex_var.rgb*_MainTex_var.a*i.vertexColor.rgb*_TexPower);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
