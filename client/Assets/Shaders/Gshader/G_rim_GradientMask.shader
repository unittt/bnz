// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33033,y:32599,varname:node_3138,prsc:2|emission-7175-OUT,alpha-2130-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32090,y:32553,ptovrint:False,ptlb:ColorOut,ptin:_ColorOut,varname:node_7241,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.7132353,c2:0.7132353,c3:0.7132353,c4:1;n:type:ShaderForge.SFN_Fresnel,id:5441,x:32090,y:32712,varname:node_5441,prsc:2|EXP-9185-OUT;n:type:ShaderForge.SFN_Slider,id:9185,x:31713,y:32729,ptovrint:False,ptlb:rim_power,ptin:_rim_power,varname:node_9185,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:5;n:type:ShaderForge.SFN_Color,id:803,x:32090,y:32378,ptovrint:False,ptlb:ColorIn,ptin:_ColorIn,varname:node_803,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.2573529,c2:0.2573529,c3:0.2573529,c4:1;n:type:ShaderForge.SFN_Lerp,id:2881,x:32414,y:32618,varname:node_2881,prsc:2|A-803-RGB,B-7241-RGB,T-5441-OUT;n:type:ShaderForge.SFN_Multiply,id:3286,x:32645,y:32704,varname:node_3286,prsc:2|A-2881-OUT,B-413-OUT;n:type:ShaderForge.SFN_ValueProperty,id:413,x:32414,y:32789,ptovrint:False,ptlb:all_power,ptin:_all_power,varname:node_413,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:2130,x:32692,y:32883,varname:node_2130,prsc:2|A-413-OUT,B-3876-OUT,C-6037-OUT;n:type:ShaderForge.SFN_TexCoord,id:445,x:31136,y:33128,varname:node_445,prsc:2,uv:0;n:type:ShaderForge.SFN_Add,id:1635,x:31689,y:33043,varname:node_1635,prsc:2|A-4292-OUT,B-5793-OUT;n:type:ShaderForge.SFN_Slider,id:4895,x:31110,y:32914,ptovrint:False,ptlb:Mask_amount,ptin:_Mask_amount,varname:node_4895,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.5646425,max:1;n:type:ShaderForge.SFN_Clamp01,id:7695,x:31870,y:33029,varname:node_7695,prsc:2|IN-1635-OUT;n:type:ShaderForge.SFN_RemapRange,id:4292,x:31505,y:32912,varname:node_4292,prsc:2,frmn:0,frmx:1,tomn:-0.15,tomx:1|IN-4895-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:5793,x:31414,y:33148,ptovrint:False,ptlb:Mask_U/V,ptin:_Mask_UV,varname:node_5793,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-445-U,B-445-V;n:type:ShaderForge.SFN_OneMinus,id:5757,x:32262,y:33088,varname:node_5757,prsc:2|IN-8274-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:3876,x:32447,y:32985,ptovrint:False,ptlb:Mask_reverse,ptin:_Mask_reverse,varname:node_3876,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-8274-OUT,B-5757-OUT;n:type:ShaderForge.SFN_Tex2d,id:937,x:32408,y:32390,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_937,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Add,id:7175,x:32839,y:32679,varname:node_7175,prsc:2|A-4034-OUT,B-3286-OUT;n:type:ShaderForge.SFN_Color,id:6116,x:32408,y:32217,ptovrint:False,ptlb:MainTex_Color,ptin:_MainTex_Color,varname:node_6116,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:4034,x:32651,y:32466,varname:node_4034,prsc:2|A-6116-RGB,B-937-RGB;n:type:ShaderForge.SFN_Slider,id:9501,x:31723,y:33332,ptovrint:False,ptlb:Mask_GradientWidth,ptin:_Mask_GradientWidth,varname:node_9501,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-50,cur:-50,max:-5;n:type:ShaderForge.SFN_RemapRangeAdvanced,id:8274,x:32072,y:33029,varname:node_8274,prsc:2|IN-7695-OUT,IMIN-5090-OUT,IMAX-8769-OUT,OMIN-9501-OUT,OMAX-8769-OUT;n:type:ShaderForge.SFN_Vector1,id:5090,x:31801,y:33178,varname:node_5090,prsc:2,v1:0;n:type:ShaderForge.SFN_Vector1,id:8769,x:31801,y:33243,varname:node_8769,prsc:2,v1:1;n:type:ShaderForge.SFN_Slider,id:8647,x:31713,y:32886,ptovrint:False,ptlb:alpha_rim_power,ptin:_alpha_rim_power,varname:node_8647,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:3;n:type:ShaderForge.SFN_Fresnel,id:489,x:32090,y:32867,varname:node_489,prsc:2|EXP-8647-OUT;n:type:ShaderForge.SFN_Add,id:6037,x:32447,y:32844,varname:node_6037,prsc:2|A-937-R,B-489-OUT;proporder:7241-803-413-9185-8647-6116-937-4895-9501-5793-3876;pass:END;sub:END;*/

Shader "G/G_rim_GradientMask" {
    Properties {
        _ColorOut ("ColorOut", Color) = (0.7132353,0.7132353,0.7132353,1)
        _ColorIn ("ColorIn", Color) = (0.2573529,0.2573529,0.2573529,1)
        _all_power ("all_power", Float ) = 1
        _rim_power ("rim_power", Range(0, 5)) = 1
        _alpha_rim_power ("alpha_rim_power", Range(0, 3)) = 0
        _MainTex_Color ("MainTex_Color", Color) = (0.5,0.5,0.5,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _Mask_amount ("Mask_amount", Range(0, 1)) = 0.5646425
        _Mask_GradientWidth ("Mask_GradientWidth", Range(-50, -5)) = -50
        [MaterialToggle] _Mask_UV ("Mask_U/V", Float ) = 0
        [MaterialToggle] _Mask_reverse ("Mask_reverse", Float ) = -24.53372
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
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            //#pragma multi_compile_fwdbase
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 2.0
            uniform float4 _ColorOut;
            uniform float _rim_power;
            uniform float4 _ColorIn;
            uniform float _all_power;
            uniform float _Mask_amount;
            uniform fixed _Mask_UV;
            uniform fixed _Mask_reverse;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _MainTex_Color;
            uniform float _Mask_GradientWidth;
            uniform float _alpha_rim_power;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float3 emissive = ((_MainTex_Color.rgb*_MainTex_var.rgb)+(lerp(_ColorIn.rgb,_ColorOut.rgb,pow(1.0-max(0,dot(normalDirection, viewDirection)),_rim_power))*_all_power));
                float3 finalColor = emissive;
                float node_5090 = 0.0;
                float node_8769 = 1.0;
                float node_8274 = (_Mask_GradientWidth + ( (saturate(((_Mask_amount*1.15+-0.15)+lerp( i.uv0.r, i.uv0.g, _Mask_UV ))) - node_5090) * (node_8769 - _Mask_GradientWidth) ) / (node_8769 - node_5090));
                return fixed4(finalColor,(_all_power*lerp( node_8274, (1.0 - node_8274), _Mask_reverse )*(_MainTex_var.r+pow(1.0-max(0,dot(normalDirection, viewDirection)),_alpha_rim_power))));
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
