// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:True,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:167,x:33690,y:32708,varname:node_167,prsc:2|emission-5261-OUT,alpha-3878-OUT;n:type:ShaderForge.SFN_Tex2d,id:3018,x:32584,y:32282,ptovrint:False,ptlb:TEX,ptin:_TEX,varname:node_3018,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-4986-UVOUT;n:type:ShaderForge.SFN_Panner,id:4986,x:31839,y:32286,varname:node_4986,prsc:2,spu:1,spv:0|UVIN-6560-UVOUT,DIST-118-OUT;n:type:ShaderForge.SFN_TexCoord,id:6560,x:31515,y:32286,varname:node_6560,prsc:2,uv:0;n:type:ShaderForge.SFN_VertexColor,id:6241,x:31642,y:32662,varname:node_6241,prsc:2;n:type:ShaderForge.SFN_RemapRange,id:8107,x:31865,y:32649,varname:node_8107,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-6241-A;n:type:ShaderForge.SFN_Panner,id:9551,x:32169,y:32574,varname:node_9551,prsc:2,spu:1,spv:0|UVIN-6560-UVOUT,DIST-8107-OUT;n:type:ShaderForge.SFN_Panner,id:1847,x:32169,y:32767,varname:node_1847,prsc:2,spu:0,spv:1|UVIN-6560-UVOUT,DIST-8107-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:2129,x:32401,y:32713,ptovrint:False,ptlb:maskUV_switch,ptin:_maskUV_switch,varname:node_2129,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-9551-UVOUT,B-1847-UVOUT;n:type:ShaderForge.SFN_Time,id:2344,x:31110,y:32481,varname:node_2344,prsc:2;n:type:ShaderForge.SFN_Multiply,id:118,x:31418,y:32510,varname:node_118,prsc:2|A-2344-TSL,B-1372-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1372,x:31098,y:32740,ptovrint:False,ptlb:sudu,ptin:_sudu,varname:node_1372,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Tex2d,id:4142,x:32597,y:32696,ptovrint:False,ptlb:mask,ptin:_mask,varname:node_4142,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-2129-OUT;n:type:ShaderForge.SFN_Color,id:7946,x:32597,y:32918,ptovrint:False,ptlb:color,ptin:_color,varname:node_7946,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:8281,x:32808,y:32819,varname:node_8281,prsc:2|A-4142-A,B-7946-RGB;n:type:ShaderForge.SFN_Multiply,id:5348,x:33035,y:32741,varname:node_5348,prsc:2|A-3018-RGB,B-4142-RGB,C-8281-OUT,D-8662-RGB,E-121-OUT;n:type:ShaderForge.SFN_VertexColor,id:8662,x:32808,y:32989,varname:node_8662,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:121,x:32808,y:33146,ptovrint:False,ptlb:ZT,ptin:_ZT,varname:node_121,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:4;n:type:ShaderForge.SFN_Multiply,id:5261,x:33257,y:32809,varname:node_5261,prsc:2|A-5348-OUT,B-4265-RGB;n:type:ShaderForge.SFN_Tex2d,id:4265,x:32990,y:32937,ptovrint:False,ptlb:mask2,ptin:_mask2,varname:node_4265,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:3878,x:33310,y:32935,varname:node_3878,prsc:2|A-4142-A,B-6807-OUT,C-4265-A,D-3018-A;n:type:ShaderForge.SFN_Max,id:82,x:33026,y:33139,varname:node_82,prsc:2|A-8662-R,B-8662-G,C-8662-B;n:type:ShaderForge.SFN_SwitchProperty,id:6807,x:33229,y:33139,ptovrint:False,ptlb:blackcolor_switch,ptin:_blackcolor_switch,varname:node_6807,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-82-OUT,B-4889-OUT;n:type:ShaderForge.SFN_Vector1,id:4889,x:33026,y:33271,varname:node_4889,prsc:2,v1:1;proporder:3018-2129-1372-4142-7946-121-4265-6807;pass:END;sub:END;*/

Shader "H/H_liuguang_blend02" {
    Properties {
        _TEX ("TEX", 2D) = "white" {}
        [MaterialToggle] _maskUV_switch ("maskUV_switch", Float ) = -1
        _sudu ("sudu", Float ) = 1
        _mask ("mask", 2D) = "white" {}
        _color ("color", Color) = (0.5,0.5,0.5,1)
        _ZT ("ZT", Float ) = 4
        _mask2 ("mask2", 2D) = "white" {}
        [MaterialToggle] _blackcolor_switch ("blackcolor_switch", Float ) = 0
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
            //#pragma multi_compile_fwdbase
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            //#pragma target 2.0
            uniform float4 _TimeEditor;
            uniform sampler2D _TEX; uniform float4 _TEX_ST;
            uniform fixed _maskUV_switch;
            uniform float _sudu;
            uniform sampler2D _mask; uniform float4 _mask_ST;
            uniform float4 _color;
            uniform float _ZT;
            uniform sampler2D _mask2; uniform float4 _mask2_ST;
            uniform fixed _blackcolor_switch;
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
                float4 node_2344 = _Time + _TimeEditor;
                float2 node_4986 = (i.uv0+(node_2344.r*_sudu)*float2(1,0));
                float4 _TEX_var = tex2D(_TEX,TRANSFORM_TEX(node_4986, _TEX));
                float node_8107 = (i.vertexColor.a*2.0+-1.0);
                float2 _maskUV_switch_var = lerp( (i.uv0+node_8107*float2(1,0)), (i.uv0+node_8107*float2(0,1)), _maskUV_switch );
                float4 _mask_var = tex2D(_mask,TRANSFORM_TEX(_maskUV_switch_var, _mask));
                float4 _mask2_var = tex2D(_mask2,TRANSFORM_TEX(i.uv0, _mask2));
                float3 emissive = ((_TEX_var.rgb*_mask_var.rgb*(_mask_var.a*_color.rgb)*i.vertexColor.rgb*_ZT)*_mask2_var.rgb);
                float3 finalColor = emissive;
                return fixed4(finalColor,(_mask_var.a*lerp( max(max(i.vertexColor.r,i.vertexColor.g),i.vertexColor.b), 1.0, _blackcolor_switch )*_mask2_var.a*_TEX_var.a));
            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
