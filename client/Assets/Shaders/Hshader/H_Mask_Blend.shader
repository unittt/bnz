// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:9743,x:33436,y:32691,varname:node_9743,prsc:2|emission-5905-OUT,alpha-5356-OUT;n:type:ShaderForge.SFN_Tex2d,id:6357,x:32601,y:32445,ptovrint:False,ptlb:TEX,ptin:_TEX,varname:node_6357,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:1217,x:32493,y:33038,ptovrint:False,ptlb:MASK,ptin:_MASK,varname:node_1217,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:d3bbd4d3021993a41b4da31bcf4547e7,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:5905,x:33055,y:32735,varname:node_5905,prsc:2|A-6357-RGB,B-5805-RGB,C-4712-RGB,D-1927-OUT;n:type:ShaderForge.SFN_ComponentMask,id:4893,x:32757,y:33044,varname:node_4893,prsc:2,cc1:0,cc2:-1,cc3:-1,cc4:-1|IN-1217-RGB;n:type:ShaderForge.SFN_Color,id:5805,x:32601,y:32626,ptovrint:False,ptlb:node_5805,ptin:_node_5805,varname:node_5805,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_VertexColor,id:4712,x:32588,y:32773,varname:node_4712,prsc:2;n:type:ShaderForge.SFN_Slider,id:3563,x:32558,y:33286,ptovrint:False,ptlb:alpha,ptin:_alpha,varname:node_3563,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:2.660058,max:5;n:type:ShaderForge.SFN_Multiply,id:5356,x:33102,y:33038,varname:node_5356,prsc:2|A-4893-OUT,B-3563-OUT,C-6357-A,D-4712-A;n:type:ShaderForge.SFN_ValueProperty,id:1927,x:32651,y:32950,ptovrint:False,ptlb:ZT,ptin:_ZT,varname:node_1927,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;proporder:6357-5805-1217-3563-1927;pass:END;sub:END;*/

Shader "H/H_Mask_Blend" {
    Properties {
        _TEX ("TEX", 2D) = "white" {}
        _node_5805 ("node_5805", Color) = (0.5,0.5,0.5,1)
        _MASK ("MASK", 2D) = "white" {}
        _alpha ("alpha", Range(0, 5)) = 2.660058
        _ZT ("ZT", Float ) = 2
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
           // #pragma target 3.0
            uniform sampler2D _TEX; uniform float4 _TEX_ST;
            uniform sampler2D _MASK; uniform float4 _MASK_ST;
            uniform float4 _node_5805;
            uniform float _alpha;
            uniform float _ZT;
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
                float4 _TEX_var = tex2D(_TEX,TRANSFORM_TEX(i.uv0, _TEX));
                float3 emissive = (_TEX_var.rgb*_node_5805.rgb*i.vertexColor.rgb*_ZT);
                float3 finalColor = emissive;
                float4 _MASK_var = tex2D(_MASK,TRANSFORM_TEX(i.uv0, _MASK));
                return fixed4(finalColor,(_MASK_var.rgb.r*_alpha*_TEX_var.a*i.vertexColor.a));
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
