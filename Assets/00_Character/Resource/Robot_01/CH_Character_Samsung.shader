// Made with Amplify Shader Editor v1.9.0.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Samsung"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Rim_Color("Rim_Color", Color) = (1,1,1,0)
		_Rim_Power("Rim_Power", Range( 0.1 , 10)) = 0.1
		_Rim_Offset("Rim_Offset", Float) = 0.7
		[SingleLineTexture]_Main_Texture("Main_Texture", 2D) = "gray" {}
		[SingleLineTexture]_Roughness_Texture("Roughness_Texture", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Smooth_Step("Smooth_Step", Range( 0 , 0.49)) = 0
		_Smooth_Multiply("Smooth_Multiply", Range( 0 , 1)) = 0
		_Shade_Step("Shade_Step", Range( 0 , 0.49)) = 0
		[SingleLineTexture]_Height_Texture("Height_Texture", 2D) = "white" {}
		_Height_Strength("Height_Strength", Range( 0 , 0.5)) = 0.5
		_Use_SphereNormal("Use_SphereNormal", Range( 0 , 1)) = 0
		[SingleLineTexture]_Normal_Texture("Normal_Texture", 2D) = "bump" {}
		_Normal_Scale("Normal_Scale", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
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
			float3 viewDir;
			INTERNAL_DATA
			float3 worldPos;
			float3 worldNormal;
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

		uniform sampler2D _Main_Texture;
		uniform float4 _Main_Texture_ST;
		uniform sampler2D _Height_Texture;
		uniform float4 _Height_Texture_ST;
		uniform float _Height_Strength;
		uniform float _Shade_Step;
		uniform sampler2D _Normal_Texture;
		uniform float _Normal_Scale;
		uniform float _Use_SphereNormal;
		uniform float _Rim_Offset;
		uniform float _Rim_Power;
		uniform float4 _Rim_Color;
		uniform float _Smooth_Step;
		uniform sampler2D _Roughness_Texture;
		uniform float4 _Roughness_Texture_ST;
		uniform float _Smoothness;
		uniform float _Smooth_Multiply;
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
			float2 uv_Main_Texture = i.uv_texcoord * _Main_Texture_ST.xy + _Main_Texture_ST.zw;
			float2 uv_Height_Texture = i.uv_texcoord * _Height_Texture_ST.xy + _Height_Texture_ST.zw;
			float4 tex2DNode1735 = tex2D( _Height_Texture, uv_Height_Texture );
			float lerpResult1906 = lerp( _Height_Strength , 0.0 , tex2DNode1735.r);
			float2 paralaxOffset1899 = ParallaxOffset( ( 1.0 - tex2DNode1735.r ) , lerpResult1906 , i.viewDir );
			float2 Height1904 = ( i.uv_texcoord + paralaxOffset1899 );
			float3 temp_output_1815_0 = (tex2D( _Main_Texture, Height1904 )).rgb;
			float3 temp_output_1162_0 = saturate( temp_output_1815_0 );
			float3 temp_cast_0 = (2.0).xxx;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 Nomal1248 = UnpackScaleNormal( tex2D( _Normal_Texture, Height1904 ), _Normal_Scale );
			float3 normalizeResult1235 = normalize( (WorldNormalVector( i , Nomal1248 )) );
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
			float3 lerpResult1237 = lerp( pow( ( temp_output_1162_0 * 0.9 ) , temp_cast_0 ) , temp_output_1162_0 , Base_Light1336);
			float3 newWorldNormal1796 = normalize( (WorldNormalVector( i , Nomal1248 )) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult1798 = dot( newWorldNormal1796 , ase_worldViewDir );
			float dotResult1801 = dot( newWorldNormal1796 , ase_worldlightDir );
			float4 Rim1813 = ( saturate( ( pow( ( 1.0 - saturate( ( dotResult1798 + _Rim_Offset ) ) ) , _Rim_Power ) * dotResult1801 ) ) * _Rim_Color );
			float2 uv_Roughness_Texture = i.uv_texcoord * _Roughness_Texture_ST.xy + _Roughness_Texture_ST.zw;
			float3 normalizeResult1863 = normalize( ( ase_worldlightDir + ase_worldViewDir ) );
			float dotResult1864 = dot( normalizeResult1863 , (WorldNormalVector( i , Nomal1248 )) );
			float smoothstepResult1858 = smoothstep( _Smooth_Step , ( 1.0 - _Smooth_Step ) , ( tex2D( _Roughness_Texture, uv_Roughness_Texture ).r * pow( saturate( dotResult1864 ) , max( ( _Smoothness * 100.0 ) , 0.01 ) ) ));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = ( ( float4( lerpResult1237 , 0.0 ) + ( Rim1813 * Base_Light1336 ) + ( ( Base_Light1336 * smoothstepResult1858 ) * _Smooth_Multiply ) ) * ase_lightColor ).rgb;
			c.a = 1;
			clip( tex2D( _Main_Texture, uv_Main_Texture ).a - _Cutoff );
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
		#pragma only_renderers d3d9 d3d11_9x d3d11 glcore gles gles3 metal vulkan 
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred 

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
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
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
Version=19002
996;476;1285;738;-768.0613;623.6442;2.278512;True;False
Node;AmplifyShaderEditor.SamplerNode;1735;3034.547,293.1426;Inherit;True;Property;_Height_Texture;Height_Texture;14;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;1908;3409.478,560.2616;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1734;3406.137,392.4894;Inherit;False;Property;_Height_Strength;Height_Strength;15;0;Create;True;0;0;0;False;0;False;0.5;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1907;3408.346,469.2275;Inherit;False;Constant;_Float2;Float 2;28;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1741;3680.215,313.6914;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1906;3683.948,396.6265;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1901;3670.009,528.6349;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexCoordVertexDataNode;1903;3895.561,234.2952;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ParallaxOffsetHlpNode;1899;3890.49,362.6051;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1902;4126.562,355.2953;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1904;4252.687,351.4168;Inherit;False;Height;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1246;4269.206,439.3627;Float;False;Property;_Normal_Scale;Normal_Scale;18;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1245;4466.153,345.2121;Inherit;True;Property;_Normal_Texture;Normal_Texture;17;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;377951176c18fc94bbc4bcfc434e16c8;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;891;624,-1040;Inherit;False;943.3417;383.8057;;8;879;881;874;883;875;1342;1235;880;Light_Type;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1248;4790.51,343.1401;Float;False;Nomal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;874;656,-832;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1342;656,-992;Inherit;False;1248;Nomal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;1812;2188.112,954.3241;Inherit;False;2218.444;503.7776;Comment;19;1813;1596;1811;1810;1809;1808;1807;1806;1805;1804;1803;1802;1801;1800;1799;1798;1797;1796;1795;Rim;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;880;864,-992;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;1596;2204.647,1003.571;Inherit;False;1248;Nomal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;875;864,-832;Inherit;False;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;1109;1616,-1120;Inherit;False;1828.034;517.4945;;13;1243;1244;1239;1336;1160;1334;1241;1240;1220;1224;1215;1017;1015;Shade_Step;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1797;2379.334,1164.324;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;1796;2379.334,1004.324;Inherit;False;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;879;1120,-752;Float;False;Property;_Use_SphereNormal;Use_SphereNormal;16;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;883;1120,-832;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;1235;1120,-992;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;1798;2603.334,1004.324;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;1015;1648,-960;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;1811;2603.334,1164.324;Float;False;Property;_Rim_Offset;Rim_Offset;3;0;Create;True;0;0;0;False;0;False;0.7;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;881;1408,-832;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1860;1419.535,390.0556;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;1017;1904,-848;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;1861;1419.762,234.0119;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;1799;2763.334,1004.324;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;1215;2048,-960;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1862;1679.955,243.9421;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;1800;2923.334,1004.324;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1882;1683.073,373.182;Inherit;False;1248;Nomal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;1809;2585.817,1238.257;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;1224;2048,-848;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;1802;3099.334,1292.324;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;1803;3099.334,1004.324;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1810;3099.334,1164.324;Float;False;Property;_Rim_Power;Rim_Power;2;0;Create;True;0;0;0;False;0;False;0.1;2;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1736;1709.863,567.8215;Inherit;False;Property;_Smoothness;Smoothness;10;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;1859;1878.813,372.9732;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1220;2256,-960;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;1863;1878.777,245.6013;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;1808;3289.817,1254.257;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1870;1821.911,689.1776;Inherit;False;Constant;_Float0;Float 0;30;0;Create;True;0;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1240;2416,-848;Float;False;Property;_Shade_Step;Shade_Step;13;0;Create;True;0;0;0;False;0;False;0;0.2;0;0.49;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1850;2410.298,-696.0088;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;1804;3387.334,1004.324;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1905;-80.10722,-354.4958;Inherit;False;1904;Height;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;1241;2720,-800;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1872;1989.997,689.8063;Inherit;False;Constant;_Float4;Float 4;30;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1864;2067.132,247.1224;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1825;2004.778,571.3786;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1801;3387.334,1292.324;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1867;2225.559,250.8943;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;1871;2161.479,571.4241;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1805;3579.334,1004.324;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1334;2720,-960;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;1160;2720,-704;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1244;2864,-1056;Float;False;Constant;_Step_Smooth;Step_Smooth;13;0;Create;True;0;0;0;False;0;False;0.49;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;1239;2864,-960;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1794;117.0028,-372.5551;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;gray;Auto;False;Instance;541;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1855;2710.007,89.74554;Float;False;Property;_Smooth_Step;Smooth_Step;11;0;Create;True;0;0;0;False;0;False;0;0.1;0;0.49;0;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;1243;3056,-1024;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1806;3771.334,1004.324;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1377;2364.109,-50.31298;Inherit;True;Property;_Roughness_Texture;Roughness_Texture;9;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;c2d6885906841914a9be699be07e123d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;1795;3771.334,1164.324;Float;False;Property;_Rim_Color;Rim_Color;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.5754717,0.5754717,0.5754717,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;1815;472.3698,-375.7883;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;1869;2380.99,247.7229;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1856;3014.007,137.7456;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1164;2384,-240;Float;False;Constant;_Float9;Float 9;19;0;Create;True;0;0;0;False;0;False;0.9;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1807;3979.334,1004.324;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1162;2192,-368;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1879;2724.368,-53.65833;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1336;3248,-1024;Float;False;Base_Light;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1166;2624,-240;Float;False;Constant;_Float10;Float 10;18;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1340;2337.067,-282.5732;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1165;2624,-368;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1813;4178.553,1013.424;Inherit;False;Rim;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;1858;3158.007,-22.25454;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1890;3158.343,-117.5435;Inherit;False;1336;Base_Light;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1909;3357.755,-0.8413775;Float;False;Property;_Smooth_Multiply;Smooth_Multiply;12;0;Create;True;0;0;0;False;0;False;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1888;3362.573,-118.396;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1878;3358.565,-210.7852;Inherit;False;1336;Base_Light;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1876;3361.214,-291.1361;Inherit;False;1813;Rim;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;1339;2967.029,-285.2563;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1337;2816,-240;Inherit;False;1336;Base_Light;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;1169;2816,-368;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;1237;3040,-368;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1910;3625.195,-122.5851;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1881;3616.177,-251.5229;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;1540;1616,-2080;Inherit;False;870.5974;234.3248;Adjustable Light Attenuation (directional light shadow tweaking);5;1552;1550;1547;1546;1542;SSS Directional Lights (shadow control);1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1234;3791.413,-374.7064;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;1528;640,-1760;Inherit;False;931.8422;456.5702;;8;1535;1532;1538;1536;1533;1531;1530;1529;Subsurface Scattering Directional Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightColorNode;936;3821.625,-241.6147;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;1551;2528,-2080;Inherit;False;663.2922;345.9129;;5;1482;1556;1600;1555;1554;SSS Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1534;1607.983,-1760;Inherit;False;878.892;563.86;;9;1549;1548;1544;1545;1543;1539;1541;1651;1537;SSS Mask Strength;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;1555;2544,-2032;Float;False;Property;_InternalColour;Internal Colour;20;0;Create;True;0;0;0;False;0;False;0.9632353,0.08499137,0.08499137,0;1,0.4408097,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1531;960,-1568;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;1536;1248,-1712;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1217;4057.414,-367.5659;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1482;2992,-2032;Inherit;False;SSS;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1543;1792,-1426.004;Inherit;True;Property;_SSSMap;SSS Map;19;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;1552;2336,-2016;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1778;213.0509,41.50286;Inherit;True;Property;_AO_Texture;AO_Texture;5;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;1546;1952,-2016;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1545;1952,-1712;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1556;2816,-2032;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1535;1248,-1568;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;1549;2336,-1712;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1767;2117.262,-1066.094;Inherit;False;Constant;_Float1;Float 1;22;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;541;4339.614,-175.2903;Inherit;True;Property;_Main_Texture;Main_Texture;4;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;d07811b6d0785c243a0a3fac97471d0b;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1554;2544,-1840;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1651;1632,-1712;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1538;1440,-1712;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1731;4021.067,-595.0965;Inherit;True;Property;_TextureSample0;Texture Sample 0;4;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;gray;Auto;False;Instance;541;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1537;1632,-1568;Float;False;Property;_SSSPower;SSS Power;21;0;Create;True;0;0;0;False;0;False;1;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;1529;672,-1568;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;1530;672,-1424;Float;False;Property;_SubsurfaceDistortion;Subsurface Distortion;24;0;Create;True;0;0;0;False;0;False;0.5;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1539;1792,-1568;Float;False;Property;_SSSScale;SSS Scale;23;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;1532;672,-1712;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;1780;724.8858,-129.0583;Inherit;False;Constant;_Float3;Float 3;11;0;Create;True;0;0;0;False;0;False;1.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1781;719.6578,-36.15541;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;1792;1787.368,-365.076;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1783;871.8911,-43.16542;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1782;719.5508,64.29391;Inherit;False;Property;_AO_Pow;AO_Pow;7;0;Create;True;0;0;0;False;0;False;1;10;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;1784;1019.026,-30.05042;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;4;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;1786;898.7694,175.7527;Inherit;False;Property;_AO_Color;AO_Color;8;0;Create;True;0;0;0;False;0;False;0,0,0,1;0.7647059,0.4039216,0.2196078,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1790;1457.549,-154.9857;Inherit;False;Property;_AO_Blend;AO_Blend;6;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1785;1172.571,-31.48524;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightAttenuation;1547;1952,-1936;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;1816;1129.893,176.4302;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1787;1323.488,-31.85328;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1548;2176,-1712;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1550;2176,-2016;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1600;2762.49,-1860.413;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1542;1632,-2016;Float;False;Property;_ShadowStrength;Shadow Strength;25;0;Create;True;0;0;0;False;0;False;1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1533;1104,-1712;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;1541;1792,-1712;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1544;1952,-1568;Float;False;Property;_SSSMultiplier;SSS Multiplier;22;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;1793;1957.851,-366.8243;Inherit;False;True;True;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;1788;600.7524,-166.0117;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1789;1449.023,-280.4881;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;47;4358.491,-602.6362;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Custom/Samsung;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;ForwardOnly;8;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;vulkan;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;5;False;;10;False;;0;False;;0;False;;0;False;0.005;0,0,0,1;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1908;0;1735;1
WireConnection;1741;0;1735;1
WireConnection;1906;0;1734;0
WireConnection;1906;1;1907;0
WireConnection;1906;2;1908;0
WireConnection;1899;0;1741;0
WireConnection;1899;1;1906;0
WireConnection;1899;2;1901;0
WireConnection;1902;0;1903;0
WireConnection;1902;1;1899;0
WireConnection;1904;0;1902;0
WireConnection;1245;1;1904;0
WireConnection;1245;5;1246;0
WireConnection;1248;0;1245;0
WireConnection;880;0;1342;0
WireConnection;875;0;874;0
WireConnection;1796;0;1596;0
WireConnection;883;0;875;0
WireConnection;1235;0;880;0
WireConnection;1798;0;1796;0
WireConnection;1798;1;1797;0
WireConnection;881;0;1235;0
WireConnection;881;1;883;0
WireConnection;881;2;879;0
WireConnection;1017;0;1015;0
WireConnection;1017;1;881;0
WireConnection;1799;0;1798;0
WireConnection;1799;1;1811;0
WireConnection;1862;0;1861;0
WireConnection;1862;1;1860;0
WireConnection;1800;0;1799;0
WireConnection;1809;0;1796;0
WireConnection;1224;0;1017;0
WireConnection;1803;0;1800;0
WireConnection;1859;0;1882;0
WireConnection;1220;0;1215;0
WireConnection;1220;1;1224;0
WireConnection;1863;0;1862;0
WireConnection;1808;0;1809;0
WireConnection;1850;0;1220;0
WireConnection;1804;0;1803;0
WireConnection;1804;1;1810;0
WireConnection;1241;0;1240;0
WireConnection;1864;0;1863;0
WireConnection;1864;1;1859;0
WireConnection;1825;0;1736;0
WireConnection;1825;1;1870;0
WireConnection;1801;0;1808;0
WireConnection;1801;1;1802;0
WireConnection;1867;0;1864;0
WireConnection;1871;0;1825;0
WireConnection;1871;1;1872;0
WireConnection;1805;0;1804;0
WireConnection;1805;1;1801;0
WireConnection;1334;0;1240;0
WireConnection;1160;1;1850;0
WireConnection;1239;0;1220;0
WireConnection;1239;1;1240;0
WireConnection;1239;2;1241;0
WireConnection;1794;1;1905;0
WireConnection;1243;0;1244;0
WireConnection;1243;1;1334;0
WireConnection;1243;2;1239;0
WireConnection;1243;3;1160;0
WireConnection;1806;0;1805;0
WireConnection;1815;0;1794;0
WireConnection;1869;0;1867;0
WireConnection;1869;1;1871;0
WireConnection;1856;0;1855;0
WireConnection;1807;0;1806;0
WireConnection;1807;1;1795;0
WireConnection;1162;0;1815;0
WireConnection;1879;0;1377;1
WireConnection;1879;1;1869;0
WireConnection;1336;0;1243;0
WireConnection;1340;0;1162;0
WireConnection;1165;0;1162;0
WireConnection;1165;1;1164;0
WireConnection;1813;0;1807;0
WireConnection;1858;0;1879;0
WireConnection;1858;1;1855;0
WireConnection;1858;2;1856;0
WireConnection;1888;0;1890;0
WireConnection;1888;1;1858;0
WireConnection;1339;0;1340;0
WireConnection;1169;0;1165;0
WireConnection;1169;1;1166;0
WireConnection;1237;0;1169;0
WireConnection;1237;1;1339;0
WireConnection;1237;2;1337;0
WireConnection;1910;0;1888;0
WireConnection;1910;1;1909;0
WireConnection;1881;0;1876;0
WireConnection;1881;1;1878;0
WireConnection;1234;0;1237;0
WireConnection;1234;1;1881;0
WireConnection;1234;2;1910;0
WireConnection;1531;0;1529;0
WireConnection;1531;1;1530;0
WireConnection;1536;0;1533;0
WireConnection;1217;0;1234;0
WireConnection;1217;1;936;0
WireConnection;1482;0;1556;0
WireConnection;1552;0;1550;0
WireConnection;1546;0;1542;0
WireConnection;1545;0;1541;0
WireConnection;1545;1;1539;0
WireConnection;1556;0;1555;0
WireConnection;1556;1;1600;0
WireConnection;1549;0;1548;0
WireConnection;1554;0;1552;0
WireConnection;1554;1;1549;0
WireConnection;1651;0;1538;0
WireConnection;1538;0;1536;0
WireConnection;1538;1;1535;0
WireConnection;1781;0;1815;0
WireConnection;1781;1;1778;1
WireConnection;1792;0;1815;0
WireConnection;1792;1;1789;0
WireConnection;1792;2;1790;0
WireConnection;1783;0;1780;0
WireConnection;1783;1;1781;0
WireConnection;1784;0;1783;0
WireConnection;1784;1;1782;0
WireConnection;1785;0;1784;0
WireConnection;1816;0;1786;0
WireConnection;1787;0;1785;0
WireConnection;1787;1;1816;0
WireConnection;1548;0;1545;0
WireConnection;1548;1;1544;0
WireConnection;1548;2;1543;1
WireConnection;1550;0;1546;0
WireConnection;1550;1;1547;0
WireConnection;1600;0;1554;0
WireConnection;1533;0;1532;0
WireConnection;1533;1;1531;0
WireConnection;1541;0;1651;0
WireConnection;1541;1;1537;0
WireConnection;1793;0;1792;0
WireConnection;1788;0;1778;1
WireConnection;1789;0;1787;0
WireConnection;1789;1;1815;0
WireConnection;1789;2;1788;0
WireConnection;47;10;1731;4
WireConnection;47;13;1217;0
ASEEND*/
//CHKSM=51A3DBF761F43BBAF52346A65618E47C2EE8AFA7