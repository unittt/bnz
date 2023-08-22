// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:False,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:5160,x:33088,y:32655,varname:node_5160,prsc:2|emission-6495-OUT,alpha-8989-OUT;n:type:ShaderForge.SFN_Tex2d,id:3775,x:31493,y:32436,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_3775,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Color,id:4519,x:31493,y:32261,ptovrint:False,ptlb:MainColor,ptin:_Color,varname:node_4519,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:4275,x:32002,y:32435,varname:node_4275,prsc:2|A-4519-RGB,B-3775-RGB;n:type:ShaderForge.SFN_Tex2d,id:2603,x:31669,y:33240,ptovrint:False,ptlb:BlendTex,ptin:_BlendTex,varname:node_2603,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7acc33f24a06fcd46baa112415b42195,ntxv:0,isnm:False|UVIN-2136-OUT;n:type:ShaderForge.SFN_TexCoord,id:1209,x:30720,y:32855,varname:node_1209,prsc:2,uv:0;n:type:ShaderForge.SFN_Time,id:3357,x:30506,y:33040,varname:node_3357,prsc:2;n:type:ShaderForge.SFN_Multiply,id:4098,x:30720,y:33063,varname:node_4098,prsc:2|A-3357-TSL,B-508-OUT;n:type:ShaderForge.SFN_ValueProperty,id:508,x:30506,y:33202,ptovrint:False,ptlb:SpeedX,ptin:_SpeedX,varname:node_508,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:8820,x:30720,y:33315,varname:node_8820,prsc:2|A-957-TSL,B-8192-OUT;n:type:ShaderForge.SFN_Time,id:957,x:30504,y:33277,varname:node_957,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:8192,x:30504,y:33443,ptovrint:False,ptlb:SpeedY,ptin:_SpeedY,varname:node_8192,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Add,id:6449,x:30987,y:33203,varname:node_6449,prsc:2|A-1209-V,B-8820-OUT;n:type:ShaderForge.SFN_Add,id:986,x:30987,y:33028,varname:node_986,prsc:2|A-1209-U,B-4098-OUT;n:type:ShaderForge.SFN_Append,id:2136,x:31253,y:33100,varname:node_2136,prsc:2|A-986-OUT,B-6449-OUT;n:type:ShaderForge.SFN_Add,id:6495,x:32617,y:32738,varname:node_6495,prsc:2|A-6369-OUT,B-1167-OUT;n:type:ShaderForge.SFN_Color,id:216,x:31921,y:32904,ptovrint:False,ptlb:BlendColor,ptin:_BlendColor,varname:node_216,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Slider,id:8536,x:31201,y:32668,ptovrint:False,ptlb:MainTex_Alpha,ptin:_MainTex_Alpha,varname:node_8536,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Add,id:3229,x:31660,y:32614,varname:node_3229,prsc:2|A-3775-A,B-8536-OUT;n:type:ShaderForge.SFN_Clamp01,id:8383,x:31828,y:32614,varname:node_8383,prsc:2|IN-3229-OUT;n:type:ShaderForge.SFN_ValueProperty,id:336,x:32160,y:33426,ptovrint:False,ptlb:BlendPower,ptin:_BlendPower,varname:node_336,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Power,id:7207,x:32357,y:33260,varname:node_7207,prsc:2|VAL-618-OUT,EXP-336-OUT;n:type:ShaderForge.SFN_Multiply,id:618,x:32160,y:33260,varname:node_618,prsc:2|A-5925-OUT,B-5603-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5603,x:31983,y:33426,ptovrint:False,ptlb:LightPower,ptin:_LightPower,varname:node_5603,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Lerp,id:1167,x:32282,y:32920,varname:node_1167,prsc:2|A-1974-RGB,B-216-RGB,T-436-OUT;n:type:ShaderForge.SFN_Clamp01,id:436,x:32022,y:33088,varname:node_436,prsc:2|IN-7207-OUT;n:type:ShaderForge.SFN_Color,id:1974,x:31921,y:32753,ptovrint:False,ptlb:BlendColor2,ptin:_BlendColor2,varname:node_1974,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_ComponentMask,id:6966,x:32439,y:33073,varname:node_6966,prsc:2,cc1:0,cc2:-1,cc3:-1,cc4:-1|IN-436-OUT;n:type:ShaderForge.SFN_Add,id:7605,x:32616,y:33013,varname:node_7605,prsc:2|A-8383-OUT,B-6966-OUT;n:type:ShaderForge.SFN_Multiply,id:5925,x:31983,y:33260,varname:node_5925,prsc:2|A-2603-RGB,B-2603-A,C-734-RGB,D-734-A;n:type:ShaderForge.SFN_Tex2d,id:734,x:31669,y:33478,ptovrint:False,ptlb:BlendTex2,ptin:_BlendTex2,varname:node_734,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:887d45145f23c924a94ff8fca910e1ad,ntxv:0,isnm:False|UVIN-3799-UVOUT;n:type:ShaderForge.SFN_Panner,id:3799,x:31400,y:33542,varname:node_3799,prsc:2,spu:1,spv:1|UVIN-9799-UVOUT,DIST-2341-OUT;n:type:ShaderForge.SFN_Time,id:5653,x:31015,y:33642,varname:node_5653,prsc:2;n:type:ShaderForge.SFN_Multiply,id:2341,x:31206,y:33677,varname:node_2341,prsc:2|A-5653-TSL,B-7318-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7318,x:31022,y:33818,ptovrint:False,ptlb:BlendTex2_Speed,ptin:_BlendTex2_Speed,varname:node_7318,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:8989,x:32812,y:32957,varname:node_8989,prsc:2|A-4519-A,B-7605-OUT;n:type:ShaderForge.SFN_Multiply,id:6369,x:32436,y:32555,varname:node_6369,prsc:2|A-4275-OUT,B-2031-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2031,x:32181,y:32623,ptovrint:False,ptlb:MainTex_Power,ptin:_MainTex_Power,varname:node_2031,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_TexCoord,id:9799,x:31206,y:33478,varname:node_9799,prsc:2,uv:0;proporder:4519-3775-8536-2031-2603-508-8192-734-7318-216-1974-336-5603;pass:END;sub:END;*/

Shader "G/G_Wing_blend" {
    Properties {
        _Color ("MainColor", Color) = (0.5,0.5,0.5,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _MainTex_Alpha ("MainTex_Alpha", Range(0, 1)) = 1
        _MainTex_Power ("MainTex_Power", Float ) = 1
        _BlendTex ("BlendTex", 2D) = "white" {}
        _SpeedX ("SpeedX", Float ) = 0
        _SpeedY ("SpeedY", Float ) = 0
        _BlendTex2 ("BlendTex2", 2D) = "white" {}
        _BlendTex2_Speed ("BlendTex2_Speed", Float ) = 0
        _BlendColor ("BlendColor", Color) = (0.5,0.5,0.5,1)
        _BlendColor2 ("BlendColor2", Color) = (0.5,0.5,0.5,1)
        _BlendPower ("BlendPower", Float ) = 1
        _LightPower ("LightPower", Float ) = 1
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
         _ColorAlpha("Color", Color) = (1,1,1,1)
         _Alpha("Alpha", Color) = (1,1,1,1)
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="AlphaTest+100"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            //#pragma multi_compile_fwdbase
            //#pragma multi_compile_fog
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 2.0
            uniform float4 _TimeEditor;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _Color;
            uniform sampler2D _BlendTex; uniform float4 _BlendTex_ST;
            uniform float _SpeedX;
            uniform float _SpeedY;
            uniform float4 _BlendColor;
            uniform float _MainTex_Alpha;
            uniform float _BlendPower;
            uniform float _LightPower;
            uniform float4 _BlendColor2;
            uniform sampler2D _BlendTex2; uniform float4 _BlendTex2_ST;
            uniform float _BlendTex2_Speed;
            uniform float _MainTex_Power;
            fixed4 _ColorAlpha;
            fixed4 _Alpha;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float4 node_3357 = _Time + _TimeEditor;
                float4 node_957 = _Time + _TimeEditor;
                float2 node_2136 = float2((i.uv0.r+(node_3357.r*_SpeedX)),(i.uv0.g+(node_957.r*_SpeedY)));
                float4 _BlendTex_var = tex2D(_BlendTex,TRANSFORM_TEX(node_2136, _BlendTex));
                float4 node_5653 = _Time + _TimeEditor;
                float2 node_3799 = (i.uv0+(node_5653.r*_BlendTex2_Speed)*float2(1,1));
                float4 _BlendTex2_var = tex2D(_BlendTex2,TRANSFORM_TEX(node_3799, _BlendTex2));
                float3 node_436 = saturate(pow(((_BlendTex_var.rgb*_BlendTex_var.a*_BlendTex2_var.rgb*_BlendTex2_var.a)*_LightPower),_BlendPower));
                float3 emissive = (((_Color.rgb*_MainTex_var.rgb)*_MainTex_Power)+lerp(_BlendColor2.rgb,_BlendColor.rgb,node_436));
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,(_Color.a*(saturate((_MainTex_var.a+_MainTex_Alpha))+node_436.r)));
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA * _ColorAlpha * _Alpha;
            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
