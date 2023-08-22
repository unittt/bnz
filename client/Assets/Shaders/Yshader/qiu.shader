// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:34512,y:32697,varname:node_3138,prsc:2|emission-5031-OUT,alpha-4678-OUT,clip-4678-OUT,voffset-1524-OUT;n:type:ShaderForge.SFN_Color,id:7241,x:32559,y:32119,ptovrint:False,ptlb:Color1,ptin:_Color1,varname:node_7241,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.07843138,c2:0.3921569,c3:0.7843137,c4:1;n:type:ShaderForge.SFN_Tex2d,id:3438,x:32322,y:32573,ptovrint:False,ptlb:tex1,ptin:_tex1,varname:node_3438,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7acc33f24a06fcd46baa112415b42195,ntxv:0,isnm:False|UVIN-5264-OUT;n:type:ShaderForge.SFN_Tex2d,id:3927,x:32292,y:32834,ptovrint:False,ptlb:tex2,ptin:_tex2,varname:node_3927,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:211bdb41edc435940a6de87a1c8d0e42,ntxv:0,isnm:False|UVIN-7456-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5597,x:31402,y:32630,ptovrint:False,ptlb:U1,ptin:_U1,varname:node_5597,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.2;n:type:ShaderForge.SFN_ValueProperty,id:1617,x:31377,y:32708,ptovrint:False,ptlb:V1,ptin:_V1,varname:_node_5597_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.2;n:type:ShaderForge.SFN_ValueProperty,id:644,x:31377,y:32801,ptovrint:False,ptlb:U2,ptin:_U2,varname:_node_5597_copy_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.1;n:type:ShaderForge.SFN_ValueProperty,id:3275,x:31377,y:32940,ptovrint:False,ptlb:V2,ptin:_V2,varname:_node_5597_copy_copy_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.2;n:type:ShaderForge.SFN_Append,id:2280,x:31636,y:32856,varname:node_2280,prsc:2|A-644-OUT,B-3275-OUT;n:type:ShaderForge.SFN_Append,id:7722,x:31617,y:32630,varname:node_7722,prsc:2|A-5597-OUT,B-1617-OUT;n:type:ShaderForge.SFN_Multiply,id:8559,x:31706,y:32403,varname:node_8559,prsc:2|A-9103-T,B-7722-OUT;n:type:ShaderForge.SFN_Time,id:9103,x:31272,y:32365,varname:node_9103,prsc:2;n:type:ShaderForge.SFN_Multiply,id:796,x:31802,y:32781,varname:node_796,prsc:2|A-9103-T,B-2280-OUT;n:type:ShaderForge.SFN_Add,id:5264,x:31988,y:32427,varname:node_5264,prsc:2|A-6538-UVOUT,B-8559-OUT;n:type:ShaderForge.SFN_TexCoord,id:6538,x:31482,y:32170,varname:node_6538,prsc:2,uv:0;n:type:ShaderForge.SFN_Add,id:7456,x:32030,y:32803,varname:node_7456,prsc:2|A-6538-UVOUT,B-796-OUT;n:type:ShaderForge.SFN_Append,id:8303,x:32515,y:32699,varname:node_8303,prsc:2|A-3438-R,B-3927-R;n:type:ShaderForge.SFN_Tex2d,id:1596,x:32874,y:32677,ptovrint:False,ptlb:raodong,ptin:_raodong,varname:node_1596,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7acc33f24a06fcd46baa112415b42195,ntxv:0,isnm:False|UVIN-8303-OUT;n:type:ShaderForge.SFN_Fresnel,id:6066,x:33136,y:32823,varname:node_6066,prsc:2|EXP-9887-OUT;n:type:ShaderForge.SFN_Slider,id:9887,x:32266,y:33092,ptovrint:False,ptlb:fresenl,ptin:_fresenl,varname:node_9887,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:5;n:type:ShaderForge.SFN_Multiply,id:3149,x:33308,y:32730,varname:node_3149,prsc:2|A-1596-RGB,B-6066-OUT;n:type:ShaderForge.SFN_Multiply,id:5031,x:33706,y:32706,varname:node_5031,prsc:2|A-2849-OUT,B-3149-OUT;n:type:ShaderForge.SFN_Lerp,id:2849,x:33352,y:32354,varname:node_2849,prsc:2|A-7241-RGB,B-1176-RGB,T-3301-VFACE;n:type:ShaderForge.SFN_Color,id:1176,x:32549,y:32352,ptovrint:False,ptlb:Color2,ptin:_Color2,varname:node_1176,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.2132353,c2:1,c3:0.5767747,c4:1;n:type:ShaderForge.SFN_FaceSign,id:3301,x:33073,y:32490,varname:node_3301,prsc:2,fstp:0;n:type:ShaderForge.SFN_Tex2d,id:1053,x:32998,y:33984,ptovrint:False,ptlb:vertex,ptin:_vertex,varname:node_1053,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7acc33f24a06fcd46baa112415b42195,ntxv:0,isnm:False|UVIN-6209-OUT;n:type:ShaderForge.SFN_Multiply,id:1524,x:33629,y:33974,varname:node_1524,prsc:2|A-1053-RGB,B-3798-OUT,C-669-OUT,D-3396-OUT;n:type:ShaderForge.SFN_NormalVector,id:3798,x:33178,y:34059,prsc:2,pt:False;n:type:ShaderForge.SFN_ValueProperty,id:3396,x:33325,y:34254,ptovrint:False,ptlb:vertex_power,ptin:_vertex_power,varname:node_3396,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.1;n:type:ShaderForge.SFN_Time,id:4194,x:31934,y:34186,varname:node_4194,prsc:2;n:type:ShaderForge.SFN_Cos,id:767,x:32442,y:34067,varname:node_767,prsc:2|IN-3229-OUT;n:type:ShaderForge.SFN_Multiply,id:3229,x:32750,y:34191,varname:node_3229,prsc:2|A-8116-OUT,B-4194-T;n:type:ShaderForge.SFN_ValueProperty,id:8116,x:32036,y:34062,ptovrint:False,ptlb:cos,ptin:_cos,varname:node_8116,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:5;n:type:ShaderForge.SFN_Add,id:669,x:32904,y:34396,varname:node_669,prsc:2|A-767-OUT,B-6348-OUT;n:type:ShaderForge.SFN_Vector1,id:6348,x:32515,y:34259,varname:node_6348,prsc:2,v1:1;n:type:ShaderForge.SFN_Multiply,id:6209,x:32772,y:34001,varname:node_6209,prsc:2|A-8303-OUT,B-1792-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1792,x:32135,y:34004,ptovrint:False,ptlb:vertex_bian,ptin:_vertex_bian,varname:node_1792,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.5;n:type:ShaderForge.SFN_FragmentPosition,id:936,x:32309,y:33436,varname:node_936,prsc:2;n:type:ShaderForge.SFN_ComponentMask,id:6065,x:32527,y:33436,varname:node_6065,prsc:2,cc1:1,cc2:-1,cc3:-1,cc4:-1|IN-936-XYZ;n:type:ShaderForge.SFN_Multiply,id:5133,x:32704,y:33543,varname:node_5133,prsc:2|A-6065-OUT,B-6434-OUT;n:type:ShaderForge.SFN_Vector1,id:6434,x:32511,y:33603,varname:node_6434,prsc:2,v1:-1;n:type:ShaderForge.SFN_SwitchProperty,id:2235,x:32871,y:33409,ptovrint:False,ptlb:RE,ptin:_RE,varname:node_2235,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-6065-OUT,B-5133-OUT;n:type:ShaderForge.SFN_Add,id:3593,x:33060,y:33375,varname:node_3593,prsc:2|A-2235-OUT,B-2235-OUT;n:type:ShaderForge.SFN_Tex2d,id:8277,x:32776,y:33217,ptovrint:False,ptlb:disslovetexa,ptin:_disslovetexa,varname:node_8277,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7acc33f24a06fcd46baa112415b42195,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Add,id:2171,x:33242,y:33274,varname:node_2171,prsc:2|A-8277-R,B-3593-OUT;n:type:ShaderForge.SFN_Step,id:9724,x:33495,y:33254,varname:node_9724,prsc:2|A-2338-OUT,B-2171-OUT;n:type:ShaderForge.SFN_Slider,id:2338,x:32923,y:33165,ptovrint:False,ptlb:amount,ptin:_amount,varname:node_2338,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0.2293591,max:10;n:type:ShaderForge.SFN_RemapRange,id:9485,x:33722,y:33267,varname:node_9485,prsc:2,frmn:0,frmx:1,tomn:1,tomx:0|IN-9724-OUT;n:type:ShaderForge.SFN_Clamp01,id:4678,x:34002,y:33193,varname:node_4678,prsc:2|IN-9485-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5057,x:32923,y:33067,ptovrint:False,ptlb:dissloves,ptin:_dissloves,varname:node_5057,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.1;n:type:ShaderForge.SFN_Subtract,id:8283,x:33206,y:32991,varname:node_8283,prsc:2|A-5057-OUT,B-2338-OUT;n:type:ShaderForge.SFN_Step,id:4281,x:33431,y:32994,varname:node_4281,prsc:2|A-8283-OUT,B-2171-OUT;n:type:ShaderForge.SFN_RemapRange,id:3338,x:33596,y:32994,varname:node_3338,prsc:2,frmn:0,frmx:1,tomn:0,tomx:1|IN-4281-OUT;n:type:ShaderForge.SFN_Subtract,id:5683,x:33839,y:32994,varname:node_5683,prsc:2|A-3338-OUT,B-9485-OUT;n:type:ShaderForge.SFN_Lerp,id:7379,x:34111,y:32775,varname:node_7379,prsc:2|A-5031-OUT,B-3887-RGB,T-5683-OUT;n:type:ShaderForge.SFN_Color,id:3887,x:33665,y:32839,ptovrint:False,ptlb:color3,ptin:_color3,varname:node_3887,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;proporder:7241-3438-3927-5597-1617-644-3275-1596-9887-1176-1053-3396-8116-1792-2235-8277-2338-5057-3887;pass:END;sub:END;*/

Shader "Y/qiu" {
    Properties {
        _Color1 ("Color1", Color) = (0.07843138,0.3921569,0.7843137,1)
        _tex1 ("tex1", 2D) = "white" {}
        _tex2 ("tex2", 2D) = "white" {}
        _U1 ("U1", Float ) = 0.2
        _V1 ("V1", Float ) = 0.2
        _U2 ("U2", Float ) = 0.1
        _V2 ("V2", Float ) = 0.2
        _raodong ("raodong", 2D) = "white" {}
        _fresenl ("fresenl", Range(0, 5)) = 1
        _Color2 ("Color2", Color) = (0.2132353,1,0.5767747,1)
        _vertex ("vertex", 2D) = "white" {}
        _vertex_power ("vertex_power", Float ) = 0.1
        _cos ("cos", Float ) = 5
        _vertex_bian ("vertex_bian", Float ) = 0.5
        [MaterialToggle] _RE ("RE", Float ) = 0
        _disslovetexa ("disslovetexa", 2D) = "white" {}
        _amount ("amount", Range(-5, 10)) = 0.2293591
        _dissloves ("dissloves", Float ) = 0.1
        _color3 ("color3", Color) = (1,1,1,1)
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
            Blend One One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
           // #pragma multi_compile_fwdbase
           // #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
          //  #pragma target 3.0
            #pragma glsl
            uniform float4 _TimeEditor;
            uniform float4 _Color1;
            uniform sampler2D _tex1; uniform float4 _tex1_ST;
            uniform sampler2D _tex2; uniform float4 _tex2_ST;
            uniform float _U1;
            uniform float _V1;
            uniform float _U2;
            uniform float _V2;
            uniform sampler2D _raodong; uniform float4 _raodong_ST;
            uniform float _fresenl;
            uniform float4 _Color2;
            uniform sampler2D _vertex; uniform float4 _vertex_ST;
            uniform float _vertex_power;
            uniform float _cos;
            uniform float _vertex_bian;
            uniform fixed _RE;
            uniform sampler2D _disslovetexa; uniform float4 _disslovetexa_ST;
            uniform float _amount;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                float4 node_9103 = _Time + _TimeEditor;
                float2 node_5264 = (o.uv0+(node_9103.g*float2(_U1,_V1)));
                float4 _tex1_var = tex2Dlod(_tex1,float4(TRANSFORM_TEX(node_5264, _tex1),0.0,0));
                float2 node_7456 = (o.uv0+(node_9103.g*float2(_U2,_V2)));
                float4 _tex2_var = tex2Dlod(_tex2,float4(TRANSFORM_TEX(node_7456, _tex2),0.0,0));
                float2 node_8303 = float2(_tex1_var.r,_tex2_var.r);
                float2 node_6209 = (node_8303*_vertex_bian);
                float4 _vertex_var = tex2Dlod(_vertex,float4(TRANSFORM_TEX(node_6209, _vertex),0.0,0));
                float4 node_4194 = _Time + _TimeEditor;
                v.vertex.xyz += (_vertex_var.rgb*v.normal*(cos((_cos*node_4194.g))+1.0)*_vertex_power);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float4 _disslovetexa_var = tex2D(_disslovetexa,TRANSFORM_TEX(i.uv0, _disslovetexa));
                float node_6065 = i.posWorld.rgb.g;
                float _RE_var = lerp( node_6065, (node_6065*(-1.0)), _RE );
                float node_2171 = (_disslovetexa_var.r+(_RE_var+_RE_var));
                float node_9485 = (step(_amount,node_2171)*-1.0+1.0);
                float node_4678 = saturate(node_9485);
                clip(node_4678 - 0.5);
////// Lighting:
////// Emissive:
                float4 node_9103 = _Time + _TimeEditor;
                float2 node_5264 = (i.uv0+(node_9103.g*float2(_U1,_V1)));
                float4 _tex1_var = tex2D(_tex1,TRANSFORM_TEX(node_5264, _tex1));
                float2 node_7456 = (i.uv0+(node_9103.g*float2(_U2,_V2)));
                float4 _tex2_var = tex2D(_tex2,TRANSFORM_TEX(node_7456, _tex2));
                float2 node_8303 = float2(_tex1_var.r,_tex2_var.r);
                float4 _raodong_var = tex2D(_raodong,TRANSFORM_TEX(node_8303, _raodong));
                float3 node_5031 = (lerp(_Color1.rgb,_Color2.rgb,isFrontFace)*(_raodong_var.rgb*pow(1.0-max(0,dot(normalDirection, viewDirection)),_fresenl)));
                float3 emissive = node_5031;
                float3 finalColor = emissive;
                return fixed4(finalColor,node_4678);
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            #pragma glsl
            uniform float4 _TimeEditor;
            uniform sampler2D _tex1; uniform float4 _tex1_ST;
            uniform sampler2D _tex2; uniform float4 _tex2_ST;
            uniform float _U1;
            uniform float _V1;
            uniform float _U2;
            uniform float _V2;
            uniform sampler2D _vertex; uniform float4 _vertex_ST;
            uniform float _vertex_power;
            uniform float _cos;
            uniform float _vertex_bian;
            uniform fixed _RE;
            uniform sampler2D _disslovetexa; uniform float4 _disslovetexa_ST;
            uniform float _amount;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
                float4 posWorld : TEXCOORD2;
                float3 normalDir : TEXCOORD3;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                float4 node_9103 = _Time + _TimeEditor;
                float2 node_5264 = (o.uv0+(node_9103.g*float2(_U1,_V1)));
                float4 _tex1_var = tex2Dlod(_tex1,float4(TRANSFORM_TEX(node_5264, _tex1),0.0,0));
                float2 node_7456 = (o.uv0+(node_9103.g*float2(_U2,_V2)));
                float4 _tex2_var = tex2Dlod(_tex2,float4(TRANSFORM_TEX(node_7456, _tex2),0.0,0));
                float2 node_8303 = float2(_tex1_var.r,_tex2_var.r);
                float2 node_6209 = (node_8303*_vertex_bian);
                float4 _vertex_var = tex2Dlod(_vertex,float4(TRANSFORM_TEX(node_6209, _vertex),0.0,0));
                float4 node_4194 = _Time + _TimeEditor;
                v.vertex.xyz += (_vertex_var.rgb*v.normal*(cos((_cos*node_4194.g))+1.0)*_vertex_power);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float4 _disslovetexa_var = tex2D(_disslovetexa,TRANSFORM_TEX(i.uv0, _disslovetexa));
                float node_6065 = i.posWorld.rgb.g;
                float _RE_var = lerp( node_6065, (node_6065*(-1.0)), _RE );
                float node_2171 = (_disslovetexa_var.r+(_RE_var+_RE_var));
                float node_9485 = (step(_amount,node_2171)*-1.0+1.0);
                float node_4678 = saturate(node_9485);
                clip(node_4678 - 0.5);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    //FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
