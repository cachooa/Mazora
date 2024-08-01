// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/CH_Cloth"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Outline_Color("Outline_Color", Color) = (1,1,1,0)
		_Outline_Scale1("Outline_Scale", Float) = 10
		_Outline_Width1("Outline_Width", Range( 0 , 0.1)) = 0.012
		[SingleLineTexture]_Diffuse_Texture("Diffuse_Texture", 2D) = "white" {}
		_Diffuse_Color("Diffuse_Color", Color) = (0,0,0,0)
		_ColorBlend("ColorBlend", Range( 0 , 1)) = 0
		_Use_SphereNormal("Use_SphereNormal", Range( 0 , 1)) = 0
		_Shade_Step("Shade_Step", Range( 0 , 0.49)) = 0
		[SingleLineTexture]_AO_Texture("AO_Texture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		ZWrite Off
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			float simplePerlin3D17_g7 = snoise( ase_vertexNormal*_Outline_Scale1 );
			simplePerlin3D17_g7 = simplePerlin3D17_g7*0.5 + 0.5;
			float outlineVar = ( simplePerlin3D17_g7 * _Outline_Width1 );
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			float2 uv_Diffuse_Texture = i.uv_texcoord * _Diffuse_Texture_ST.xy + _Diffuse_Texture_ST.zw;
			float4 Diffuse_Texture1929 = tex2D( _Diffuse_Texture, uv_Diffuse_Texture );
			float4 temp_cast_1 = (1.2).xxxx;
			o.Emission = saturate( ( pow( ( Diffuse_Texture1929 * 0.3 ) , temp_cast_1 ) * _Outline_Color ) ).xyz;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+50" }
		Cull Off
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
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

		uniform sampler2D _Diffuse_Texture;
		uniform float4 _Diffuse_Texture_ST;
		uniform sampler2D _AO_Texture;
		uniform float4 _AO_Texture_ST;
		uniform float _Shade_Step;
		uniform float _Use_SphereNormal;
		uniform float4 _Diffuse_Color;
		uniform float _ColorBlend;
		uniform float _Cutoff = 0.5;
		uniform float4 _Outline_Color;
		uniform float _Outline_Scale1;
		uniform float _Outline_Width1;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += 0;
			v.vertex.w = 1;
		}

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
			float2 uv_Diffuse_Texture = i.uv_texcoord * _Diffuse_Texture_ST.xy + _Diffuse_Texture_ST.zw;
			float4 Diffuse_Texture1929 = tex2D( _Diffuse_Texture, uv_Diffuse_Texture );
			float4 temp_cast_0 = (2.0).xxxx;
			float2 uv_AO_Texture = i.uv_texcoord * _AO_Texture_ST.xy + _AO_Texture_ST.zw;
			float4 lerpResult1896 = lerp( saturate( pow( ( Diffuse_Texture1929 * 0.9 ) , temp_cast_0 ) ) , Diffuse_Texture1929 , tex2D( _AO_Texture, uv_AO_Texture ).r);
			float4 temp_output_1162_0 = saturate( lerpResult1896 );
			float4 temp_cast_1 = (2.0).xxxx;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = i.worldNormal;
			float3 normalizeResult1235 = normalize( ase_worldNormal );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorldDir875 = mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 0 ) ).xyz;
			float3 normalizeResult883 = normalize( objToWorldDir875 );
			float3 lerpResult881 = lerp( normalizeResult1235 , normalizeResult883 , _Use_SphereNormal);
			float dotResult1017 = dot( ase_worldlightDir , lerpResult881 );
			float smoothstepResult1239 = smoothstep( _Shade_Step , ( 1.0 - _Shade_Step ) , ( ase_lightAtten * saturate( dotResult1017 ) ));
			float Base_Light1336 = smoothstepResult1239;
			float4 lerpResult1237 = lerp( saturate( pow( ( temp_output_1162_0 * 0.9 ) , temp_cast_1 ) ) , temp_output_1162_0 , Base_Light1336);
			float4 lerpResult1733 = lerp( ( lerpResult1237 + _Diffuse_Color ) , ( lerpResult1237 * _Diffuse_Color ) , _ColorBlend);
			float4 Diffuse_Out1792 = saturate( lerpResult1733 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = ( Diffuse_Out1792 * ase_lightColor ).rgb;
			c.a = 1;
			clip( tex2D( _Diffuse_Texture, uv_Diffuse_Texture ).a - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma exclude_renderers xboxone xboxseries playstation ps4 switch 
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
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
Node;AmplifyShaderEditor.CommentaryNode;891;747.4213,-797.0136;Inherit;False;943.3417;383.8057;;7;879;881;874;883;875;1235;880;Light_Type;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1109;1725.969,-794.0516;Inherit;False;1487.217;311.2107;;9;1336;1239;1241;1240;1220;1224;1215;1017;1015;Shade_Step;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;942;1808,-240;Float;False;Property;_Diffuse_Color;Diffuse_Color;6;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;1237;1808,-368;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1731;2048,-240;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1734;2048,-144;Inherit;False;Property;_ColorBlend;ColorBlend;7;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1650;2048,-368;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1733;2368,-368;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1210;2528,-368;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;1339;1718.634,-283.5771;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1162;1117.792,-363.6557;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;874;779.4213,-589.0136;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;880;987.4213,-749.0136;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;875;987.4213,-589.0136;Inherit;False;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;883;1243.422,-589.0136;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;879;1243.422,-509.0136;Float;False;Property;_Use_SphereNormal;Use_SphereNormal;8;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;1235;1243.422,-749.0136;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;881;1531.422,-589.0136;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;1015;1762.453,-723.7401;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;1017;2018.453,-611.7401;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1224;2162.453,-611.7401;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1220;2370.453,-723.7401;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1240;2373.499,-616.2243;Float;False;Property;_Shade_Step;Shade_Step;9;0;Create;True;0;0;0;False;0;False;0;0.49;0;0.49;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1241;2675.257,-568.2244;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1336;3003.699,-718.2314;Float;False;Base_Light;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1337;1639.154,-237.7886;Inherit;False;1336;Base_Light;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1892;1640.318,-365.5898;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1166;1302.457,-237.8148;Float;False;Constant;_Float10;Float 10;18;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;1340;1245.792,-281.4443;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;1169;1471.826,-365.8148;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1165;1302.457,-365.8148;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1164;1117.792,-235.6557;Float;False;Constant;_Float9;Float 9;19;0;Create;True;0;0;0;False;0;False;0.9;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;1215;2162.453,-723.7401;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;1239;2834.951,-717.4454;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1896;955.3285,-361.2678;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1893;629.0432,-177.4234;Inherit;True;Property;_AO_Texture;AO_Texture;10;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;1901;480.4781,-359.7449;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1902;328.7849,-359.7449;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1899;328.7849,-255.3119;Float;False;Constant;_Float11;Float 10;18;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1931;117.5208,-357.2818;Inherit;False;1929;Diffuse_Texture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1903;118.3886,-253.7882;Float;False;Constant;_Float12;Float 9;19;0;Create;True;0;0;0;False;0;False;0.9;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1898;637.2704,-359.52;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1932;634.5206,-261.8817;Inherit;False;1929;Diffuse_Texture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1792;2672,-368;Inherit;False;Diffuse_Out;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;541;147.0036,-752.1817;Inherit;True;Property;_Diffuse_Texture;Diffuse_Texture;5;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;1929;442.9965,-757.4733;Inherit;False;Diffuse_Texture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1217;1663.597,312.6056;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;936;1460.4,412.9107;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;1793;1460.4,316.9109;Inherit;False;1792;Diffuse_Out;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1377;1460.4,108.9107;Inherit;True;Property;_Opacity_Texture;Opacity_Texture;5;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;541;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;47;1904,80;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Custom/CH_Cloth;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;50;True;Opaque;;AlphaTest;All;7;d3d11;glcore;gles;gles3;metal;vulkan;ps5;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;5;False;;10;False;;0;False;;0;False;;0;False;0.005;0,0,0,1;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;1935;1663.987,414.8251;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1941;1398.054,547.837;Inherit;False;1929;Diffuse_Texture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1948;1600.503,541.4425;Inherit;False;ASF_Outline;1;;7;b02d7e57892384d448ca41a5faa4fcb1;0;1;14;FLOAT4;0,0,0,0;False;1;FLOAT3;0
WireConnection;1237;0;1892;0
WireConnection;1237;1;1339;0
WireConnection;1237;2;1337;0
WireConnection;1731;0;1237;0
WireConnection;1731;1;942;0
WireConnection;1650;0;1237;0
WireConnection;1650;1;942;0
WireConnection;1733;0;1650;0
WireConnection;1733;1;1731;0
WireConnection;1733;2;1734;0
WireConnection;1210;0;1733;0
WireConnection;1339;0;1340;0
WireConnection;1162;0;1896;0
WireConnection;875;0;874;0
WireConnection;883;0;875;0
WireConnection;1235;0;880;0
WireConnection;881;0;1235;0
WireConnection;881;1;883;0
WireConnection;881;2;879;0
WireConnection;1017;0;1015;0
WireConnection;1017;1;881;0
WireConnection;1224;0;1017;0
WireConnection;1220;0;1215;0
WireConnection;1220;1;1224;0
WireConnection;1241;0;1240;0
WireConnection;1336;0;1239;0
WireConnection;1892;0;1169;0
WireConnection;1340;0;1162;0
WireConnection;1169;0;1165;0
WireConnection;1169;1;1166;0
WireConnection;1165;0;1162;0
WireConnection;1165;1;1164;0
WireConnection;1239;0;1220;0
WireConnection;1239;1;1240;0
WireConnection;1239;2;1241;0
WireConnection;1896;0;1898;0
WireConnection;1896;1;1932;0
WireConnection;1896;2;1893;1
WireConnection;1901;0;1902;0
WireConnection;1901;1;1899;0
WireConnection;1902;0;1931;0
WireConnection;1902;1;1903;0
WireConnection;1898;0;1901;0
WireConnection;1792;0;1210;0
WireConnection;1929;0;541;0
WireConnection;1217;0;1793;0
WireConnection;1217;1;936;0
WireConnection;47;10;1377;4
WireConnection;47;13;1217;0
WireConnection;47;11;1948;0
WireConnection;1948;14;1941;0
ASEEND*/
//CHKSM=80E68C429F3EC64878A0A7A0373A6954C1FE29F8