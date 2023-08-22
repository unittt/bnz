// THIS SHADER IS FROM: http://www.unifycommunity.com/wiki/index.php?title=Dissolve_With_Texture

// simple "dissolving" shader by genericuser (radware.wordpress.com)
// clips materials, using an image as guidance.
// use clouds or random noise as the slice guide for best results.

  Shader "mShaders/Holes1" {
    Properties {
      _MainTex ("Texture (RGB)", 2D) = "white" {}
      _SliceGuide ("Slice Guide (RGB)", 2D) = "white" {}
      _SliceAmount ("Slice Amount", Range(0.0, 1.0)) = 0.9
	  _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
      Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
      Cull Off
      CGPROGRAM
      //if you're not planning on using shadows, remove "addshadow" for better performance
      #pragma surface surf Lambert alphatest:_Cutoff
      struct Input {
          float2 uv_MainTex;
          float2 uv_SliceGuide;
          float _SliceAmount;
      };
      sampler2D _MainTex;
      sampler2D _SliceGuide;
      float _SliceAmount;
      void surf (Input IN, inout SurfaceOutput o) {
          clip(tex2D (_SliceGuide, IN.uv_SliceGuide).rgb - _SliceAmount);
          o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
		  o.Alpha = tex2D (_MainTex, IN.uv_MainTex).a;
      }
      ENDCG
    }
    Fallback "Diffuse"
  }