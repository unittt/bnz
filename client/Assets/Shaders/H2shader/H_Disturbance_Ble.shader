// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:True,fgod:False,fgor:False,fgmd:0,fgcr:0,fgcg:0,fgcb:0,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:True,fnsp:True,fnfb:True;n:type:ShaderForge.SFN_Final,id:4795,x:32863,y:32693,varname:node_4795,prsc:2|emission-2393-OUT,alpha-7438-OUT;n:type:ShaderForge.SFN_Tex2d,id:6074,x:31989,y:32605,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:_MainTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:8ff5a1d6e481b6d4d8869ee4b06c120f,ntxv:0,isnm:False|UVIN-8842-OUT;n:type:ShaderForge.SFN_Multiply,id:2393,x:32667,y:32770,varname:node_2393,prsc:2|A-4302-OUT,B-797-RGB,C-2499-RGB;n:type:ShaderForge.SFN_Color,id:797,x:32245,y:32920,ptovrint:True,ptlb:Color,ptin:_TintColor,varname:_TintColor,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Tex2d,id:849,x:32071,y:33028,ptovrint:False,ptlb:MASK,ptin:_MASK,varname:_MASK,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Add,id:8842,x:31801,y:32608,varname:node_8842,prsc:2|A-5135-OUT,B-2668-OUT;n:type:ShaderForge.SFN_Tex2d,id:1963,x:31066,y:32760,ptovrint:False,ptlb:Tex_Dis,ptin:_Tex_Dis,varname:node_1963,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7acc33f24a06fcd46baa112415b42195,ntxv:0,isnm:False|UVIN-584-OUT;n:type:ShaderForge.SFN_Multiply,id:2668,x:31350,y:32790,varname:node_2668,prsc:2|A-1963-R,B-5425-OUT,C-3813-OUT,D-1963-A;n:type:ShaderForge.SFN_Vector1,id:3813,x:31062,y:33048,varname:node_3813,prsc:2,v1:0.01;n:type:ShaderForge.SFN_ValueProperty,id:5425,x:31069,y:32965,ptovrint:False,ptlb:Disturbance,ptin:_Disturbance,varname:node_5425,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Multiply,id:9234,x:32240,y:32661,varname:node_9234,prsc:2|A-6074-RGB,B-4926-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4926,x:32026,y:32776,ptovrint:False,ptlb:ZT,ptin:_ZT,varname:node_4926,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Power,id:4302,x:32415,y:32739,varname:node_4302,prsc:2|VAL-9234-OUT,EXP-4624-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4624,x:32182,y:32829,ptovrint:False,ptlb:Power,ptin:_Power,varname:node_4624,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_VertexColor,id:2499,x:32327,y:33193,varname:node_2499,prsc:2;n:type:ShaderForge.SFN_Multiply,id:9604,x:32319,y:33047,varname:node_9604,prsc:2|A-849-R,B-849-A;n:type:ShaderForge.SFN_Append,id:5135,x:31540,y:32571,varname:node_5135,prsc:2|A-5898-OUT,B-1565-OUT;n:type:ShaderForge.SFN_TexCoord,id:4396,x:31164,y:32477,varname:node_4396,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:3224,x:31165,y:32346,varname:node_3224,prsc:2|A-8387-TSL,B-7592-OUT;n:type:ShaderForge.SFN_Time,id:8387,x:30952,y:32323,varname:node_8387,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:7592,x:30962,y:32439,ptovrint:False,ptlb:U_Sapeed,ptin:_U_Sapeed,varname:node_7592,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Add,id:5898,x:31342,y:32410,varname:node_5898,prsc:2|A-3224-OUT,B-4396-U;n:type:ShaderForge.SFN_Multiply,id:7290,x:31151,y:32623,varname:node_7290,prsc:2|A-6634-TSL,B-4956-OUT;n:type:ShaderForge.SFN_Time,id:6634,x:30937,y:32534,varname:node_6634,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:4956,x:30937,y:32704,ptovrint:False,ptlb:V_Speed,ptin:_V_Speed,varname:_U_Sapeed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Add,id:1565,x:31354,y:32625,varname:node_1565,prsc:2|A-4396-V,B-7290-OUT;n:type:ShaderForge.SFN_Append,id:584,x:30834,y:32750,varname:node_584,prsc:2|A-420-OUT,B-1638-OUT;n:type:ShaderForge.SFN_TexCoord,id:9952,x:30412,y:32769,varname:node_9952,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:753,x:30426,y:32623,varname:node_753,prsc:2|A-6168-TSL,B-8874-OUT;n:type:ShaderForge.SFN_Time,id:6168,x:30213,y:32600,varname:node_6168,prsc:2;n:type:ShaderForge.SFN_Add,id:420,x:30616,y:32664,varname:node_420,prsc:2|A-753-OUT,B-9952-U;n:type:ShaderForge.SFN_Multiply,id:5606,x:30452,y:32893,varname:node_5606,prsc:2|A-9212-TSL,B-6296-OUT;n:type:ShaderForge.SFN_Time,id:9212,x:30238,y:32804,varname:node_9212,prsc:2;n:type:ShaderForge.SFN_Add,id:1638,x:30641,y:32873,varname:node_1638,prsc:2|A-9952-V,B-5606-OUT;n:type:ShaderForge.SFN_ValueProperty,id:8874,x:30201,y:32769,ptovrint:False,ptlb:Dis_U_Speed,ptin:_Dis_U_Speed,varname:node_8874,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:4;n:type:ShaderForge.SFN_ValueProperty,id:6296,x:30230,y:32976,ptovrint:False,ptlb:Dis_V_Speed,ptin:_Dis_V_Speed,varname:_Dis_V_Speed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:7438,x:32659,y:32975,varname:node_7438,prsc:2|A-9604-OUT,B-2499-A,C-6074-A;proporder:797-4624-4926-6074-7592-4956-1963-5425-8874-6296-849;pass:END;sub:END;*/

Shader "H2/H_Disturbance_Ble" {
    Properties {
        _TintColor ("Color", Color) = (0.5,0.5,0.5,1)
        _Power ("Power", Float ) = 1
        _ZT ("ZT", Float ) = 2
        _MainTex ("MainTex", 2D) = "white" {}
        _U_Sapeed ("U_Sapeed", Float ) = 0
        _V_Speed ("V_Speed", Float ) = 0
        _Tex_Dis ("Tex_Dis", 2D) = "white" {}
        _Disturbance ("Disturbance", Float ) = 2
        _Dis_U_Speed ("Dis_U_Speed", Float ) = 4
        _Dis_V_Speed ("Dis_V_Speed", Float ) = 0
        _MASK ("MASK", 2D) = "white" {}
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
           // #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            //#pragma target 2.0
            uniform float4 _TimeEditor;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _TintColor;
            uniform sampler2D _MASK; uniform float4 _MASK_ST;
            uniform sampler2D _Tex_Dis; uniform float4 _Tex_Dis_ST;
            uniform float _Disturbance;
            uniform float _ZT;
            uniform float _Power;
            uniform float _U_Sapeed;
            uniform float _V_Speed;
            uniform float _Dis_U_Speed;
            uniform float _Dis_V_Speed;
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
                float4 node_8387 = _Time + _TimeEditor;
                float4 node_6634 = _Time + _TimeEditor;
                float4 node_6168 = _Time + _TimeEditor;
                float4 node_9212 = _Time + _TimeEditor;
                float2 node_584 = float2(((node_6168.r*_Dis_U_Speed)+i.uv0.r),(i.uv0.g+(node_9212.r*_Dis_V_Speed)));
                float4 _Tex_Dis_var = tex2D(_Tex_Dis,TRANSFORM_TEX(node_584, _Tex_Dis));
                float2 node_8842 = (float2(((node_8387.r*_U_Sapeed)+i.uv0.r),(i.uv0.g+(node_6634.r*_V_Speed)))+(_Tex_Dis_var.r*_Disturbance*0.01*_Tex_Dis_var.a));
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_8842, _MainTex));
                float3 emissive = (pow((_MainTex_var.rgb*_ZT),_Power)*_TintColor.rgb*i.vertexColor.rgb);
                float3 finalColor = emissive;
                float4 _MASK_var = tex2D(_MASK,TRANSFORM_TEX(i.uv0, _MASK));
                return fixed4(finalColor,((_MASK_var.r*_MASK_var.a)*i.vertexColor.a*_MainTex_var.a));
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
