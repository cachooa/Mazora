// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/UV_Flip_02"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[SingleLineTexture]_Diffuse_Texture("Diffuse_Texture", 2D) = "white" {}
		[KeywordEnum(Idle, Ah, Aw,Mmm, Ooo, Uh) 0]_Mouth("Mouth", Int) = 0
		_Mouth_X_Scale("Mouth_X_Scale", Float) = 1
		_Mouth_Y_Scale("Mouth_Y_Scale", Float) = 1
		_Diffuse_Color("Diffuse_Color", Color) = (0,0,0,0)
		_Intensity("Intensity", Range( 1 , 4)) = 1
		_ColorBlend("ColorBlend", Range( 0 , 1)) = 0
		_Use_SphereNormal("Use_SphereNormal", Range( 0 , 1)) = 0
		_Shade_Step("Shade_Step", Range( 0 , 0.49)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _Diffuse_Texture;
		uniform float _Mouth_X_Scale;
		uniform float _Mouth_Y_Scale;
		uniform int _Mouth;
		uniform float _Shade_Step;
		uniform float _Use_SphereNormal;
		uniform float4 _Diffuse_Color;
		uniform float _ColorBlend;
		uniform float _Intensity;
		uniform float _Cutoff = 0.5;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 appendResult1971 = (float2(_Mouth_X_Scale , _Mouth_Y_Scale));
			float temp_output_4_0_g33 = 4.0;
			float temp_output_5_0_g33 = 4.0;
			float2 appendResult7_g33 = (float2(temp_output_4_0_g33 , temp_output_5_0_g33));
			float totalFrames39_g33 = ( temp_output_4_0_g33 * temp_output_5_0_g33 );
			float2 appendResult8_g33 = (float2(totalFrames39_g33 , temp_output_5_0_g33));
			float clampResult42_g33 = clamp( 0.0 , 0.0001 , ( totalFrames39_g33 - 1.0 ) );
			float temp_output_35_0_g33 = frac( ( ( (float)_Mouth + clampResult42_g33 ) / totalFrames39_g33 ) );
			float2 appendResult29_g33 = (float2(temp_output_35_0_g33 , ( 1.0 - temp_output_35_0_g33 )));
			float2 temp_output_15_0_g33 = ( ( ( ( ( i.uv_texcoord * appendResult1971 ) + 0.5 ) - ( appendResult1971 / 2.0 ) ) / appendResult7_g33 ) + ( floor( ( appendResult8_g33 * appendResult29_g33 ) ) / appendResult7_g33 ) );
			float2 UV_Out1954 = temp_output_15_0_g33;
			float4 temp_output_1162_0 = saturate( tex2D( _Diffuse_Texture, UV_Out1954 ) );
			float4 temp_cast_1 = (2.0).xxxx;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult1235 = normalize( (WorldNormalVector( i , half3(0,0,0) )) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorldDir875 = mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 0 ) ).xyz;
			float3 normalizeResult883 = normalize( objToWorldDir875 );
			float3 lerpResult881 = lerp( normalizeResult1235 , normalizeResult883 , _Use_SphereNormal);
			float dotResult1017 = dot( ase_worldlightDir , lerpResult881 );
			float temp_output_1220_0 = ( ase_lightAtten * saturate( dotResult1017 ) );
			float smoothstepResult1239 = smoothstep( _Shade_Step , ( 1.0 - _Shade_Step ) , temp_output_1220_0);
			float ifLocalVar1243 = 0;
			if( 0.49 > _Shade_Step )
				ifLocalVar1243 = smoothstepResult1239;
			else if( 0.49 == _Shade_Step )
				ifLocalVar1243 = step( 0.5 , temp_output_1220_0 );
			float Base_Light1336 = ifLocalVar1243;
			float4 lerpResult1237 = lerp( pow( ( temp_output_1162_0 * 0.9 ) , temp_cast_1 ) , temp_output_1162_0 , Base_Light1336);
			float4 lerpResult1733 = lerp( ( lerpResult1237 + _Diffuse_Color ) , ( lerpResult1237 * _Diffuse_Color ) , _ColorBlend);
			float4 Diffuse_Out1792 = saturate( lerpResult1733 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = ( ( ( Diffuse_Out1792 + Base_Light1336 ) * ase_lightColor ) * _Intensity ).rgb;
			c.a = 1;
			clip( tex2D( _Diffuse_Texture, UV_Out1954 ).a - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;891;624,-1040;Inherit;False;943.3417;383.8057;;8;879;881;874;883;875;1342;1235;880;Light_Type;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;1342;656,-992;Inherit;False;-1;;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;874;656,-832;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;880;864,-992;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;875;864,-832;Inherit;False;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;879;1120,-752;Float;False;Property;_Use_SphereNormal;Use_SphereNormal;8;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;1235;1120,-992;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;883;1120,-832;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;1109;1616,-1120;Inherit;False;1828.034;517.4945;;14;1243;1244;1239;1336;1332;1160;1334;1241;1240;1220;1224;1215;1017;1015;Shade_Step;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;1015;1648,-960;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;881;1408,-832;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1963;699.9426,53.18985;Inherit;False;Constant;_Float2;Float 2;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1958;699.058,-20.5818;Inherit;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;0;False;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1017;1904,-848;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;1215;2048,-960;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1952;894.9265,-26.8285;Inherit;True;Flipbook;-1;;33;53c2488c220f6564ca6c90721ee16673;2,71,0,68,0;8;51;SAMPLER2D;0.0;False;13;FLOAT2;0,0;False;4;FLOAT;4;False;5;FLOAT;4;False;24;FLOAT;0;False;2;FLOAT;0;False;55;FLOAT;0;False;70;FLOAT;0;False;5;COLOR;53;FLOAT2;0;FLOAT;47;FLOAT;48;FLOAT;62
Node;AmplifyShaderEditor.SaturateNode;1224;2048,-848;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1954;1309.768,-23.59573;Inherit;False;UV_Out;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1240;2416,-848;Float;False;Property;_Shade_Step;Shade_Step;9;0;Create;True;0;0;0;False;0;False;0;0;0;0.49;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1220;2256,-960;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1332;2400,-704;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1955;136.1796,-373.8263;Inherit;False;1954;UV_Out;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;1241;2720,-800;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;1239;2864,-958.1897;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;541;336,-368;Inherit;True;Property;_Diffuse_Texture;Diffuse_Texture;1;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;3894a6fdc3441444daa92aa00ff2b8c4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1244;2864,-1056;Float;False;Constant;_Step_Smooth;Step_Smooth;13;0;Create;True;0;0;0;False;0;False;0.49;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1334;2720,-960;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;1160;2720,-704;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;1243;3056,-1024;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1164;672,-240;Float;False;Constant;_Float9;Float 9;19;0;Create;True;0;0;0;False;0;False;0.9;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1162;672,-368;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1165;896,-368;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1166;896,-240;Float;False;Constant;_Float10;Float 10;18;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1336;3248,-1024;Float;False;Base_Light;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1340;800,-288;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1337;1648,-240;Inherit;False;1336;Base_Light;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1339;1712,-288;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;1169;1120,-368;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1237;1808,-368;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;942;1808,-240;Float;False;Property;_Diffuse_Color;Diffuse_Color;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;1650;2048,-368;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1734;2048,-144;Inherit;False;Property;_ColorBlend;ColorBlend;7;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1731;2048,-240;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1733;2368,-368;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1210;2528,-368;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1792;2672,-368;Inherit;False;Diffuse_Out;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1840;3855.95,-319.8236;Inherit;False;1336;Base_Light;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1793;3852.484,-402.9785;Inherit;False;1792;Diffuse_Out;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;936;4076.484,-274.9785;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;1234;4076.484,-402.9785;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1217;4252.483,-402.9785;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1843;4078.084,-130.485;Inherit;False;Property;_Intensity;Intensity;6;0;Create;True;0;0;0;False;0;False;1;1;1;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1956;4178.955,-24.74512;Inherit;False;1954;UV_Out;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1889;4403.158,-117.5487;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;gray;Auto;False;Instance;541;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1842;4577.335,-391.2683;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1931;4605.363,163.0364;Inherit;False;Constant;_Float0;Float 0;26;0;Create;True;0;0;0;False;0;False;0.01;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;1964;4832.15,-382.4812;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Custom/UV_Flip_02;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.IntNode;1960;701.058,127.4182;Inherit;False;Property;_Mouth;Mouth;2;0;Create;True;0;0;0;False;1;KeywordEnum(Idle, Ah, Aw,Mmm, Ooo, Uh) 0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.CommentaryNode;1965;-128.6892,-139.8094;Inherit;False;798;411;Comment;10;1975;1974;1973;1972;1971;1970;1969;1968;1967;1966;Zoom;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1966;371.3111,-88.80941;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1967;503.3111,-89.8094;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1968;222.311,9.190552;Inherit;False;Constant;_Float4;Float 4;8;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;1969;367.3111,92.19077;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1970;223.311,155.1907;Inherit;False;Constant;_Float5;Float 5;8;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1971;74.31098,37.19064;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1972;223.9186,-88.57882;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1973;-75.53358,-88.57879;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1975;-78.68935,30.19062;Inherit;False;Property;_Mouth_X_Scale;Mouth_X_Scale;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1974;-79.68935,106.1908;Inherit;False;Property;_Mouth_Y_Scale;Mouth_Y_Scale;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
WireConnection;880;0;1342;0
WireConnection;875;0;874;0
WireConnection;1235;0;880;0
WireConnection;883;0;875;0
WireConnection;881;0;1235;0
WireConnection;881;1;883;0
WireConnection;881;2;879;0
WireConnection;1017;0;1015;0
WireConnection;1017;1;881;0
WireConnection;1952;13;1967;0
WireConnection;1952;4;1958;0
WireConnection;1952;5;1958;0
WireConnection;1952;24;1963;0
WireConnection;1952;2;1960;0
WireConnection;1224;0;1017;0
WireConnection;1954;0;1952;0
WireConnection;1220;0;1215;0
WireConnection;1220;1;1224;0
WireConnection;1332;0;1220;0
WireConnection;1241;0;1240;0
WireConnection;1239;0;1220;0
WireConnection;1239;1;1240;0
WireConnection;1239;2;1241;0
WireConnection;541;1;1955;0
WireConnection;1334;0;1240;0
WireConnection;1160;1;1332;0
WireConnection;1243;0;1244;0
WireConnection;1243;1;1334;0
WireConnection;1243;2;1239;0
WireConnection;1243;3;1160;0
WireConnection;1162;0;541;0
WireConnection;1165;0;1162;0
WireConnection;1165;1;1164;0
WireConnection;1336;0;1243;0
WireConnection;1340;0;1162;0
WireConnection;1339;0;1340;0
WireConnection;1169;0;1165;0
WireConnection;1169;1;1166;0
WireConnection;1237;0;1169;0
WireConnection;1237;1;1339;0
WireConnection;1237;2;1337;0
WireConnection;1650;0;1237;0
WireConnection;1650;1;942;0
WireConnection;1731;0;1237;0
WireConnection;1731;1;942;0
WireConnection;1733;0;1650;0
WireConnection;1733;1;1731;0
WireConnection;1733;2;1734;0
WireConnection;1210;0;1733;0
WireConnection;1792;0;1210;0
WireConnection;1234;0;1793;0
WireConnection;1234;1;1840;0
WireConnection;1217;0;1234;0
WireConnection;1217;1;936;0
WireConnection;1889;1;1956;0
WireConnection;1842;0;1217;0
WireConnection;1842;1;1843;0
WireConnection;1964;10;1889;4
WireConnection;1964;13;1842;0
WireConnection;1966;0;1972;0
WireConnection;1966;1;1968;0
WireConnection;1967;0;1966;0
WireConnection;1967;1;1969;0
WireConnection;1969;0;1971;0
WireConnection;1969;1;1970;0
WireConnection;1971;0;1975;0
WireConnection;1971;1;1974;0
WireConnection;1972;0;1973;0
WireConnection;1972;1;1971;0
ASEEND*/
//CHKSM=3A8FDCB6648626A2DAC261CB5E15EE8BA8474368