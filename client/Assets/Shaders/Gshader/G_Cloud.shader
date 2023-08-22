// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:True,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33083,y:32748,varname:node_3138,prsc:2|emission-7942-OUT,alpha-6923-OUT;n:type:ShaderForge.SFN_Tex2dAsset,id:3029,x:31612,y:32159,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:_MainTex,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:3a4c87121d719a347a172d96d644e151,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:3223,x:32233,y:32733,varname:node_3223,prsc:2,tex:3a4c87121d719a347a172d96d644e151,ntxv:0,isnm:False|UVIN-7897-OUT,TEX-3029-TEX;n:type:ShaderForge.SFN_Tex2d,id:7790,x:32241,y:33112,varname:node_7790,prsc:2,tex:3a4c87121d719a347a172d96d644e151,ntxv:0,isnm:False|UVIN-5857-OUT,TEX-3029-TEX;n:type:ShaderForge.SFN_Tex2d,id:4590,x:32237,y:33536,varname:node_4590,prsc:2,tex:3a4c87121d719a347a172d96d644e151,ntxv:0,isnm:False|UVIN-3302-OUT,TEX-3029-TEX;n:type:ShaderForge.SFN_Time,id:4860,x:31135,y:32654,varname:node_4860,prsc:2;n:type:ShaderForge.SFN_Multiply,id:364,x:31397,y:32701,varname:node_364,prsc:2|A-4860-TSL,B-4211-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4211,x:31135,y:32840,ptovrint:False,ptlb:Speed1,ptin:_Speed1,varname:_Speed1,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_TexCoord,id:3348,x:31135,y:32331,varname:node_3348,prsc:2,uv:0;n:type:ShaderForge.SFN_Panner,id:291,x:31613,y:32613,varname:node_291,prsc:2,spu:-1,spv:0|UVIN-8459-OUT,DIST-364-OUT;n:type:ShaderForge.SFN_Add,id:6923,x:32736,y:33002,varname:node_6923,prsc:2|A-3223-R,B-7790-G,C-4590-B;n:type:ShaderForge.SFN_Multiply,id:8459,x:31397,y:32457,varname:node_8459,prsc:2|A-3348-UVOUT,B-6283-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6283,x:31135,y:32517,ptovrint:False,ptlb:Tiling1,ptin:_Tiling1,varname:_Tiling1,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Time,id:7135,x:31125,y:33272,varname:node_7135,prsc:2;n:type:ShaderForge.SFN_Multiply,id:4766,x:31387,y:33319,varname:node_4766,prsc:2|A-7135-TSL,B-206-OUT;n:type:ShaderForge.SFN_ValueProperty,id:206,x:31125,y:33458,ptovrint:False,ptlb:Speed2,ptin:_Speed2,varname:_Speed2,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_TexCoord,id:4119,x:31125,y:32949,varname:node_4119,prsc:2,uv:0;n:type:ShaderForge.SFN_Panner,id:7263,x:31603,y:33231,varname:node_7263,prsc:2,spu:-1,spv:0|UVIN-9459-OUT,DIST-4766-OUT;n:type:ShaderForge.SFN_Multiply,id:9459,x:31387,y:33075,varname:node_9459,prsc:2|A-4119-UVOUT,B-4210-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4210,x:31125,y:33135,ptovrint:False,ptlb:Tiling2,ptin:_Tiling2,varname:_Tiling2,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Time,id:423,x:31123,y:33874,varname:node_423,prsc:2;n:type:ShaderForge.SFN_Multiply,id:4346,x:31385,y:33921,varname:node_4346,prsc:2|A-423-TSL,B-5746-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5746,x:31123,y:34060,ptovrint:False,ptlb:Speed3,ptin:_Speed3,varname:_Speed3,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_TexCoord,id:5056,x:31123,y:33551,varname:node_5056,prsc:2,uv:0;n:type:ShaderForge.SFN_Panner,id:8515,x:31601,y:33833,varname:node_8515,prsc:2,spu:-1,spv:0|UVIN-5243-OUT,DIST-4346-OUT;n:type:ShaderForge.SFN_Multiply,id:5243,x:31385,y:33677,varname:node_5243,prsc:2|A-5056-UVOUT,B-3799-OUT;n:type:ShaderForge.SFN_ValueProperty,id:3799,x:31123,y:33737,ptovrint:False,ptlb:Tiling3,ptin:_Tiling3,varname:_Tiling3,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Add,id:5857,x:31944,y:33104,varname:node_5857,prsc:2|A-7263-UVOUT,B-6296-OUT;n:type:ShaderForge.SFN_Slider,id:1472,x:31369,y:33492,ptovrint:False,ptlb:offset2,ptin:_offset2,varname:node_1472,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Append,id:6296,x:31752,y:33352,varname:node_6296,prsc:2|A-1472-OUT,B-1472-OUT;n:type:ShaderForge.SFN_Color,id:7058,x:32550,y:32630,ptovrint:False,ptlb:Color1,ptin:_Color,varname:node_7058,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Add,id:3302,x:32022,y:33678,varname:node_3302,prsc:2|A-8515-UVOUT,B-5300-OUT;n:type:ShaderForge.SFN_Slider,id:4404,x:31371,y:34147,ptovrint:False,ptlb:offset3,ptin:_offset3,varname:node_4404,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Append,id:5300,x:31859,y:33925,varname:node_5300,prsc:2|A-4404-OUT,B-8264-OUT;n:type:ShaderForge.SFN_Negate,id:8264,x:31696,y:34059,varname:node_8264,prsc:2|IN-4404-OUT;n:type:ShaderForge.SFN_Lerp,id:7942,x:32836,y:32713,varname:node_7942,prsc:2|A-7058-RGB,B-4058-RGB,T-6923-OUT;n:type:ShaderForge.SFN_Color,id:4058,x:32550,y:32792,ptovrint:False,ptlb:Color2,ptin:_Color2,varname:node_4058,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Add,id:7897,x:31950,y:32669,varname:node_7897,prsc:2|A-291-UVOUT,B-5878-OUT;n:type:ShaderForge.SFN_Append,id:5878,x:31798,y:32783,varname:node_5878,prsc:2|A-9187-OUT,B-5641-OUT;n:type:ShaderForge.SFN_Slider,id:5641,x:31452,y:32962,ptovrint:False,ptlb:offset1,ptin:_offset1,varname:node_5641,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Multiply,id:9187,x:31641,y:32783,varname:node_9187,prsc:2|A-2169-OUT,B-5641-OUT;n:type:ShaderForge.SFN_Vector1,id:2169,x:31397,y:32845,varname:node_2169,prsc:2,v1:2;proporder:7058-4058-3029-4211-206-5746-6283-4210-3799-5641-1472-4404;pass:END;sub:END;*/

Shader "G/G_Cloud" {
    Properties {
        _Color ("Color1", Color) = (1,1,1,1)
        _Color2 ("Color2", Color) = (0.5,0.5,0.5,1)
        _Alpha("Alpha", Range(0, 1)) = 1
        _MainTex ("MainTex", 2D) = "white" {}
        _Speed1 ("Speed1", Float ) = 1
        _Speed2 ("Speed2", Float ) = 1
        _Speed3 ("Speed3", Float ) = 1
        _Tiling1 ("Tiling1", Float ) = 1
        _Tiling2 ("Tiling2", Float ) = 1
        _Tiling3 ("Tiling3", Float ) = 1
        _offset1 ("offset1", Range(0, 1)) = 0
        _offset2 ("offset2", Range(0, 1)) = 0
        _offset3 ("offset3", Range(0, 1)) = 0
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
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            //#pragma multi_compile_fwdbase
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 2.0
            uniform float4 _TimeEditor;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float _Speed1;
            uniform float _Tiling1;
            uniform float _Speed2;
            uniform float _Tiling2;
            uniform float _Speed3;
            uniform float _Tiling3;
            uniform float _offset2;
            uniform float4 _Color;
            uniform float _offset3;
            uniform float4 _Color2;
            uniform float _offset1;
            uniform float _Alpha;
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
                float4 node_4860 = _Time + _TimeEditor;
                float2 node_7897 = (((i.uv0*_Tiling1)+(node_4860.r*_Speed1)*float2(-1,0))+float2((2.0*_offset1),_offset1));
                float4 node_3223 = tex2D(_MainTex,TRANSFORM_TEX(node_7897, _MainTex));
                float4 node_7135 = _Time + _TimeEditor;
                float2 node_5857 = (((i.uv0*_Tiling2)+(node_7135.r*_Speed2)*float2(-1,0))+float2(_offset2,_offset2));
                float4 node_7790 = tex2D(_MainTex,TRANSFORM_TEX(node_5857, _MainTex));
                float4 node_423 = _Time + _TimeEditor;
                float2 node_3302 = (((i.uv0*_Tiling3)+(node_423.r*_Speed3)*float2(-1,0))+float2(_offset3,(-1*_offset3)));
                float4 node_4590 = tex2D(_MainTex,TRANSFORM_TEX(node_3302, _MainTex));
                float node_6923 = (node_3223.r+node_7790.g+node_4590.b);
                float3 finalColor = lerp(_Color.rgb, _Color2.rgb, node_6923);
                return fixed4(finalColor,node_6923 * _Color.a * _Alpha);
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
