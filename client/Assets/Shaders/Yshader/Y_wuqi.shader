// Shader created with Shader Forge v1.30 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.30;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:34836,y:32466,varname:node_3138,prsc:2|emission-5491-OUT,alpha-8594-OUT;n:type:ShaderForge.SFN_Tex2d,id:3916,x:32583,y:32952,ptovrint:False,ptlb:TEX,ptin:_TEX,varname:_TEX,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:b80e0499a3f13cb4b9e83b937143bf8a,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:2112,x:31292,y:32971,ptovrint:False,ptlb:wenli_1,ptin:_wenli_1,varname:_wenli_1,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7acc33f24a06fcd46baa112415b42195,ntxv:0,isnm:False|UVIN-8909-OUT;n:type:ShaderForge.SFN_Tex2d,id:9036,x:31303,y:32784,ptovrint:False,ptlb:wenli_2,ptin:_wenli_2,varname:_wenli_2,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:b9a7f5fb90567434992ff4737f365378,ntxv:0,isnm:False|UVIN-2015-OUT;n:type:ShaderForge.SFN_TexCoord,id:6648,x:30638,y:32797,varname:node_6648,prsc:2,uv:0;n:type:ShaderForge.SFN_Time,id:8825,x:30501,y:32698,varname:node_8825,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:5519,x:30618,y:32525,ptovrint:False,ptlb:U1,ptin:_U1,varname:_U1,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.1;n:type:ShaderForge.SFN_ValueProperty,id:9171,x:30550,y:32625,ptovrint:False,ptlb:V1,ptin:_V1,varname:_V1,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.1;n:type:ShaderForge.SFN_Append,id:6450,x:30823,y:32525,varname:node_6450,prsc:2|A-5519-OUT,B-9171-OUT;n:type:ShaderForge.SFN_Multiply,id:9206,x:31018,y:32507,varname:node_9206,prsc:2|A-6450-OUT,B-8825-T;n:type:ShaderForge.SFN_Add,id:2015,x:31205,y:32549,varname:node_2015,prsc:2|A-9206-OUT,B-6648-UVOUT;n:type:ShaderForge.SFN_ValueProperty,id:2057,x:30516,y:33097,ptovrint:False,ptlb:U2,ptin:_U2,varname:_U2,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:-0.1;n:type:ShaderForge.SFN_ValueProperty,id:6138,x:30448,y:33197,ptovrint:False,ptlb:V2,ptin:_V2,varname:_V2,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:-0.2;n:type:ShaderForge.SFN_Append,id:6427,x:30720,y:33121,varname:node_6427,prsc:2|A-2057-OUT,B-6138-OUT;n:type:ShaderForge.SFN_Multiply,id:6362,x:30912,y:33121,varname:node_6362,prsc:2|A-6427-OUT,B-8825-T;n:type:ShaderForge.SFN_Add,id:8909,x:31103,y:33121,varname:node_8909,prsc:2|A-6362-OUT,B-6648-UVOUT;n:type:ShaderForge.SFN_Multiply,id:1516,x:31590,y:32828,varname:node_1516,prsc:2|A-9036-R,B-2112-R,C-7721-R;n:type:ShaderForge.SFN_Tex2d,id:7721,x:31409,y:33090,ptovrint:False,ptlb:zhezhao_1,ptin:_zhezhao_1,varname:_zhezhao_1,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:411c200152f76c442bf486755b6085a6,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:2486,x:31779,y:32814,varname:node_2486,prsc:2|A-1516-OUT,B-5691-OUT;n:type:ShaderForge.SFN_Slider,id:5691,x:31512,y:32979,ptovrint:False,ptlb:liangdu,ptin:_liangdu,varname:_liangdu,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:5,max:5;n:type:ShaderForge.SFN_Multiply,id:7489,x:31871,y:32688,varname:node_7489,prsc:2|A-849-RGB,B-2486-OUT;n:type:ShaderForge.SFN_Color,id:849,x:31657,y:32522,ptovrint:False,ptlb:color_1,ptin:_color_1,varname:_color_1,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Add,id:3999,x:32959,y:32548,varname:node_3999,prsc:2|A-7489-OUT,B-8693-OUT,C-3916-RGB,D-6887-OUT,E-8639-OUT;n:type:ShaderForge.SFN_Tex2d,id:6681,x:31593,y:33266,ptovrint:False,ptlb:zhehzao_2,ptin:_zhehzao_2,varname:_zhehzao_2,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:041e185de0d8d274497d2e801aa497a1,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:4480,x:31840,y:33255,varname:node_4480,prsc:2|A-9036-R,B-6681-RGB;n:type:ShaderForge.SFN_Multiply,id:8693,x:32100,y:33054,varname:node_8693,prsc:2|A-4480-OUT,B-4696-RGB;n:type:ShaderForge.SFN_Color,id:4696,x:31896,y:33522,ptovrint:False,ptlb:color_2,ptin:_color_2,varname:_color_2,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:0.5846856,c3:0.1397059,c4:1;n:type:ShaderForge.SFN_Time,id:9770,x:31184,y:31900,varname:node_9770,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:1004,x:31204,y:32154,ptovrint:False,ptlb:sin,ptin:_sin,varname:_sin,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Sin,id:8837,x:31658,y:31908,varname:node_8837,prsc:2|IN-3173-OUT;n:type:ShaderForge.SFN_Multiply,id:3173,x:31476,y:31908,varname:node_3173,prsc:2|A-9770-T,B-1004-OUT;n:type:ShaderForge.SFN_Add,id:7906,x:31974,y:31919,varname:node_7906,prsc:2|A-8837-OUT,B-2023-OUT;n:type:ShaderForge.SFN_Vector1,id:2023,x:31737,y:31843,varname:node_2023,prsc:2,v1:1;n:type:ShaderForge.SFN_Multiply,id:8322,x:31518,y:31712,varname:node_8322,prsc:2|A-7205-OUT,B-3173-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7205,x:31338,y:31724,ptovrint:False,ptlb:cos,ptin:_cos,varname:_cos,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1.2;n:type:ShaderForge.SFN_Cos,id:8210,x:31835,y:31703,varname:node_8210,prsc:2|IN-8322-OUT;n:type:ShaderForge.SFN_Multiply,id:6001,x:32000,y:31703,varname:node_6001,prsc:2|A-8210-OUT,B-2023-OUT;n:type:ShaderForge.SFN_Add,id:1130,x:32170,y:31763,varname:node_1130,prsc:2|A-6001-OUT,B-7906-OUT;n:type:ShaderForge.SFN_Clamp01,id:3699,x:32374,y:31763,varname:node_3699,prsc:2|IN-1130-OUT;n:type:ShaderForge.SFN_Tex2d,id:265,x:32588,y:31797,ptovrint:False,ptlb:shanshuo,ptin:_shanshuo,varname:_shanshuo,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:69d76a08a8802dd45b07c50c6b5ce7b9,ntxv:0,isnm:False|MIP-3699-OUT;n:type:ShaderForge.SFN_Multiply,id:8639,x:32903,y:32126,varname:node_8639,prsc:2|A-1393-OUT,B-1371-OUT,C-7089-RGB;n:type:ShaderForge.SFN_Slider,id:1371,x:32324,y:32011,ptovrint:False,ptlb:shanshuo_liangdu,ptin:_shanshuo_liangdu,varname:_shanshuo_liangdu,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.3512792,max:2;n:type:ShaderForge.SFN_Multiply,id:1393,x:32636,y:31601,varname:node_1393,prsc:2|A-3699-OUT,B-265-RGB;n:type:ShaderForge.SFN_Color,id:7089,x:32481,y:32196,ptovrint:False,ptlb:color_shanshuo,ptin:_color_shanshuo,varname:_color_shanshuo,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Tex2d,id:5981,x:33363,y:32953,ptovrint:False,ptlb:saoguang,ptin:_saoguang,varname:_saoguang,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:ed00f37083b32ca408b74665013ba327,ntxv:0,isnm:False|UVIN-8650-OUT;n:type:ShaderForge.SFN_TexCoord,id:2291,x:32768,y:32971,varname:node_2291,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:4532,x:33704,y:32959,varname:node_4532,prsc:2|A-5981-RGB,B-3073-OUT;n:type:ShaderForge.SFN_Slider,id:3073,x:33380,y:33186,ptovrint:False,ptlb:saoguang_liangdu,ptin:_saoguang_liangdu,varname:_saoguang_liangdu,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.3144406,max:1;n:type:ShaderForge.SFN_Multiply,id:6887,x:33971,y:32943,varname:node_6887,prsc:2|A-4532-OUT,B-951-RGB;n:type:ShaderForge.SFN_Color,id:951,x:33821,y:33125,ptovrint:False,ptlb:saoguang_color,ptin:_saoguang_color,varname:_saoguang_color,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_ValueProperty,id:8150,x:32712,y:33203,ptovrint:False,ptlb:saoguang_sudu,ptin:_saoguang_sudu,varname:_saoguang_sudu,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Time,id:8106,x:32667,y:33300,varname:node_8106,prsc:2;n:type:ShaderForge.SFN_Multiply,id:5563,x:32914,y:33261,varname:node_5563,prsc:2|A-8150-OUT,B-8106-T;n:type:ShaderForge.SFN_Add,id:8650,x:33111,y:33079,varname:node_8650,prsc:2|A-2291-UVOUT,B-5563-OUT;n:type:ShaderForge.SFN_Multiply,id:5491,x:33623,y:32456,varname:node_5491,prsc:2|A-3999-OUT,B-8594-OUT;n:type:ShaderForge.SFN_ValueProperty,id:8594,x:33329,y:32670,ptovrint:False,ptlb:Brightness_Main,ptin:_LightenMain,varname:_LightenMain,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;proporder:3916-2112-9036-5519-9171-2057-6138-7721-5691-849-6681-4696-1004-7205-265-1371-7089-5981-3073-951-8150-8594;pass:END;sub:END;*/

Shader "Y/wuqi" {
    Properties {
        _TEX ("TEX", 2D) = "white" {}
        _wenli_1 ("wenli_1", 2D) = "white" {}
        _wenli_2 ("wenli_2", 2D) = "white" {}
        _U1 ("U1", Float ) = 0.1
        _V1 ("V1", Float ) = 0.1
        _U2 ("U2", Float ) = -0.1
        _V2 ("V2", Float ) = -0.2
        _zhezhao_1 ("zhezhao_1", 2D) = "white" {}
        _liangdu ("liangdu", Range(0, 5)) = 5
        _color_1 ("color_1", Color) = (1,1,1,1)
        _zhehzao_2 ("zhehzao_2", 2D) = "white" {}
        _color_2 ("color_2", Color) = (1,0.5846856,0.1397059,1)
        _sin ("sin", Float ) = 2
        _cos ("cos", Float ) = 1.2
        _shanshuo ("shanshuo", 2D) = "white" {}
        _shanshuo_liangdu ("shanshuo_liangdu", Range(0, 2)) = 0.3512792
        _color_shanshuo ("color_shanshuo", Color) = (0.5,0.5,0.5,1)
        _saoguang ("saoguang", 2D) = "white" {}
        _saoguang_liangdu ("saoguang_liangdu", Range(0, 1)) = 0.3144406
        _saoguang_color ("saoguang_color", Color) = (1,1,1,1)
        _saoguang_sudu ("saoguang_sudu", Float ) = 1
        _LightenMain ("Brightness_Main", Float ) = 1
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
            colormask rgb

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
           // #pragma multi_compile_fwdbase
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            //#pragma target 3.0
            #pragma glsl
            uniform float4 _TimeEditor;
            uniform sampler2D _TEX; uniform float4 _TEX_ST;
            uniform sampler2D _wenli_1; uniform float4 _wenli_1_ST;
            uniform sampler2D _wenli_2; uniform float4 _wenli_2_ST;
            uniform float _U1;
            uniform float _V1;
            uniform float _U2;
            uniform float _V2;
            uniform sampler2D _zhezhao_1; uniform float4 _zhezhao_1_ST;
            uniform float _liangdu;
            uniform float4 _color_1;
            uniform sampler2D _zhehzao_2; uniform float4 _zhehzao_2_ST;
            uniform float4 _color_2;
            uniform float _sin;
            uniform float _cos;
            uniform sampler2D _shanshuo; uniform float4 _shanshuo_ST;
            uniform float _shanshuo_liangdu;
            uniform float4 _color_shanshuo;
            uniform sampler2D _saoguang; uniform float4 _saoguang_ST;
            uniform float _saoguang_liangdu;
            uniform float4 _saoguang_color;
            uniform float _saoguang_sudu;
            uniform float _LightenMain;
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
                float4 node_8825 = _Time + _TimeEditor;
                float2 node_2015 = ((float2(_U1,_V1)*node_8825.g)+i.uv0);
                float4 _wenli_2_var = tex2D(_wenli_2,TRANSFORM_TEX(node_2015, _wenli_2));
                float2 node_8909 = ((float2(_U2,_V2)*node_8825.g)+i.uv0);
                float4 _wenli_1_var = tex2D(_wenli_1,TRANSFORM_TEX(node_8909, _wenli_1));
                float4 _zhezhao_1_var = tex2D(_zhezhao_1,TRANSFORM_TEX(i.uv0, _zhezhao_1));
                float4 _zhehzao_2_var = tex2D(_zhehzao_2,TRANSFORM_TEX(i.uv0, _zhehzao_2));
                float4 _TEX_var = tex2D(_TEX,TRANSFORM_TEX(i.uv0, _TEX));
                float4 node_8106 = _Time + _TimeEditor;
                float2 node_8650 = (i.uv0+(_saoguang_sudu*node_8106.g));
                float4 _saoguang_var = tex2D(_saoguang,TRANSFORM_TEX(node_8650, _saoguang));
                float4 node_9770 = _Time + _TimeEditor;
                float node_3173 = (node_9770.g*_sin);
                float node_2023 = 1.0;
                float node_3699 = saturate(((cos((_cos*node_3173))*node_2023)+(sin(node_3173)+node_2023)));
                float4 _shanshuo_var = tex2Dlod(_shanshuo,float4(TRANSFORM_TEX(i.uv0, _shanshuo),0.0,node_3699));
                float3 emissive = (((_color_1.rgb*((_wenli_2_var.r*_wenli_1_var.r*_zhezhao_1_var.r)*_liangdu))+((_wenli_2_var.r*_zhehzao_2_var.rgb)*_color_2.rgb)+_TEX_var.rgb+((_saoguang_var.rgb*_saoguang_liangdu)*_saoguang_color.rgb)+((node_3699*_shanshuo_var.rgb)*_shanshuo_liangdu*_color_shanshuo.rgb))*_LightenMain);
                float3 finalColor = emissive;
                return fixed4(finalColor,_LightenMain);
            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
