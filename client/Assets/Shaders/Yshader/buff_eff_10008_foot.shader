// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:34133,y:32695,varname:node_3138,prsc:2|emission-9413-OUT,alpha-8082-OUT;n:type:ShaderForge.SFN_Tex2d,id:9816,x:31448,y:32956,ptovrint:False,ptlb:tex,ptin:_tex,varname:node_9816,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:653cd631021be5c429c78302fb57f7fd,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:8910,x:32382,y:32495,ptovrint:False,ptlb:node_8910,ptin:_node_8910,varname:node_8910,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7acc33f24a06fcd46baa112415b42195,ntxv:0,isnm:False|UVIN-312-UVOUT;n:type:ShaderForge.SFN_Tex2d,id:2028,x:32323,y:32662,ptovrint:False,ptlb:node_2028,ptin:_node_2028,varname:node_2028,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:6475569e57de23843b4c52854998a6af,ntxv:0,isnm:False|UVIN-2730-UVOUT;n:type:ShaderForge.SFN_Panner,id:312,x:32100,y:32484,varname:node_312,prsc:2,spu:0.1,spv:0.1|UVIN-6023-UVOUT;n:type:ShaderForge.SFN_Panner,id:2730,x:32100,y:32662,varname:node_2730,prsc:2,spu:-0.2,spv:-0.2|UVIN-2487-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:6023,x:31831,y:32526,varname:node_6023,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:1051,x:32639,y:32618,varname:node_1051,prsc:2|A-8910-RGB,B-2028-RGB;n:type:ShaderForge.SFN_Add,id:1478,x:32639,y:32778,varname:node_1478,prsc:2|A-5284-OUT,B-2025-OUT;n:type:ShaderForge.SFN_TexCoord,id:2487,x:31852,y:32705,varname:node_2487,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:7972,x:32907,y:32447,varname:node_7972,prsc:2|A-2200-RGB,B-1051-OUT;n:type:ShaderForge.SFN_Color,id:2200,x:32639,y:32434,ptovrint:False,ptlb:color,ptin:_color,varname:node_2200,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:0.64929,c3:0.3308824,c4:1;n:type:ShaderForge.SFN_Multiply,id:5284,x:33077,y:32447,varname:node_5284,prsc:2|A-7972-OUT,B-1059-OUT;n:type:ShaderForge.SFN_Slider,id:1059,x:32817,y:32624,ptovrint:False,ptlb:light_1,ptin:_light_1,varname:node_1059,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:4.875953,max:10;n:type:ShaderForge.SFN_VertexColor,id:2772,x:32415,y:33149,varname:node_2772,prsc:2;n:type:ShaderForge.SFN_Multiply,id:322,x:32988,y:32763,varname:node_322,prsc:2|A-1478-OUT,B-2772-RGB;n:type:ShaderForge.SFN_Multiply,id:4549,x:33042,y:32964,varname:node_4549,prsc:2|A-9816-A,B-2772-A;n:type:ShaderForge.SFN_Multiply,id:9413,x:33652,y:32622,varname:node_9413,prsc:2|A-322-OUT,B-9471-OUT;n:type:ShaderForge.SFN_Slider,id:9471,x:33173,y:32842,ptovrint:False,ptlb:qiangdu,ptin:_qiangdu,varname:node_9471,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:5;n:type:ShaderForge.SFN_Multiply,id:2025,x:32186,y:32955,varname:node_2025,prsc:2|A-9816-RGB,B-8382-RGB;n:type:ShaderForge.SFN_Color,id:8382,x:31702,y:32912,ptovrint:False,ptlb:color_x,ptin:_color_x,varname:node_8382,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_VertexColor,id:7481,x:31373,y:33557,varname:node_7481,prsc:2;n:type:ShaderForge.SFN_OneMinus,id:5812,x:31669,y:33530,varname:node_5812,prsc:2|IN-7481-A;n:type:ShaderForge.SFN_RemapRange,id:584,x:31862,y:33572,varname:node_584,prsc:2,frmn:0,frmx:1,tomn:-0.01,tomx:1|IN-5812-OUT;n:type:ShaderForge.SFN_Slider,id:4976,x:31530,y:33353,ptovrint:False,ptlb:diss_amount,ptin:_diss_amount,varname:node_4976,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_SwitchProperty,id:2908,x:32067,y:33453,ptovrint:False,ptlb:kaiguan,ptin:_kaiguan,varname:node_2908,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-4976-OUT,B-584-OUT;n:type:ShaderForge.SFN_Tex2d,id:8394,x:31422,y:33157,ptovrint:False,ptlb:rongjie,ptin:_rongjie,varname:node_8394,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Desaturate,id:9327,x:31729,y:33158,varname:node_9327,prsc:2|COL-8394-RGB;n:type:ShaderForge.SFN_Multiply,id:9241,x:31935,y:33216,varname:node_9241,prsc:2|A-9327-OUT,B-8394-A;n:type:ShaderForge.SFN_Step,id:8786,x:32209,y:33316,varname:node_8786,prsc:2|A-9241-OUT,B-2908-OUT;n:type:ShaderForge.SFN_OneMinus,id:4218,x:32502,y:33378,varname:node_4218,prsc:2|IN-8786-OUT;n:type:ShaderForge.SFN_Multiply,id:6690,x:32974,y:33371,varname:node_6690,prsc:2|A-9816-A,B-4218-OUT;n:type:ShaderForge.SFN_Clamp01,id:8082,x:33259,y:33361,varname:node_8082,prsc:2|IN-6690-OUT;proporder:9816-8910-2028-2200-1059-9471-8382-4976-2908-8394;pass:END;sub:END;*/

Shader "Y/buff_eff_10008_foot" {
    Properties {
        _tex ("tex", 2D) = "white" {}
        _node_8910 ("node_8910", 2D) = "white" {}
        _node_2028 ("node_2028", 2D) = "white" {}
        _color ("color", Color) = (1,0.64929,0.3308824,1)
        _light_1 ("light_1", Range(0, 10)) = 4.875953
        _qiangdu ("qiangdu", Range(0, 5)) = 1
        _color_x ("color_x", Color) = (0.5,0.5,0.5,1)
        _diss_amount ("diss_amount", Range(0, 1)) = 0
        [MaterialToggle] _kaiguan ("kaiguan", Float ) = 0
        _rongjie ("rongjie", 2D) = "white" {}
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
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _tex; uniform float4 _tex_ST;
            uniform sampler2D _node_8910; uniform float4 _node_8910_ST;
            uniform sampler2D _node_2028; uniform float4 _node_2028_ST;
            uniform float4 _color;
            uniform float _light_1;
            uniform float _qiangdu;
            uniform float4 _color_x;
            uniform float _diss_amount;
            uniform fixed _kaiguan;
            uniform sampler2D _rongjie; uniform float4 _rongjie_ST;
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
                float4 node_9065 = _Time + _TimeEditor;
                float2 node_312 = (i.uv0+node_9065.g*float2(0.1,0.1));
                float4 _node_8910_var = tex2D(_node_8910,TRANSFORM_TEX(node_312, _node_8910));
                float2 node_2730 = (i.uv0+node_9065.g*float2(-0.2,-0.2));
                float4 _node_2028_var = tex2D(_node_2028,TRANSFORM_TEX(node_2730, _node_2028));
                float4 _tex_var = tex2D(_tex,TRANSFORM_TEX(i.uv0, _tex));
                float3 emissive = (((((_color.rgb*(_node_8910_var.rgb*_node_2028_var.rgb))*_light_1)+(_tex_var.rgb*_color_x.rgb))*i.vertexColor.rgb)*_qiangdu);
                float3 finalColor = emissive;
                float4 _rongjie_var = tex2D(_rongjie,TRANSFORM_TEX(i.uv0, _rongjie));
                return fixed4(finalColor,saturate((_tex_var.a*(1.0 - step((dot(_rongjie_var.rgb,float3(0.3,0.59,0.11))*_rongjie_var.a),lerp( _diss_amount, ((1.0 - i.vertexColor.a)*1.01+-0.01), _kaiguan ))))));
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
