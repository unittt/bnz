// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:33061,y:32677,varname:node_3138,prsc:2|emission-7284-OUT,alpha-7717-OUT;n:type:ShaderForge.SFN_Tex2d,id:4083,x:31705,y:32673,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_4083,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:77b1d77cdcc43994d9214e4da61cf0a1,ntxv:0,isnm:False|UVIN-7700-OUT;n:type:ShaderForge.SFN_Tex2d,id:746,x:31545,y:32919,ptovrint:False,ptlb:Mask,ptin:_Mask,varname:node_746,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:77b1d77cdcc43994d9214e4da61cf0a1,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:3596,x:32069,y:32903,varname:node_3596,prsc:2|A-4083-A,B-746-A,C-9106-OUT;n:type:ShaderForge.SFN_TexCoord,id:449,x:30758,y:32388,varname:node_449,prsc:2,uv:0;n:type:ShaderForge.SFN_VertexColor,id:1895,x:30290,y:32825,varname:node_1895,prsc:2;n:type:ShaderForge.SFN_RemapRange,id:2003,x:30506,y:32814,varname:node_2003,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:1|IN-1895-A;n:type:ShaderForge.SFN_SwitchProperty,id:3282,x:30718,y:32744,ptovrint:False,ptlb:particle_control,ptin:_particle_control,varname:node_3282,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-3008-OUT,B-2003-OUT;n:type:ShaderForge.SFN_FaceSign,id:5166,x:31705,y:32459,varname:node_5166,prsc:2,fstp:0;n:type:ShaderForge.SFN_Lerp,id:7088,x:32347,y:32600,varname:node_7088,prsc:2|A-4404-OUT,B-2363-OUT,T-5166-VFACE;n:type:ShaderForge.SFN_Color,id:312,x:31972,y:32744,ptovrint:False,ptlb:InColor,ptin:_InColor,varname:node_312,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.3897059,c2:0.3897059,c3:0.3897059,c4:1;n:type:ShaderForge.SFN_Multiply,id:2363,x:32144,y:32672,varname:node_2363,prsc:2|A-4083-RGB,B-312-RGB;n:type:ShaderForge.SFN_Add,id:5415,x:31273,y:32672,varname:node_5415,prsc:2|A-449-V,B-8168-OUT;n:type:ShaderForge.SFN_Add,id:9851,x:31273,y:32446,varname:node_9851,prsc:2|A-449-U,B-362-OUT;n:type:ShaderForge.SFN_Multiply,id:362,x:31049,y:32534,varname:node_362,prsc:2|A-2091-OUT,B-3282-OUT;n:type:ShaderForge.SFN_Multiply,id:8168,x:31033,y:32784,varname:node_8168,prsc:2|A-3282-OUT,B-4111-OUT;n:type:ShaderForge.SFN_Append,id:7700,x:31526,y:32672,varname:node_7700,prsc:2|A-9851-OUT,B-5415-OUT;n:type:ShaderForge.SFN_Slider,id:2091,x:30640,y:32577,ptovrint:False,ptlb:X_dir,ptin:_X_dir,varname:node_2091,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Slider,id:4111,x:30640,y:33013,ptovrint:False,ptlb:Y_dir,ptin:_Y_dir,varname:node_4111,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Multiply,id:4404,x:32161,y:32412,varname:node_4404,prsc:2|A-4174-RGB,B-4083-RGB;n:type:ShaderForge.SFN_Color,id:4174,x:31885,y:32258,ptovrint:False,ptlb:MainColor,ptin:_MainColor,varname:node_4174,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.6911765,c2:0.6911765,c3:0.6911765,c4:1;n:type:ShaderForge.SFN_Multiply,id:7284,x:32629,y:32679,varname:node_7284,prsc:2|A-7088-OUT,B-2943-RGB,C-2015-OUT;n:type:ShaderForge.SFN_VertexColor,id:2943,x:32347,y:32757,varname:node_2943,prsc:2;n:type:ShaderForge.SFN_Time,id:3517,x:30159,y:32507,varname:node_3517,prsc:2;n:type:ShaderForge.SFN_Multiply,id:3008,x:30439,y:32579,varname:node_3008,prsc:2|A-3517-TSL,B-6707-OUT;n:type:ShaderForge.SFN_ValueProperty,id:6707,x:30151,y:32717,ptovrint:False,ptlb:MT_Speed,ptin:_MT_Speed,varname:node_6707,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Max,id:9106,x:31784,y:32908,varname:node_9106,prsc:2|A-746-R,B-746-G,C-746-B;n:type:ShaderForge.SFN_Multiply,id:963,x:32433,y:33063,varname:node_963,prsc:2|A-2943-A,B-3596-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:5230,x:32629,y:32914,ptovrint:False,ptlb:particle_alpha,ptin:_particle_alpha,varname:node_5230,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-963-OUT,B-3596-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2015,x:32368,y:32392,ptovrint:False,ptlb:MainTex_Power,ptin:_MainTex_Power,varname:node_2015,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:7717,x:32864,y:32916,varname:node_7717,prsc:2|A-2015-OUT,B-5230-OUT;proporder:4174-312-4083-746-3282-5230-6707-2091-4111-2015;pass:END;sub:END;*/

Shader "G/G_GradientMask_blend" {
    Properties {
        _MainColor ("MainColor", Color) = (0.6911765,0.6911765,0.6911765,1)
        _InColor ("InColor", Color) = (0.3897059,0.3897059,0.3897059,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _Mask ("Mask", 2D) = "white" {}
        [MaterialToggle] _particle_control ("particle_control", Float ) = 0
        [MaterialToggle] _particle_alpha ("particle_alpha", Float ) = 0
        _MT_Speed ("MT_Speed", Float ) = 0
        _X_dir ("X_dir", Range(0, 1)) = 1
        _Y_dir ("Y_dir", Range(0, 1)) = 1
        _MainTex_Power ("MainTex_Power", Float ) = 1
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
            //#pragma target 3.0
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
                float4 node_3517 = _Time + _TimeEditor;
                float _particle_control_var = lerp( (node_3517.r*_MT_Speed), (i.vertexColor.a*2.0+-1.0), _particle_control );
                float2 node_7700 = float2((i.uv0.r+(_X_dir*_particle_control_var)),(i.uv0.g+(_particle_control_var*_Y_dir)));
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_7700, _MainTex));
                float3 emissive = (lerp((_MainColor.rgb*_MainTex_var.rgb),(_MainTex_var.rgb*_InColor.rgb),isFrontFace)*i.vertexColor.rgb*_MainTex_Power);
                float3 finalColor = emissive;
                float4 _Mask_var = tex2D(_Mask,TRANSFORM_TEX(i.uv0, _Mask));
                float node_3596 = (_MainTex_var.a*_Mask_var.a*max(max(_Mask_var.r,_Mask_var.g),_Mask_var.b));
                return fixed4(finalColor,(_MainTex_Power*lerp( (i.vertexColor.a*node_3596), node_3596, _particle_alpha )));
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
