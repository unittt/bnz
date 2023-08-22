// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:True,fgod:False,fgor:False,fgmd:0,fgcr:0,fgcg:0,fgcb:0,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True;n:type:ShaderForge.SFN_Final,id:4795,x:32935,y:32659,varname:node_4795,prsc:2|emission-2393-OUT;n:type:ShaderForge.SFN_Tex2d,id:6074,x:31562,y:32508,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:_MainTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:2393,x:32692,y:32760,varname:node_2393,prsc:2|A-8294-OUT,B-2053-RGB,C-797-RGB,D-9295-OUT;n:type:ShaderForge.SFN_VertexColor,id:2053,x:32159,y:32752,varname:node_2053,prsc:2;n:type:ShaderForge.SFN_Color,id:797,x:32172,y:32896,ptovrint:True,ptlb:Color,ptin:_TintColor,varname:_TintColor,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Tex2d,id:4885,x:31562,y:32317,ptovrint:False,ptlb:MASK,ptin:_MASK,varname:_MainTex_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-1994-OUT;n:type:ShaderForge.SFN_Panner,id:195,x:31063,y:32254,varname:node_195,prsc:2,spu:0,spv:1|UVIN-1068-UVOUT,DIST-4127-OUT;n:type:ShaderForge.SFN_TexCoord,id:1068,x:30720,y:32223,varname:node_1068,prsc:2,uv:0;n:type:ShaderForge.SFN_Slider,id:6962,x:30132,y:32366,ptovrint:False,ptlb:Slider,ptin:_Slider,varname:node_6962,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Multiply,id:8294,x:31847,y:32468,varname:node_8294,prsc:2|A-4885-RGB,B-6074-RGB,C-4885-A,D-6074-A;n:type:ShaderForge.SFN_RemapRange,id:4127,x:30695,y:32429,varname:node_4127,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-7198-OUT;n:type:ShaderForge.SFN_Panner,id:3485,x:31063,y:32426,varname:node_3485,prsc:2,spu:1,spv:0|UVIN-1068-UVOUT,DIST-4127-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:1994,x:31312,y:32317,ptovrint:False,ptlb:UorV,ptin:_UorV,varname:node_1994,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:True|A-195-UVOUT,B-3485-UVOUT;n:type:ShaderForge.SFN_VertexColor,id:2381,x:30132,y:32465,varname:node_2381,prsc:2;n:type:ShaderForge.SFN_Multiply,id:7198,x:30472,y:32468,varname:node_7198,prsc:2|A-6962-OUT,B-2381-A;n:type:ShaderForge.SFN_ValueProperty,id:9295,x:32271,y:33127,ptovrint:False,ptlb:ZT,ptin:_ZT,varname:node_9295,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:3;proporder:6074-797-4885-6962-1994-9295;pass:END;sub:END;*/

Shader "H/Par/H_Par_liuguang_Add" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _TintColor ("Color", Color) = (0.5,0.5,0.5,1)
        _MASK ("MASK", 2D) = "white" {}
        _Slider ("Slider", Range(0, 1)) = 1
        [MaterialToggle] _UorV ("UorV", Float ) = -1
        _ZT ("ZT", Float ) = 3
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
            Cull Off
            ZWrite Off
            colormask rgb
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
           // #pragma multi_compile_fwdbase
          //  #pragma multi_compile_fog
          // #pragma exclude_renderers xbox360 xboxone ps3 ps4 psp2 
          //  #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _TintColor;
            uniform sampler2D _MASK; uniform float4 _MASK_ST;
            uniform float _Slider;
            uniform fixed _UorV;
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
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                float node_4127 = ((_Slider*i.vertexColor.a)*2.0+-1.0);
                float2 _UorV_var = lerp( (i.uv0+node_4127*float2(0,1)), (i.uv0+node_4127*float2(1,0)), _UorV );
                float4 _MASK_var = tex2D(_MASK,TRANSFORM_TEX(_UorV_var, _MASK));
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float3 emissive = ((_MASK_var.rgb*_MainTex_var.rgb*_MASK_var.a*_MainTex_var.a)*i.vertexColor.rgb*_TintColor.rgb*_ZT);
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
