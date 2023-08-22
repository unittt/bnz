// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:False,igpj:False,qofs:0,qpre:3,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:True,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:6677,x:33197,y:33025,varname:node_6677,prsc:2|emission-8957-OUT,clip-9830-OUT;n:type:ShaderForge.SFN_Tex2d,id:5253,x:31683,y:32672,ptovrint:False,ptlb:mainTex,ptin:_mainTex,varname:node_5253,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:afbfd3ef2a6a85743b87688e97e2173b,ntxv:0,isnm:False|UVIN-5238-OUT;n:type:ShaderForge.SFN_Fresnel,id:286,x:31582,y:33039,varname:node_286,prsc:2;n:type:ShaderForge.SFN_Multiply,id:1960,x:32013,y:32962,varname:node_1960,prsc:2|A-2319-OUT,B-1588-OUT;n:type:ShaderForge.SFN_Color,id:429,x:31814,y:32867,ptovrint:False,ptlb:edgeColor,ptin:_edgeColor,varname:node_429,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:4615,x:32092,y:32664,varname:node_4615,prsc:2|A-9071-RGB,B-5253-RGB,C-5253-A;n:type:ShaderForge.SFN_Color,id:9071,x:31874,y:32474,ptovrint:False,ptlb:mainColor,ptin:_mainColor,varname:node_9071,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Add,id:7740,x:32502,y:32840,varname:node_7740,prsc:2|A-4615-OUT,B-9849-OUT;n:type:ShaderForge.SFN_Power,id:2319,x:31829,y:33039,varname:node_2319,prsc:2|VAL-286-OUT,EXP-3068-OUT;n:type:ShaderForge.SFN_ValueProperty,id:1588,x:31829,y:33243,ptovrint:False,ptlb:edgePower,ptin:_edgePower,varname:node_1588,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Slider,id:3068,x:31448,y:33223,ptovrint:False,ptlb:RimPower,ptin:_RimPower,varname:node_3068,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:1,cur:1,max:5;n:type:ShaderForge.SFN_FragmentPosition,id:7918,x:30728,y:33941,varname:node_7918,prsc:2;n:type:ShaderForge.SFN_ComponentMask,id:8302,x:30927,y:33941,varname:node_8302,prsc:2,cc1:1,cc2:-1,cc3:-1,cc4:-1|IN-7918-XYZ;n:type:ShaderForge.SFN_Tex2d,id:5049,x:31307,y:33737,ptovrint:False,ptlb:dissolveTex,ptin:_dissolveTex,varname:node_5049,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:b9a7f5fb90567434992ff4737f365378,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Add,id:9749,x:31671,y:33851,varname:node_9749,prsc:2|A-5049-R,B-7179-OUT;n:type:ShaderForge.SFN_Step,id:104,x:32022,y:33857,varname:node_104,prsc:2|A-4651-OUT,B-9749-OUT;n:type:ShaderForge.SFN_Slider,id:4651,x:31633,y:33730,ptovrint:False,ptlb:amount,ptin:_amount,varname:node_4651,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-5,cur:0,max:5;n:type:ShaderForge.SFN_RemapRange,id:8677,x:32268,y:33812,varname:node_8677,prsc:2,frmn:0,frmx:1,tomn:1,tomx:0|IN-104-OUT;n:type:ShaderForge.SFN_Clamp01,id:9830,x:32506,y:33750,varname:node_9830,prsc:2|IN-8677-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4949,x:31474,y:33510,ptovrint:False,ptlb:dissolveWide,ptin:_dissolveWide,varname:node_4949,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.1;n:type:ShaderForge.SFN_Step,id:3946,x:32001,y:33486,varname:node_3946,prsc:2|A-1264-OUT,B-9749-OUT;n:type:ShaderForge.SFN_RemapRange,id:1299,x:32159,y:33486,varname:node_1299,prsc:2,frmn:0,frmx:1,tomn:1,tomx:0|IN-3946-OUT;n:type:ShaderForge.SFN_Subtract,id:258,x:32357,y:33486,varname:node_258,prsc:2|A-8677-OUT,B-1299-OUT;n:type:ShaderForge.SFN_Subtract,id:1264,x:31768,y:33476,varname:node_1264,prsc:2|A-4651-OUT,B-4949-OUT;n:type:ShaderForge.SFN_Color,id:2679,x:32165,y:33113,ptovrint:False,ptlb:dissolveColor,ptin:_dissolveColor,varname:node_2679,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:9849,x:32251,y:32871,varname:node_9849,prsc:2|A-429-RGB,B-1960-OUT;n:type:ShaderForge.SFN_Tex2d,id:53,x:31009,y:32822,ptovrint:False,ptlb:noiseTex,ptin:_noiseTex,varname:node_53,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7acc33f24a06fcd46baa112415b42195,ntxv:0,isnm:False|UVIN-7341-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:9612,x:31010,y:32562,varname:node_9612,prsc:2,uv:0;n:type:ShaderForge.SFN_Add,id:5238,x:31416,y:32689,varname:node_5238,prsc:2|A-9612-UVOUT,B-8902-OUT;n:type:ShaderForge.SFN_Multiply,id:8902,x:31236,y:32865,varname:node_8902,prsc:2|A-53-R,B-5638-OUT;n:type:ShaderForge.SFN_Slider,id:5638,x:30828,y:33014,ptovrint:False,ptlb:noisePower,ptin:_noisePower,varname:node_5638,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:0.2;n:type:ShaderForge.SFN_Multiply,id:8957,x:32882,y:33106,varname:node_8957,prsc:2|A-6962-OUT,B-2050-A,C-9071-A;n:type:ShaderForge.SFN_VertexColor,id:2050,x:32677,y:33094,varname:node_2050,prsc:2;n:type:ShaderForge.SFN_SwitchProperty,id:8842,x:31283,y:33941,ptovrint:False,ptlb:reverse,ptin:_reverse,varname:node_8842,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-8302-OUT,B-4599-OUT;n:type:ShaderForge.SFN_Multiply,id:4599,x:31114,y:34065,varname:node_4599,prsc:2|A-8302-OUT,B-7256-OUT;n:type:ShaderForge.SFN_Vector1,id:7256,x:30927,y:34099,varname:node_7256,prsc:2,v1:-1;n:type:ShaderForge.SFN_Add,id:7179,x:31492,y:33922,varname:node_7179,prsc:2|A-8842-OUT,B-8842-OUT,C-8842-OUT;n:type:ShaderForge.SFN_Lerp,id:6962,x:32677,y:32948,varname:node_6962,prsc:2|A-7740-OUT,B-2679-RGB,T-258-OUT;n:type:ShaderForge.SFN_Panner,id:7341,x:30669,y:32783,varname:node_7341,prsc:2,spu:1,spv:1|UVIN-239-UVOUT,DIST-4494-OUT;n:type:ShaderForge.SFN_Time,id:4018,x:30231,y:32729,varname:node_4018,prsc:2;n:type:ShaderForge.SFN_Multiply,id:4494,x:30430,y:32826,varname:node_4494,prsc:2|A-4018-TSL,B-2648-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2648,x:30200,y:32948,ptovrint:False,ptlb:noiseSpeed,ptin:_noiseSpeed,varname:node_2648,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_TexCoord,id:239,x:30459,y:32605,varname:node_239,prsc:2,uv:0;proporder:9071-5253-429-3068-1588-2679-5049-4949-4651-8842-53-5638-2648;pass:END;sub:END;*/

Shader "G/G_rongjie_jianbian2" {
    Properties {
        _mainColor ("mainColor", Color) = (0.5,0.5,0.5,1)
        _mainTex ("mainTex", 2D) = "white" {}
        _edgeColor ("edgeColor", Color) = (0.5,0.5,0.5,1)
        _RimPower ("RimPower", Range(1, 5)) = 1
        _edgePower ("edgePower", Float ) = 1
        _dissolveColor ("dissolveColor", Color) = (0.5,0.5,0.5,1)
        _dissolveTex ("dissolveTex", 2D) = "white" {}
        _dissolveWide ("dissolveWide", Float ) = 0.1
        _amount ("amount", Range(-5, 5)) = 0
        [MaterialToggle] _reverse ("reverse", Float ) = 0
        _noiseTex ("noiseTex", 2D) = "white" {}
        _noisePower ("noisePower", Range(0, 0.2)) = 0
        _noiseSpeed ("noiseSpeed", Float ) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "Queue"="Transparent"
            "RenderType"="TransparentCutout"
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
            //#pragma multi_compile_fwdbase_fullshadows
            //#pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            //#pragma target 2.0
            uniform float4 _TimeEditor;
            uniform sampler2D _mainTex; uniform float4 _mainTex_ST;
            uniform float4 _edgeColor;
            uniform float4 _mainColor;
            uniform float _edgePower;
            uniform float _RimPower;
            uniform sampler2D _dissolveTex; uniform float4 _dissolveTex_ST;
            uniform float _amount;
            uniform float _dissolveWide;
            uniform float4 _dissolveColor;
            uniform sampler2D _noiseTex; uniform float4 _noiseTex_ST;
            uniform float _noisePower;
            uniform fixed _reverse;
            uniform float _noiseSpeed;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
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
                float4 _dissolveTex_var = tex2D(_dissolveTex,TRANSFORM_TEX(i.uv0, _dissolveTex));
                float node_8302 = i.posWorld.rgb.g;
                float _reverse_var = lerp( node_8302, (node_8302*(-1.0)), _reverse );
                float node_9749 = (_dissolveTex_var.r+(_reverse_var+_reverse_var+_reverse_var));
                float node_8677 = (step(_amount,node_9749)*-1.0+1.0);
                clip(saturate(node_8677) - 0.5);
////// Lighting:
////// Emissive:
                float4 node_4018 = _Time + _TimeEditor;
                float2 node_7341 = (i.uv0+(node_4018.r*_noiseSpeed)*float2(1,1));
                float4 _noiseTex_var = tex2D(_noiseTex,TRANSFORM_TEX(node_7341, _noiseTex));
                float2 node_5238 = (i.uv0+(_noiseTex_var.r*_noisePower));
                float4 _mainTex_var = tex2D(_mainTex,TRANSFORM_TEX(node_5238, _mainTex));
                float3 emissive = (lerp(((_mainColor.rgb*_mainTex_var.rgb*_mainTex_var.a)+(_edgeColor.rgb*(pow((1.0-max(0,dot(normalDirection, viewDirection))),_RimPower)*_edgePower))),_dissolveColor.rgb,(node_8677-(step((_amount-_dissolveWide),node_9749)*-1.0+1.0)))*i.vertexColor.a*_mainColor.a);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
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
            #pragma target 2.0
            uniform sampler2D _dissolveTex; uniform float4 _dissolveTex_ST;
            uniform float _amount;
            uniform fixed _reverse;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
                float4 posWorld : TEXCOORD2;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                float4 _dissolveTex_var = tex2D(_dissolveTex,TRANSFORM_TEX(i.uv0, _dissolveTex));
                float node_8302 = i.posWorld.rgb.g;
                float _reverse_var = lerp( node_8302, (node_8302*(-1.0)), _reverse );
                float node_9749 = (_dissolveTex_var.r+(_reverse_var+_reverse_var+_reverse_var));
                float node_8677 = (step(_amount,node_9749)*-1.0+1.0);
                clip(saturate(node_8677) - 0.5);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
