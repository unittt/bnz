// Shader created with Shader Forge v1.05 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.05;sub:START;pass:START;ps:flbk:,lico:1,lgpr:1,nrmq:1,limd:1,uamb:True,mssp:True,lmpd:False,lprd:False,rprd:False,enco:False,frtr:True,vitr:True,dbil:False,rmgx:True,rpth:0,hqsc:True,hqlp:False,tesm:0,blpr:2,bsrc:0,bdst:0,culm:2,dpts:2,wrdp:False,dith:0,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:False;n:type:ShaderForge.SFN_Final,id:167,x:33356,y:32774,varname:node_167,prsc:2|emission-634-OUT;n:type:ShaderForge.SFN_Tex2d,id:4442,x:32597,y:32634,ptovrint:False,ptlb:TEX,ptin:_TEX,varname:node_4442,prsc:2,tex:ceb84b42936fee447b4ac494463ea016,ntxv:0,isnm:False|UVIN-2123-UVOUT;n:type:ShaderForge.SFN_Multiply,id:8432,x:33011,y:32825,varname:node_8432,prsc:2|A-4442-RGB,B-1588-RGB,C-2374-OUT,D-2650-RGB,E-7637-OUT;n:type:ShaderForge.SFN_Tex2d,id:1588,x:32597,y:32822,ptovrint:False,ptlb:mask,ptin:_mask,varname:node_1588,prsc:2,ntxv:0,isnm:False|UVIN-7750-OUT;n:type:ShaderForge.SFN_Panner,id:2123,x:32030,y:32612,varname:node_2123,prsc:2,spu:1,spv:0|UVIN-8590-UVOUT,DIST-3188-OUT;n:type:ShaderForge.SFN_Time,id:177,x:31394,y:32755,varname:node_177,prsc:2;n:type:ShaderForge.SFN_Multiply,id:3188,x:31632,y:32777,varname:node_3188,prsc:2|A-177-T,B-508-OUT;n:type:ShaderForge.SFN_ValueProperty,id:508,x:31394,y:32912,ptovrint:False,ptlb:sudu,ptin:_sudu,varname:node_508,prsc:2,glob:False,v1:1;n:type:ShaderForge.SFN_TexCoord,id:8590,x:31756,y:32613,varname:node_8590,prsc:2,uv:0;n:type:ShaderForge.SFN_Color,id:5338,x:32584,y:33002,ptovrint:False,ptlb:color,ptin:_color,varname:node_5338,prsc:2,glob:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_VertexColor,id:2650,x:32392,y:33279,varname:node_2650,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:7637,x:32597,y:33424,ptovrint:False,ptlb:ZT,ptin:_ZT,varname:node_7637,prsc:2,glob:False,v1:4;n:type:ShaderForge.SFN_Multiply,id:634,x:33184,y:32880,varname:node_634,prsc:2|A-8432-OUT,B-6301-RGB;n:type:ShaderForge.SFN_Panner,id:216,x:32248,y:32760,varname:node_216,prsc:2,spu:1,spv:0|DIST-1673-OUT;n:type:ShaderForge.SFN_RemapRange,id:1673,x:32030,y:32789,varname:node_1673,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-415-A;n:type:ShaderForge.SFN_VertexColor,id:415,x:31844,y:32772,varname:node_415,prsc:2;n:type:ShaderForge.SFN_Tex2d,id:6301,x:32973,y:33103,ptovrint:False,ptlb:mask2,ptin:_mask2,varname:_mask_copy,prsc:2,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Panner,id:1607,x:32248,y:32899,varname:node_1607,prsc:2,spu:0,spv:1|DIST-1673-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:7750,x:32419,y:32839,ptovrint:False,ptlb:maskUV_switch,ptin:_maskUV_switch,varname:node_7750,prsc:2,on:False|A-216-UVOUT,B-1607-UVOUT;n:type:ShaderForge.SFN_Multiply,id:2374,x:32781,y:32877,varname:node_2374,prsc:2|A-1588-A,B-5338-RGB;proporder:4442-1588-7750-508-5338-7637-6301;pass:END;sub:END;*/

Shader "H/H_liuguang_ADD03" {
    Properties {
        _TEX ("TEX", 2D) = "white" {}
        _mask ("mask", 2D) = "white" {}
        [MaterialToggle] _maskUV_switch ("maskUV_switch", Float ) = 1
        _sudu ("sudu", Float ) = 1
        _color ("color", Color) = (0.5,0.5,0.5,1)
        _ZT ("ZT", Float ) = 4
        _mask2 ("mask2", 2D) = "white" {}
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
            colormask rgb

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
            uniform sampler2D _mask; uniform float4 _mask_ST;
            uniform float _sudu;
            uniform float4 _color;
            uniform float _ZT;
            uniform sampler2D _mask2; uniform float4 _mask2_ST;
            uniform fixed _maskUV_switch;
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
                float4 node_177 = _Time + _TimeEditor;
                float2 node_2123 = (i.uv0+(node_177.g*_sudu)*float2(1,0));
                float4 _TEX_var = tex2D(_TEX,TRANSFORM_TEX(node_2123, _TEX));
                float node_1673 = (i.vertexColor.a*2.0+-1.0);
                float2 _maskUV_switch_var = lerp( (i.uv0+node_1673*float2(1,0)), (i.uv0+node_1673*float2(0,1)), _maskUV_switch );
                float4 _mask_var = tex2D(_mask,TRANSFORM_TEX(_maskUV_switch_var, _mask));
                float4 _mask2_var = tex2D(_mask2,TRANSFORM_TEX(i.uv0, _mask2));
                float3 emissive = ((_TEX_var.rgb*_mask_var.rgb*(_mask_var.a*_color.rgb)*i.vertexColor.rgb*_ZT)*_mask2_var.rgb);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
