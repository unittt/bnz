// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:True,fgod:False,fgor:False,fgmd:0,fgcr:0,fgcg:0,fgcb:0,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True;n:type:ShaderForge.SFN_Final,id:4795,x:33064,y:32490,varname:node_4795,prsc:2|emission-2393-OUT;n:type:ShaderForge.SFN_Multiply,id:2393,x:32688,y:32544,varname:node_2393,prsc:2|A-3186-OUT,B-2053-RGB,C-797-RGB,D-9210-OUT,E-601-OUT;n:type:ShaderForge.SFN_VertexColor,id:2053,x:32179,y:32668,varname:node_2053,prsc:2;n:type:ShaderForge.SFN_Color,id:797,x:32179,y:32826,ptovrint:True,ptlb:Color,ptin:_TintColor,varname:_TintColor,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Tex2d,id:4110,x:31905,y:32341,ptovrint:False,ptlb:TEX1,ptin:_TEX1,varname:node_4110,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:False|UVIN-4952-UVOUT;n:type:ShaderForge.SFN_Panner,id:4952,x:31671,y:32341,varname:node_4952,prsc:2,spu:0,spv:0.1|UVIN-9414-UVOUT,DIST-5020-OUT;n:type:ShaderForge.SFN_TexCoord,id:9414,x:31462,y:32222,varname:node_9414,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:5020,x:31462,y:32365,varname:node_5020,prsc:2|A-1627-T,B-9558-OUT;n:type:ShaderForge.SFN_Time,id:1627,x:31274,y:32365,varname:node_1627,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:9558,x:31274,y:32516,ptovrint:False,ptlb:TEX1_SUDU,ptin:_TEX1_SUDU,varname:node_9558,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:-0.2;n:type:ShaderForge.SFN_Tex2d,id:1599,x:31868,y:32580,ptovrint:False,ptlb:TEX2,ptin:_TEX2,varname:_TEX2,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:3,isnm:False|UVIN-9657-UVOUT;n:type:ShaderForge.SFN_Panner,id:9657,x:31671,y:32580,varname:node_9657,prsc:2,spu:0,spv:0.1|UVIN-9905-UVOUT,DIST-5394-OUT;n:type:ShaderForge.SFN_TexCoord,id:9905,x:31462,y:32580,varname:node_9905,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:5394,x:31462,y:32734,varname:node_5394,prsc:2|A-9073-T,B-6931-OUT;n:type:ShaderForge.SFN_Time,id:9073,x:31274,y:32734,varname:node_9073,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:6931,x:31274,y:32897,ptovrint:False,ptlb:TEX2_SUDU,ptin:_TEX2_SUDU,varname:_TEX1_SUDU_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.1;n:type:ShaderForge.SFN_Add,id:3186,x:32300,y:32484,varname:node_3186,prsc:2|A-4946-OUT,B-1689-OUT;n:type:ShaderForge.SFN_ValueProperty,id:9210,x:32179,y:32994,ptovrint:False,ptlb:ZT,ptin:_ZT,varname:node_9210,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Tex2d,id:5476,x:32179,y:33082,ptovrint:False,ptlb:MASk,ptin:_MASk,varname:node_5476,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:4946,x:32097,y:32403,varname:node_4946,prsc:2|A-4110-RGB,B-4110-A;n:type:ShaderForge.SFN_Multiply,id:1689,x:32067,y:32580,varname:node_1689,prsc:2|A-1599-RGB,B-1599-A;n:type:ShaderForge.SFN_Multiply,id:601,x:32465,y:33035,varname:node_601,prsc:2|A-5476-RGB,B-2114-OUT,C-5476-A;n:type:ShaderForge.SFN_ValueProperty,id:2114,x:32299,y:33286,ptovrint:False,ptlb:ALPHA,ptin:_ALPHA,varname:node_2114,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;proporder:797-4110-9558-1599-6931-9210-5476-2114;pass:END;sub:END;*/

Shader "H/H_liuguang_ADD04" {
    Properties {
        _TintColor ("Color", Color) = (0.5,0.5,0.5,1)
        _TEX1 ("TEX1", 2D) = "bump" {}
        _TEX1_SUDU ("TEX1_SUDU", Float ) = -0.2
        _TEX2 ("TEX2", 2D) = "bump" {}
        _TEX2_SUDU ("TEX2_SUDU", Float ) = 0.1
        _ZT ("ZT", Float ) = 1
        _MASk ("MASk", 2D) = "white" {}
        _ALPHA ("ALPHA", Float ) = 2
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
            //#pragma multi_compile_fog
           // #pragma exclude_renderers xbox360 xboxone ps3 ps4 psp2 
            //#pragma target 3.0
            uniform float4 _TimeEditor;
            uniform float4 _TintColor;
            uniform sampler2D _TEX1; uniform float4 _TEX1_ST;
            uniform float _TEX1_SUDU;
            uniform sampler2D _TEX2; uniform float4 _TEX2_ST;
            uniform float _TEX2_SUDU;
            uniform float _ZT;
            uniform sampler2D _MASk; uniform float4 _MASk_ST;
            uniform float _ALPHA;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float4 node_1627 = _Time + _TimeEditor;
                float2 node_4952 = (i.uv0+(node_1627.g*_TEX1_SUDU)*float2(0,0.1));
                float4 _TEX1_var = tex2D(_TEX1,TRANSFORM_TEX(node_4952, _TEX1));
                float4 node_9073 = _Time + _TimeEditor;
                float2 node_9657 = (i.uv0+(node_9073.g*_TEX2_SUDU)*float2(0,0.1));
                float4 _TEX2_var = tex2D(_TEX2,TRANSFORM_TEX(node_9657, _TEX2));
                float4 _MASk_var = tex2D(_MASk,TRANSFORM_TEX(i.uv0, _MASk));
                float3 emissive = (((_TEX1_var.rgb*_TEX1_var.a)+(_TEX2_var.rgb*_TEX2_var.a))*i.vertexColor.rgb*_TintColor.rgb*_ZT*(_MASk_var.rgb*_ALPHA*_MASk_var.a));
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG_COLOR(i.fogCoord, finalRGBA, fixed4(0,0,0,1));
                return finalRGBA;
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
