﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Weapon UI"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
		[PerRendererData] _FillPercentage("FillPercentage", Float) = 1
		[MaterialToggle] PixelSnap("Pixel snap", Float) = 0
	}

		SubShader
		{
			Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}

			Cull Off
			Lighting Off
			ZWrite Off
			Fog{ Mode Off }
			Blend One OneMinusSrcAlpha

			Pass
		{
			CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#pragma multi_compile DUMMY PIXELSNAP_ON
	#include "UnityCG.cginc"

		struct appdata_t
		{
			float4 vertex   : POSITION;
			float4 color    : COLOR;
			float2 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			float4 vertex   : SV_POSITION;
			fixed4 color : COLOR;
			half2 texcoord  : TEXCOORD0;
		};

		fixed4 _Color;
		float _FillPercentage;

		v2f vert(appdata_t IN)
		{
			v2f OUT;
			OUT.vertex = UnityObjectToClipPos(IN.vertex);
			OUT.texcoord = IN.texcoord;
			OUT.color = IN.color * _Color;
			#ifdef PIXELSNAP_ON
			OUT.vertex = cos(_Time.a) * UnityPixelSnap(OUT.vertex);
			#endif

			return OUT;
		}

		sampler2D _MainTex;

		fixed4 frag(v2f IN) : SV_Target
		{
			fixed4 c = tex2D(_MainTex, IN.texcoord) * IN.color;
			
			if (c.a == 0) discard;

			c.a = c.a * (c.g + 1 - step(_FillPercentage, IN.texcoord.y));
			c.rgb = c.a;
			if (_FillPercentage == 0) c.gb = 0;
			
			return c;
		}
			ENDCG
		}
		}
}