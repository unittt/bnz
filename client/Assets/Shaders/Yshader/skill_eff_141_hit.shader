// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33285,y:32623,varname:node_3138,prsc:2|emission-6038-OUT,alpha-7526-A;n:type:ShaderForge.SFN_Tex2d,id:2544,x:32034,y:32685,ptovrint:False,ptlb:node_2544,ptin:_node_2544,varname:node_2544,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:da62ae5937e57db40b207dc6a96f39e5,ntxv:0,isnm:False|UVIN-5585-UVOUT;n:type:ShaderForge.SFN_Multiply,id:82,x:32256,y:32685,varname:node_82,prsc:2|A-2544-RGB,B-1495-OUT;n:type:ShaderForge.SFN_Slider,id:1495,x:31913,y:32863,ptovrint:False,ptlb:light,ptin:_light,varname:node_1495,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1.19097,max:10;n:type:ShaderForge.SFN_Panner,id:5585,x:31854,y:32685,varname:node_5585,prsc:2,spu:0.5,spv:0.5|UVIN-2389-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:2389,x:31660,y:32685,varname:node_2389,prsc:2,uv:0;n:type:ShaderForge.SFN_Power,id:7548,x:32520,y:32691,varname:node_7548,prsc:2|VAL-82-OUT,EXP-8294-OUT;n:type:ShaderForge.SFN_Slider,id:8294,x:32238,y:32888,ptovrint:False,ptlb:power,ptin:_power,varname:node_8294,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:4.976144,max:5;n:type:ShaderForge.SFN_Multiply,id:2113,x:32710,y:32691,varname:node_2113,prsc:2|A-7548-OUT,B-7526-RGB;n:type:ShaderForge.SFN_VertexColor,id:7526,x:32579,y:32888,varname:node_7526,prsc:2;n:type:ShaderForge.SFN_Multiply,id:6038,x:33049,y:32688,varname:node_6038,prsc:2|A-2113-OUT,B-4057-OUT;n:type:ShaderForge.SFN_Fresnel,id:4057,x:32944,y:32905,varname:node_4057,prsc:2|EXP-2094-OUT;n:type:ShaderForge.SFN_Slider,id:2094,x:32609,y:33077,ptovrint:False,ptlb:fresnel,ptin:_fresnel,varname:node_2094,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:3.162393,max:10;proporder:2544-1495-8294-2094;pass:END;sub:END;*/

Shader "Y/skill_eff_141_hit" {
    Properties {
        _node_2544 ("node_2544", 2D) = "white" {}
        _light ("light", Range(0, 10)) = 1.19097
        _power ("power", Range(0, 5)) = 4.976144
        _fresnel ("fresnel", Range(0, 10)) = 3.162393
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
            Blend One One
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            //#pragma multi_compile_fwdbase
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _node_2544; uniform float4 _node_2544_ST;
            uniform float _light;
            uniform float _power;
            uniform float _fresnel;
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
                float4 node_3385 = _Time + _TimeEditor;
                float2 node_5585 = (i.uv0+node_3385.g*float2(0.5,0.5));
                float4 _node_2544_var = tex2D(_node_2544,TRANSFORM_TEX(node_5585, _node_2544));
                float3 emissive = ((pow((_node_2544_var.rgb*_light),_power)*i.vertexColor.rgb)*pow(1.0-max(0,dot(normalDirection, viewDirection)),_fresnel));
                float3 finalColor = emissive;
                return fixed4(finalColor,i.vertexColor.a);
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
