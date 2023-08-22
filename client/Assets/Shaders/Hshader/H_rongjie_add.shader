// Shader created with Shader Forge v1.05 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.05;sub:START;pass:START;ps:flbk:,lico:1,lgpr:1,nrmq:1,limd:1,uamb:True,mssp:True,lmpd:False,lprd:False,rprd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,rpth:0,hqsc:True,hqlp:False,tesm:0,blpr:2,bsrc:0,bdst:0,culm:2,dpts:2,wrdp:False,dith:0,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:True;n:type:ShaderForge.SFN_Final,id:370,x:34912,y:32670,varname:node_370,prsc:2|emission-9571-OUT;n:type:ShaderForge.SFN_Tex2d,id:6008,x:32330,y:32582,ptovrint:False,ptlb:TEX,ptin:_TEX,varname:node_6008,prsc:2,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:3165,x:32948,y:32707,varname:node_3165,prsc:2|A-6008-RGB,B-501-RGB,C-9083-OUT;n:type:ShaderForge.SFN_VertexColor,id:501,x:31837,y:32835,varname:node_501,prsc:2;n:type:ShaderForge.SFN_Tex2d,id:5233,x:32314,y:33235,ptovrint:False,ptlb:TEX_rongjie,ptin:_TEX_rongjie,varname:node_5233,prsc:2,tex:7acc33f24a06fcd46baa112415b42195,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:3310,x:32514,y:32930,varname:node_3310,prsc:2|A-9387-OUT,B-5174-OUT;n:type:ShaderForge.SFN_ValueProperty,id:9387,x:32292,y:32876,ptovrint:False,ptlb:rongjie_MAX,ptin:_rongjie_MAX,varname:node_9387,prsc:2,glob:False,v1:0.5;n:type:ShaderForge.SFN_ValueProperty,id:9083,x:32680,y:32842,ptovrint:False,ptlb:ZT,ptin:_ZT,varname:node_9083,prsc:2,glob:False,v1:2;n:type:ShaderForge.SFN_Step,id:6638,x:33093,y:32896,varname:node_6638,prsc:2|A-3310-OUT,B-5233-RGB;n:type:ShaderForge.SFN_Multiply,id:9571,x:34463,y:32773,varname:node_9571,prsc:2|A-3165-OUT,B-6638-OUT,C-2710-OUT,D-279-RGB;n:type:ShaderForge.SFN_Tex2d,id:8284,x:33295,y:33024,ptovrint:False,ptlb:wenli,ptin:_wenli,varname:node_8284,prsc:2,tex:e9b173c0d6ac89c44898e6fd7b99a15f,ntxv:0,isnm:False|UVIN-6147-UVOUT;n:type:ShaderForge.SFN_Tex2d,id:8559,x:33336,y:33254,ptovrint:False,ptlb:wenli2,ptin:_wenli2,varname:node_8559,prsc:2,tex:887d45145f23c924a94ff8fca910e1ad,ntxv:0,isnm:False|UVIN-1176-UVOUT;n:type:ShaderForge.SFN_Panner,id:6147,x:33106,y:33075,varname:node_6147,prsc:2,spu:1,spv:0|DIST-9676-OUT;n:type:ShaderForge.SFN_Panner,id:1176,x:33116,y:33272,varname:node_1176,prsc:2,spu:0,spv:1|DIST-6454-OUT;n:type:ShaderForge.SFN_Multiply,id:9676,x:32899,y:33146,varname:node_9676,prsc:2|A-1959-T,B-884-OUT;n:type:ShaderForge.SFN_Time,id:1959,x:32615,y:33179,varname:node_1959,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:884,x:32636,y:33329,ptovrint:False,ptlb:wenli1_sudu,ptin:_wenli1_sudu,varname:node_884,prsc:2,glob:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:6454,x:32934,y:33473,varname:node_6454,prsc:2|A-9209-T,B-8412-OUT;n:type:ShaderForge.SFN_Time,id:9209,x:32640,y:33468,varname:node_9209,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:8412,x:32671,y:33656,ptovrint:False,ptlb:wenli2_sudu,ptin:_wenli2_sudu,varname:_wenli1_sudu_copy,prsc:2,glob:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:3664,x:33592,y:32962,varname:node_3664,prsc:2|A-8284-RGB,B-8559-RGB,C-1075-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1075,x:33571,y:33316,ptovrint:False,ptlb:wenli_ZT,ptin:_wenli_ZT,varname:node_1075,prsc:2,glob:False,v1:2;n:type:ShaderForge.SFN_Power,id:2710,x:33955,y:32922,varname:node_2710,prsc:2|VAL-3664-OUT,EXP-2634-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2634,x:33839,y:33352,ptovrint:False,ptlb:wenli_power,ptin:_wenli_power,varname:node_2634,prsc:2,glob:False,v1:2;n:type:ShaderForge.SFN_OneMinus,id:4711,x:32055,y:32924,varname:node_4711,prsc:2|IN-501-A;n:type:ShaderForge.SFN_Add,id:5174,x:32276,y:33045,varname:node_5174,prsc:2|A-4711-OUT,B-1249-OUT;n:type:ShaderForge.SFN_Slider,id:1249,x:31826,y:33136,ptovrint:False,ptlb:rongjie,ptin:_rongjie,varname:node_1249,prsc:2,min:0,cur:1,max:3;n:type:ShaderForge.SFN_Color,id:279,x:34072,y:33134,ptovrint:False,ptlb:color,ptin:_color,varname:node_279,prsc:2,glob:False,c1:0.5,c2:0.5,c3:0.5,c4:1;proporder:6008-5233-9387-9083-8284-8559-884-8412-1075-2634-1249-279;pass:END;sub:END;*/

Shader "H/H_rongjie_add" {
    Properties {
        _TEX ("TEX", 2D) = "white" {}
        _TEX_rongjie ("TEX_rongjie", 2D) = "white" {}
        _rongjie_MAX ("rongjie_MAX", Float ) = 0.5
        _ZT ("ZT", Float ) = 2
        _wenli ("wenli", 2D) = "white" {}
        _wenli2 ("wenli2", 2D) = "white" {}
        _wenli1_sudu ("wenli1_sudu", Float ) = 1
        _wenli2_sudu ("wenli2_sudu", Float ) = 1
        _wenli_ZT ("wenli_ZT", Float ) = 2
        _wenli_power ("wenli_power", Float ) = 2
        _rongjie ("rongjie", Range(0, 3)) = 1
        _color ("color", Color) = (0.5,0.5,0.5,1)
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "ForwardBase"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One
            Cull Off
            ZWrite Off
            
            Fog {Mode Off}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            //#pragma multi_compile_fwdbase
           // #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
           // #pragma target 2.0
            uniform float4 _TimeEditor;
            uniform sampler2D _TEX; uniform float4 _TEX_ST;
            uniform sampler2D _TEX_rongjie; uniform float4 _TEX_rongjie_ST;
            uniform float _rongjie_MAX;
            uniform float _ZT;
            uniform sampler2D _wenli; uniform float4 _wenli_ST;
            uniform sampler2D _wenli2; uniform float4 _wenli2_ST;
            uniform float _wenli1_sudu;
            uniform float _wenli2_sudu;
            uniform float _wenli_ZT;
            uniform float _wenli_power;
            uniform float _rongjie;
            uniform float4 _color;
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
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
/////// Vectors:
////// Lighting:
////// Emissive:
                float4 _TEX_var = tex2D(_TEX,TRANSFORM_TEX(i.uv0, _TEX));
                float4 _TEX_rongjie_var = tex2D(_TEX_rongjie,TRANSFORM_TEX(i.uv0, _TEX_rongjie));
                float4 node_1959 = _Time + _TimeEditor;
                float2 node_6147 = (i.uv0+(node_1959.g*_wenli1_sudu)*float2(1,0));
                float4 _wenli_var = tex2D(_wenli,TRANSFORM_TEX(node_6147, _wenli));
                float4 node_9209 = _Time + _TimeEditor;
                float2 node_1176 = (i.uv0+(node_9209.g*_wenli2_sudu)*float2(0,1));
                float4 _wenli2_var = tex2D(_wenli2,TRANSFORM_TEX(node_1176, _wenli2));
                float3 emissive = ((_TEX_var.rgb*i.vertexColor.rgb*_ZT)*step((_rongjie_MAX*((1.0 - i.vertexColor.a)+_rongjie)),_TEX_rongjie_var.rgb)*pow((_wenli_var.rgb*_wenli2_var.rgb*_wenli_ZT),_wenli_power)*_color.rgb);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
