// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:6,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:True,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33812,y:32689,varname:node_3138,prsc:2|emission-9195-OUT,alpha-7631-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:31624,y:32313,ptovrint:False,ptlb:ColorIn,ptin:_ColorIn,varname:node_7241,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.4411765,c2:0.4411765,c3:0.4411765,c4:1;n:type:ShaderForge.SFN_Fresnel,id:5445,x:31497,y:32695,varname:node_5445,prsc:2|EXP-9730-OUT;n:type:ShaderForge.SFN_Lerp,id:7734,x:32201,y:32711,varname:node_7734,prsc:2|A-7241-RGB,B-8039-RGB,T-8324-OUT;n:type:ShaderForge.SFN_Color,id:8039,x:31624,y:32507,ptovrint:False,ptlb:ColorOut,ptin:_ColorOut,varname:node_8039,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.8676471,c2:0.8676471,c3:0.8676471,c4:1;n:type:ShaderForge.SFN_Slider,id:9730,x:31117,y:32729,ptovrint:False,ptlb:rimedge_Power,ptin:_rimedge_Power,varname:node_9730,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0.5,cur:0.5,max:3;n:type:ShaderForge.SFN_Tex2d,id:7209,x:31144,y:33329,ptovrint:False,ptlb:dissolveTex,ptin:_dissolveTex,varname:node_7209,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:b9a7f5fb90567434992ff4737f365378,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Slider,id:6786,x:30804,y:33544,ptovrint:False,ptlb:diss_Amount,ptin:_diss_Amount,varname:node_6786,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:2;n:type:ShaderForge.SFN_Subtract,id:2924,x:31511,y:33346,varname:node_2924,prsc:2|A-2883-OUT,B-6786-OUT;n:type:ShaderForge.SFN_Add,id:6654,x:31719,y:33280,varname:node_6654,prsc:2|A-3006-OUT,B-2924-OUT;n:type:ShaderForge.SFN_Clamp01,id:3293,x:32103,y:33282,varname:node_3293,prsc:2|IN-6654-OUT;n:type:ShaderForge.SFN_Vector1,id:3006,x:31277,y:33242,varname:node_3006,prsc:2,v1:1;n:type:ShaderForge.SFN_Step,id:3623,x:31961,y:33494,varname:node_3623,prsc:2|A-6654-OUT,B-8419-OUT;n:type:ShaderForge.SFN_Vector1,id:8419,x:31567,y:33537,varname:node_8419,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Subtract,id:8236,x:32147,y:33568,varname:node_8236,prsc:2|A-8137-OUT,B-3623-OUT;n:type:ShaderForge.SFN_Step,id:8137,x:31961,y:33634,varname:node_8137,prsc:2|A-6654-OUT,B-861-OUT;n:type:ShaderForge.SFN_ValueProperty,id:294,x:31448,y:33787,ptovrint:False,ptlb:dissEdge_Width,ptin:_dissEdge_Width,varname:node_294,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Add,id:861,x:31804,y:33686,varname:node_861,prsc:2|A-8419-OUT,B-4955-OUT;n:type:ShaderForge.SFN_Add,id:7895,x:32835,y:32688,varname:node_7895,prsc:2|A-1352-OUT,B-7734-OUT;n:type:ShaderForge.SFN_Divide,id:4955,x:31630,y:33787,varname:node_4955,prsc:2|A-294-OUT,B-5544-OUT;n:type:ShaderForge.SFN_Vector1,id:5544,x:31429,y:33873,varname:node_5544,prsc:2,v1:100;n:type:ShaderForge.SFN_Color,id:76,x:32279,y:33119,ptovrint:False,ptlb:dissEdge_Color,ptin:_dissEdge_Color,varname:node_76,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Clamp01,id:3313,x:32315,y:33485,varname:node_3313,prsc:2|IN-8236-OUT;n:type:ShaderForge.SFN_Tex2d,id:8926,x:32235,y:32188,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_8926,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:1a1992c76cf9d75479ecc734a7216892,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:1352,x:32670,y:32422,varname:node_1352,prsc:2|A-34-OUT,B-1042-RGB,C-8926-A,D-7675-OUT;n:type:ShaderForge.SFN_Color,id:1042,x:32476,y:32464,ptovrint:False,ptlb:MainTex_Color,ptin:_MainTex_Color,varname:node_1042,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_ValueProperty,id:7675,x:32476,y:32651,ptovrint:False,ptlb:MainTex_Power,ptin:_MainTex_Power,varname:node_7675,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Clamp01,id:9182,x:33016,y:32688,varname:node_9182,prsc:2|IN-7895-OUT;n:type:ShaderForge.SFN_Multiply,id:2883,x:31330,y:33346,varname:node_2883,prsc:2|A-7209-R,B-7209-A;n:type:ShaderForge.SFN_Lerp,id:9195,x:33243,y:32788,varname:node_9195,prsc:2|A-9182-OUT,B-76-RGB,T-3313-OUT;n:type:ShaderForge.SFN_Clamp01,id:4569,x:31855,y:32709,varname:node_4569,prsc:2|IN-6481-OUT;n:type:ShaderForge.SFN_Step,id:4397,x:32812,y:33215,varname:node_4397,prsc:2|A-2706-OUT,B-2212-OUT;n:type:ShaderForge.SFN_Vector1,id:2212,x:32295,y:33393,varname:node_2212,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Multiply,id:9079,x:33024,y:33093,varname:node_9079,prsc:2|A-1042-A,B-4397-OUT;n:type:ShaderForge.SFN_OneMinus,id:2706,x:32457,y:33253,varname:node_2706,prsc:2|IN-3293-OUT;n:type:ShaderForge.SFN_Multiply,id:6481,x:31672,y:32829,varname:node_6481,prsc:2|A-5445-OUT,B-1745-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1745,x:31447,y:32907,ptovrint:False,ptlb:rim_Power,ptin:_rim_Power,varname:node_1745,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:8324,x:32035,y:32839,varname:node_8324,prsc:2|A-4569-OUT,B-5458-OUT;n:type:ShaderForge.SFN_Slider,id:5458,x:31615,y:33016,ptovrint:False,ptlb:rim_alpha,ptin:_rim_alpha,varname:node_5458,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:1,cur:1,max:0;n:type:ShaderForge.SFN_Add,id:2136,x:33216,y:32958,varname:node_2136,prsc:2|A-8324-OUT,B-9079-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:136,x:33404,y:33057,ptovrint:False,ptlb:diss_type,ptin:_diss_type,varname:node_136,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-2136-OUT,B-9079-OUT;n:type:ShaderForge.SFN_Tex2d,id:8725,x:33387,y:33229,ptovrint:False,ptlb:MaskTex,ptin:_MaskTex,varname:node_8725,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:7631,x:33605,y:33087,varname:node_7631,prsc:2|A-136-OUT,B-8725-R,C-8725-A,D-3861-A;n:type:ShaderForge.SFN_VertexColor,id:3861,x:33387,y:33429,varname:node_3861,prsc:2;n:type:ShaderForge.SFN_SwitchProperty,id:34,x:32580,y:32218,ptovrint:False,ptlb:Desaturate,ptin:_Desaturate,varname:node_34,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-8926-RGB,B-7254-OUT;n:type:ShaderForge.SFN_Desaturate,id:7254,x:32404,y:32249,varname:node_7254,prsc:2|COL-8926-RGB;proporder:7241-8039-1745-9730-5458-1042-34-8926-7675-7209-136-6786-76-294-8725;pass:END;sub:END;*/

Shader "G/G_dissolveRim_blend2_db" {
    Properties {
        _ColorIn ("ColorIn", Color) = (0.4411765,0.4411765,0.4411765,1)
        _ColorOut ("ColorOut", Color) = (0.8676471,0.8676471,0.8676471,1)
        _rim_Power ("rim_Power", Float ) = 1
        _rimedge_Power ("rimedge_Power", Range(0.5, 3)) = 0.5
        _rim_alpha ("rim_alpha", Range(1, 0)) = 1
        _MainTex_Color ("MainTex_Color", Color) = (0.5,0.5,0.5,1)
        [MaterialToggle] _Desaturate ("Desaturate", Float ) = 0
        _MainTex ("MainTex", 2D) = "white" {}
        _MainTex_Power ("MainTex_Power", Float ) = 1
        _dissolveTex ("dissolveTex", 2D) = "white" {}
        [MaterialToggle] _diss_type ("diss_type", Float ) = 1
        _diss_Amount ("diss_Amount", Range(0, 2)) = 0
        _dissEdge_Color ("dissEdge_Color", Color) = (0.5,0.5,0.5,1)
        _dissEdge_Width ("dissEdge_Width", Float ) = 1
        _MaskTex ("MaskTex", 2D) = "white" {}
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
            ZTest Always
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            //#pragma multi_compile_fwdbase
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            //#pragma target 2.0
            uniform float4 _ColorIn;
            uniform float4 _ColorOut;
            uniform float _rimedge_Power;
            uniform sampler2D _dissolveTex; uniform float4 _dissolveTex_ST;
            uniform float _diss_Amount;
            uniform float _dissEdge_Width;
            uniform float4 _dissEdge_Color;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _MainTex_Color;
            uniform float _MainTex_Power;
            uniform float _rim_Power;
            uniform float _rim_alpha;
            uniform fixed _diss_type;
            uniform sampler2D _MaskTex; uniform float4 _MaskTex_ST;
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
////// Lighting:
////// Emissive:
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float node_8324 = (saturate((pow(1.0-max(0,dot(normalDirection, viewDirection)),_rimedge_Power)*_rim_Power))*_rim_alpha);
                float4 _dissolveTex_var = tex2D(_dissolveTex,TRANSFORM_TEX(i.uv0, _dissolveTex));
                float node_6654 = (1.0+((_dissolveTex_var.r*_dissolveTex_var.a)-_diss_Amount));
                float node_8419 = 0.5;
                float3 emissive = lerp(saturate(((lerp( _MainTex_var.rgb, dot(_MainTex_var.rgb,float3(0.3,0.59,0.11)), _Desaturate )*_MainTex_Color.rgb*_MainTex_var.a*_MainTex_Power)+lerp(_ColorIn.rgb,_ColorOut.rgb,node_8324))),_dissEdge_Color.rgb,saturate((step(node_6654,(node_8419+(_dissEdge_Width/100.0)))-step(node_6654,node_8419))));
                float3 finalColor = emissive;
                float node_9079 = (_MainTex_Color.a*step((1.0 - saturate(node_6654)),0.5));
                float4 _MaskTex_var = tex2D(_MaskTex,TRANSFORM_TEX(i.uv0, _MaskTex));
                return fixed4(finalColor,(lerp( (node_8324+node_9079), node_9079, _diss_type )*_MaskTex_var.r*_MaskTex_var.a*i.vertexColor.a));
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
