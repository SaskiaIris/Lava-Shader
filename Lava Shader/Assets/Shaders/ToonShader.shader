Shader "EigenShaders/Toon" {
	Properties {
		_MainTexture("Main Texture", 2D) = "white" {}
		_SecondaryTexture("Secondary Texture", 2D) = "black" {}
		_Color("Color", Color) = (1,1,1,1)
		_Direction("Texture Direction", Vector) = (0,1,0,0)
		//_VertexOffset("Vertex Offset", Float) = (0,0,0,0)
		_CoverAmount("Cover Amount", Range(0,1)) = 1
		_AnimationSpeed("Animation Speed", Range(0, 3)) = 0
		_OffsetSize("Offset Size", Range(0, 10)) = 0
		[HDR]
		_AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)
		[HDR]
		_SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
		_Glossiness("Glossiness", Float) = 32
		[HDR]
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimAmount("Rim Amount", Range(0, 1)) = 0.716
		_RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
	}

	SubShader {
		CULL OFF
		Pass {
			Tags {
				"LightMode" = "ForwardBase"
				"PassFlags" = "OnlyDirectional"
			}
			CGPROGRAM
			
				#pragma vertex vertexFunc
				#pragma fragment fragmentFunc
				#pragma multi_compile_fwdbase

				#include "UnityCG.cginc" //volgens tutorial is dit een nvidia ding en moet ik misschien iets anders hebben voor amd?
				#include "Lighting.cginc"
				#include "AutoLight.cginc"

				/*struct appdata {
					float4 vertex : POSITION;
					float2 uvMain : TEXCOORD0;
					float2 uvSecondary : TEXCOORD1;
					float3 normal : NORMAL;
				};*/

				struct v2f {
					float4 pos : SV_POSITION;
					float2 uvMain : TEXCOORD0;
					float3 normal : NORMAL0;
					float3 worldNormal : NORMAL1;
					float2 uvSecondary : TEXCOORD1;
					float3 viewDirection : TEXCOORD2;
					SHADOW_COORDS(3)
				};

				//fixed4 _VertexOffset;
				fixed4 _Color;
				sampler2D _MainTexture;
				sampler2D _SecondaryTexture;
				float4 _MainTexture_ST;
				float4 _SecondaryTexture_ST;

				float _AnimationSpeed;
				float _OffsetSize;

				v2f vertexFunc(appdata_full IN) {
					v2f OUT;

					//IN.vertex += _VertexOffset;
					IN.vertex.y += sin((_Time.z * _AnimationSpeed) + (IN.vertex.z * _OffsetSize));

					OUT.pos = UnityObjectToClipPos(IN.vertex);
					OUT.uvMain = TRANSFORM_TEX(IN.texcoord, _MainTexture);
					OUT.uvSecondary = TRANSFORM_TEX(IN.texcoord, _SecondaryTexture);
					OUT.normal = mul(unity_ObjectToWorld, IN.normal);
					//OUT.uv = IN.uvMain;

					OUT.worldNormal = UnityObjectToWorldNormal(IN.normal);
					OUT.viewDirection = WorldSpaceViewDir(IN.vertex);

					TRANSFER_SHADOW(OUT)

					return OUT;
				}

				float3 _Direction;
				fixed _CoverAmount;

				float4 _AmbientColor;

				float _Glossiness;
				float4 _SpecularColor;

				float4 _RimColor;
				float _RimAmount;
				float _RimThreshold;

				fixed4 fragmentFunc(v2f IN) : COLOR {
					float3 normal = normalize(IN.worldNormal);
					float NdotL = dot(_WorldSpaceLightPos0, normal);

					float shadow = SHADOW_ATTENUATION(IN);

					float lightIntensity = smoothstep(0, 0.01, NdotL * shadow);
					float4 light = lightIntensity * _LightColor0;

					float3 viewDirection = normalize(IN.viewDirection);

					float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDirection);
					float NdotH = dot(normal, halfVector);

					float specularIntensity = pow(NdotH * lightIntensity, _Glossiness * _Glossiness);

					float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
					float4 specular = specularIntensitySmooth * _SpecularColor;

					float4 rimDot = 1 - dot(viewDirection, normal);

					fixed direction = dot(normalize(IN.normal), _Direction);

					float rimIntensity = rimDot * pow(NdotL, _RimThreshold);
					rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
					float4 rim = rimIntensity * _RimColor;

					if (direction < 1 - _CoverAmount) {
						direction = 0;
					}

					fixed4 tex1 = tex2D(_MainTexture, IN.uvMain);
					fixed4 tex2 = tex2D(_SecondaryTexture, IN.uvSecondary);

					return lerp(tex1, tex2, direction) * (_AmbientColor + light + specular + rim);
					//return pixelColor * _Color;
				}

			ENDCG
		}
		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
	}
}