// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33925,y:32737,varname:node_3138,prsc:2|emission-5436-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32009,y:32772,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_7241,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.07843138,c2:0.3921569,c3:0.7843137,c4:1;n:type:ShaderForge.SFN_Tex2d,id:226,x:32009,y:32945,ptovrint:False,ptlb:node_226,ptin:_node_226,varname:node_226,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:55d1ca2a97d5585418e892cfddf4d26d,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:2686,x:31994,y:33220,ptovrint:False,ptlb:node_2686,ptin:_node_2686,varname:node_2686,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:8d4fa605ed2360b45a78626bfd86da6b,ntxv:0,isnm:False|UVIN-6260-UVOUT;n:type:ShaderForge.SFN_Tex2d,id:4364,x:32247,y:32945,ptovrint:False,ptlb:node_4364,ptin:_node_4364,varname:node_4364,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:5890575058f4fd4438c90a85dfa8b2b2,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Panner,id:5861,x:31648,y:33137,varname:node_5861,prsc:2,spu:0,spv:0|UVIN-1623-UVOUT;n:type:ShaderForge.SFN_Multiply,id:6786,x:32467,y:33285,varname:node_6786,prsc:2|A-5913-OUT,B-1666-OUT;n:type:ShaderForge.SFN_TexCoord,id:1623,x:31542,y:33325,varname:node_1623,prsc:2,uv:0;n:type:ShaderForge.SFN_Add,id:5436,x:33234,y:33031,varname:node_5436,prsc:2|A-6251-OUT,B-226-RGB,C-8135-OUT,D-9923-OUT;n:type:ShaderForge.SFN_Multiply,id:6251,x:32726,y:33293,varname:node_6251,prsc:2|A-6786-OUT,B-9569-OUT;n:type:ShaderForge.SFN_Vector1,id:9569,x:32467,y:33532,varname:node_9569,prsc:2,v1:1.5;n:type:ShaderForge.SFN_Tex2d,id:8878,x:31994,y:33446,ptovrint:False,ptlb:node_8878,ptin:_node_8878,varname:node_8878,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7eb85728f2f1c37429198cb85fe476d0,ntxv:0,isnm:False|UVIN-4945-UVOUT;n:type:ShaderForge.SFN_Panner,id:4945,x:31764,y:33446,varname:node_4945,prsc:2,spu:0.25,spv:0.15|UVIN-1623-UVOUT;n:type:ShaderForge.SFN_Multiply,id:1666,x:32259,y:33285,varname:node_1666,prsc:2|A-2686-RGB,B-8878-RGB;n:type:ShaderForge.SFN_Tex2d,id:3727,x:32673,y:32504,ptovrint:False,ptlb:node_3727,ptin:_node_3727,varname:node_3727,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:914003372f0e9fc40955a42d8b73d057,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Time,id:6465,x:31820,y:32325,varname:node_6465,prsc:2;n:type:ShaderForge.SFN_Multiply,id:8416,x:32086,y:32329,varname:node_8416,prsc:2|A-6465-T,B-5294-OUT;n:type:ShaderForge.SFN_Vector1,id:5294,x:31863,y:32492,varname:node_5294,prsc:2,v1:100;n:type:ShaderForge.SFN_Sin,id:556,x:32271,y:32329,varname:node_556,prsc:2|IN-8416-OUT;n:type:ShaderForge.SFN_Cos,id:3946,x:32285,y:32146,varname:node_3946,prsc:2|IN-2640-OUT;n:type:ShaderForge.SFN_Multiply,id:2640,x:32097,y:32146,varname:node_2640,prsc:2|A-6749-OUT,B-8416-OUT;n:type:ShaderForge.SFN_Vector1,id:6749,x:31903,y:32146,varname:node_6749,prsc:2,v1:1.2;n:type:ShaderForge.SFN_Add,id:3797,x:32577,y:32147,varname:node_3797,prsc:2|A-3946-OUT,B-958-OUT;n:type:ShaderForge.SFN_Add,id:8747,x:32567,y:32336,varname:node_8747,prsc:2|A-958-OUT,B-556-OUT;n:type:ShaderForge.SFN_Vector1,id:958,x:32407,y:32235,varname:node_958,prsc:2,v1:1;n:type:ShaderForge.SFN_Divide,id:4449,x:32810,y:32131,varname:node_4449,prsc:2|A-3797-OUT,B-5168-OUT;n:type:ShaderForge.SFN_Vector1,id:5168,x:32684,y:32268,varname:node_5168,prsc:2,v1:2;n:type:ShaderForge.SFN_Add,id:3672,x:32894,y:32290,varname:node_3672,prsc:2|A-4449-OUT,B-8747-OUT;n:type:ShaderForge.SFN_Clamp01,id:5353,x:33113,y:32290,varname:node_5353,prsc:2|IN-3672-OUT;n:type:ShaderForge.SFN_Multiply,id:3582,x:33428,y:32403,varname:node_3582,prsc:2|A-5353-OUT,B-422-OUT,C-2205-RGB,D-9923-OUT;n:type:ShaderForge.SFN_Vector1,id:422,x:33349,y:32665,varname:node_422,prsc:2,v1:2;n:type:ShaderForge.SFN_Color,id:2205,x:33150,y:32597,ptovrint:False,ptlb:node_2205,ptin:_node_2205,varname:node_2205,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.3529412,c2:0.6787019,c3:1,c4:1;n:type:ShaderForge.SFN_Add,id:5913,x:32593,y:32911,varname:node_5913,prsc:2|A-3727-RGB,B-4364-RGB;n:type:ShaderForge.SFN_Color,id:3254,x:32382,y:32641,ptovrint:False,ptlb:node_2205_copy,ptin:_node_2205_copy,varname:_node_2205_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5955882,c2:0.88286,c3:1,c4:1;n:type:ShaderForge.SFN_Rotator,id:6260,x:31791,y:33272,varname:node_6260,prsc:2|UVIN-1623-UVOUT;n:type:ShaderForge.SFN_Tex2d,id:3572,x:32020,y:33874,ptovrint:False,ptlb:node_3572,ptin:_node_3572,varname:node_3572,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7a27459c5b87d984d989eb4907d9b7d3,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:9072,x:32020,y:33665,ptovrint:False,ptlb:node_8878_copy,ptin:_node_8878_copy,varname:_node_8878_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7eb85728f2f1c37429198cb85fe476d0,ntxv:0,isnm:False|UVIN-9591-UVOUT;n:type:ShaderForge.SFN_Panner,id:9591,x:31760,y:33630,varname:node_9591,prsc:2,spu:-0.25,spv:0|UVIN-1623-UVOUT;n:type:ShaderForge.SFN_Multiply,id:6219,x:32269,y:33771,varname:node_6219,prsc:2|A-9072-RGB,B-3572-RGB;n:type:ShaderForge.SFN_Tex2d,id:5953,x:32020,y:34112,ptovrint:False,ptlb:node_5953,ptin:_node_5953,varname:node_5953,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:585baf83d46cd394eb81afab2ca3bf53,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:7979,x:32302,y:34122,varname:node_7979,prsc:2|A-5353-OUT,B-5953-RGB;n:type:ShaderForge.SFN_Multiply,id:9923,x:32468,y:33897,varname:node_9923,prsc:2|A-6219-OUT,B-7979-OUT;n:type:ShaderForge.SFN_Power,id:8135,x:33732,y:32378,varname:node_8135,prsc:2|VAL-3582-OUT,EXP-6714-OUT;n:type:ShaderForge.SFN_Vector1,id:6714,x:33566,y:32571,varname:node_6714,prsc:2,v1:1.5;proporder:7241-226-2686-4364-8878-3727-2205-3254-3572-9072-5953;pass:END;sub:END;*/

Shader "Shader Forge/5143" {
    Properties {
        _Color ("Color", Color) = (0.07843138,0.3921569,0.7843137,1)
        _node_226 ("node_226", 2D) = "white" {}
        _node_2686 ("node_2686", 2D) = "white" {}
        _node_4364 ("node_4364", 2D) = "white" {}
        _node_8878 ("node_8878", 2D) = "white" {}
        _node_3727 ("node_3727", 2D) = "white" {}
        _node_2205 ("node_2205", Color) = (0.3529412,0.6787019,1,1)
        _node_2205_copy ("node_2205_copy", Color) = (0.5955882,0.88286,1,1)
        _node_3572 ("node_3572", 2D) = "white" {}
        _node_8878_copy ("node_8878_copy", 2D) = "white" {}
        _node_5953 ("node_5953", 2D) = "white" {}
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
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
          //  #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _node_226; uniform float4 _node_226_ST;
            uniform sampler2D _node_2686; uniform float4 _node_2686_ST;
            uniform sampler2D _node_4364; uniform float4 _node_4364_ST;
            uniform sampler2D _node_8878; uniform float4 _node_8878_ST;
            uniform sampler2D _node_3727; uniform float4 _node_3727_ST;
            uniform float4 _node_2205;
            uniform sampler2D _node_3572; uniform float4 _node_3572_ST;
            uniform sampler2D _node_8878_copy; uniform float4 _node_8878_copy_ST;
            uniform sampler2D _node_5953; uniform float4 _node_5953_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float4 _node_3727_var = tex2D(_node_3727,TRANSFORM_TEX(i.uv0, _node_3727));
                float4 _node_4364_var = tex2D(_node_4364,TRANSFORM_TEX(i.uv0, _node_4364));
                float4 node_702 = _Time + _TimeEditor;
                float node_6260_ang = node_702.g;
                float node_6260_spd = 1.0;
                float node_6260_cos = cos(node_6260_spd*node_6260_ang);
                float node_6260_sin = sin(node_6260_spd*node_6260_ang);
                float2 node_6260_piv = float2(0.5,0.5);
                float2 node_6260 = (mul(i.uv0-node_6260_piv,float2x2( node_6260_cos, -node_6260_sin, node_6260_sin, node_6260_cos))+node_6260_piv);
                float4 _node_2686_var = tex2D(_node_2686,TRANSFORM_TEX(node_6260, _node_2686));
                float2 node_4945 = (i.uv0+node_702.g*float2(0.25,0.15));
                float4 _node_8878_var = tex2D(_node_8878,TRANSFORM_TEX(node_4945, _node_8878));
                float4 _node_226_var = tex2D(_node_226,TRANSFORM_TEX(i.uv0, _node_226));
                float4 node_6465 = _Time + _TimeEditor;
                float node_8416 = (node_6465.g*100.0);
                float node_958 = 1.0;
                float node_5353 = saturate((((cos((1.2*node_8416))+node_958)/2.0)+(node_958+sin(node_8416))));
                float2 node_9591 = (i.uv0+node_702.g*float2(-0.25,0));
                float4 _node_8878_copy_var = tex2D(_node_8878_copy,TRANSFORM_TEX(node_9591, _node_8878_copy));
                float4 _node_3572_var = tex2D(_node_3572,TRANSFORM_TEX(i.uv0, _node_3572));
                float4 _node_5953_var = tex2D(_node_5953,TRANSFORM_TEX(i.uv0, _node_5953));
                float3 node_9923 = ((_node_8878_copy_var.rgb*_node_3572_var.rgb)*(node_5353*_node_5953_var.rgb));
                float3 emissive = ((((_node_3727_var.rgb+_node_4364_var.rgb)*(_node_2686_var.rgb*_node_8878_var.rgb))*1.5)+_node_226_var.rgb+pow((node_5353*2.0*_node_2205.rgb*node_9923),1.5)+node_9923);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
