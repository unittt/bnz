// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:3,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:False,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:True,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:576,x:33192,y:32668,varname:node_576,prsc:2|emission-7649-OUT;n:type:ShaderForge.SFN_Tex2d,id:276,x:32497,y:32755,ptovrint:False,ptlb:tex,ptin:_tex,varname:node_276,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-1055-OUT;n:type:ShaderForge.SFN_Multiply,id:7612,x:32804,y:32792,varname:node_7612,prsc:2|A-276-RGB,B-7308-RGB,C-9427-RGB,D-1876-OUT;n:type:ShaderForge.SFN_Tex2d,id:9898,x:31910,y:32730,ptovrint:False,ptlb:raodong,ptin:_raodong,varname:node_9898,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7acc33f24a06fcd46baa112415b42195,ntxv:0,isnm:False|UVIN-1502-UVOUT;n:type:ShaderForge.SFN_VertexColor,id:7308,x:32447,y:32944,varname:node_7308,prsc:2;n:type:ShaderForge.SFN_Color,id:9427,x:32508,y:33154,ptovrint:False,ptlb:color,ptin:_color,varname:node_9427,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Add,id:1055,x:32326,y:32755,varname:node_1055,prsc:2|A-6163-UVOUT,B-3252-OUT;n:type:ShaderForge.SFN_TexCoord,id:6163,x:32165,y:32560,varname:node_6163,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:3252,x:32165,y:32772,varname:node_3252,prsc:2|A-9898-R,B-3904-OUT;n:type:ShaderForge.SFN_ValueProperty,id:3904,x:32042,y:32947,ptovrint:False,ptlb:qiangdu,ptin:_qiangdu,varname:node_3904,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.1;n:type:ShaderForge.SFN_Panner,id:1502,x:31732,y:32737,varname:node_1502,prsc:2,spu:1,spv:1|UVIN-5918-UVOUT,DIST-4408-OUT;n:type:ShaderForge.SFN_TexCoord,id:5918,x:31462,y:32652,varname:node_5918,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:4408,x:31586,y:32868,varname:node_4408,prsc:2|A-8137-T,B-496-OUT;n:type:ShaderForge.SFN_Time,id:8137,x:31393,y:32827,varname:node_8137,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:496,x:31408,y:33053,ptovrint:False,ptlb:sudu,ptin:_sudu,varname:node_496,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.2;n:type:ShaderForge.SFN_ValueProperty,id:1876,x:32447,y:33082,ptovrint:False,ptlb:ZT,ptin:_ZT,varname:node_1876,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Multiply,id:7649,x:32984,y:32916,varname:node_7649,prsc:2|A-7612-OUT,B-276-A,C-7308-A,D-9427-A;proporder:276-9427-9898-3904-496-1876;pass:END;sub:END;*/

Shader "H/H_raodong_Add" {
    Properties {
        _tex ("tex", 2D) = "white" {}
        _color ("color", Color) = (0.5,0.5,0.5,1)
        _raodong ("raodong", 2D) = "white" {}
        _qiangdu ("qiangdu", Float ) = 0.1
        _sudu ("sudu", Float ) = 0.2
        _ZT ("ZT", Float ) = 2
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
            colormask rgb
            Cull Off
            ZWrite Off
            colormask rgb
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            //#pragma multi_compile_fwdbase_fullshadows
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            //#pragma target 2.0
            uniform float4 _TimeEditor;
            uniform sampler2D _tex; uniform float4 _tex_ST;
            uniform sampler2D _raodong; uniform float4 _raodong_ST;
            uniform float4 _color;
            uniform float _qiangdu;
            uniform float _sudu;
            uniform float _ZT;
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
                float4 node_8137 = _Time + _TimeEditor;
                float2 node_1502 = (i.uv0+(node_8137.g*_sudu)*float2(1,1));
                float4 _raodong_var = tex2D(_raodong,TRANSFORM_TEX(node_1502, _raodong));
                float2 node_1055 = (i.uv0+(_raodong_var.r*_qiangdu));
                float4 _tex_var = tex2D(_tex,TRANSFORM_TEX(node_1055, _tex));
                float3 emissive = ((_tex_var.rgb*i.vertexColor.rgb*_color.rgb*_ZT)*_tex_var.a*i.vertexColor.a*_color.a);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
