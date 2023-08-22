// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:14,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:5627,x:33763,y:32811,varname:node_5627,prsc:2|emission-681-OUT,alpha-9078-OUT;n:type:ShaderForge.SFN_Tex2d,id:9959,x:32587,y:32713,ptovrint:False,ptlb:Spread_TEX,ptin:_Spread_TEX,varname:node_8590,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:cf06fda7585047f4bae76ed280019d45,ntxv:0,isnm:False|UVIN-2146-OUT;n:type:ShaderForge.SFN_TexCoord,id:3482,x:30803,y:32540,varname:node_3482,prsc:2,uv:0;n:type:ShaderForge.SFN_Vector1,id:5569,x:30747,y:32792,varname:node_5569,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Lerp,id:9220,x:31757,y:32767,varname:node_9220,prsc:2|A-6550-OUT,B-5569-OUT,T-5585-A;n:type:ShaderForge.SFN_Add,id:6550,x:31577,y:32647,varname:node_6550,prsc:2|A-3482-UVOUT,B-7430-OUT;n:type:ShaderForge.SFN_Subtract,id:9167,x:31048,y:32668,varname:node_9167,prsc:2|A-3482-UVOUT,B-5569-OUT;n:type:ShaderForge.SFN_Divide,id:7430,x:31316,y:32685,varname:node_7430,prsc:2|A-9167-OUT,B-5585-A;n:type:ShaderForge.SFN_Clamp01,id:2146,x:32414,y:32713,varname:node_2146,prsc:2|IN-1262-UVOUT;n:type:ShaderForge.SFN_VertexColor,id:5585,x:30707,y:32932,varname:node_5585,prsc:2;n:type:ShaderForge.SFN_Multiply,id:9168,x:32975,y:32826,varname:node_9168,prsc:2|A-9959-RGB,B-4515-RGB,C-2779-RGB;n:type:ShaderForge.SFN_Tex2d,id:4515,x:32568,y:32914,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_3584,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Color,id:2779,x:32587,y:33124,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_4409,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_ValueProperty,id:5817,x:32975,y:32980,ptovrint:False,ptlb:Lighting Levels,ptin:_LightingLevels,varname:node_5046,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Multiply,id:681,x:33235,y:32870,varname:node_681,prsc:2|A-9168-OUT,B-4515-A,C-5817-OUT;n:type:ShaderForge.SFN_Multiply,id:9078,x:33196,y:33077,varname:node_9078,prsc:2|A-4011-OUT,B-9959-A,C-4515-A,D-9219-OUT;n:type:ShaderForge.SFN_ValueProperty,id:9219,x:32829,y:33197,ptovrint:False,ptlb:ALPHA,ptin:_ALPHA,varname:node_9219,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:3;n:type:ShaderForge.SFN_Rotator,id:1262,x:32104,y:32774,varname:node_1262,prsc:2|UVIN-9220-OUT,SPD-3877-OUT;n:type:ShaderForge.SFN_ValueProperty,id:3877,x:31822,y:32990,ptovrint:False,ptlb:Rotate_Speed,ptin:_Rotate_Speed,varname:node_3877,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Step,id:6064,x:32780,y:33614,varname:node_6064,prsc:2|A-7825-OUT,B-4422-OUT;n:type:ShaderForge.SFN_OneMinus,id:4011,x:32959,y:33644,varname:node_4011,prsc:2|IN-6064-OUT;n:type:ShaderForge.SFN_VertexColor,id:9180,x:32054,y:33811,varname:node_9180,prsc:2;n:type:ShaderForge.SFN_OneMinus,id:3789,x:32257,y:33811,varname:node_3789,prsc:2|IN-9180-R;n:type:ShaderForge.SFN_Slider,id:4280,x:32224,y:33681,ptovrint:False,ptlb:diss_amount,ptin:_diss_amount,varname:node_9849,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-0.01,cur:-0.01,max:1;n:type:ShaderForge.SFN_SwitchProperty,id:4422,x:32596,y:33757,ptovrint:False,ptlb:particle_control(R),ptin:_particle_controlR,varname:node_312,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-4280-OUT,B-5812-OUT;n:type:ShaderForge.SFN_RemapRange,id:5812,x:32434,y:33811,varname:node_5812,prsc:2,frmn:0,frmx:1,tomn:-0.01,tomx:1|IN-3789-OUT;n:type:ShaderForge.SFN_Tex2d,id:8554,x:32381,y:33472,ptovrint:False,ptlb:Dissolve_Tex,ptin:_Dissolve_Tex,varname:node_8554,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Desaturate,id:7825,x:32587,y:33472,varname:node_7825,prsc:2|COL-8554-RGB;proporder:4515-5817-2779-9959-9219-3877-4280-4422-8554;pass:END;sub:END;*/

Shader "G/G_Spread_Blend" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _LightingLevels ("Lighting Levels", Float ) = 2
        _Color ("Color", Color) = (0.5,0.5,0.5,1)
        _Spread_TEX ("Spread_TEX", 2D) = "white" {}
        _ALPHA ("ALPHA", Float ) = 3
        _Rotate_Speed ("Rotate_Speed", Float ) = 0
        _diss_amount ("diss_amount", Range(-0.01, 1)) = -0.01
        [MaterialToggle] _particle_controlR ("particle_control(R)", Float ) = -0.01
        _Dissolve_Tex ("Dissolve_Tex", 2D) = "white" {}
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            ColorMask RGB
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            //#pragma multi_compile_fwdbase
            //#pragma multi_compile_fog
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            //#pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _Spread_TEX; uniform float4 _Spread_TEX_ST;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _Color;
            uniform float _LightingLevels;
            uniform float _ALPHA;
            uniform float _Rotate_Speed;
            uniform float _diss_amount;
            uniform fixed _particle_controlR;
            uniform sampler2D _Dissolve_Tex; uniform float4 _Dissolve_Tex_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                float4 node_2637 = _Time + _TimeEditor;
                float node_1262_ang = node_2637.g;
                float node_1262_spd = _Rotate_Speed;
                float node_1262_cos = cos(node_1262_spd*node_1262_ang);
                float node_1262_sin = sin(node_1262_spd*node_1262_ang);
                float2 node_1262_piv = float2(0.5,0.5);
                float node_5569 = 0.5;
                float2 node_1262 = (mul(lerp((i.uv0+((i.uv0-node_5569)/i.vertexColor.a)),float2(node_5569,node_5569),i.vertexColor.a)-node_1262_piv,float2x2( node_1262_cos, -node_1262_sin, node_1262_sin, node_1262_cos))+node_1262_piv);
                float2 node_2146 = saturate(node_1262);
                float4 _Spread_TEX_var = tex2D(_Spread_TEX,TRANSFORM_TEX(node_2146, _Spread_TEX));
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float3 emissive = ((_Spread_TEX_var.rgb*_MainTex_var.rgb*_Color.rgb)*_MainTex_var.a*_LightingLevels);
                float3 finalColor = emissive;
                float4 _Dissolve_Tex_var = tex2D(_Dissolve_Tex,TRANSFORM_TEX(i.uv0, _Dissolve_Tex));
                fixed4 finalRGBA = fixed4(finalColor,((1.0 - step(dot(_Dissolve_Tex_var.rgb,float3(0.3,0.59,0.11)),lerp( _diss_amount, ((1.0 - i.vertexColor.r)*1.01+-0.01), _particle_controlR )))*_Spread_TEX_var.a*_MainTex_var.a*_ALPHA));
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
