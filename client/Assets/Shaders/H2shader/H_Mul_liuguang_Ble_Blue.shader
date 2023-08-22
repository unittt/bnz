// Shader created with Shader Forge v1.35 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.35;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:14,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:True,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True;n:type:ShaderForge.SFN_Final,id:4795,x:32173,y:32535,varname:node_4795,prsc:2|emission-2393-OUT,alpha-9464-OUT;n:type:ShaderForge.SFN_Tex2d,id:6074,x:31598,y:32980,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:_MainTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:00f05a73b7d166c418d0608e83b95e01,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:2393,x:31861,y:32596,varname:node_2393,prsc:2|A-99-OUT,B-9248-OUT,C-797-RGB,D-2053-RGB;n:type:ShaderForge.SFN_VertexColor,id:2053,x:31734,y:32801,varname:node_2053,prsc:2;n:type:ShaderForge.SFN_Color,id:797,x:31582,y:32791,ptovrint:True,ptlb:Color,ptin:_TintColor,varname:_TintColor,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.6,c2:2,c3:0.5,c4:1;n:type:ShaderForge.SFN_Vector1,id:9248,x:31556,y:32438,varname:node_9248,prsc:2,v1:2;n:type:ShaderForge.SFN_Append,id:2664,x:30627,y:32484,varname:node_2664,prsc:2|A-9290-OUT,B-37-OUT;n:type:ShaderForge.SFN_TexCoord,id:6184,x:30157,y:32524,varname:node_6184,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Add,id:9290,x:30417,y:32400,varname:node_9290,prsc:2|A-8940-OUT,B-6184-U;n:type:ShaderForge.SFN_Multiply,id:8940,x:30157,y:32375,varname:node_8940,prsc:2|A-2703-TSL,B-961-OUT;n:type:ShaderForge.SFN_Time,id:2703,x:29840,y:32363,varname:node_2703,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:961,x:29840,y:32512,ptovrint:False,ptlb:U_Speed01,ptin:_U_Speed01,varname:node_961,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Add,id:37,x:30408,y:32660,varname:node_37,prsc:2|A-6184-V,B-1653-OUT;n:type:ShaderForge.SFN_Tex2d,id:3191,x:30823,y:32484,ptovrint:False,ptlb:Liuguang01,ptin:_Liuguang01,varname:node_3191,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:151e00485d3690f468aa9147bde608ff,ntxv:0,isnm:False|UVIN-2664-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2826,x:29852,y:32725,ptovrint:False,ptlb:V_Speed01,ptin:_V_Speed01,varname:_node_961_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:1653,x:30157,y:32714,varname:node_1653,prsc:2|A-2703-TSL,B-2826-OUT;n:type:ShaderForge.SFN_Multiply,id:8903,x:31144,y:32520,varname:node_8903,prsc:2|A-3191-R,B-4055-R;n:type:ShaderForge.SFN_Append,id:908,x:30610,y:32814,varname:node_908,prsc:2|A-2253-OUT,B-8936-OUT;n:type:ShaderForge.SFN_TexCoord,id:8053,x:30133,y:32993,varname:node_8053,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Add,id:2253,x:30393,y:32834,varname:node_2253,prsc:2|A-72-OUT,B-8053-U;n:type:ShaderForge.SFN_Multiply,id:72,x:30133,y:32844,varname:node_72,prsc:2|A-2703-TSL,B-8448-OUT;n:type:ShaderForge.SFN_ValueProperty,id:8448,x:29837,y:32933,ptovrint:False,ptlb:U_Speed02,ptin:_U_Speed02,varname:_U_Speed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Add,id:8936,x:30409,y:33064,varname:node_8936,prsc:2|A-8053-V,B-5279-OUT;n:type:ShaderForge.SFN_Tex2d,id:4055,x:30801,y:32814,ptovrint:False,ptlb:Liuguang02,ptin:_Liuguang02,varname:_LiuGuang_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:ad6081b088d0376479358f4945dc40e8,ntxv:0,isnm:False|UVIN-908-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5518,x:29842,y:33208,ptovrint:False,ptlb:V_Speed02,ptin:_V_Speed02,varname:_V_Speed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:5279,x:30133,y:33166,varname:node_5279,prsc:2|A-2703-TSL,B-5518-OUT;n:type:ShaderForge.SFN_Multiply,id:99,x:31626,y:32567,varname:node_99,prsc:2|A-1085-OUT,B-7787-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7787,x:31377,y:32679,ptovrint:False,ptlb:Liuguang_ZT,ptin:_Liuguang_ZT,varname:node_7787,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:4;n:type:ShaderForge.SFN_Power,id:1085,x:31364,y:32526,varname:node_1085,prsc:2|VAL-8903-OUT,EXP-5850-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5850,x:31127,y:32710,ptovrint:False,ptlb:Liuguang_power,ptin:_Liuguang_power,varname:node_5850,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1.3;n:type:ShaderForge.SFN_Multiply,id:9464,x:31998,y:32865,varname:node_9464,prsc:2|A-6074-R,B-6074-A,C-2053-A,D-2402-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2402,x:31768,y:33170,ptovrint:False,ptlb:Alpha,ptin:_Alpha,varname:node_2402,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;proporder:6074-797-7787-2402-5850-3191-961-2826-4055-8448-5518;pass:END;sub:END;*/

Shader "H2/H_Mul_liuguang_Ble_Blue" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _TintColor ("Color", Color) = (0.6,2,0.5,1)
        _Liuguang_ZT ("Liuguang_ZT", Float ) = 4
        _Alpha ("Alpha", Float ) = 1
        _Liuguang_power ("Liuguang_power", Float ) = 1.3
        _Liuguang01 ("Liuguang01", 2D) = "white" {}
        _U_Speed01 ("U_Speed01", Float ) = 1
        _V_Speed01 ("V_Speed01", Float ) = 0
        _Liuguang02 ("Liuguang02", 2D) = "white" {}
        _U_Speed02 ("U_Speed02", Float ) = 1
        _V_Speed02 ("V_Speed02", Float ) = 0
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
            ColorMask RGB
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
           // #pragma multi_compile_fwdbase
          //  #pragma only_renderers d3d9 d3d11 glcore gles n3ds wiiu 
            //#pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _TintColor;
            uniform float _U_Speed01;
            uniform sampler2D _Liuguang01; uniform float4 _Liuguang01_ST;
            uniform float _V_Speed01;
            uniform float _U_Speed02;
            uniform sampler2D _Liuguang02; uniform float4 _Liuguang02_ST;
            uniform float _V_Speed02;
            uniform float _Liuguang_ZT;
            uniform float _Liuguang_power;
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
                float4 node_2703 = _Time + _TimeEditor;
                float2 node_2664 = float2(((node_2703.r*_U_Speed01)+i.uv0.r),(i.uv0.g+(node_2703.r*_V_Speed01)));
                float4 _Liuguang01_var = tex2D(_Liuguang01,TRANSFORM_TEX(node_2664, _Liuguang01));
                float2 node_908 = float2(((node_2703.r*_U_Speed02)+i.uv0.r),(i.uv0.g+(node_2703.r*_V_Speed02)));
                float4 _Liuguang02_var = tex2D(_Liuguang02,TRANSFORM_TEX(node_908, _Liuguang02));
                float3 emissive = ((pow((_Liuguang01_var.r*_Liuguang02_var.r),_Liuguang_power)*_Liuguang_ZT)*2.0*_TintColor.rgb*i.vertexColor.rgb);
                float3 finalColor = emissive;
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                return fixed4(finalColor,(_MainTex_var.r*_MainTex_var.a*i.vertexColor.a*_Alpha));
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
