// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.28 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.28;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:35681,y:33438,varname:node_3138,prsc:2|emission-5376-OUT,custl-4031-OUT;n:type:ShaderForge.SFN_Tex2d,id:2675,x:32492,y:32698,ptovrint:False,ptlb:node_2675,ptin:_node_2675,varname:node_2675,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:ce6140a4a1f207b4292cfd7a73b935e8,ntxv:0,isnm:False|UVIN-8181-UVOUT;n:type:ShaderForge.SFN_Panner,id:8181,x:32252,y:32698,varname:node_8181,prsc:2,spu:0,spv:0.45|UVIN-626-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:626,x:32010,y:32680,varname:node_626,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:2566,x:32935,y:32813,varname:node_2566,prsc:2|A-2675-RGB,B-1367-OUT;n:type:ShaderForge.SFN_Fresnel,id:1367,x:32707,y:32885,varname:node_1367,prsc:2|EXP-9840-OUT;n:type:ShaderForge.SFN_Slider,id:9840,x:32441,y:33098,ptovrint:False,ptlb:fresnel_1,ptin:_fresnel_1,varname:node_9840,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1.69,max:2;n:type:ShaderForge.SFN_Power,id:7596,x:33175,y:32850,varname:node_7596,prsc:2|VAL-2566-OUT,EXP-9861-OUT;n:type:ShaderForge.SFN_Slider,id:9861,x:32854,y:33168,ptovrint:False,ptlb:power_1,ptin:_power_1,varname:node_9861,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:2;n:type:ShaderForge.SFN_Multiply,id:5285,x:33585,y:32883,varname:node_5285,prsc:2|A-169-OUT,B-36-RGB;n:type:ShaderForge.SFN_Color,id:36,x:33386,y:33085,ptovrint:False,ptlb:color_1,ptin:_color_1,varname:node_36,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:0.5953346,c3:0.2279412,c4:1;n:type:ShaderForge.SFN_Tex2d,id:6816,x:32326,y:33270,ptovrint:False,ptlb:node_6816,ptin:_node_6816,varname:node_6816,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:d1407dbeed6eb8e4e90724711da8304e,ntxv:0,isnm:False|UVIN-7432-UVOUT;n:type:ShaderForge.SFN_Panner,id:7432,x:32087,y:33270,varname:node_7432,prsc:2,spu:0,spv:-0.2|UVIN-4248-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:4248,x:31850,y:33270,varname:node_4248,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:6547,x:32764,y:33265,varname:node_6547,prsc:2|A-6816-RGB,B-8847-OUT;n:type:ShaderForge.SFN_Fresnel,id:8847,x:32484,y:33398,varname:node_8847,prsc:2|EXP-3930-OUT;n:type:ShaderForge.SFN_Slider,id:3930,x:32159,y:33601,ptovrint:False,ptlb:fresnel_2,ptin:_fresnel_2,varname:node_3930,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1.48,max:2;n:type:ShaderForge.SFN_Power,id:9093,x:32990,y:33341,varname:node_9093,prsc:2|VAL-6547-OUT,EXP-4728-OUT;n:type:ShaderForge.SFN_Slider,id:4728,x:32606,y:33548,ptovrint:False,ptlb:power_2,ptin:_power_2,varname:node_4728,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1.52,max:2;n:type:ShaderForge.SFN_Multiply,id:9962,x:33470,y:33359,varname:node_9962,prsc:2|A-2508-OUT,B-4123-RGB;n:type:ShaderForge.SFN_Color,id:4123,x:33373,y:33559,ptovrint:False,ptlb:color_2,ptin:_color_2,varname:node_4123,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:0.7387424,c3:0.1764706,c4:1;n:type:ShaderForge.SFN_Multiply,id:8330,x:33947,y:33154,varname:node_8330,prsc:2|A-5285-OUT,B-9962-OUT;n:type:ShaderForge.SFN_Add,id:8276,x:33805,y:33468,varname:node_8276,prsc:2|A-5285-OUT,B-9962-OUT;n:type:ShaderForge.SFN_Tex2d,id:8859,x:33042,y:33871,ptovrint:False,ptlb:node_8859,ptin:_node_8859,varname:node_8859,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:f7b513bd321d683409f551c9a374a0a4,ntxv:0,isnm:False|UVIN-6343-UVOUT;n:type:ShaderForge.SFN_Panner,id:6343,x:32444,y:33845,varname:node_6343,prsc:2,spu:0.2,spv:0|UVIN-944-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:944,x:32129,y:33793,varname:node_944,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:5095,x:33466,y:33846,varname:node_5095,prsc:2|A-8859-RGB,B-5311-OUT;n:type:ShaderForge.SFN_Slider,id:5311,x:33062,y:34072,ptovrint:False,ptlb:light,ptin:_light,varname:node_5311,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1.33931,max:2;n:type:ShaderForge.SFN_Power,id:9713,x:33946,y:33831,varname:node_9713,prsc:2|VAL-5095-OUT,EXP-814-OUT;n:type:ShaderForge.SFN_Slider,id:814,x:33592,y:34013,ptovrint:False,ptlb:node_814,ptin:_node_814,varname:node_814,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:2,max:2;n:type:ShaderForge.SFN_Add,id:5734,x:34415,y:33531,varname:node_5734,prsc:2|A-783-OUT,B-3529-OUT;n:type:ShaderForge.SFN_Multiply,id:5511,x:34310,y:33924,varname:node_5511,prsc:2|A-9713-OUT,B-9990-RGB;n:type:ShaderForge.SFN_Color,id:9990,x:34046,y:33996,ptovrint:False,ptlb:color_3,ptin:_color_3,varname:node_9990,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:0.560649,c3:0.1617647,c4:1;n:type:ShaderForge.SFN_Multiply,id:3529,x:34608,y:33934,varname:node_3529,prsc:2|A-5511-OUT,B-5721-OUT;n:type:ShaderForge.SFN_Fresnel,id:5721,x:34584,y:34115,varname:node_5721,prsc:2|EXP-9799-OUT;n:type:ShaderForge.SFN_Slider,id:9799,x:34249,y:34184,ptovrint:False,ptlb:frenel_3,ptin:_frenel_3,varname:node_9799,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.8476688,max:5;n:type:ShaderForge.SFN_Multiply,id:783,x:34150,y:33431,varname:node_783,prsc:2|A-8276-OUT,B-8694-OUT;n:type:ShaderForge.SFN_Fresnel,id:8694,x:34021,y:33559,varname:node_8694,prsc:2|EXP-8979-OUT;n:type:ShaderForge.SFN_Slider,id:8979,x:33758,y:33734,ptovrint:False,ptlb:frensenl_4_z,ptin:_frensenl_4_z,varname:node_8979,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1.077255,max:5;n:type:ShaderForge.SFN_Multiply,id:6809,x:34765,y:33491,varname:node_6809,prsc:2|A-5734-OUT,B-7975-OUT;n:type:ShaderForge.SFN_Slider,id:7975,x:34501,y:33698,ptovrint:False,ptlb:light_zong,ptin:_light_zong,varname:node_7975,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.6519087,max:2;n:type:ShaderForge.SFN_Multiply,id:5376,x:35236,y:33469,varname:node_5376,prsc:2|A-6809-OUT,B-1494-RGB,C-8330-OUT;n:type:ShaderForge.SFN_VertexColor,id:1494,x:34862,y:33889,varname:node_1494,prsc:2;n:type:ShaderForge.SFN_Multiply,id:4031,x:35218,y:33831,varname:node_4031,prsc:2|A-6809-OUT,B-1494-A;n:type:ShaderForge.SFN_Multiply,id:2508,x:33200,y:33252,varname:node_2508,prsc:2|A-9093-OUT,B-7987-OUT;n:type:ShaderForge.SFN_Slider,id:7987,x:32983,y:33586,ptovrint:False,ptlb:light_sx_2,ptin:_light_sx_2,varname:node_7987,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.4243519,max:1;n:type:ShaderForge.SFN_Multiply,id:169,x:33492,y:32702,varname:node_169,prsc:2|A-7596-OUT,B-8251-OUT;n:type:ShaderForge.SFN_Slider,id:8251,x:33229,y:32949,ptovrint:False,ptlb:light_sx_1,ptin:_light_sx_1,varname:node_8251,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.8523774,max:1;n:type:ShaderForge.SFN_Tex2d,id:5629,x:33505,y:32715,ptovrint:False,ptlb:maintex_mask,ptin:_maintex_mask,varname:node_8073,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;proporder:2675-9840-9861-36-6816-3930-4728-4123-8859-5311-814-9990-9799-8979-7975-7987-8251;pass:END;sub:END;*/

Shader "Y/buff_eff_10003_foot" {
    Properties {
        _node_2675 ("node_2675", 2D) = "white" {}
        _fresnel_1 ("fresnel_1", Range(0, 2)) = 1.69
        _power_1 ("power_1", Range(0, 2)) = 1
        _color_1 ("color_1", Color) = (1,0.5953346,0.2279412,1)
        _node_6816 ("node_6816", 2D) = "white" {}
        _fresnel_2 ("fresnel_2", Range(0, 2)) = 1.48
        _power_2 ("power_2", Range(0, 2)) = 1.52
        _color_2 ("color_2", Color) = (1,0.7387424,0.1764706,1)
        _node_8859 ("node_8859", 2D) = "white" {}
        _light ("light", Range(0, 2)) = 1.33931
        _node_814 ("node_814", Range(0, 2)) = 2
        _color_3 ("color_3", Color) = (1,0.560649,0.1617647,1)
        _frenel_3 ("frenel_3", Range(0, 5)) = 0.8476688
        _frensenl_4_z ("frensenl_4_z", Range(0, 5)) = 1.077255
        _light_zong ("light_zong", Range(0, 2)) = 0.6519087
        _light_sx_2 ("light_sx_2", Range(0, 1)) = 0.4243519
        _light_sx_1 ("light_sx_1", Range(0, 1)) = 0.8523774
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
            uniform sampler2D _node_2675; uniform float4 _node_2675_ST;
            uniform float _fresnel_1;
            uniform float _power_1;
            uniform float4 _color_1;
            uniform sampler2D _node_6816; uniform float4 _node_6816_ST;
            uniform float _fresnel_2;
            uniform float _power_2;
            uniform float4 _color_2;
            uniform sampler2D _node_8859; uniform float4 _node_8859_ST;
            uniform float _light;
            uniform float _node_814;
            uniform float4 _color_3;
            uniform float _frenel_3;
            uniform float _frensenl_4_z;
            uniform float _light_zong;
            uniform float _light_sx_2;
            uniform float _light_sx_1;
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
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                float4 node_1595 = _Time + _TimeEditor;
                float2 node_8181 = (i.uv0+node_1595.g*float2(0,0.45));
                float4 _node_2675_var = tex2D(_node_2675,TRANSFORM_TEX(node_8181, _node_2675));
                float3 node_5285 = ((pow((_node_2675_var.rgb*pow(1.0-max(0,dot(normalDirection, viewDirection)),_fresnel_1)),_power_1)*_light_sx_1)*_color_1.rgb);
                float2 node_7432 = (i.uv0+node_1595.g*float2(0,-0.2));
                float4 _node_6816_var = tex2D(_node_6816,TRANSFORM_TEX(node_7432, _node_6816));
                float3 node_9962 = ((pow((_node_6816_var.rgb*pow(1.0-max(0,dot(normalDirection, viewDirection)),_fresnel_2)),_power_2)*_light_sx_2)*_color_2.rgb);
                float2 node_6343 = (i.uv0+node_1595.g*float2(0.2,0));
                float4 _node_8859_var = tex2D(_node_8859,TRANSFORM_TEX(node_6343, _node_8859));
                float3 node_6809 = ((((node_5285+node_9962)*pow(1.0-max(0,dot(normalDirection, viewDirection)),_frensenl_4_z))+((pow((_node_8859_var.rgb*_light),_node_814)*_color_3.rgb)*pow(1.0-max(0,dot(normalDirection, viewDirection)),_frenel_3)))*_light_zong);
                float3 emissive = (node_6809*i.vertexColor.rgb*(node_5285*node_9962));
                float3 finalColor = emissive + (node_6809*i.vertexColor.a);
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
