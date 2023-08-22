// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:3,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:False,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:True,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:576,x:34392,y:32667,varname:node_576,prsc:2|emission-1003-OUT,alpha-9067-OUT;n:type:ShaderForge.SFN_Tex2d,id:276,x:32506,y:32755,ptovrint:False,ptlb:tex,ptin:_tex,varname:node_276,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-1055-OUT;n:type:ShaderForge.SFN_Multiply,id:7612,x:33000,y:32821,varname:node_7612,prsc:2|A-276-RGB,B-7308-RGB,C-9427-RGB,D-1876-OUT;n:type:ShaderForge.SFN_Tex2d,id:9898,x:31920,y:32755,ptovrint:False,ptlb:raodong,ptin:_raodong,varname:node_9898,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-4020-OUT;n:type:ShaderForge.SFN_VertexColor,id:7308,x:32366,y:32916,varname:node_7308,prsc:2;n:type:ShaderForge.SFN_Color,id:9427,x:32479,y:33148,ptovrint:False,ptlb:color,ptin:_color,varname:node_9427,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:6739,x:32920,y:32975,varname:node_6739,prsc:2|A-276-B,B-7308-A,C-9427-A;n:type:ShaderForge.SFN_Add,id:1055,x:32326,y:32755,varname:node_1055,prsc:2|A-6163-UVOUT,B-3252-OUT;n:type:ShaderForge.SFN_TexCoord,id:6163,x:32165,y:32560,varname:node_6163,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:3252,x:32165,y:32772,varname:node_3252,prsc:2|A-9898-R,B-3904-OUT;n:type:ShaderForge.SFN_ValueProperty,id:3904,x:32042,y:32947,ptovrint:False,ptlb:qiangdu,ptin:_qiangdu,varname:node_3904,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.1;n:type:ShaderForge.SFN_TexCoord,id:5918,x:31462,y:32652,varname:node_5918,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:4408,x:31586,y:32868,varname:node_4408,prsc:2|A-8137-T,B-8521-OUT;n:type:ShaderForge.SFN_Time,id:8137,x:31393,y:32827,varname:node_8137,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:1876,x:32337,y:33102,ptovrint:False,ptlb:ZT,ptin:_ZT,varname:node_1876,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_ValueProperty,id:4869,x:31353,y:33115,ptovrint:False,ptlb:U,ptin:_U,varname:node_4869,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:6526,x:31340,y:33198,ptovrint:False,ptlb:V,ptin:_V,varname:node_6526,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Append,id:8521,x:31532,y:33138,varname:node_8521,prsc:2|A-4869-OUT,B-6526-OUT;n:type:ShaderForge.SFN_Add,id:4020,x:31723,y:32701,varname:node_4020,prsc:2|A-5918-UVOUT,B-4408-OUT;n:type:ShaderForge.SFN_TexCoord,id:785,x:32754,y:32403,varname:node_785,prsc:2,uv:0;n:type:ShaderForge.SFN_ConstantClamp,id:2363,x:33034,y:32349,varname:node_2363,prsc:2,min:0,max:1|IN-785-V;n:type:ShaderForge.SFN_Slider,id:4600,x:33018,y:32726,ptovrint:False,ptlb:fanwei_v,ptin:_fanwei_v,varname:node_4600,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:20;n:type:ShaderForge.SFN_OneMinus,id:367,x:33204,y:32528,varname:node_367,prsc:2|IN-6801-OUT;n:type:ShaderForge.SFN_ConstantClamp,id:6801,x:33018,y:32518,varname:node_6801,prsc:2,min:0,max:1|IN-785-V;n:type:ShaderForge.SFN_Multiply,id:1857,x:33406,y:32429,varname:node_1857,prsc:2|A-2363-OUT,B-367-OUT;n:type:ShaderForge.SFN_Multiply,id:4358,x:33609,y:32451,varname:node_4358,prsc:2|A-1857-OUT,B-4600-OUT;n:type:ShaderForge.SFN_ConstantClamp,id:6579,x:33041,y:32020,varname:node_6579,prsc:2,min:0,max:1|IN-785-U;n:type:ShaderForge.SFN_ConstantClamp,id:2409,x:33041,y:32182,varname:node_2409,prsc:2,min:0,max:1|IN-785-U;n:type:ShaderForge.SFN_OneMinus,id:6940,x:33279,y:32030,varname:node_6940,prsc:2|IN-6579-OUT;n:type:ShaderForge.SFN_Multiply,id:4523,x:33408,y:32154,varname:node_4523,prsc:2|A-6940-OUT,B-2409-OUT;n:type:ShaderForge.SFN_Multiply,id:9773,x:33713,y:32173,varname:node_9773,prsc:2|A-4523-OUT,B-7051-OUT;n:type:ShaderForge.SFN_Slider,id:7051,x:33229,y:32330,ptovrint:False,ptlb:fanwei_u,ptin:_fanwei_u,varname:node_7051,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:20;n:type:ShaderForge.SFN_SwitchProperty,id:994,x:33873,y:32341,ptovrint:False,ptlb:Uorv,ptin:_Uorv,varname:node_994,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:True|A-9773-OUT,B-4358-OUT;n:type:ShaderForge.SFN_Multiply,id:1003,x:33903,y:32725,varname:node_1003,prsc:2|A-7263-OUT,B-7612-OUT;n:type:ShaderForge.SFN_Clamp01,id:7263,x:34063,y:32341,varname:node_7263,prsc:2|IN-994-OUT;n:type:ShaderForge.SFN_Multiply,id:9067,x:33661,y:32889,varname:node_9067,prsc:2|A-7263-OUT,B-6739-OUT;proporder:276-9427-9898-3904-1876-4869-6526-4600-7051-994;pass:END;sub:END;*/

Shader "Y/ad_raodong" {
    Properties {
        _tex ("tex", 2D) = "white" {}
        _color ("color", Color) = (0.5,0.5,0.5,1)
        _raodong ("raodong", 2D) = "white" {}
        _qiangdu ("qiangdu", Float ) = 0.1
        _ZT ("ZT", Float ) = 2
        _U ("U", Float ) = 0
        _V ("V", Float ) = 0
        _fanwei_v ("fanwei_v", Range(0, 20)) = 1
        _fanwei_u ("fanwei_u", Range(0, 20)) = 1
        [MaterialToggle] _Uorv ("Uorv", Float ) = 0
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
            Blend One One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
         //   #pragma multi_compile_fwdbase_fullshadows
         //   #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
          //  #pragma target 2.0
            uniform float4 _TimeEditor;
            uniform sampler2D _tex; uniform float4 _tex_ST;
            uniform sampler2D _raodong; uniform float4 _raodong_ST;
            uniform float4 _color;
            uniform float _qiangdu;
            uniform float _ZT;
            uniform float _U;
            uniform float _V;
            uniform float _fanwei_v;
            uniform float _fanwei_u;
            uniform fixed _Uorv;
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
                float node_7263 = saturate(lerp( (((1.0 - clamp(i.uv0.r,0,1))*clamp(i.uv0.r,0,1))*_fanwei_u), ((clamp(i.uv0.g,0,1)*(1.0 - clamp(i.uv0.g,0,1)))*_fanwei_v), _Uorv ));
                float4 node_8137 = _Time + _TimeEditor;
                float2 node_4020 = (i.uv0+(node_8137.g*float2(_U,_V)));
                float4 _raodong_var = tex2D(_raodong,TRANSFORM_TEX(node_4020, _raodong));
                float2 node_1055 = (i.uv0+(_raodong_var.r*_qiangdu));
                float4 _tex_var = tex2D(_tex,TRANSFORM_TEX(node_1055, _tex));
                float3 emissive = (node_7263*(_tex_var.rgb*i.vertexColor.rgb*_color.rgb*_ZT));
                float3 finalColor = emissive;
                return fixed4(finalColor,(node_7263*(_tex_var.b*i.vertexColor.a*_color.a)));
            }
            ENDCG
        }
    }
   // FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
