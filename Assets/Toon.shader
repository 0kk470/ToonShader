Shader "Roystan/Toon"
{
	Properties
	{
		_Color("Color", Color) = (0.5, 0.65, 1, 1)
		_MainTex("Main Texture", 2D) = "white" {}
		[HDR]
		_AmbientColor("Ambient Color", Color) = (0.4, 0.4, 0.4, 1)
		[HDR]
		_SpecularColor("Specular Color", Color) = (0.9, 0.9, 0.9, 1)
		_Glossiness("Glossiness", Float) = 32
		[HDR]
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimAmount("Rim Amount", Range(0, 1)) = 0.716
		_RimThreshold("Rim Threshold", Range(0, 1)) = 0.1

		_Outline("Outline Thickness", Range(0, 1)) = 0.1
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
	}
	SubShader
	{
		Pass
		{
			Name "MainPass"

			Cull Back

			Tags
			{
				"LightMode" = "ForwardBase"
				//"PassFlags" = "OnlyDirectional"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;				
				float4 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : NORMAL;
				float3 viewDir : TEXCOORD1;
				//float4 _ShadowCoord: TEXCOORD2;
				SHADOW_COORDS(2)  
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _AmbientColor;
			float4 _SpecularColor;
			float _Glossiness;
			float4 _RimColor;
			float _RimAmount;
			float _RimThreshold;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = WorldSpaceViewDir(v.vertex);
				//o._ShadowCoord = mul(unity_WorldToShadow[0], mul(unity_ObjectToWorld, v.vertex ));
				TRANSFER_SHADOW(o); 
				return o;
			}
			
			float4 _Color;

			float4 frag (v2f i) : SV_Target
			{
				float3 normal = normalize(i.worldNormal);
				float NdotL = dot(_WorldSpaceLightPos0, normal);

				//float shadow = unitySampleShadow(i._ShadowCoord)
				float shadow = SHADOW_ATTENUATION(i);
				float lightIntensity = smoothstep(0, 0.01, NdotL * shadow);
				float4 light = lightIntensity * _LightColor0;

				float3 viewDir = normalize(i.viewDir);
				float3 halfVector = normalize(viewDir + _WorldSpaceLightPos0);
				float NdotH = dot(halfVector, normal);
				float specularIntensity = pow(NdotH * lightIntensity, _Glossiness * _Glossiness);
				float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
				float4 specular = _SpecularColor * specularIntensitySmooth;
				float4 rimDot = 1 - dot(viewDir, normal);

				float rimInstensity = rimDot * pow(NdotL, _RimThreshold);
				rimInstensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimInstensity);
				float4 rim = rimInstensity * _RimColor;

				float4 sample = tex2D(_MainTex, i.uv);

				return _Color * sample * (_AmbientColor + light + specular + rim);
			}
			ENDCG
		}

		// Pass
		// {
		// 	Name "Other Lights"
		// }

		Pass
		{
			//另一个pass剔除掉前面 用来渲染描边
			Name "Outline"

			Cull Front

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			float _Outline;
			fixed4 _OutlineColor;
			
			struct appdata {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			}; 
			
			struct v2f {
			    float4 pos : SV_POSITION;
			};
			
			v2f vert (appdata v) {
				v2f o;
				
				//沿着法线稍微外扩下模型
				float4 objPos = v.vertex;
				float4 normal = float4(v.normal.xy, -0.5f, 1);
				objPos = objPos + normalize(normal) * _Outline;
				o.pos = UnityObjectToClipPos(objPos);
				
				return o;
			}
			
			float4 frag(v2f i) : SV_Target { 
				return float4(_OutlineColor.rgb, 1);               
			}
			
			ENDCG

		}

		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
	}
}