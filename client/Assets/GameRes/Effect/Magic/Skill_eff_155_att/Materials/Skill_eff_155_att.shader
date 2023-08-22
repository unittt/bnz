// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:34001,y:32732,varname:node_3138,prsc:2|emission-7024-OUT,clip-1707-OUT;n:type:ShaderForge.SFN_Tex2d,id:3502,x:32522,y:32699,ptovrint:False,ptlb:tex,ptin:_tex,varname:node_3502,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:d8c695b740d7369499062aedcafa0d3a,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Fresnel,id:8059,x:32522,y:32930,varname:node_8059,prsc:2|EXP-8971-OUT;n:type:ShaderForge.SFN_Slider,id:8971,x:32395,y:33139,ptovrint:False,ptlb:fresenl_daxiao,ptin:_fresenl_daxiao,varname:node_8971,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1.570664,max:10;n:type:ShaderForge.SFN_Multiply,id:7024,x:33017,y:32842,varname:node_7024,prsc:2|A-9569-OUT,B-8808-RGB;n:type:ShaderForge.SFN_Color,id:8808,x:32793,y:33097,ptovrint:False,ptlb:fresnel_color,ptin:_fresnel_color,varname:node_8808,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:0.5735294,c3:0.5735294,c4:1;n:type:ShaderForge.SFN_Add,id:9569,x:32793,y:32881,varname:node_9569,prsc:2|A-3502-RGB,B-8059-OUT;n:type:ShaderForge.SFN_Tex2d,id:5783,x:33030,y:33153,ptovrint:False,ptlb:mask,ptin:_mask,varname:node_5783,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7acc33f24a06fcd46baa112415b42195,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Slider,id:99,x:32873,y:33413,ptovrint:False,ptlb:rongjie,ptin:_rongjie,varname:node_99,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-2,cur:-0.0294972,max:10;n:type:ShaderForge.SFN_Subtract,id:1707,x:33627,y:33148,varname:node_1707,prsc:2|A-1796-A,B-1480-OUT;n:type:ShaderForge.SFN_Add,id:1480,x:33301,y:33226,varname:node_1480,prsc:2|A-5783-R,B-99-OUT;n:type:ShaderForge.SFN_VertexColor,id:1796,x:33200,y:32960,varname:node_1796,prsc:2;proporder:3502-8971-8808-5783-99;pass:END;sub:END;*/

Shader "Shader Forge/155" {
    Properties {
        _tex ("tex", 2D) = "white" {}
        _fresenl_daxiao ("fresenl_daxiao", Range(0, 10)) = 1.570664
        _fresnel_color ("fresnel_color", Color) = (1,0.5735294,0.5735294,1)
        _mask ("mask", 2D) = "white" {}
        _rongjie ("rongjie", Range(-2, 10)) = -0.0294972
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "Queue"="AlphaTest"
            "RenderType"="TransparentCutout"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
           // #pragma multi_compile_fwdbase_fullshadows
           // #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
           // #pragma target 3.0
            uniform sampler2D _tex; uniform float4 _tex_ST;
            uniform float _fresenl_daxiao;
            uniform float4 _fresnel_color;
            uniform sampler2D _mask; uniform float4 _mask_ST;
            uniform float _rongjie;
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
                float4 _mask_var = tex2D(_mask,TRANSFORM_TEX(i.uv0, _mask));
                float node_1707 = (i.vertexColor.a-(_mask_var.r+_rongjie));
                clip(node_1707 - 0.5);
////// Lighting:
////// Emissive:
                float4 _tex_var = tex2D(_tex,TRANSFORM_TEX(i.uv0, _tex));
                float node_8059 = pow(1.0-max(0,dot(normalDirection, viewDirection)),_fresenl_daxiao);
                float3 node_7024 = ((_tex_var.rgb+node_8059)*_fresnel_color.rgb);
                float3 emissive = node_7024;
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform sampler2D _mask; uniform float4 _mask_ST;
            uniform float _rongjie;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float4 _mask_var = tex2D(_mask,TRANSFORM_TEX(i.uv0, _mask));
                float node_1707 = (i.vertexColor.a-(_mask_var.r+_rongjie));
                clip(node_1707 - 0.5);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
