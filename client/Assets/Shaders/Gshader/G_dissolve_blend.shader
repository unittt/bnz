// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:32800,y:32711,varname:node_3138,prsc:2|emission-9612-OUT,alpha-931-OUT;n:type:ShaderForge.SFN_Tex2d,id:4077,x:31473,y:32852,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_4077,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:db36219cc3b6b4142a31bc09becfc16d,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Color,id:876,x:31976,y:32468,ptovrint:False,ptlb:MainColor,ptin:_MainColor,varname:node_876,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:9612,x:32239,y:32605,varname:node_9612,prsc:2|A-876-RGB,B-2156-RGB,C-4077-RGB,D-1726-OUT;n:type:ShaderForge.SFN_VertexColor,id:2156,x:31976,y:32634,varname:node_2156,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:1726,x:32043,y:32806,ptovrint:False,ptlb:MainTex_Power,ptin:_MainTex_Power,varname:node_1726,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:3;n:type:ShaderForge.SFN_Step,id:9142,x:32137,y:32956,varname:node_9142,prsc:2|A-5999-OUT,B-312-OUT;n:type:ShaderForge.SFN_OneMinus,id:8999,x:32316,y:32986,varname:node_8999,prsc:2|IN-9142-OUT;n:type:ShaderForge.SFN_Multiply,id:931,x:32523,y:32943,varname:node_931,prsc:2|A-4077-A,B-8999-OUT;n:type:ShaderForge.SFN_VertexColor,id:5452,x:31411,y:33153,varname:node_5452,prsc:2;n:type:ShaderForge.SFN_OneMinus,id:3623,x:31614,y:33153,varname:node_3623,prsc:2|IN-5452-A;n:type:ShaderForge.SFN_Slider,id:9849,x:31581,y:33023,ptovrint:False,ptlb:diss_amount,ptin:_diss_amount,varname:node_9849,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-0.01,cur:-0.01,max:1;n:type:ShaderForge.SFN_SwitchProperty,id:312,x:31953,y:33099,ptovrint:False,ptlb:particle_control(A),ptin:_particle_controlA,varname:node_312,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-9849-OUT,B-108-OUT;n:type:ShaderForge.SFN_RemapRange,id:108,x:31791,y:33153,varname:node_108,prsc:2,frmn:0,frmx:1,tomn:-0.01,tomx:1|IN-3623-OUT;n:type:ShaderForge.SFN_Multiply,id:5999,x:31920,y:32943,varname:node_5999,prsc:2|A-9537-OUT,B-4077-A;n:type:ShaderForge.SFN_Desaturate,id:9537,x:31716,y:32869,varname:node_9537,prsc:2|COL-4077-RGB;proporder:876-4077-1726-9849-312;pass:END;sub:END;*/

Shader "G/G_dissolve_blend" {
    Properties {
        _MainColor ("MainColor", Color) = (0.5,0.5,0.5,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _MainTex_Power ("MainTex_Power", Float ) = 3
        _diss_amount ("diss_amount", Range(-0.01, 1)) = -0.01
        [MaterialToggle] _particle_controlA ("particle_control(A)", Float ) = -0.01
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
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            //#pragma multi_compile_fwdbase
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _MainColor;
            uniform float _MainTex_Power;
            uniform float _diss_amount;
            uniform fixed _particle_controlA;
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
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float3 emissive = (_MainColor.rgb*i.vertexColor.rgb*_MainTex_var.rgb*_MainTex_Power);
                float3 finalColor = emissive;
                return fixed4(finalColor,(_MainTex_var.a*(1.0 - step((dot(_MainTex_var.rgb,float3(0.3,0.59,0.11))*_MainTex_var.a),lerp( _diss_amount, ((1.0 - i.vertexColor.a)*1.01+-0.01), _particle_controlA )))));
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
