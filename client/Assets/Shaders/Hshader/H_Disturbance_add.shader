// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:True,fgod:False,fgor:False,fgmd:0,fgcr:0,fgcg:0,fgcb:0,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:True,fnsp:True,fnfb:True;n:type:ShaderForge.SFN_Final,id:4795,x:32863,y:32693,varname:node_4795,prsc:2|emission-2393-OUT;n:type:ShaderForge.SFN_Tex2d,id:6074,x:31908,y:32635,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:_MainTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:afbfd3ef2a6a85743b87688e97e2173b,ntxv:0,isnm:False|UVIN-8842-OUT;n:type:ShaderForge.SFN_Multiply,id:2393,x:32553,y:32793,varname:node_2393,prsc:2|A-4302-OUT,B-797-RGB,C-9604-OUT,D-2499-RGB,E-2499-A;n:type:ShaderForge.SFN_Color,id:797,x:32170,y:32982,ptovrint:True,ptlb:Color,ptin:_TintColor,varname:_TintColor,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Tex2d,id:849,x:32024,y:33129,ptovrint:False,ptlb:MASK,ptin:_MASK,varname:_MASK,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Add,id:8842,x:31655,y:32652,varname:node_8842,prsc:2|A-3073-OUT,B-2668-OUT;n:type:ShaderForge.SFN_Tex2d,id:1963,x:31109,y:32891,ptovrint:False,ptlb:Disturbance,ptin:_Disturbance,varname:node_1963,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7acc33f24a06fcd46baa112415b42195,ntxv:0,isnm:False|UVIN-6081-OUT;n:type:ShaderForge.SFN_Multiply,id:2668,x:31449,y:32859,varname:node_2668,prsc:2|A-1963-R,B-5425-OUT,C-3813-OUT,D-1963-A;n:type:ShaderForge.SFN_Vector1,id:3813,x:31121,y:33198,varname:node_3813,prsc:2,v1:0.01;n:type:ShaderForge.SFN_ValueProperty,id:5425,x:31121,y:33099,ptovrint:False,ptlb:Disturbance_QD ,ptin:_Disturbance_QD,varname:node_5425,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Multiply,id:9234,x:32113,y:32713,varname:node_9234,prsc:2|A-6074-RGB,B-4926-OUT,C-6074-A;n:type:ShaderForge.SFN_ValueProperty,id:4926,x:31892,y:32883,ptovrint:False,ptlb:ZT,ptin:_ZT,varname:node_4926,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Power,id:4302,x:32301,y:32762,varname:node_4302,prsc:2|VAL-9234-OUT,EXP-4624-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4624,x:32071,y:32881,ptovrint:False,ptlb:Power,ptin:_Power,varname:node_4624,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_VertexColor,id:2499,x:32023,y:33329,varname:node_2499,prsc:2;n:type:ShaderForge.SFN_Multiply,id:9604,x:32263,y:33115,varname:node_9604,prsc:2|A-849-RGB,B-849-A;n:type:ShaderForge.SFN_Append,id:3073,x:31292,y:32580,varname:node_3073,prsc:2|A-1383-OUT,B-444-OUT;n:type:ShaderForge.SFN_TexCoord,id:6628,x:30071,y:32772,varname:node_6628,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:2172,x:30837,y:32484,varname:node_2172,prsc:2|A-3069-TSL,B-2958-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2958,x:30244,y:32598,ptovrint:False,ptlb:U_Speed,ptin:_U_Speed,varname:node_2958,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Add,id:1383,x:31065,y:32544,varname:node_1383,prsc:2|A-2172-OUT,B-6628-U;n:type:ShaderForge.SFN_ValueProperty,id:6764,x:30373,y:32790,ptovrint:False,ptlb:V_Speed,ptin:_V_Speed,varname:_U_Speed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:7903,x:30776,y:32745,varname:node_7903,prsc:2|A-3069-TSL,B-6764-OUT;n:type:ShaderForge.SFN_Add,id:444,x:31094,y:32704,varname:node_444,prsc:2|A-6628-V,B-7903-OUT;n:type:ShaderForge.SFN_Append,id:6081,x:30898,y:32904,varname:node_6081,prsc:2|A-8976-OUT,B-832-OUT;n:type:ShaderForge.SFN_Multiply,id:1606,x:30426,y:32849,varname:node_1606,prsc:2|A-3069-TSL,B-6147-OUT;n:type:ShaderForge.SFN_Time,id:3069,x:30072,y:32644,varname:node_3069,prsc:2;n:type:ShaderForge.SFN_Add,id:8976,x:30671,y:32868,varname:node_8976,prsc:2|A-1606-OUT,B-6628-U;n:type:ShaderForge.SFN_ValueProperty,id:9826,x:30168,y:33242,ptovrint:False,ptlb:DisV_Speed,ptin:_DisV_Speed,varname:_V_Speed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:2977,x:30433,y:33127,varname:node_2977,prsc:2|A-3069-TSL,B-9826-OUT;n:type:ShaderForge.SFN_Add,id:832,x:30700,y:33028,varname:node_832,prsc:2|A-6628-V,B-2977-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6147,x:30093,y:32972,ptovrint:False,ptlb:DisU_Speed,ptin:_DisU_Speed,varname:node_6147,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:6248,x:30452,y:33224,ptovrint:False,ptlb:DisU_Speed_copy,ptin:_DisU_Speed_copy,varname:_DisU_Speed_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;proporder:6074-2958-6764-797-4926-4624-1963-9826-6147-5425-849;pass:END;sub:END;*/

Shader "H/H_Disturbance_Add" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _U_Speed ("U_Speed", Float ) = 0
        _V_Speed ("V_Speed", Float ) = 0
        _TintColor ("Color", Color) = (0.5,0.5,0.5,1)
        _ZT ("ZT", Float ) = 1
        _Power ("Power", Float ) = 1
        _Disturbance ("Disturbance", 2D) = "white" {}
        _DisV_Speed ("DisV_Speed", Float ) = 0
        _DisU_Speed ("DisU_Speed", Float ) = 0
        _Disturbance_QD ("Disturbance_QD ", Float ) = 2
        _MASK ("MASK", 2D) = "white" {}
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
           // #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
           // #pragma target 2.0
            uniform float4 _TimeEditor;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _TintColor;
            uniform sampler2D _MASK; uniform float4 _MASK_ST;
            uniform sampler2D _Disturbance; uniform float4 _Disturbance_ST;
            uniform float _Disturbance_QD;
            uniform float _ZT;
            uniform float _Power;
            uniform float _U_Speed;
            uniform float _V_Speed;
            uniform float _DisV_Speed;
            uniform float _DisU_Speed;
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
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float4 node_3069 = _Time + _TimeEditor;
                float2 node_6081 = float2(((node_3069.r*_DisU_Speed)+i.uv0.r),(i.uv0.g+(node_3069.r*_DisV_Speed)));
                float4 _Disturbance_var = tex2D(_Disturbance,TRANSFORM_TEX(node_6081, _Disturbance));
                float2 node_8842 = (float2(((node_3069.r*_U_Speed)+i.uv0.r),(i.uv0.g+(node_3069.r*_V_Speed)))+(_Disturbance_var.r*_Disturbance_QD*0.01*_Disturbance_var.a));
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_8842, _MainTex));
                float4 _MASK_var = tex2D(_MASK,TRANSFORM_TEX(i.uv0, _MASK));
                float3 emissive = (pow((_MainTex_var.rgb*_ZT*_MainTex_var.a),_Power)*_TintColor.rgb*(_MASK_var.rgb*_MASK_var.a)*i.vertexColor.rgb*i.vertexColor.a);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
