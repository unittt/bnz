// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0,fgcg:0,fgcb:0,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True;n:type:ShaderForge.SFN_Final,id:4795,x:32949,y:32663,varname:node_4795,prsc:2|emission-3499-OUT,alpha-798-OUT;n:type:ShaderForge.SFN_Multiply,id:798,x:32651,y:32811,varname:node_798,prsc:2|A-245-A,B-2308-A,C-3953-A,D-3965-A,E-3629-OUT;n:type:ShaderForge.SFN_Tex2d,id:3965,x:31641,y:32570,ptovrint:False,ptlb:MainTex_copy,ptin:_MainTex_copy,varname:_MainTex_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:3499,x:32372,y:32610,varname:node_3499,prsc:2|A-4365-OUT,B-2308-RGB,C-3953-RGB,D-5135-OUT;n:type:ShaderForge.SFN_VertexColor,id:2308,x:31659,y:32788,varname:node_2308,prsc:2;n:type:ShaderForge.SFN_Color,id:3953,x:31642,y:32945,ptovrint:True,ptlb:Color,ptin:_TintColor,varname:_TintColor,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Tex2d,id:245,x:31663,y:32366,ptovrint:False,ptlb:MainTeX_Mask,ptin:_MainTeX_Mask,varname:_MainTex_copy_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-6092-OUT;n:type:ShaderForge.SFN_Panner,id:6378,x:31179,y:32362,varname:node_6378,prsc:2,spu:0,spv:1|UVIN-9590-UVOUT,DIST-485-OUT;n:type:ShaderForge.SFN_TexCoord,id:9590,x:30903,y:32328,varname:node_9590,prsc:2,uv:0;n:type:ShaderForge.SFN_Slider,id:2810,x:30356,y:32409,ptovrint:False,ptlb:Slider,ptin:_Slider,varname:node_6962,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Multiply,id:4365,x:32163,y:32437,varname:node_4365,prsc:2|A-245-RGB,B-3965-RGB;n:type:ShaderForge.SFN_RemapRange,id:485,x:30932,y:32480,varname:node_485,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-3080-OUT;n:type:ShaderForge.SFN_Panner,id:5867,x:31246,y:32531,varname:node_5867,prsc:2,spu:1,spv:0|UVIN-9590-UVOUT,DIST-485-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:6092,x:31484,y:32383,ptovrint:False,ptlb:UorV,ptin:_UorV,varname:node_1994,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:True|A-6378-UVOUT,B-5867-UVOUT;n:type:ShaderForge.SFN_VertexColor,id:8508,x:30369,y:32516,varname:node_8508,prsc:2;n:type:ShaderForge.SFN_Multiply,id:3080,x:30709,y:32519,varname:node_3080,prsc:2|A-2810-OUT,B-8508-A;n:type:ShaderForge.SFN_ValueProperty,id:5135,x:31970,y:32799,ptovrint:False,ptlb:ZT,ptin:_ZT,varname:node_9295,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:3;n:type:ShaderForge.SFN_ValueProperty,id:3629,x:32201,y:33032,ptovrint:False,ptlb:Alpha,ptin:_Alpha,varname:node_3629,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;proporder:3965-245-2810-6092-3953-5135-3629;pass:END;sub:END;*/

Shader "H/Par/H_Par_liuguang_Ble" {
    Properties {
        _MainTex_copy ("MainTex_copy", 2D) = "white" {}
        _MainTeX_Mask ("MainTeX_Mask", 2D) = "white" {}
        _Slider ("Slider", Range(0, 1)) = 1
        [MaterialToggle] _UorV ("UorV", Float ) = -1
        _TintColor ("Color", Color) = (0.5,0.5,0.5,1)
        _ZT ("ZT", Float ) = 3
        _Alpha ("Alpha", Float ) = 2
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
           // #pragma multi_compile_fog
          // #pragma exclude_renderers xbox360 xboxone ps3 ps4 psp2 
           // #pragma target 3.0
            uniform sampler2D _MainTex_copy; uniform float4 _MainTex_copy_ST;
            uniform float4 _TintColor;
            uniform sampler2D _MainTeX_Mask; uniform float4 _MainTeX_Mask_ST;
            uniform float _Slider;
            uniform fixed _UorV;
            uniform float _ZT;
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
                float node_485 = ((_Slider*i.vertexColor.a)*2.0+-1.0);
                float2 _UorV_var = lerp( (i.uv0+node_485*float2(0,1)), (i.uv0+node_485*float2(1,0)), _UorV );
                float4 _MainTeX_Mask_var = tex2D(_MainTeX_Mask,TRANSFORM_TEX(_UorV_var, _MainTeX_Mask));
                float4 _MainTex_copy_var = tex2D(_MainTex_copy,TRANSFORM_TEX(i.uv0, _MainTex_copy));
                float3 emissive = ((_MainTeX_Mask_var.rgb*_MainTex_copy_var.rgb)*i.vertexColor.rgb*_TintColor.rgb*_ZT);
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,(_MainTeX_Mask_var.a*i.vertexColor.a*_TintColor.a*_MainTex_copy_var.a*_Alpha));
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
