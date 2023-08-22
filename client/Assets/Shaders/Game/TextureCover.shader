Shader "Game/TextureCover"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
		_SkipRange ("Clip Range",Vector) = (0,0,0,0)
	}
	
	SubShader
	{
		LOD 200

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			Offset -1, -1
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _SkipRange; 
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};
	
			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};
	
			v2f o;

			v2f vert (appdata_t v)
			{
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = v.texcoord;
				o.color = v.color;
				return o;
			}
				
			fixed4 frag (v2f IN) : SV_Target
			{
				//if((pow((IN.texcoord.x - _SkipRange.x), 2) / pow(_SkipRange.z, 2) + pow((IN.texcoord.y - _SkipRange.y), 2) / pow(_SkipRange.w, 2)) <= 1)
				//{
				//	fixed4 col = tex2D(_MainTex, IN.texcoord);
				//	col = col * IN.color;
				//	return col;
				//}
				//else
				//{
				//	fixed4 col = fixed4(0,0,0,0);
				//	return col;
				//}
				if ( (IN.texcoord.x - _SkipRange.x >= - _SkipRange.z) && (IN.texcoord.x - _SkipRange.x <= _SkipRange.z) && (IN.texcoord.y - _SkipRange.y >= - _SkipRange.w) && (IN.texcoord.y - _SkipRange.y <= _SkipRange.w) )
				{
					fixed4 col = fixed4(0,0,0,0);
					return col;
				}
				else
				{
					fixed4 col = tex2D(_MainTex, IN.texcoord);
					col = col * IN.color;
					return col;
				}
			}
			ENDCG
		}
	}
}
