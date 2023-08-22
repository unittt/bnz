// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:32954,y:32691,varname:node_3138,prsc:2|emission-3271-OUT,alpha-931-OUT;n:type:ShaderForge.SFN_Tex2d,id:4077,x:31332,y:32995,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_4077,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:5d727a2a7c2ec15438dd9fe0b443596c,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Color,id:876,x:31706,y:32341,ptovrint:False,ptlb:MainColor,ptin:_MainColor,varname:node_876,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_VertexColor,id:2156,x:32474,y:32849,varname:node_2156,prsc:2;n:type:ShaderForge.SFN_Add,id:9159,x:32216,y:32555,varname:node_9159,prsc:2|A-876-RGB,B-1726-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1726,x:31971,y:32688,ptovrint:False,ptlb:Glow_Level,ptin:_Glow_Level,varname:node_1726,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Step,id:9142,x:32337,y:33230,varname:node_9142,prsc:2|A-2338-OUT,B-312-OUT;n:type:ShaderForge.SFN_OneMinus,id:8999,x:32507,y:33230,varname:node_8999,prsc:2|IN-9142-OUT;n:type:ShaderForge.SFN_Multiply,id:931,x:32717,y:33165,varname:node_931,prsc:2|A-4077-A,B-8999-OUT;n:type:ShaderForge.SFN_VertexColor,id:5452,x:30081,y:33755,varname:node_5452,prsc:2;n:type:ShaderForge.SFN_OneMinus,id:3623,x:30284,y:33755,varname:node_3623,prsc:2|IN-5452-A;n:type:ShaderForge.SFN_Slider,id:9849,x:30081,y:33586,ptovrint:False,ptlb:diss_amount,ptin:_diss_amount,varname:node_9849,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-0.05,cur:0.399283,max:1;n:type:ShaderForge.SFN_SwitchProperty,id:312,x:30623,y:33701,ptovrint:False,ptlb:particle_control(A),ptin:_particle_controlA,varname:node_312,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-9849-OUT,B-108-OUT;n:type:ShaderForge.SFN_RemapRange,id:108,x:30461,y:33755,varname:node_108,prsc:2,frmn:0,frmx:1,tomn:-0.05,tomx:1|IN-3623-OUT;n:type:ShaderForge.SFN_Lerp,id:7720,x:32474,y:32689,varname:node_7720,prsc:2|A-9159-OUT,B-8890-RGB,T-4077-R;n:type:ShaderForge.SFN_Color,id:8890,x:31971,y:32265,ptovrint:False,ptlb:Outline_Colr,ptin:_Outline_Colr,varname:node_8890,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Tex2d,id:575,x:30235,y:32931,ptovrint:False,ptlb:dissolve_Tex,ptin:_dissolve_Tex,varname:node_575,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Subtract,id:2469,x:30803,y:33142,varname:node_2469,prsc:2|A-2811-OUT,B-312-OUT;n:type:ShaderForge.SFN_OneMinus,id:4663,x:30454,y:32948,varname:node_4663,prsc:2|IN-575-R;n:type:ShaderForge.SFN_Clamp01,id:2338,x:32112,y:33033,varname:node_2338,prsc:2|IN-1099-OUT;n:type:ShaderForge.SFN_Step,id:6991,x:31353,y:33427,varname:node_6991,prsc:2|A-312-OUT,B-2469-OUT;n:type:ShaderForge.SFN_Multiply,id:1099,x:31928,y:33021,varname:node_1099,prsc:2|A-4077-A,B-3291-OUT;n:type:ShaderForge.SFN_Lerp,id:3291,x:31588,y:33304,varname:node_3291,prsc:2|A-7897-OUT,B-5996-OUT,T-4909-OUT;n:type:ShaderForge.SFN_Vector1,id:5996,x:31353,y:33365,varname:node_5996,prsc:2,v1:1;n:type:ShaderForge.SFN_Multiply,id:2811,x:30683,y:32966,varname:node_2811,prsc:2|A-4663-OUT,B-5710-OUT;n:type:ShaderForge.SFN_Vector1,id:5710,x:30459,y:33150,varname:node_5710,prsc:2,v1:2;n:type:ShaderForge.SFN_OneMinus,id:7897,x:30995,y:33338,varname:node_7897,prsc:2|IN-312-OUT;n:type:ShaderForge.SFN_Clamp01,id:4909,x:31160,y:33182,varname:node_4909,prsc:2|IN-2469-OUT;n:type:ShaderForge.SFN_TexCoord,id:8634,x:31650,y:34783,varname:node_8634,prsc:2,uv:0;n:type:ShaderForge.SFN_RemapRange,id:2730,x:32021,y:34783,varname:node_2730,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-8634-U;n:type:ShaderForge.SFN_Abs,id:4649,x:32190,y:34783,varname:node_4649,prsc:2|IN-2730-OUT;n:type:ShaderForge.SFN_OneMinus,id:1558,x:32469,y:34772,varname:node_1558,prsc:2|IN-3813-OUT;n:type:ShaderForge.SFN_Power,id:3813,x:32393,y:34951,varname:node_3813,prsc:2|VAL-4649-OUT,EXP-1101-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1101,x:32140,y:35030,ptovrint:False,ptlb:Mask_amount,ptin:_Mask_amount,varname:node_298,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:50;n:type:ShaderForge.SFN_RemapRange,id:5963,x:32011,y:35112,varname:node_5963,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-8634-V;n:type:ShaderForge.SFN_Abs,id:8006,x:32179,y:35112,varname:node_8006,prsc:2|IN-5963-OUT;n:type:ShaderForge.SFN_OneMinus,id:3847,x:32459,y:35101,varname:node_3847,prsc:2|IN-5754-OUT;n:type:ShaderForge.SFN_Power,id:5754,x:32383,y:35280,varname:node_5754,prsc:2|VAL-8006-OUT,EXP-1101-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:6339,x:32736,y:34798,ptovrint:False,ptlb:Mask_U/V,ptin:_Mask_UV,varname:node_7155,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-1558-OUT,B-3847-OUT;n:type:ShaderForge.SFN_Multiply,id:3271,x:32732,y:32736,varname:node_3271,prsc:2|A-7720-OUT,B-2156-RGB;proporder:876-4077-1726-9849-312-8890-575;pass:END;sub:END;*/

Shader "G/G_dissolve_blend4" {
    Properties {
        _MainColor ("MainColor", Color) = (0.5,0.5,0.5,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _Glow_Level ("Glow_Level", Float ) = 0
        _diss_amount ("diss_amount", Range(-0.05, 1)) = 0.399283
        [MaterialToggle] _particle_controlA ("particle_control(A)", Float ) = 0.399283
        _Outline_Colr ("Outline_Colr", Color) = (1,1,1,1)
        _dissolve_Tex ("dissolve_Tex", 2D) = "white" {}
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
            //#pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _MainColor;
            uniform float _Glow_Level;
            uniform float _diss_amount;
            uniform fixed _particle_controlA;
            uniform float4 _Outline_Colr;
            uniform sampler2D _dissolve_Tex; uniform float4 _dissolve_Tex_ST;
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
                float3 emissive = (lerp((_MainColor.rgb+_Glow_Level),_Outline_Colr.rgb,_MainTex_var.r)*i.vertexColor.rgb);
                float3 finalColor = emissive;
                float _particle_controlA_var = lerp( _diss_amount, ((1.0 - i.vertexColor.a)*1.05+-0.05), _particle_controlA );
                float4 _dissolve_Tex_var = tex2D(_dissolve_Tex,TRANSFORM_TEX(i.uv0, _dissolve_Tex));
                float node_2469 = (((1.0 - _dissolve_Tex_var.r)*2.0)-_particle_controlA_var);
                return fixed4(finalColor,(_MainTex_var.a*(1.0 - step(saturate((_MainTex_var.a*lerp((1.0 - _particle_controlA_var),1.0,saturate(node_2469)))),_particle_controlA_var))));
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
