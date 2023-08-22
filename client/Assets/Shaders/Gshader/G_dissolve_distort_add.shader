// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:1,fgcg:0.4527383,fgcb:0.4411765,fgca:1,fgde:0.01,fgrn:-43.8,fgrf:384.7,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33759,y:32669,varname:node_3138,prsc:2|emission-9011-OUT;n:type:ShaderForge.SFN_Tex2d,id:7188,x:32102,y:32715,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_7188,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-5382-UVOUT;n:type:ShaderForge.SFN_Rotator,id:5382,x:31892,y:32715,varname:node_5382,prsc:2|UVIN-9101-OUT,ANG-785-OUT;n:type:ShaderForge.SFN_TexCoord,id:2471,x:29764,y:32648,varname:node_2471,prsc:2,uv:0;n:type:ShaderForge.SFN_Pi,id:4465,x:31233,y:33342,varname:node_4465,prsc:2;n:type:ShaderForge.SFN_Multiply,id:785,x:31446,y:33188,varname:node_785,prsc:2|A-7797-OUT,B-4465-OUT;n:type:ShaderForge.SFN_Slider,id:4640,x:30778,y:33198,ptovrint:False,ptlb:MT_Rotate,ptin:_MT_Rotate,varname:node_4640,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Multiply,id:7797,x:31142,y:33189,varname:node_7797,prsc:2|A-4640-OUT,B-279-OUT;n:type:ShaderForge.SFN_Vector1,id:279,x:31033,y:33347,varname:node_279,prsc:2,v1:2;n:type:ShaderForge.SFN_Tex2d,id:8646,x:30511,y:32753,ptovrint:False,ptlb:Distort_Tex,ptin:_Distort_Tex,varname:node_8646,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7acc33f24a06fcd46baa112415b42195,ntxv:0,isnm:False|UVIN-6322-OUT;n:type:ShaderForge.SFN_Time,id:4982,x:29563,y:32422,varname:node_4982,prsc:2;n:type:ShaderForge.SFN_Multiply,id:9351,x:29842,y:32439,varname:node_9351,prsc:2|A-4982-TSL,B-1952-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1952,x:29563,y:32593,ptovrint:False,ptlb:Dist_SppedX,ptin:_Dist_SppedX,varname:node_1952,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:8847,x:29516,y:33044,ptovrint:False,ptlb:Dist_SppedY,ptin:_Dist_SppedY,varname:_Dist_SppedX_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Add,id:3113,x:30075,y:32419,varname:node_3113,prsc:2|A-9351-OUT,B-2471-U;n:type:ShaderForge.SFN_Time,id:4794,x:29516,y:32852,varname:node_4794,prsc:2;n:type:ShaderForge.SFN_Multiply,id:5037,x:29795,y:32869,varname:node_5037,prsc:2|A-4794-TSL,B-8847-OUT;n:type:ShaderForge.SFN_Add,id:5138,x:30041,y:32839,varname:node_5138,prsc:2|A-2471-V,B-5037-OUT;n:type:ShaderForge.SFN_Append,id:6322,x:30319,y:32753,varname:node_6322,prsc:2|A-3113-OUT,B-5138-OUT;n:type:ShaderForge.SFN_TexCoord,id:7490,x:30477,y:32472,varname:node_7490,prsc:2,uv:0;n:type:ShaderForge.SFN_Add,id:9883,x:31000,y:32559,varname:node_9883,prsc:2|A-7490-U,B-3271-OUT;n:type:ShaderForge.SFN_Multiply,id:3271,x:30814,y:32725,varname:node_3271,prsc:2|A-8646-R,B-3847-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7955,x:30375,y:32980,ptovrint:False,ptlb:Dist_amountX,ptin:_Dist_amountX,varname:node_7955,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Add,id:5007,x:31000,y:32807,varname:node_5007,prsc:2|A-7490-V,B-5738-OUT;n:type:ShaderForge.SFN_Multiply,id:5738,x:30814,y:32899,varname:node_5738,prsc:2|A-8646-R,B-8771-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4316,x:30375,y:33179,ptovrint:False,ptlb:Dist_amountY,ptin:_Dist_amountY,varname:_Dist_amountX_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Append,id:9101,x:31232,y:32708,varname:node_9101,prsc:2|A-9883-OUT,B-5007-OUT;n:type:ShaderForge.SFN_Divide,id:3847,x:30557,y:32936,varname:node_3847,prsc:2|A-7955-OUT,B-6993-OUT;n:type:ShaderForge.SFN_Vector1,id:6993,x:30375,y:33053,varname:node_6993,prsc:2,v1:10;n:type:ShaderForge.SFN_Vector1,id:7356,x:30375,y:33263,varname:node_7356,prsc:2,v1:10;n:type:ShaderForge.SFN_Divide,id:8771,x:30558,y:33204,varname:node_8771,prsc:2|A-4316-OUT,B-7356-OUT;n:type:ShaderForge.SFN_Color,id:4698,x:32097,y:32316,ptovrint:False,ptlb:MainColor,ptin:_MainColor,varname:node_876,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:3274,x:32741,y:32463,varname:node_3274,prsc:2|A-4698-RGB,B-3905-RGB,C-1732-OUT,D-7188-RGB;n:type:ShaderForge.SFN_VertexColor,id:3905,x:32097,y:32482,varname:node_3905,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:1732,x:32495,y:32686,ptovrint:False,ptlb:MainTex_Power,ptin:_MainTex_Power,varname:node_1726,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:3;n:type:ShaderForge.SFN_Step,id:9427,x:32539,y:33322,varname:node_9427,prsc:2|A-6153-OUT,B-4423-OUT;n:type:ShaderForge.SFN_OneMinus,id:8370,x:32746,y:33322,varname:node_8370,prsc:2|IN-9427-OUT;n:type:ShaderForge.SFN_VertexColor,id:6320,x:31679,y:33662,varname:node_6320,prsc:2;n:type:ShaderForge.SFN_OneMinus,id:5726,x:31928,y:33662,varname:node_5726,prsc:2|IN-6320-A;n:type:ShaderForge.SFN_Slider,id:7023,x:31942,y:33529,ptovrint:False,ptlb:diss_amount,ptin:_diss_amount,varname:node_9849,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-0.01,cur:-0.01,max:1;n:type:ShaderForge.SFN_SwitchProperty,id:4423,x:32314,y:33605,ptovrint:False,ptlb:particle_control(A),ptin:_particle_controlA,varname:node_312,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-7023-OUT,B-2903-OUT;n:type:ShaderForge.SFN_Tex2d,id:47,x:32006,y:33292,ptovrint:False,ptlb:Dissolve_Tex,ptin:_Dissolve_Tex,varname:node_3615,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Desaturate,id:8961,x:32184,y:33292,varname:node_8961,prsc:2|COL-47-RGB;n:type:ShaderForge.SFN_RemapRange,id:2903,x:32099,y:33662,varname:node_2903,prsc:2,frmn:0,frmx:1,tomn:-0.01,tomx:1|IN-5726-OUT;n:type:ShaderForge.SFN_Multiply,id:3273,x:33126,y:32848,varname:node_3273,prsc:2|A-3274-OUT,B-4558-OUT,C-8370-OUT;n:type:ShaderForge.SFN_Clamp01,id:9011,x:33304,y:32848,varname:node_9011,prsc:2|IN-3273-OUT;n:type:ShaderForge.SFN_Multiply,id:6153,x:32358,y:33363,varname:node_6153,prsc:2|A-8961-OUT,B-47-A;n:type:ShaderForge.SFN_Power,id:4558,x:32444,y:32861,varname:node_4558,prsc:2|VAL-7188-A,EXP-8634-OUT;n:type:ShaderForge.SFN_ValueProperty,id:8634,x:32200,y:32964,ptovrint:False,ptlb:node_8634,ptin:_node_8634,varname:node_8634,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;proporder:4698-7188-1732-4640-8646-1952-8847-7955-4316-7023-4423-47-8634;pass:END;sub:END;*/

Shader "G/G_dissolve_distort_add" {
    Properties {
        _MainColor ("MainColor", Color) = (0.5,0.5,0.5,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _MainTex_Power ("MainTex_Power", Float ) = 3
        _MT_Rotate ("MT_Rotate", Range(0, 1)) = 0
        _Distort_Tex ("Distort_Tex", 2D) = "white" {}
        _Dist_SppedX ("Dist_SppedX", Float ) = 0
        _Dist_SppedY ("Dist_SppedY", Float ) = 0
        _Dist_amountX ("Dist_amountX", Float ) = 0
        _Dist_amountY ("Dist_amountY", Float ) = 0
        _diss_amount ("diss_amount", Range(-0.01, 1)) = -0.01
        [MaterialToggle] _particle_controlA ("particle_control(A)", Float ) = -0.01
        _Dissolve_Tex ("Dissolve_Tex", 2D) = "white" {}
        _node_8634 ("node_8634", Float ) = 1
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
            Cull Off
            ZWrite Off
            ColorMask RGB
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            //#pragma multi_compile_fwdbase
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            //#pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float _MT_Rotate;
            uniform sampler2D _Distort_Tex; uniform float4 _Distort_Tex_ST;
            uniform float _Dist_SppedX;
            uniform float _Dist_SppedY;
            uniform float _Dist_amountX;
            uniform float _Dist_amountY;
            uniform float4 _MainColor;
            uniform float _MainTex_Power;
            uniform float _diss_amount;
            uniform fixed _particle_controlA;
            uniform sampler2D _Dissolve_Tex; uniform float4 _Dissolve_Tex_ST;
            uniform float _node_8634;
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
                float node_5382_ang = ((_MT_Rotate*2.0)*3.141592654);
                float node_5382_spd = 1.0;
                float node_5382_cos = cos(node_5382_spd*node_5382_ang);
                float node_5382_sin = sin(node_5382_spd*node_5382_ang);
                float2 node_5382_piv = float2(0.5,0.5);
                float4 node_4982 = _Time + _TimeEditor;
                float4 node_4794 = _Time + _TimeEditor;
                float2 node_6322 = float2(((node_4982.r*_Dist_SppedX)+i.uv0.r),(i.uv0.g+(node_4794.r*_Dist_SppedY)));
                float4 _Distort_Tex_var = tex2D(_Distort_Tex,TRANSFORM_TEX(node_6322, _Distort_Tex));
                float2 node_5382 = (mul(float2((i.uv0.r+(_Distort_Tex_var.r*(_Dist_amountX/10.0))),(i.uv0.g+(_Distort_Tex_var.r*(_Dist_amountY/10.0))))-node_5382_piv,float2x2( node_5382_cos, -node_5382_sin, node_5382_sin, node_5382_cos))+node_5382_piv);
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_5382, _MainTex));
                float4 _Dissolve_Tex_var = tex2D(_Dissolve_Tex,TRANSFORM_TEX(i.uv0, _Dissolve_Tex));
                float3 emissive = saturate(((_MainColor.rgb*i.vertexColor.rgb*_MainTex_Power*_MainTex_var.rgb)*pow(_MainTex_var.a,_node_8634)*(1.0 - step((dot(_Dissolve_Tex_var.rgb,float3(0.3,0.59,0.11))*_Dissolve_Tex_var.a),lerp( _diss_amount, ((1.0 - i.vertexColor.a)*1.01+-0.01), _particle_controlA )))));
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
