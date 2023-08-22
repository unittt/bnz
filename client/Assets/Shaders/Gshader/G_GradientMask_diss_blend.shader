// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33340,y:32702,varname:node_3138,prsc:2|emission-7284-OUT,alpha-3303-OUT;n:type:ShaderForge.SFN_Tex2d,id:4083,x:31705,y:32673,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_4083,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:77b1d77cdcc43994d9214e4da61cf0a1,ntxv:0,isnm:False|UVIN-9116-UVOUT;n:type:ShaderForge.SFN_Tex2d,id:746,x:31545,y:32919,ptovrint:False,ptlb:Mask,ptin:_Mask,varname:node_746,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:77b1d77cdcc43994d9214e4da61cf0a1,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:3596,x:32069,y:32903,varname:node_3596,prsc:2|A-4083-A,B-746-A,C-9106-OUT;n:type:ShaderForge.SFN_TexCoord,id:449,x:30758,y:32388,varname:node_449,prsc:2,uv:0;n:type:ShaderForge.SFN_VertexColor,id:1895,x:30290,y:32825,varname:node_1895,prsc:2;n:type:ShaderForge.SFN_RemapRange,id:2003,x:30506,y:32814,varname:node_2003,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-1895-A;n:type:ShaderForge.SFN_SwitchProperty,id:3282,x:30718,y:32744,ptovrint:False,ptlb:particle_control,ptin:_particle_control,varname:node_3282,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-3008-OUT,B-2003-OUT;n:type:ShaderForge.SFN_FaceSign,id:5166,x:31705,y:32459,varname:node_5166,prsc:2,fstp:0;n:type:ShaderForge.SFN_Lerp,id:7088,x:32347,y:32600,varname:node_7088,prsc:2|A-4404-OUT,B-2363-OUT,T-5166-VFACE;n:type:ShaderForge.SFN_Color,id:312,x:31972,y:32744,ptovrint:False,ptlb:InColor,ptin:_InColor,varname:node_312,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.3897059,c2:0.3897059,c3:0.3897059,c4:1;n:type:ShaderForge.SFN_Multiply,id:2363,x:32144,y:32672,varname:node_2363,prsc:2|A-4083-RGB,B-312-RGB,C-4833-OUT;n:type:ShaderForge.SFN_Add,id:5415,x:31273,y:32672,varname:node_5415,prsc:2|A-449-V,B-8168-OUT;n:type:ShaderForge.SFN_Add,id:9851,x:31273,y:32446,varname:node_9851,prsc:2|A-449-U,B-362-OUT;n:type:ShaderForge.SFN_Multiply,id:362,x:31049,y:32534,varname:node_362,prsc:2|A-2091-OUT,B-3282-OUT;n:type:ShaderForge.SFN_Multiply,id:8168,x:31033,y:32784,varname:node_8168,prsc:2|A-3282-OUT,B-4111-OUT;n:type:ShaderForge.SFN_Append,id:7700,x:31526,y:32672,varname:node_7700,prsc:2|A-9851-OUT,B-5415-OUT;n:type:ShaderForge.SFN_Slider,id:2091,x:30640,y:32577,ptovrint:False,ptlb:X_dir,ptin:_X_dir,varname:node_2091,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Slider,id:4111,x:30640,y:33013,ptovrint:False,ptlb:Y_dir,ptin:_Y_dir,varname:node_4111,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Multiply,id:4404,x:32161,y:32412,varname:node_4404,prsc:2|A-4174-RGB,B-430-OUT;n:type:ShaderForge.SFN_Color,id:4174,x:31885,y:32258,ptovrint:False,ptlb:MainColor,ptin:_MainColor,varname:node_4174,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.6911765,c2:0.6911765,c3:0.6911765,c4:1;n:type:ShaderForge.SFN_Multiply,id:7284,x:32824,y:32709,varname:node_7284,prsc:2|A-4997-OUT,B-2943-RGB;n:type:ShaderForge.SFN_VertexColor,id:2943,x:32347,y:32757,varname:node_2943,prsc:2;n:type:ShaderForge.SFN_Time,id:3517,x:30159,y:32507,varname:node_3517,prsc:2;n:type:ShaderForge.SFN_Multiply,id:3008,x:30439,y:32579,varname:node_3008,prsc:2|A-3517-TSL,B-6707-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6707,x:30151,y:32717,ptovrint:False,ptlb:MT_Speed,ptin:_MT_Speed,varname:node_6707,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Max,id:9106,x:31784,y:32908,varname:node_9106,prsc:2|A-746-R,B-746-G,C-746-B;n:type:ShaderForge.SFN_Multiply,id:963,x:32433,y:33063,varname:node_963,prsc:2|A-2943-A,B-3596-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:5230,x:32636,y:32918,ptovrint:False,ptlb:particle_alpha,ptin:_particle_alpha,varname:node_5230,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-963-OUT,B-3596-OUT;n:type:ShaderForge.SFN_TexCoord,id:8421,x:31778,y:34911,varname:node_8421,prsc:2,uv:0;n:type:ShaderForge.SFN_RemapRange,id:6657,x:32149,y:34911,varname:node_6657,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-8421-U;n:type:ShaderForge.SFN_Abs,id:7701,x:32318,y:34911,varname:node_7701,prsc:2|IN-6657-OUT;n:type:ShaderForge.SFN_OneMinus,id:566,x:32597,y:34900,varname:node_566,prsc:2|IN-9197-OUT;n:type:ShaderForge.SFN_Power,id:9197,x:32521,y:35079,varname:node_9197,prsc:2|VAL-7701-OUT,EXP-2149-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2149,x:32268,y:35158,ptovrint:False,ptlb:Mask_amount,ptin:_Mask_amount,varname:node_298,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:50;n:type:ShaderForge.SFN_RemapRange,id:7056,x:32139,y:35240,varname:node_7056,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-8421-V;n:type:ShaderForge.SFN_Abs,id:4779,x:32307,y:35240,varname:node_4779,prsc:2|IN-7056-OUT;n:type:ShaderForge.SFN_OneMinus,id:774,x:32587,y:35229,varname:node_774,prsc:2|IN-3297-OUT;n:type:ShaderForge.SFN_Power,id:3297,x:32511,y:35408,varname:node_3297,prsc:2|VAL-4779-OUT,EXP-2149-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:7343,x:32864,y:34926,ptovrint:False,ptlb:Mask_U/V,ptin:_Mask_UV,varname:node_7155,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-566-OUT,B-774-OUT;n:type:ShaderForge.SFN_Multiply,id:430,x:31998,y:32547,varname:node_430,prsc:2|A-4083-RGB,B-4833-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4833,x:31816,y:32632,ptovrint:False,ptlb:MainTex_Power,ptin:_MainTex_Power,varname:node_4833,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Tex2d,id:5972,x:31167,y:33424,ptovrint:False,ptlb:dissolve_tex,ptin:_dissolve_tex,varname:node_5972,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:b9a7f5fb90567434992ff4737f365378,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Add,id:2050,x:31675,y:33415,varname:node_2050,prsc:2|A-7319-OUT,B-9667-OUT;n:type:ShaderForge.SFN_Slider,id:8052,x:30936,y:33267,ptovrint:False,ptlb:diss_amount,ptin:_diss_amount,varname:node_8052,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:1,max:1;n:type:ShaderForge.SFN_Clamp01,id:8670,x:31894,y:33415,varname:node_8670,prsc:2|IN-2050-OUT;n:type:ShaderForge.SFN_RemapRange,id:3270,x:32088,y:33415,varname:node_3270,prsc:2,frmn:0.5,frmx:0.6,tomn:0,tomx:1|IN-8670-OUT;n:type:ShaderForge.SFN_Clamp01,id:6470,x:32282,y:33415,varname:node_6470,prsc:2|IN-3270-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:7319,x:31399,y:33252,ptovrint:False,ptlb:particle_control(diss),ptin:_particle_controldiss,varname:node_7319,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-8052-OUT,B-16-OUT;n:type:ShaderForge.SFN_Desaturate,id:9667,x:31506,y:33428,varname:node_9667,prsc:2|COL-314-OUT;n:type:ShaderForge.SFN_VertexColor,id:6676,x:30888,y:33105,varname:node_6676,prsc:2;n:type:ShaderForge.SFN_Multiply,id:314,x:31336,y:33428,varname:node_314,prsc:2|A-5972-RGB,B-5972-A;n:type:ShaderForge.SFN_Multiply,id:3303,x:32892,y:32961,varname:node_3303,prsc:2|A-5230-OUT,B-6470-OUT;n:type:ShaderForge.SFN_RemapRange,id:16,x:31147,y:33090,varname:node_16,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-6676-R;n:type:ShaderForge.SFN_SwitchProperty,id:4997,x:32619,y:32596,ptovrint:False,ptlb:doubleface_color,ptin:_doubleface_color,varname:node_4997,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-4404-OUT,B-7088-OUT;n:type:ShaderForge.SFN_Rotator,id:9116,x:31322,y:32833,varname:node_9116,prsc:2|UVIN-7700-OUT,ANG-7945-OUT;n:type:ShaderForge.SFN_Slider,id:8278,x:30920,y:32926,ptovrint:False,ptlb:MainTex_Rotate,ptin:_MainTex_Rotate,varname:node_8278,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:2;n:type:ShaderForge.SFN_Pi,id:2368,x:31095,y:32979,varname:node_2368,prsc:2;n:type:ShaderForge.SFN_Multiply,id:7945,x:31251,y:32944,varname:node_7945,prsc:2|A-8278-OUT,B-2368-OUT;proporder:4174-312-4997-4083-8278-4833-746-3282-5230-6707-2091-4111-5972-8052-7319;pass:END;sub:END;*/

Shader "G/G_GradientMask_diss_blend" {
    Properties {
        _MainColor ("MainColor", Color) = (0.6911765,0.6911765,0.6911765,1)
        _InColor ("InColor", Color) = (0.3897059,0.3897059,0.3897059,1)
        [MaterialToggle] _doubleface_color ("doubleface_color", Float ) = 0
        _MainTex ("MainTex", 2D) = "white" {}
        _MainTex_Rotate ("MainTex_Rotate", Range(0, 2)) = 0
        _MainTex_Power ("MainTex_Power", Float ) = 1
        _Mask ("Mask", 2D) = "white" {}
        [MaterialToggle] _particle_control ("particle_control", Float ) = 0
        [MaterialToggle] _particle_alpha ("particle_alpha", Float ) = 0
        _MT_Speed ("MT_Speed", Float ) = 0
        _X_dir ("X_dir", Range(0, 1)) = 1
        _Y_dir ("Y_dir", Range(0, 1)) = 1
        _dissolve_tex ("dissolve_tex", 2D) = "white" {}
        _diss_amount ("diss_amount", Range(-1, 1)) = 1
        [MaterialToggle] _particle_controldiss ("particle_control(diss)", Float ) = 1
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
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _Mask; uniform float4 _Mask_ST;
            uniform fixed _particle_control;
            uniform float4 _InColor;
            uniform float _X_dir;
            uniform float _Y_dir;
            uniform float4 _MainColor;
            uniform float _MT_Speed;
            uniform fixed _particle_alpha;
            uniform float _MainTex_Power;
            uniform sampler2D _dissolve_tex; uniform float4 _dissolve_tex_ST;
            uniform float _diss_amount;
            uniform fixed _particle_controldiss;
            uniform fixed _doubleface_color;
            uniform float _MainTex_Rotate;
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
                float node_9116_ang = (_MainTex_Rotate*3.141592654);
                float node_9116_spd = 1.0;
                float node_9116_cos = cos(node_9116_spd*node_9116_ang);
                float node_9116_sin = sin(node_9116_spd*node_9116_ang);
                float2 node_9116_piv = float2(0.5,0.5);
                float4 node_3517 = _Time + _TimeEditor;
                float _particle_control_var = lerp( (node_3517.r*_MT_Speed), (i.vertexColor.a*2.0+-1.0), _particle_control );
                float2 node_9116 = (mul(float2((i.uv0.r+(_X_dir*_particle_control_var)),(i.uv0.g+(_particle_control_var*_Y_dir)))-node_9116_piv,float2x2( node_9116_cos, -node_9116_sin, node_9116_sin, node_9116_cos))+node_9116_piv);
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_9116, _MainTex));
                float3 node_4404 = (_MainColor.rgb*(_MainTex_var.rgb*_MainTex_Power));
                float3 emissive = (lerp( node_4404, lerp(node_4404,(_MainTex_var.rgb*_InColor.rgb*_MainTex_Power),isFrontFace), _doubleface_color )*i.vertexColor.rgb);
                float3 finalColor = emissive;
                float4 _Mask_var = tex2D(_Mask,TRANSFORM_TEX(i.uv0, _Mask));
                float node_3596 = (_MainTex_var.a*_Mask_var.a*max(max(_Mask_var.r,_Mask_var.g),_Mask_var.b));
                float4 _dissolve_tex_var = tex2D(_dissolve_tex,TRANSFORM_TEX(i.uv0, _dissolve_tex));
                return fixed4(finalColor,(lerp( (i.vertexColor.a*node_3596), node_3596, _particle_alpha )*saturate((saturate((lerp( _diss_amount, (i.vertexColor.r*2.0+-1.0), _particle_controldiss )+dot((_dissolve_tex_var.rgb*_dissolve_tex_var.a),float3(0.3,0.59,0.11))))*9.999998+-4.999999))));
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
