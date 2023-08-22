// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:3,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:False,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:True,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:576,x:33192,y:32668,varname:node_576,prsc:2|emission-7612-OUT,alpha-6739-OUT;n:type:ShaderForge.SFN_Tex2d,id:276,x:32253,y:32673,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_276,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-8395-OUT;n:type:ShaderForge.SFN_Multiply,id:7612,x:32804,y:32792,varname:node_7612,prsc:2|A-9579-OUT,B-7308-RGB,C-9427-RGB,D-1876-OUT;n:type:ShaderForge.SFN_Tex2d,id:9898,x:30620,y:32638,ptovrint:False,ptlb:DistortTex,ptin:_DistortTex,varname:node_9898,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7acc33f24a06fcd46baa112415b42195,ntxv:0,isnm:False|UVIN-8089-OUT;n:type:ShaderForge.SFN_VertexColor,id:7308,x:32497,y:32931,varname:node_7308,prsc:2;n:type:ShaderForge.SFN_Color,id:9427,x:32484,y:33228,ptovrint:False,ptlb:MainColor,ptin:_MainColor,varname:node_9427,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:6739,x:32825,y:32933,varname:node_6739,prsc:2|A-276-A,B-7308-A,C-9427-A,D-5696-OUT;n:type:ShaderForge.SFN_Add,id:1055,x:31623,y:32832,varname:node_1055,prsc:2|A-6163-V,B-3252-OUT;n:type:ShaderForge.SFN_TexCoord,id:6163,x:31408,y:32621,varname:node_6163,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:3252,x:31384,y:32849,varname:node_3252,prsc:2|A-336-OUT,B-3904-OUT;n:type:ShaderForge.SFN_ValueProperty,id:3904,x:31166,y:33085,ptovrint:False,ptlb:Distort_PowerY,ptin:_Distort_PowerY,varname:node_3904,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.1;n:type:ShaderForge.SFN_TexCoord,id:5918,x:29778,y:32646,varname:node_5918,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:4408,x:29875,y:32856,varname:node_4408,prsc:2|A-8137-T,B-496-OUT;n:type:ShaderForge.SFN_Time,id:8137,x:29658,y:32804,varname:node_8137,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:496,x:29658,y:33002,ptovrint:False,ptlb:Speed_Y,ptin:_Speed_Y,varname:node_496,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.2;n:type:ShaderForge.SFN_ValueProperty,id:1876,x:32484,y:33103,ptovrint:False,ptlb:MainTex_Power,ptin:_MainTex_Power,varname:node_1876,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Add,id:6942,x:30098,y:32875,varname:node_6942,prsc:2|A-5918-V,B-4408-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1263,x:29604,y:32508,ptovrint:False,ptlb:Speed_X,ptin:_Speed_X,varname:_sudu_Z,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.2;n:type:ShaderForge.SFN_Multiply,id:5785,x:29821,y:32416,varname:node_5785,prsc:2|A-6244-T,B-1263-OUT;n:type:ShaderForge.SFN_Time,id:6244,x:29604,y:32364,varname:node_6244,prsc:2;n:type:ShaderForge.SFN_Add,id:7908,x:30067,y:32465,varname:node_7908,prsc:2|A-5785-OUT,B-5918-U;n:type:ShaderForge.SFN_Append,id:8089,x:30383,y:32638,varname:node_8089,prsc:2|A-7908-OUT,B-6942-OUT;n:type:ShaderForge.SFN_TexCoord,id:5715,x:29963,y:33316,varname:node_5715,prsc:2,uv:0;n:type:ShaderForge.SFN_ComponentMask,id:2914,x:30421,y:33320,varname:node_2914,prsc:2,cc1:0,cc2:-1,cc3:-1,cc4:-1|IN-4048-UVOUT;n:type:ShaderForge.SFN_Add,id:6158,x:30548,y:33181,varname:node_6158,prsc:2|A-2598-OUT,B-2914-OUT;n:type:ShaderForge.SFN_Slider,id:2598,x:30132,y:33177,ptovrint:False,ptlb:Dist_Mask_Amount,ptin:_Dist_Mask_Amount,varname:node_2598,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:1,max:1;n:type:ShaderForge.SFN_Clamp01,id:7705,x:30748,y:33164,varname:node_7705,prsc:2|IN-6158-OUT;n:type:ShaderForge.SFN_Power,id:6805,x:30977,y:33207,varname:node_6805,prsc:2|VAL-7705-OUT,EXP-1798-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1798,x:30755,y:33353,ptovrint:False,ptlb:Dist_Mask_Power,ptin:_Dist_Mask_Power,varname:node_1798,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:5;n:type:ShaderForge.SFN_Multiply,id:336,x:31166,y:32875,varname:node_336,prsc:2|A-3097-OUT,B-9898-A,C-6805-OUT;n:type:ShaderForge.SFN_Rotator,id:4048,x:30233,y:33390,varname:node_4048,prsc:2|UVIN-5715-UVOUT,ANG-6070-OUT;n:type:ShaderForge.SFN_Slider,id:8849,x:29553,y:33532,ptovrint:False,ptlb:Dist_Mask_Rotate,ptin:_Dist_Mask_Rotate,varname:node_8849,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Multiply,id:6070,x:29904,y:33539,varname:node_6070,prsc:2|A-8849-OUT,B-2337-OUT,C-1323-OUT;n:type:ShaderForge.SFN_Vector1,id:2337,x:29692,y:33633,varname:node_2337,prsc:2,v1:2;n:type:ShaderForge.SFN_Pi,id:1323,x:29708,y:33734,varname:node_1323,prsc:2;n:type:ShaderForge.SFN_Max,id:3097,x:30938,y:32671,varname:node_3097,prsc:2|A-9898-R,B-9898-G,C-9898-B;n:type:ShaderForge.SFN_Multiply,id:8451,x:31428,y:32434,varname:node_8451,prsc:2|A-6578-OUT,B-336-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6578,x:31179,y:32455,ptovrint:False,ptlb:Distort_PowerX,ptin:_Distort_PowerX,varname:_Distort_PowerY_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.1;n:type:ShaderForge.SFN_Add,id:1074,x:31605,y:32610,varname:node_1074,prsc:2|A-8451-OUT,B-6163-U;n:type:ShaderForge.SFN_Append,id:8395,x:31893,y:32759,varname:node_8395,prsc:2|A-1074-OUT,B-1055-OUT;n:type:ShaderForge.SFN_TexCoord,id:2249,x:31382,y:33794,varname:node_2249,prsc:2,uv:0;n:type:ShaderForge.SFN_RemapRange,id:286,x:31753,y:33794,varname:node_286,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-2249-U;n:type:ShaderForge.SFN_Abs,id:5397,x:31922,y:33794,varname:node_5397,prsc:2|IN-286-OUT;n:type:ShaderForge.SFN_OneMinus,id:7339,x:32201,y:33783,varname:node_7339,prsc:2|IN-8715-OUT;n:type:ShaderForge.SFN_Power,id:8715,x:32125,y:33962,varname:node_8715,prsc:2|VAL-5397-OUT,EXP-6402-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6402,x:31872,y:34041,ptovrint:False,ptlb:Mask_Amount,ptin:_Mask_Amount,varname:node_298,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:50;n:type:ShaderForge.SFN_RemapRange,id:8379,x:31743,y:34123,varname:node_8379,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-2249-V;n:type:ShaderForge.SFN_Abs,id:5148,x:31911,y:34123,varname:node_5148,prsc:2|IN-8379-OUT;n:type:ShaderForge.SFN_OneMinus,id:743,x:32191,y:34112,varname:node_743,prsc:2|IN-4588-OUT;n:type:ShaderForge.SFN_Power,id:4588,x:32115,y:34291,varname:node_4588,prsc:2|VAL-5148-OUT,EXP-6402-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:5696,x:32468,y:33809,ptovrint:False,ptlb:Mask_U/V,ptin:_Mask_UV,varname:node_7155,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-7339-OUT,B-743-OUT;n:type:ShaderForge.SFN_Desaturate,id:927,x:32439,y:32530,varname:node_927,prsc:2|COL-276-RGB;n:type:ShaderForge.SFN_SwitchProperty,id:9579,x:32638,y:32645,ptovrint:False,ptlb:Desaturate,ptin:_Desaturate,varname:node_9579,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-276-RGB,B-927-OUT;proporder:9427-276-9579-1876-9898-6578-3904-1263-496-8849-2598-1798-6402-5696;pass:END;sub:END;*/

Shader "G/G_distort_Mask_Blend" {
    Properties {
        _MainColor ("MainColor", Color) = (0.5,0.5,0.5,1)
        _MainTex ("MainTex", 2D) = "white" {}
        [MaterialToggle] _Desaturate ("Desaturate", Float ) = 0
        _MainTex_Power ("MainTex_Power", Float ) = 2
        _DistortTex ("DistortTex", 2D) = "white" {}
        _Distort_PowerX ("Distort_PowerX", Float ) = 0.1
        _Distort_PowerY ("Distort_PowerY", Float ) = 0.1
        _Speed_X ("Speed_X", Float ) = 0.2
        _Speed_Y ("Speed_Y", Float ) = 0.2
        _Dist_Mask_Rotate ("Dist_Mask_Rotate", Range(0, 1)) = 0
        _Dist_Mask_Amount ("Dist_Mask_Amount", Range(-1, 1)) = 1
        _Dist_Mask_Power ("Dist_Mask_Power", Float ) = 5
        _Mask_Amount ("Mask_Amount", Float ) = 50
        [MaterialToggle] _Mask_UV ("Mask_U/V", Float ) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
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
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            //#pragma multi_compile_fwdbase_fullshadows
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 2.0
            uniform float4 _TimeEditor;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _DistortTex; uniform float4 _DistortTex_ST;
            uniform float4 _MainColor;
            uniform float _Distort_PowerY;
            uniform float _Speed_Y;
            uniform float _MainTex_Power;
            uniform float _Speed_X;
            uniform float _Dist_Mask_Amount;
            uniform float _Dist_Mask_Power;
            uniform float _Dist_Mask_Rotate;
            uniform float _Distort_PowerX;
            uniform float _Mask_Amount;
            uniform fixed _Mask_UV;
            uniform fixed _Desaturate;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
////// Lighting:
////// Emissive:
                float4 node_6244 = _Time + _TimeEditor;
                float4 node_8137 = _Time + _TimeEditor;
                float2 node_8089 = float2(((node_6244.g*_Speed_X)+i.uv0.r),(i.uv0.g+(node_8137.g*_Speed_Y)));
                float4 _DistortTex_var = tex2D(_DistortTex,TRANSFORM_TEX(node_8089, _DistortTex));
                float node_4048_ang = (_Dist_Mask_Rotate*2.0*3.141592654);
                float node_4048_spd = 1.0;
                float node_4048_cos = cos(node_4048_spd*node_4048_ang);
                float node_4048_sin = sin(node_4048_spd*node_4048_ang);
                float2 node_4048_piv = float2(0.5,0.5);
                float2 node_4048 = (mul(i.uv0-node_4048_piv,float2x2( node_4048_cos, -node_4048_sin, node_4048_sin, node_4048_cos))+node_4048_piv);
                float node_336 = (max(max(_DistortTex_var.r,_DistortTex_var.g),_DistortTex_var.b)*_DistortTex_var.a*pow(saturate((_Dist_Mask_Amount+node_4048.r)),_Dist_Mask_Power));
                float2 node_8395 = float2(((_Distort_PowerX*node_336)+i.uv0.r),(i.uv0.g+(node_336*_Distort_PowerY)));
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_8395, _MainTex));
                float3 emissive = (lerp( _MainTex_var.rgb, dot(_MainTex_var.rgb,float3(0.3,0.59,0.11)), _Desaturate )*i.vertexColor.rgb*_MainColor.rgb*_MainTex_Power);
                float3 finalColor = emissive;
                return fixed4(finalColor,(_MainTex_var.a*i.vertexColor.a*_MainColor.a*lerp( (1.0 - pow(abs((i.uv0.r*2.0+-1.0)),_Mask_Amount)), (1.0 - pow(abs((i.uv0.g*2.0+-1.0)),_Mask_Amount)), _Mask_UV )));
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
