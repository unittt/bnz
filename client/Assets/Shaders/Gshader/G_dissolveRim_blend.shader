// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:True,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33551,y:32711,varname:node_3138,prsc:2|emission-9195-OUT,alpha-9079-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:31624,y:32313,ptovrint:False,ptlb:ColorIn,ptin:_ColorIn,varname:node_7241,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.4411765,c2:0.4411765,c3:0.4411765,c4:1;n:type:ShaderForge.SFN_Fresnel,id:5445,x:31724,y:32679,varname:node_5445,prsc:2|EXP-9730-OUT;n:type:ShaderForge.SFN_VertexColor,id:6009,x:31970,y:33025,varname:node_6009,prsc:2;n:type:ShaderForge.SFN_Multiply,id:974,x:32297,y:32897,varname:node_974,prsc:2|A-5415-OUT,B-6009-A;n:type:ShaderForge.SFN_Lerp,id:7734,x:32201,y:32711,varname:node_7734,prsc:2|A-7241-RGB,B-8039-RGB,T-4569-OUT;n:type:ShaderForge.SFN_Color,id:8039,x:31624,y:32507,ptovrint:False,ptlb:ColorOut,ptin:_ColorOut,varname:node_8039,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.8676471,c2:0.8676471,c3:0.8676471,c4:1;n:type:ShaderForge.SFN_Slider,id:1089,x:31467,y:33022,ptovrint:False,ptlb:rim_Alpha,ptin:_rim_Alpha,varname:node_1089,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Lerp,id:5415,x:32048,y:32826,varname:node_5415,prsc:2|A-4569-OUT,B-1207-OUT,T-1089-OUT;n:type:ShaderForge.SFN_Vector1,id:1207,x:31833,y:32826,varname:node_1207,prsc:2,v1:1;n:type:ShaderForge.SFN_Slider,id:9730,x:31340,y:32740,ptovrint:False,ptlb:rimedge_Power,ptin:_rimedge_Power,varname:node_9730,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0.5,cur:0.5,max:3;n:type:ShaderForge.SFN_Tex2d,id:7209,x:31144,y:33329,ptovrint:False,ptlb:dissolveTex,ptin:_dissolveTex,varname:node_7209,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:b9a7f5fb90567434992ff4737f365378,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Slider,id:6786,x:30804,y:33544,ptovrint:False,ptlb:diss_Amount,ptin:_diss_Amount,varname:node_6786,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:2;n:type:ShaderForge.SFN_Subtract,id:2924,x:31511,y:33346,varname:node_2924,prsc:2|A-2883-OUT,B-2477-OUT;n:type:ShaderForge.SFN_Add,id:6654,x:31719,y:33280,varname:node_6654,prsc:2|A-3006-OUT,B-2924-OUT;n:type:ShaderForge.SFN_Clamp01,id:3293,x:32103,y:33282,varname:node_3293,prsc:2|IN-6654-OUT;n:type:ShaderForge.SFN_Vector1,id:3006,x:31277,y:33242,varname:node_3006,prsc:2,v1:1;n:type:ShaderForge.SFN_Step,id:3623,x:31961,y:33494,varname:node_3623,prsc:2|A-6654-OUT,B-8419-OUT;n:type:ShaderForge.SFN_Vector1,id:8419,x:31567,y:33537,varname:node_8419,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Subtract,id:8236,x:32147,y:33568,varname:node_8236,prsc:2|A-8137-OUT,B-3623-OUT;n:type:ShaderForge.SFN_Step,id:8137,x:31961,y:33634,varname:node_8137,prsc:2|A-6654-OUT,B-861-OUT;n:type:ShaderForge.SFN_ValueProperty,id:294,x:31448,y:33787,ptovrint:False,ptlb:dissEdge_Width,ptin:_dissEdge_Width,varname:node_294,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Add,id:861,x:31804,y:33686,varname:node_861,prsc:2|A-8419-OUT,B-4955-OUT;n:type:ShaderForge.SFN_Add,id:7895,x:32835,y:32688,varname:node_7895,prsc:2|A-7734-OUT,B-1352-OUT;n:type:ShaderForge.SFN_Divide,id:4955,x:31630,y:33787,varname:node_4955,prsc:2|A-294-OUT,B-5544-OUT;n:type:ShaderForge.SFN_Vector1,id:5544,x:31429,y:33873,varname:node_5544,prsc:2,v1:100;n:type:ShaderForge.SFN_Color,id:76,x:32279,y:33119,ptovrint:False,ptlb:dissEdge_Color,ptin:_dissEdge_Color,varname:node_76,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Add,id:1765,x:32986,y:32978,varname:node_1765,prsc:2|A-974-OUT,B-3313-OUT;n:type:ShaderForge.SFN_Clamp01,id:3313,x:32315,y:33485,varname:node_3313,prsc:2|IN-8236-OUT;n:type:ShaderForge.SFN_Tex2d,id:8926,x:32476,y:32266,ptovrint:False,ptlb:blendTex,ptin:_blendTex,varname:node_8926,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:1a1992c76cf9d75479ecc734a7216892,ntxv:0,isnm:False|UVIN-7973-OUT;n:type:ShaderForge.SFN_TexCoord,id:4311,x:32006,y:31882,varname:node_4311,prsc:2,uv:0;n:type:ShaderForge.SFN_Panner,id:4349,x:32275,y:31948,varname:node_4349,prsc:2,spu:1,spv:0|UVIN-4311-UVOUT,DIST-8152-OUT;n:type:ShaderForge.SFN_Time,id:215,x:31916,y:32054,varname:node_215,prsc:2;n:type:ShaderForge.SFN_Multiply,id:8152,x:32099,y:32055,varname:node_8152,prsc:2|A-215-TSL,B-489-OUT;n:type:ShaderForge.SFN_ValueProperty,id:489,x:31916,y:32196,ptovrint:False,ptlb:blendTex_Speed,ptin:_blendTex_Speed,varname:node_489,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Panner,id:7711,x:32275,y:32123,varname:node_7711,prsc:2,spu:0,spv:1|UVIN-4311-UVOUT,DIST-8152-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:7973,x:32476,y:32062,ptovrint:False,ptlb:U/V_switch,ptin:_UV_switch,varname:node_7973,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-4349-UVOUT,B-7711-UVOUT;n:type:ShaderForge.SFN_Multiply,id:1352,x:32670,y:32422,varname:node_1352,prsc:2|A-8926-RGB,B-1042-RGB,C-8926-A,D-7675-OUT;n:type:ShaderForge.SFN_Color,id:1042,x:32476,y:32475,ptovrint:False,ptlb:blendTex_Color,ptin:_blendTex_Color,varname:node_1042,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_ValueProperty,id:7675,x:32476,y:32651,ptovrint:False,ptlb:blendTex_Power,ptin:_blendTex_Power,varname:node_7675,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Clamp01,id:9182,x:33016,y:32688,varname:node_9182,prsc:2|IN-7895-OUT;n:type:ShaderForge.SFN_Multiply,id:2883,x:31330,y:33346,varname:node_2883,prsc:2|A-7209-R,B-7209-A;n:type:ShaderForge.SFN_Lerp,id:9195,x:33243,y:32788,varname:node_9195,prsc:2|A-9182-OUT,B-76-RGB,T-3313-OUT;n:type:ShaderForge.SFN_Clamp01,id:4569,x:31855,y:32709,varname:node_4569,prsc:2|IN-5445-OUT;n:type:ShaderForge.SFN_Step,id:4397,x:32986,y:33142,varname:node_4397,prsc:2|A-2706-OUT,B-2212-OUT;n:type:ShaderForge.SFN_Vector1,id:2212,x:32295,y:33393,varname:node_2212,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Multiply,id:9079,x:33219,y:33024,varname:node_9079,prsc:2|A-1765-OUT,B-4397-OUT,C-7509-OUT;n:type:ShaderForge.SFN_OneMinus,id:2706,x:32457,y:33253,varname:node_2706,prsc:2|IN-3293-OUT;n:type:ShaderForge.SFN_Slider,id:7509,x:32862,y:33307,ptovrint:False,ptlb:Alpha,ptin:_Alpha,varname:node_7509,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:1,cur:1,max:0;n:type:ShaderForge.SFN_SwitchProperty,id:2477,x:31180,y:33620,ptovrint:False,ptlb:particleControl,ptin:_particleControl,varname:node_2477,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-6786-OUT,B-7949-OUT;n:type:ShaderForge.SFN_VertexColor,id:8497,x:30804,y:33725,varname:node_8497,prsc:2;n:type:ShaderForge.SFN_OneMinus,id:7949,x:30992,y:33725,varname:node_7949,prsc:2|IN-8497-A;proporder:7509-7241-8039-1089-9730-7209-6786-76-294-8926-1042-7973-489-7675-2477;pass:END;sub:END;*/

Shader "G/G_dissolveRim_blend" {
    Properties {
        _Alpha ("Alpha", Range(1, 0)) = 1
        _ColorIn ("ColorIn", Color) = (0.4411765,0.4411765,0.4411765,1)
        _ColorOut ("ColorOut", Color) = (0.8676471,0.8676471,0.8676471,1)
        _rim_Alpha ("rim_Alpha", Range(0, 1)) = 0
        _rimedge_Power ("rimedge_Power", Range(0.5, 3)) = 0.5
        _dissolveTex ("dissolveTex", 2D) = "white" {}
        _diss_Amount ("diss_Amount", Range(0, 2)) = 0
        _dissEdge_Color ("dissEdge_Color", Color) = (0.5,0.5,0.5,1)
        _dissEdge_Width ("dissEdge_Width", Float ) = 1
        _blendTex ("blendTex", 2D) = "white" {}
        _blendTex_Color ("blendTex_Color", Color) = (0.5,0.5,0.5,1)
        [MaterialToggle] _UV_switch ("U/V_switch", Float ) = 0
        _blendTex_Speed ("blendTex_Speed", Float ) = 1
        _blendTex_Power ("blendTex_Power", Float ) = 1
        [MaterialToggle] _particleControl ("particleControl", Float ) = 0
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
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            //#pragma multi_compile_fwdbase
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 2.0
            uniform float4 _TimeEditor;
            uniform float4 _ColorIn;
            uniform float4 _ColorOut;
            uniform float _rim_Alpha;
            uniform float _rimedge_Power;
            uniform sampler2D _dissolveTex; uniform float4 _dissolveTex_ST;
            uniform float _diss_Amount;
            uniform float _dissEdge_Width;
            uniform float4 _dissEdge_Color;
            uniform sampler2D _blendTex; uniform float4 _blendTex_ST;
            uniform float _blendTex_Speed;
            uniform fixed _UV_switch;
            uniform float4 _blendTex_Color;
            uniform float _blendTex_Power;
            uniform float _Alpha;
            uniform fixed _particleControl;
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
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                float node_4569 = saturate(pow(1.0-max(0,dot(normalDirection, viewDirection)),_rimedge_Power));
                float4 node_215 = _Time + _TimeEditor;
                float node_8152 = (node_215.r*_blendTex_Speed);
                float2 _UV_switch_var = lerp( (i.uv0+node_8152*float2(1,0)), (i.uv0+node_8152*float2(0,1)), _UV_switch );
                float4 _blendTex_var = tex2D(_blendTex,TRANSFORM_TEX(_UV_switch_var, _blendTex));
                float4 _dissolveTex_var = tex2D(_dissolveTex,TRANSFORM_TEX(i.uv0, _dissolveTex));
                float node_6654 = (1.0+((_dissolveTex_var.r*_dissolveTex_var.a)-lerp( _diss_Amount, (1.0 - i.vertexColor.a), _particleControl )));
                float node_8419 = 0.5;
                float node_3313 = saturate((step(node_6654,(node_8419+(_dissEdge_Width/100.0)))-step(node_6654,node_8419)));
                float3 emissive = lerp(saturate((lerp(_ColorIn.rgb,_ColorOut.rgb,node_4569)+(_blendTex_var.rgb*_blendTex_Color.rgb*_blendTex_var.a*_blendTex_Power))),_dissEdge_Color.rgb,node_3313);
                float3 finalColor = emissive;
                return fixed4(finalColor,(((lerp(node_4569,1.0,_rim_Alpha)*i.vertexColor.a)+node_3313)*step((1.0 - saturate(node_6654)),0.5)*_Alpha));
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
