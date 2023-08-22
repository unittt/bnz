// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0,fgcg:0,fgcb:0,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True;n:type:ShaderForge.SFN_Final,id:4795,x:33668,y:32802,varname:node_4795,prsc:2|emission-1340-OUT,alpha-263-OUT;n:type:ShaderForge.SFN_Tex2d,id:3458,x:32587,y:33199,ptovrint:False,ptlb:Spread TEX,ptin:_SpreadTEX,varname:node_8590,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-8340-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:3739,x:31174,y:33217,varname:node_3739,prsc:2,uv:0;n:type:ShaderForge.SFN_Vector1,id:1337,x:31153,y:33360,varname:node_1337,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Lerp,id:6535,x:32022,y:33210,varname:node_6535,prsc:2|A-4703-OUT,B-1337-OUT,T-6307-A;n:type:ShaderForge.SFN_Add,id:4703,x:31834,y:33193,varname:node_4703,prsc:2|A-3739-UVOUT,B-6224-OUT;n:type:ShaderForge.SFN_Subtract,id:5907,x:31407,y:33241,varname:node_5907,prsc:2|A-3739-UVOUT,B-1337-OUT;n:type:ShaderForge.SFN_Divide,id:6224,x:31601,y:33227,varname:node_6224,prsc:2|A-5907-OUT,B-6307-A;n:type:ShaderForge.SFN_Clamp01,id:8242,x:32196,y:33210,varname:node_8242,prsc:2|IN-6535-OUT;n:type:ShaderForge.SFN_VertexColor,id:6307,x:31407,y:33396,varname:node_6307,prsc:2;n:type:ShaderForge.SFN_Multiply,id:9215,x:32658,y:32931,varname:node_9215,prsc:2|A-1879-RGB,B-4344-RGB;n:type:ShaderForge.SFN_Tex2d,id:4344,x:32395,y:32950,ptovrint:False,ptlb:TEX,ptin:_TEX,varname:node_3584,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Color,id:9865,x:33219,y:32767,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_4409,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_ValueProperty,id:6761,x:32521,y:33107,ptovrint:False,ptlb:Lighting Levels,ptin:_LightingLevels,varname:node_5046,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_VertexColor,id:1879,x:32395,y:32801,varname:node_1879,prsc:2;n:type:ShaderForge.SFN_Multiply,id:4263,x:32918,y:32937,varname:node_4263,prsc:2|A-9215-OUT,B-4344-A,C-6761-OUT,D-5604-OUT;n:type:ShaderForge.SFN_Rotator,id:8340,x:32366,y:33199,varname:node_8340,prsc:2|UVIN-8242-OUT,SPD-1409-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1409,x:32110,y:33404,ptovrint:False,ptlb:Rotate Speed,ptin:_RotateSpeed,varname:node_1670,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:1340,x:33480,y:32893,varname:node_1340,prsc:2|A-9865-RGB,B-9033-OUT;n:type:ShaderForge.SFN_ComponentMask,id:4643,x:33165,y:33119,varname:node_4643,prsc:2,cc1:0,cc2:-1,cc3:-1,cc4:-1|IN-4263-OUT;n:type:ShaderForge.SFN_Desaturate,id:9033,x:33155,y:32925,varname:node_9033,prsc:2|COL-4263-OUT;n:type:ShaderForge.SFN_Multiply,id:263,x:33348,y:33129,varname:node_263,prsc:2|A-4643-OUT,B-6604-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6604,x:33146,y:33348,ptovrint:False,ptlb:Alpha,ptin:_Alpha,varname:node_6604,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:5604,x:32839,y:33135,varname:node_5604,prsc:2|A-3458-RGB,B-3458-A;proporder:4344-9865-6761-6604-3458-1409;pass:END;sub:END;*/

Shader "H2/H_Spread_Blend_P" {
    Properties {
        _TEX ("TEX", 2D) = "white" {}
        _Color ("Color", Color) = (0.5,0.5,0.5,1)
        _LightingLevels ("Lighting Levels", Float ) = 1
        _Alpha ("Alpha", Float ) = 1
        _SpreadTEX ("Spread TEX", 2D) = "white" {}
        _RotateSpeed ("Rotate Speed", Float ) = 0
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
           // #pragma multi_compile_fwdbase
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            //#pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _SpreadTEX; uniform float4 _SpreadTEX_ST;
            uniform sampler2D _TEX; uniform float4 _TEX_ST;
            uniform float4 _Color;
            uniform float _LightingLevels;
            uniform float _RotateSpeed;
            uniform float _Alpha;
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
                float4 node_2844 = _Time + _TimeEditor;
                float node_8340_ang = node_2844.g;
                float node_8340_spd = _RotateSpeed;
                float node_8340_cos = cos(node_8340_spd*node_8340_ang);
                float node_8340_sin = sin(node_8340_spd*node_8340_ang);
                float2 node_8340_piv = float2(0.5,0.5);
                float node_1337 = 0.5;
                float2 node_8340 = (mul(saturate(lerp((i.uv0+((i.uv0-node_1337)/i.vertexColor.a)),float2(node_1337,node_1337),i.vertexColor.a))-node_8340_piv,float2x2( node_8340_cos, -node_8340_sin, node_8340_sin, node_8340_cos))+node_8340_piv);
                float4 _SpreadTEX_var = tex2D(_SpreadTEX,TRANSFORM_TEX(node_8340, _SpreadTEX));
                float3 node_4263 = ((i.vertexColor.rgb*_TEX_var.rgb)*_TEX_var.a*_LightingLevels*(_SpreadTEX_var.rgb*_SpreadTEX_var.a));
                float3 emissive = (_Color.rgb*dot(node_4263,float3(0.3,0.59,0.11)));
                float3 finalColor = emissive;
                return fixed4(finalColor,(node_4263.r*_Alpha));
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
