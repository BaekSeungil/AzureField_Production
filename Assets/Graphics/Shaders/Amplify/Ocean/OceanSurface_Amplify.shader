// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "OceanSurface_Amplify"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_Intensity("Intensity", Float) = 1
		_Roataion("Roataion", Float) = 0
		_Direction1("Direction1", Vector) = (0.5,0,0,0)
		_Direction2("Direction2", Vector) = (-0.3,0,0.3,0)
		_Direction3("Direction3", Vector) = (0.1,0,-0.4,0)
		_Direction4("Direction4", Vector) = (0.01,0,0.01,0)
		_Amplitude1("Amplitude1", Float) = 1.5
		_Amplitude2("Amplitude2", Float) = 0.2
		_Amplitude3("Amplitude3", Float) = 0.3
		_Amplitude4("Amplitude4", Float) = 0
		_Depth("Depth", Float) = 50
		_Phase("Phase", Float) = 0
		_Gravity("Gravity", Float) = 0.2
		_NeighbourDistance("NeighbourDistance", Float) = 1
		_ColorDepth("ColorDepth", Float) = 5
		_WaveRiseThershold("WaveRiseThershold", Range( 0 , 1)) = 0.63
		_WaveRiseFallback("WaveRiseFallback", Range( 0 , 1)) = 1
		_WaterThickness("WaterThickness", Float) = 0.2
		_PanSpeed("PanSpeed", Float) = 0.5
		[HDR]_Emission("Emission", Color) = (0.06415081,0.4871341,2,0)
		[HDR]_FoamEmmision("FoamEmmision", Color) = (2,2,2,0.003921569)
		_ShallowColor("ShallowColor", Color) = (0.5415094,0.8120804,1,0)
		[Normal]_NormalTexture1("NormalTexture1", 2D) = "bump" {}
		[Normal]_NormalTexture2("NormalTexture2", 2D) = "bump" {}
		_DeepColor("DeepColor", Color) = (0,0.08763248,0.6132076,0)


		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		_TessValue( "Max Tessellation", Range( 1, 32 ) ) = 16
		_TessMin( "Tess Min Distance", Float ) = 10
		_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector][ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[HideInInspector][ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0
		[HideInInspector][ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Lit" }

		Cull Back
		ZWrite Off
		ZTest LEqual
		Offset 0 , 0
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 4.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_DISTANCE_TESSELLATION
			#define _SPECULAR_SETUP 1
			#pragma shader_feature_local_fragment _SPECULAR_SETUP
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_DEPTH_WRITE_ON
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _LIGHT_LAYERS
			#pragma multi_compile_fragment _ _LIGHT_COOKIES
			#pragma multi_compile _ _FORWARD_PLUS

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ DEBUG_DISPLAY
			#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#include "../../CustomFunctions/GerstnerWave.hlsl"
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 clipPos : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float4 lightmapUVOrVertexSH : TEXCOORD1;
				half4 fogFactorAndVertexLight : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					float4 shadowCoord : TEXCOORD6;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					float2 dynamicLightmapUV : TEXCOORD7;
				#endif
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Emission;
			float4 _NormalTexture2_ST;
			float4 _NormalTexture1_ST;
			float4 _DeepColor;
			float4 _FoamEmmision;
			float4 _ShallowColor;
			float3 _Direction4;
			float3 _Direction1;
			float3 _Direction2;
			float3 _Direction3;
			float _PanSpeed;
			float _WaveRiseFallback;
			float _WaveRiseThershold;
			float _ColorDepth;
			float _NeighbourDistance;
			float _Amplitude3;
			float _Amplitude2;
			float _Intensity;
			float _Amplitude1;
			float _Depth;
			float _Gravity;
			float _Phase;
			float _Roataion;
			float _Amplitude4;
			float _WaterThickness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _NormalTexture1;
			sampler2D _NormalTexture2;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float localgerstner4_g189 = ( 0.0 );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float temp_output_143_0_g185 = _NeighbourDistance;
				float3 appendResult69_g185 = (float3(0.0 , temp_output_143_0_g185 , 0.0));
				float3 temp_output_23_0_g189 = ( ase_worldPos + appendResult69_g185 );
				float3 position4_g189 = temp_output_23_0_g189;
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_79_0_g185 = rotatedValue387;
				float3 direction4_g189 = temp_output_79_0_g185;
				float temp_output_82_0_g185 = _Phase;
				float temp_output_24_0_g189 = temp_output_82_0_g185;
				float phase4_g189 = temp_output_24_0_g189;
				float temp_output_25_0_g189 = _TimeParameters.x;
				float time4_g189 = temp_output_25_0_g189;
				float temp_output_81_0_g185 = _Gravity;
				float temp_output_26_0_g189 = temp_output_81_0_g185;
				float gravity4_g189 = temp_output_26_0_g189;
				float temp_output_80_0_g185 = _Depth;
				float temp_output_27_0_g189 = temp_output_80_0_g185;
				float depth4_g189 = temp_output_27_0_g189;
				float temp_output_84_0_g185 = ( _Amplitude1 * _Intensity );
				float amplitude4_g189 = temp_output_84_0_g185;
				float3 result4_g189 = float3( 0,0,0 );
				gerstner_float( position4_g189 , direction4_g189 , phase4_g189 , time4_g189 , gravity4_g189 , depth4_g189 , amplitude4_g189 , result4_g189 );
				float localgerstner9_g189 = ( 0.0 );
				float3 position9_g189 = temp_output_23_0_g189;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_78_0_g185 = rotatedValue64;
				float3 direction9_g189 = temp_output_78_0_g185;
				float phase9_g189 = temp_output_24_0_g189;
				float time9_g189 = temp_output_25_0_g189;
				float gravity9_g189 = temp_output_26_0_g189;
				float depth9_g189 = temp_output_27_0_g189;
				float temp_output_73_0_g185 = ( _Intensity * _Amplitude2 );
				float amplitude9_g189 = temp_output_73_0_g185;
				float3 result9_g189 = float3( 0,0,0 );
				gerstner_float( position9_g189 , direction9_g189 , phase9_g189 , time9_g189 , gravity9_g189 , depth9_g189 , amplitude9_g189 , result9_g189 );
				float localgerstner14_g189 = ( 0.0 );
				float3 position14_g189 = temp_output_23_0_g189;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_77_0_g185 = rotatedValue65;
				float3 direction14_g189 = temp_output_77_0_g185;
				float phase14_g189 = temp_output_24_0_g189;
				float time14_g189 = temp_output_25_0_g189;
				float gravity14_g189 = temp_output_26_0_g189;
				float depth14_g189 = temp_output_27_0_g189;
				float temp_output_75_0_g185 = ( _Intensity * _Amplitude3 );
				float amplitude14_g189 = temp_output_75_0_g185;
				float3 result14_g189 = float3( 0,0,0 );
				gerstner_float( position14_g189 , direction14_g189 , phase14_g189 , time14_g189 , gravity14_g189 , depth14_g189 , amplitude14_g189 , result14_g189 );
				float localgerstner15_g189 = ( 0.0 );
				float3 position15_g189 = temp_output_23_0_g189;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_76_0_g185 = rotatedValue66;
				float3 direction15_g189 = temp_output_76_0_g185;
				float phase15_g189 = temp_output_24_0_g189;
				float time15_g189 = temp_output_25_0_g189;
				float gravity15_g189 = temp_output_26_0_g189;
				float depth15_g189 = temp_output_27_0_g189;
				float temp_output_74_0_g185 = ( _Amplitude4 * _Intensity );
				float amplitude15_g189 = temp_output_74_0_g185;
				float3 result15_g189 = float3( 0,0,0 );
				gerstner_float( position15_g189 , direction15_g189 , phase15_g189 , time15_g189 , gravity15_g189 , depth15_g189 , amplitude15_g189 , result15_g189 );
				float3 worldToObj155_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g189 + result9_g189 ) + ( result14_g189 + result15_g189 ) ) + temp_output_23_0_g189 ), 1 ) ).xyz;
				float3 GerstPos132 = worldToObj155_g185;
				
				float localgerstner4_g186 = ( 0.0 );
				float3 appendResult142_g185 = (float3(temp_output_143_0_g185 , 0.0 , 0.0));
				float3 temp_output_23_0_g186 = ( ase_worldPos + appendResult142_g185 );
				float3 position4_g186 = temp_output_23_0_g186;
				float3 direction4_g186 = temp_output_79_0_g185;
				float temp_output_24_0_g186 = temp_output_82_0_g185;
				float phase4_g186 = temp_output_24_0_g186;
				float temp_output_25_0_g186 = _TimeParameters.x;
				float time4_g186 = temp_output_25_0_g186;
				float temp_output_26_0_g186 = temp_output_81_0_g185;
				float gravity4_g186 = temp_output_26_0_g186;
				float temp_output_27_0_g186 = temp_output_80_0_g185;
				float depth4_g186 = temp_output_27_0_g186;
				float amplitude4_g186 = temp_output_84_0_g185;
				float3 result4_g186 = float3( 0,0,0 );
				gerstner_float( position4_g186 , direction4_g186 , phase4_g186 , time4_g186 , gravity4_g186 , depth4_g186 , amplitude4_g186 , result4_g186 );
				float localgerstner9_g186 = ( 0.0 );
				float3 position9_g186 = temp_output_23_0_g186;
				float3 direction9_g186 = temp_output_78_0_g185;
				float phase9_g186 = temp_output_24_0_g186;
				float time9_g186 = temp_output_25_0_g186;
				float gravity9_g186 = temp_output_26_0_g186;
				float depth9_g186 = temp_output_27_0_g186;
				float amplitude9_g186 = temp_output_73_0_g185;
				float3 result9_g186 = float3( 0,0,0 );
				gerstner_float( position9_g186 , direction9_g186 , phase9_g186 , time9_g186 , gravity9_g186 , depth9_g186 , amplitude9_g186 , result9_g186 );
				float localgerstner14_g186 = ( 0.0 );
				float3 position14_g186 = temp_output_23_0_g186;
				float3 direction14_g186 = temp_output_77_0_g185;
				float phase14_g186 = temp_output_24_0_g186;
				float time14_g186 = temp_output_25_0_g186;
				float gravity14_g186 = temp_output_26_0_g186;
				float depth14_g186 = temp_output_27_0_g186;
				float amplitude14_g186 = temp_output_75_0_g185;
				float3 result14_g186 = float3( 0,0,0 );
				gerstner_float( position14_g186 , direction14_g186 , phase14_g186 , time14_g186 , gravity14_g186 , depth14_g186 , amplitude14_g186 , result14_g186 );
				float localgerstner15_g186 = ( 0.0 );
				float3 position15_g186 = temp_output_23_0_g186;
				float3 direction15_g186 = temp_output_76_0_g185;
				float phase15_g186 = temp_output_24_0_g186;
				float time15_g186 = temp_output_25_0_g186;
				float gravity15_g186 = temp_output_26_0_g186;
				float depth15_g186 = temp_output_27_0_g186;
				float amplitude15_g186 = temp_output_74_0_g185;
				float3 result15_g186 = float3( 0,0,0 );
				gerstner_float( position15_g186 , direction15_g186 , phase15_g186 , time15_g186 , gravity15_g186 , depth15_g186 , amplitude15_g186 , result15_g186 );
				float3 worldToObj156_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g186 + result9_g186 ) + ( result14_g186 + result15_g186 ) ) + temp_output_23_0_g186 ), 1 ) ).xyz;
				float3 temp_output_3_0_g188 = worldToObj155_g185;
				float3 normalizeResult8_g188 = normalize( ( worldToObj156_g185 - temp_output_3_0_g188 ) );
				float localgerstner4_g187 = ( 0.0 );
				float3 appendResult136_g185 = (float3(0.0 , 0.0 , temp_output_143_0_g185));
				float3 temp_output_23_0_g187 = ( ase_worldPos + appendResult136_g185 );
				float3 position4_g187 = temp_output_23_0_g187;
				float3 direction4_g187 = temp_output_79_0_g185;
				float temp_output_24_0_g187 = temp_output_82_0_g185;
				float phase4_g187 = temp_output_24_0_g187;
				float temp_output_25_0_g187 = _TimeParameters.x;
				float time4_g187 = temp_output_25_0_g187;
				float temp_output_26_0_g187 = temp_output_81_0_g185;
				float gravity4_g187 = temp_output_26_0_g187;
				float temp_output_27_0_g187 = temp_output_80_0_g185;
				float depth4_g187 = temp_output_27_0_g187;
				float amplitude4_g187 = temp_output_84_0_g185;
				float3 result4_g187 = float3( 0,0,0 );
				gerstner_float( position4_g187 , direction4_g187 , phase4_g187 , time4_g187 , gravity4_g187 , depth4_g187 , amplitude4_g187 , result4_g187 );
				float localgerstner9_g187 = ( 0.0 );
				float3 position9_g187 = temp_output_23_0_g187;
				float3 direction9_g187 = temp_output_78_0_g185;
				float phase9_g187 = temp_output_24_0_g187;
				float time9_g187 = temp_output_25_0_g187;
				float gravity9_g187 = temp_output_26_0_g187;
				float depth9_g187 = temp_output_27_0_g187;
				float amplitude9_g187 = temp_output_73_0_g185;
				float3 result9_g187 = float3( 0,0,0 );
				gerstner_float( position9_g187 , direction9_g187 , phase9_g187 , time9_g187 , gravity9_g187 , depth9_g187 , amplitude9_g187 , result9_g187 );
				float localgerstner14_g187 = ( 0.0 );
				float3 position14_g187 = temp_output_23_0_g187;
				float3 direction14_g187 = temp_output_77_0_g185;
				float phase14_g187 = temp_output_24_0_g187;
				float time14_g187 = temp_output_25_0_g187;
				float gravity14_g187 = temp_output_26_0_g187;
				float depth14_g187 = temp_output_27_0_g187;
				float amplitude14_g187 = temp_output_75_0_g185;
				float3 result14_g187 = float3( 0,0,0 );
				gerstner_float( position14_g187 , direction14_g187 , phase14_g187 , time14_g187 , gravity14_g187 , depth14_g187 , amplitude14_g187 , result14_g187 );
				float localgerstner15_g187 = ( 0.0 );
				float3 position15_g187 = temp_output_23_0_g187;
				float3 direction15_g187 = temp_output_76_0_g185;
				float phase15_g187 = temp_output_24_0_g187;
				float time15_g187 = temp_output_25_0_g187;
				float gravity15_g187 = temp_output_26_0_g187;
				float depth15_g187 = temp_output_27_0_g187;
				float amplitude15_g187 = temp_output_74_0_g185;
				float3 result15_g187 = float3( 0,0,0 );
				gerstner_float( position15_g187 , direction15_g187 , phase15_g187 , time15_g187 , gravity15_g187 , depth15_g187 , amplitude15_g187 , result15_g187 );
				float3 worldToObj164_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g187 + result9_g187 ) + ( result14_g187 + result15_g187 ) ) + temp_output_23_0_g187 ), 1 ) ).xyz;
				float3 normalizeResult9_g188 = normalize( ( temp_output_3_0_g188 - worldToObj164_g185 ) );
				float3 normalizeResult11_g188 = normalize( cross( normalizeResult8_g188 , normalizeResult9_g188 ) );
				float3 GerstNorm134 = normalizeResult11_g188;
				
				o.ase_texcoord8.xy = v.texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord8.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = GerstPos132;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = GerstNorm134;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				#endif

				#if !defined(LIGHTMAP_ON)
					OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					o.dynamicLightmapUV.xy = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord.xy;
					o.lightmapUVOrVertexSH.xy = v.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );

				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif

				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				o.clipPosV = positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						, out float4 outRenderingLayers : SV_Target1
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif

				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				float2 NormalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth11_g132 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth11_g132 = saturate( abs( ( screenDepth11_g132 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _ColorDepth ) ) );
				float temp_output_298_0 = ( 1.0 - distanceDepth11_g132 );
				float smoothstepResult91 = smoothstep( 0.0 , 0.2 , (1.0 + (temp_output_298_0 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
				float2 temp_cast_0 = (_TimeParameters.x).xx;
				float2 texCoord117 = IN.ase_texcoord8.xy * float2( 1,1 ) + temp_cast_0;
				float simplePerlin2D287 = snoise( texCoord117*0.2 );
				simplePerlin2D287 = simplePerlin2D287*0.5 + 0.5;
				float clampResult107 = clamp( ( ( ( 1.0 - pow( ( 1.0 / 1000.0 ) , temp_output_298_0 ) ) * sin( ( ( temp_output_298_0 * 100.0 ) + ( 4.0 * _TimeParameters.x ) ) ) ) * ( simplePerlin2D287 + 0.7 ) ) , 0.0 , 0.9 );
				float lerpResult143 = lerp( _WaveRiseThershold , 1.0 , _WaveRiseFallback);
				float2 texCoord118 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float cos121 = cos( radians( _Roataion ) );
				float sin121 = sin( radians( _Roataion ) );
				float2 rotator121 = mul( texCoord118 - float2( 0.5,0.5 ) , float2x2( cos121 , -sin121 , sin121 , cos121 )) + float2( 0.5,0.5 );
				float simplePerlin2D126 = snoise( rotator121*0.5 );
				simplePerlin2D126 = simplePerlin2D126*0.5 + 0.5;
				float localgerstner4_g186 = ( 0.0 );
				float temp_output_143_0_g185 = _NeighbourDistance;
				float3 appendResult142_g185 = (float3(temp_output_143_0_g185 , 0.0 , 0.0));
				float3 temp_output_23_0_g186 = ( WorldPosition + appendResult142_g185 );
				float3 position4_g186 = temp_output_23_0_g186;
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_79_0_g185 = rotatedValue387;
				float3 direction4_g186 = temp_output_79_0_g185;
				float temp_output_82_0_g185 = _Phase;
				float temp_output_24_0_g186 = temp_output_82_0_g185;
				float phase4_g186 = temp_output_24_0_g186;
				float temp_output_25_0_g186 = _TimeParameters.x;
				float time4_g186 = temp_output_25_0_g186;
				float temp_output_81_0_g185 = _Gravity;
				float temp_output_26_0_g186 = temp_output_81_0_g185;
				float gravity4_g186 = temp_output_26_0_g186;
				float temp_output_80_0_g185 = _Depth;
				float temp_output_27_0_g186 = temp_output_80_0_g185;
				float depth4_g186 = temp_output_27_0_g186;
				float temp_output_84_0_g185 = ( _Amplitude1 * _Intensity );
				float amplitude4_g186 = temp_output_84_0_g185;
				float3 result4_g186 = float3( 0,0,0 );
				gerstner_float( position4_g186 , direction4_g186 , phase4_g186 , time4_g186 , gravity4_g186 , depth4_g186 , amplitude4_g186 , result4_g186 );
				float localgerstner9_g186 = ( 0.0 );
				float3 position9_g186 = temp_output_23_0_g186;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_78_0_g185 = rotatedValue64;
				float3 direction9_g186 = temp_output_78_0_g185;
				float phase9_g186 = temp_output_24_0_g186;
				float time9_g186 = temp_output_25_0_g186;
				float gravity9_g186 = temp_output_26_0_g186;
				float depth9_g186 = temp_output_27_0_g186;
				float temp_output_73_0_g185 = ( _Intensity * _Amplitude2 );
				float amplitude9_g186 = temp_output_73_0_g185;
				float3 result9_g186 = float3( 0,0,0 );
				gerstner_float( position9_g186 , direction9_g186 , phase9_g186 , time9_g186 , gravity9_g186 , depth9_g186 , amplitude9_g186 , result9_g186 );
				float localgerstner14_g186 = ( 0.0 );
				float3 position14_g186 = temp_output_23_0_g186;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_77_0_g185 = rotatedValue65;
				float3 direction14_g186 = temp_output_77_0_g185;
				float phase14_g186 = temp_output_24_0_g186;
				float time14_g186 = temp_output_25_0_g186;
				float gravity14_g186 = temp_output_26_0_g186;
				float depth14_g186 = temp_output_27_0_g186;
				float temp_output_75_0_g185 = ( _Intensity * _Amplitude3 );
				float amplitude14_g186 = temp_output_75_0_g185;
				float3 result14_g186 = float3( 0,0,0 );
				gerstner_float( position14_g186 , direction14_g186 , phase14_g186 , time14_g186 , gravity14_g186 , depth14_g186 , amplitude14_g186 , result14_g186 );
				float localgerstner15_g186 = ( 0.0 );
				float3 position15_g186 = temp_output_23_0_g186;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_76_0_g185 = rotatedValue66;
				float3 direction15_g186 = temp_output_76_0_g185;
				float phase15_g186 = temp_output_24_0_g186;
				float time15_g186 = temp_output_25_0_g186;
				float gravity15_g186 = temp_output_26_0_g186;
				float depth15_g186 = temp_output_27_0_g186;
				float temp_output_74_0_g185 = ( _Amplitude4 * _Intensity );
				float amplitude15_g186 = temp_output_74_0_g185;
				float3 result15_g186 = float3( 0,0,0 );
				gerstner_float( position15_g186 , direction15_g186 , phase15_g186 , time15_g186 , gravity15_g186 , depth15_g186 , amplitude15_g186 , result15_g186 );
				float3 worldToObj156_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g186 + result9_g186 ) + ( result14_g186 + result15_g186 ) ) + temp_output_23_0_g186 ), 1 ) ).xyz;
				float localgerstner4_g189 = ( 0.0 );
				float3 appendResult69_g185 = (float3(0.0 , temp_output_143_0_g185 , 0.0));
				float3 temp_output_23_0_g189 = ( WorldPosition + appendResult69_g185 );
				float3 position4_g189 = temp_output_23_0_g189;
				float3 direction4_g189 = temp_output_79_0_g185;
				float temp_output_24_0_g189 = temp_output_82_0_g185;
				float phase4_g189 = temp_output_24_0_g189;
				float temp_output_25_0_g189 = _TimeParameters.x;
				float time4_g189 = temp_output_25_0_g189;
				float temp_output_26_0_g189 = temp_output_81_0_g185;
				float gravity4_g189 = temp_output_26_0_g189;
				float temp_output_27_0_g189 = temp_output_80_0_g185;
				float depth4_g189 = temp_output_27_0_g189;
				float amplitude4_g189 = temp_output_84_0_g185;
				float3 result4_g189 = float3( 0,0,0 );
				gerstner_float( position4_g189 , direction4_g189 , phase4_g189 , time4_g189 , gravity4_g189 , depth4_g189 , amplitude4_g189 , result4_g189 );
				float localgerstner9_g189 = ( 0.0 );
				float3 position9_g189 = temp_output_23_0_g189;
				float3 direction9_g189 = temp_output_78_0_g185;
				float phase9_g189 = temp_output_24_0_g189;
				float time9_g189 = temp_output_25_0_g189;
				float gravity9_g189 = temp_output_26_0_g189;
				float depth9_g189 = temp_output_27_0_g189;
				float amplitude9_g189 = temp_output_73_0_g185;
				float3 result9_g189 = float3( 0,0,0 );
				gerstner_float( position9_g189 , direction9_g189 , phase9_g189 , time9_g189 , gravity9_g189 , depth9_g189 , amplitude9_g189 , result9_g189 );
				float localgerstner14_g189 = ( 0.0 );
				float3 position14_g189 = temp_output_23_0_g189;
				float3 direction14_g189 = temp_output_77_0_g185;
				float phase14_g189 = temp_output_24_0_g189;
				float time14_g189 = temp_output_25_0_g189;
				float gravity14_g189 = temp_output_26_0_g189;
				float depth14_g189 = temp_output_27_0_g189;
				float amplitude14_g189 = temp_output_75_0_g185;
				float3 result14_g189 = float3( 0,0,0 );
				gerstner_float( position14_g189 , direction14_g189 , phase14_g189 , time14_g189 , gravity14_g189 , depth14_g189 , amplitude14_g189 , result14_g189 );
				float localgerstner15_g189 = ( 0.0 );
				float3 position15_g189 = temp_output_23_0_g189;
				float3 direction15_g189 = temp_output_76_0_g185;
				float phase15_g189 = temp_output_24_0_g189;
				float time15_g189 = temp_output_25_0_g189;
				float gravity15_g189 = temp_output_26_0_g189;
				float depth15_g189 = temp_output_27_0_g189;
				float amplitude15_g189 = temp_output_74_0_g185;
				float3 result15_g189 = float3( 0,0,0 );
				gerstner_float( position15_g189 , direction15_g189 , phase15_g189 , time15_g189 , gravity15_g189 , depth15_g189 , amplitude15_g189 , result15_g189 );
				float3 worldToObj155_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g189 + result9_g189 ) + ( result14_g189 + result15_g189 ) ) + temp_output_23_0_g189 ), 1 ) ).xyz;
				float3 temp_output_3_0_g188 = worldToObj155_g185;
				float3 normalizeResult8_g188 = normalize( ( worldToObj156_g185 - temp_output_3_0_g188 ) );
				float localgerstner4_g187 = ( 0.0 );
				float3 appendResult136_g185 = (float3(0.0 , 0.0 , temp_output_143_0_g185));
				float3 temp_output_23_0_g187 = ( WorldPosition + appendResult136_g185 );
				float3 position4_g187 = temp_output_23_0_g187;
				float3 direction4_g187 = temp_output_79_0_g185;
				float temp_output_24_0_g187 = temp_output_82_0_g185;
				float phase4_g187 = temp_output_24_0_g187;
				float temp_output_25_0_g187 = _TimeParameters.x;
				float time4_g187 = temp_output_25_0_g187;
				float temp_output_26_0_g187 = temp_output_81_0_g185;
				float gravity4_g187 = temp_output_26_0_g187;
				float temp_output_27_0_g187 = temp_output_80_0_g185;
				float depth4_g187 = temp_output_27_0_g187;
				float amplitude4_g187 = temp_output_84_0_g185;
				float3 result4_g187 = float3( 0,0,0 );
				gerstner_float( position4_g187 , direction4_g187 , phase4_g187 , time4_g187 , gravity4_g187 , depth4_g187 , amplitude4_g187 , result4_g187 );
				float localgerstner9_g187 = ( 0.0 );
				float3 position9_g187 = temp_output_23_0_g187;
				float3 direction9_g187 = temp_output_78_0_g185;
				float phase9_g187 = temp_output_24_0_g187;
				float time9_g187 = temp_output_25_0_g187;
				float gravity9_g187 = temp_output_26_0_g187;
				float depth9_g187 = temp_output_27_0_g187;
				float amplitude9_g187 = temp_output_73_0_g185;
				float3 result9_g187 = float3( 0,0,0 );
				gerstner_float( position9_g187 , direction9_g187 , phase9_g187 , time9_g187 , gravity9_g187 , depth9_g187 , amplitude9_g187 , result9_g187 );
				float localgerstner14_g187 = ( 0.0 );
				float3 position14_g187 = temp_output_23_0_g187;
				float3 direction14_g187 = temp_output_77_0_g185;
				float phase14_g187 = temp_output_24_0_g187;
				float time14_g187 = temp_output_25_0_g187;
				float gravity14_g187 = temp_output_26_0_g187;
				float depth14_g187 = temp_output_27_0_g187;
				float amplitude14_g187 = temp_output_75_0_g185;
				float3 result14_g187 = float3( 0,0,0 );
				gerstner_float( position14_g187 , direction14_g187 , phase14_g187 , time14_g187 , gravity14_g187 , depth14_g187 , amplitude14_g187 , result14_g187 );
				float localgerstner15_g187 = ( 0.0 );
				float3 position15_g187 = temp_output_23_0_g187;
				float3 direction15_g187 = temp_output_76_0_g185;
				float phase15_g187 = temp_output_24_0_g187;
				float time15_g187 = temp_output_25_0_g187;
				float gravity15_g187 = temp_output_26_0_g187;
				float depth15_g187 = temp_output_27_0_g187;
				float amplitude15_g187 = temp_output_74_0_g185;
				float3 result15_g187 = float3( 0,0,0 );
				gerstner_float( position15_g187 , direction15_g187 , phase15_g187 , time15_g187 , gravity15_g187 , depth15_g187 , amplitude15_g187 , result15_g187 );
				float3 worldToObj164_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g187 + result9_g187 ) + ( result14_g187 + result15_g187 ) ) + temp_output_23_0_g187 ), 1 ) ).xyz;
				float3 normalizeResult9_g188 = normalize( ( temp_output_3_0_g188 - worldToObj164_g185 ) );
				float3 normalizeResult11_g188 = normalize( cross( normalizeResult8_g188 , normalizeResult9_g188 ) );
				float3 GerstNorm134 = normalizeResult11_g188;
				float dotResult130 = dot( GerstNorm134 , float3( 0,0,1 ) );
				float2 temp_cast_1 = (_TimeParameters.x).xx;
				float2 texCoord140 = IN.ase_texcoord8.xy * float2( 1,1 ) + temp_cast_1;
				float simplePerlin2D138 = snoise( texCoord140*0.02 );
				simplePerlin2D138 = simplePerlin2D138*0.5 + 0.5;
				float smoothstepResult147 = smoothstep( _WaveRiseThershold , lerpResult143 , ( ( (-0.1 + (simplePerlin2D126 - 0.0) * (0.1 - -0.1) / (1.0 - 0.0)) + (1.0 + (dotResult130 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) + (-0.2 + (simplePerlin2D138 - 0.0) * (0.2 - -0.2) / (1.0 - 0.0)) ));
				float waterRise149 = smoothstepResult147;
				float foam153 = step( 0.4 , ( ( ( 1.0 - smoothstepResult91 ) * clampResult107 ) + waterRise149 ) );
				float4 lerpResult284 = lerp( _ShallowColor , _DeepColor , foam153);
				
				float2 appendResult415 = (float2(WorldPosition.x , WorldPosition.y));
				float2 texCoord394 = IN.ase_texcoord8.xy * _NormalTexture1_ST.xy + ( ( ( float2( 0.4,1.17 ) * _PanSpeed ) * _TimeParameters.x ) + appendResult415 );
				float2 texCoord390 = IN.ase_texcoord8.xy * _NormalTexture2_ST.xy + ( appendResult415 + ( _TimeParameters.x * ( _PanSpeed * float2( -0.5,0.2 ) ) ) );
				float3 lerpResult181 = lerp( BlendNormal( UnpackNormalScale( tex2D( _NormalTexture1, texCoord394 ), 1.0f ) , UnpackNormalScale( tex2D( _NormalTexture2, texCoord390 ), 1.0f ) ) , float3( 0,1,0 ) , foam153);
				
				float4 lerpResult304 = lerp( _Emission , _FoamEmmision , foam153);
				
				float WaterDepth187 = temp_output_298_0;
				

				float3 BaseColor = lerpResult284.rgb;
				float3 Normal = lerpResult181;
				float3 Emission = lerpResult304.rgb;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = 1.0;
				float Occlusion = 0.0;
				float Alpha = ( ( ( 1.0 - WaterDepth187 ) * _WaterThickness ) + foam153 );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.clipPos.z;
				#endif

				#ifdef _CLEARCOAT
					float CoatMask = 0;
					float CoatSmoothness = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;

				#ifdef _NORMALMAP
						#if _NORMAL_DROPOFF_TS
							inputData.normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
						#elif _NORMAL_DROPOFF_OS
							inputData.normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							inputData.normalWS = Normal;
						#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					inputData.shadowCoord = ShadowCoords;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
				#else
					inputData.shadowCoord = float4(0, 0, 0, 0);
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif
					inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, IN.dynamicLightmapUV.xy, SH, inputData.normalWS);
				#else
					inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS);
				#endif

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				inputData.normalizedScreenSpaceUV = NormalizedScreenSpaceUV;
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

				#if defined(DEBUG_DISPLAY)
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = IN.dynamicLightmapUV.xy;
					#endif
					#if defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = IN.lightmapUVOrVertexSH.xy;
					#else
						inputData.vertexSH = SH;
					#endif
				#endif

				SurfaceData surfaceData;
				surfaceData.albedo              = BaseColor;
				surfaceData.metallic            = saturate(Metallic);
				surfaceData.specular            = Specular;
				surfaceData.smoothness          = saturate(Smoothness),
				surfaceData.occlusion           = Occlusion,
				surfaceData.emission            = Emission,
				surfaceData.alpha               = saturate(Alpha);
				surfaceData.normalTS            = Normal;
				surfaceData.clearCoatMask       = 0;
				surfaceData.clearCoatSmoothness = 1;

				#ifdef _CLEARCOAT
					surfaceData.clearCoatMask       = saturate(CoatMask);
					surfaceData.clearCoatSmoothness = saturate(CoatSmoothness);
				#endif

				#ifdef _DBUFFER
					ApplyDecalToSurfaceData(IN.clipPos, surfaceData, inputData);
				#endif

				half4 color = UniversalFragmentPBR( inputData, surfaceData);

				#ifdef ASE_TRANSMISSION
				{
					float shadow = _TransmissionShadow;

					#define SUM_LIGHT_TRANSMISSION(Light)\
						float3 atten = Light.color * Light.distanceAttenuation;\
						atten = lerp( atten, atten * Light.shadowAttenuation, shadow );\
						half3 transmission = max( 0, -dot( inputData.normalWS, Light.direction ) ) * atten * Transmission;\
						color.rgb += BaseColor * transmission;

					SUM_LIGHT_TRANSMISSION( GetMainLight( inputData.shadowCoord ) );

					#if defined(_ADDITIONAL_LIGHTS)
						uint meshRenderingLayers = GetMeshRenderingLayer();
						uint pixelLightCount = GetAdditionalLightsCount();
						#if USE_FORWARD_PLUS
							for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
							{
								FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

								Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
								#ifdef _LIGHT_LAYERS
								if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
								#endif
								{
									SUM_LIGHT_TRANSMISSION( light );
								}
							}
						#endif
						LIGHT_LOOP_BEGIN( pixelLightCount )
							Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
							#ifdef _LIGHT_LAYERS
							if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
							#endif
							{
								SUM_LIGHT_TRANSMISSION( light );
							}
						LIGHT_LOOP_END
					#endif
				}
				#endif

				#ifdef ASE_TRANSLUCENCY
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					#define SUM_LIGHT_TRANSLUCENCY(Light)\
						float3 atten = Light.color * Light.distanceAttenuation;\
						atten = lerp( atten, atten * Light.shadowAttenuation, shadow );\
						half3 lightDir = Light.direction + inputData.normalWS * normal;\
						half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );\
						half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;\
						color.rgb += BaseColor * translucency * strength;

					SUM_LIGHT_TRANSLUCENCY( GetMainLight( inputData.shadowCoord ) );

					#if defined(_ADDITIONAL_LIGHTS)
						uint meshRenderingLayers = GetMeshRenderingLayer();
						uint pixelLightCount = GetAdditionalLightsCount();
						#if USE_FORWARD_PLUS
							for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
							{
								FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

								Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
								#ifdef _LIGHT_LAYERS
								if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
								#endif
								{
									SUM_LIGHT_TRANSLUCENCY( light );
								}
							}
						#endif
						LIGHT_LOOP_BEGIN( pixelLightCount )
							Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
							#ifdef _LIGHT_LAYERS
							if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
							#endif
							{
								SUM_LIGHT_TRANSLUCENCY( light );
							}
						LIGHT_LOOP_END
					#endif
				}
				#endif

				#ifdef ASE_REFRACTION
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, float4( WorldNormal,0 ) ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif

				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask R
			AlphaToMask Off

			HLSLPROGRAM

			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_DISTANCE_TESSELLATION
			#define _SPECULAR_SETUP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_DEPTH_WRITE_ON
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			
			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#include "../../CustomFunctions/GerstnerWave.hlsl"
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 clipPos : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD1;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Emission;
			float4 _NormalTexture2_ST;
			float4 _NormalTexture1_ST;
			float4 _DeepColor;
			float4 _FoamEmmision;
			float4 _ShallowColor;
			float3 _Direction4;
			float3 _Direction1;
			float3 _Direction2;
			float3 _Direction3;
			float _PanSpeed;
			float _WaveRiseFallback;
			float _WaveRiseThershold;
			float _ColorDepth;
			float _NeighbourDistance;
			float _Amplitude3;
			float _Amplitude2;
			float _Intensity;
			float _Amplitude1;
			float _Depth;
			float _Gravity;
			float _Phase;
			float _Roataion;
			float _Amplitude4;
			float _WaterThickness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			uniform float4 _CameraDepthTexture_TexelSize;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float localgerstner4_g189 = ( 0.0 );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float temp_output_143_0_g185 = _NeighbourDistance;
				float3 appendResult69_g185 = (float3(0.0 , temp_output_143_0_g185 , 0.0));
				float3 temp_output_23_0_g189 = ( ase_worldPos + appendResult69_g185 );
				float3 position4_g189 = temp_output_23_0_g189;
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_79_0_g185 = rotatedValue387;
				float3 direction4_g189 = temp_output_79_0_g185;
				float temp_output_82_0_g185 = _Phase;
				float temp_output_24_0_g189 = temp_output_82_0_g185;
				float phase4_g189 = temp_output_24_0_g189;
				float temp_output_25_0_g189 = _TimeParameters.x;
				float time4_g189 = temp_output_25_0_g189;
				float temp_output_81_0_g185 = _Gravity;
				float temp_output_26_0_g189 = temp_output_81_0_g185;
				float gravity4_g189 = temp_output_26_0_g189;
				float temp_output_80_0_g185 = _Depth;
				float temp_output_27_0_g189 = temp_output_80_0_g185;
				float depth4_g189 = temp_output_27_0_g189;
				float temp_output_84_0_g185 = ( _Amplitude1 * _Intensity );
				float amplitude4_g189 = temp_output_84_0_g185;
				float3 result4_g189 = float3( 0,0,0 );
				gerstner_float( position4_g189 , direction4_g189 , phase4_g189 , time4_g189 , gravity4_g189 , depth4_g189 , amplitude4_g189 , result4_g189 );
				float localgerstner9_g189 = ( 0.0 );
				float3 position9_g189 = temp_output_23_0_g189;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_78_0_g185 = rotatedValue64;
				float3 direction9_g189 = temp_output_78_0_g185;
				float phase9_g189 = temp_output_24_0_g189;
				float time9_g189 = temp_output_25_0_g189;
				float gravity9_g189 = temp_output_26_0_g189;
				float depth9_g189 = temp_output_27_0_g189;
				float temp_output_73_0_g185 = ( _Intensity * _Amplitude2 );
				float amplitude9_g189 = temp_output_73_0_g185;
				float3 result9_g189 = float3( 0,0,0 );
				gerstner_float( position9_g189 , direction9_g189 , phase9_g189 , time9_g189 , gravity9_g189 , depth9_g189 , amplitude9_g189 , result9_g189 );
				float localgerstner14_g189 = ( 0.0 );
				float3 position14_g189 = temp_output_23_0_g189;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_77_0_g185 = rotatedValue65;
				float3 direction14_g189 = temp_output_77_0_g185;
				float phase14_g189 = temp_output_24_0_g189;
				float time14_g189 = temp_output_25_0_g189;
				float gravity14_g189 = temp_output_26_0_g189;
				float depth14_g189 = temp_output_27_0_g189;
				float temp_output_75_0_g185 = ( _Intensity * _Amplitude3 );
				float amplitude14_g189 = temp_output_75_0_g185;
				float3 result14_g189 = float3( 0,0,0 );
				gerstner_float( position14_g189 , direction14_g189 , phase14_g189 , time14_g189 , gravity14_g189 , depth14_g189 , amplitude14_g189 , result14_g189 );
				float localgerstner15_g189 = ( 0.0 );
				float3 position15_g189 = temp_output_23_0_g189;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_76_0_g185 = rotatedValue66;
				float3 direction15_g189 = temp_output_76_0_g185;
				float phase15_g189 = temp_output_24_0_g189;
				float time15_g189 = temp_output_25_0_g189;
				float gravity15_g189 = temp_output_26_0_g189;
				float depth15_g189 = temp_output_27_0_g189;
				float temp_output_74_0_g185 = ( _Amplitude4 * _Intensity );
				float amplitude15_g189 = temp_output_74_0_g185;
				float3 result15_g189 = float3( 0,0,0 );
				gerstner_float( position15_g189 , direction15_g189 , phase15_g189 , time15_g189 , gravity15_g189 , depth15_g189 , amplitude15_g189 , result15_g189 );
				float3 worldToObj155_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g189 + result9_g189 ) + ( result14_g189 + result15_g189 ) ) + temp_output_23_0_g189 ), 1 ) ).xyz;
				float3 GerstPos132 = worldToObj155_g185;
				
				float localgerstner4_g186 = ( 0.0 );
				float3 appendResult142_g185 = (float3(temp_output_143_0_g185 , 0.0 , 0.0));
				float3 temp_output_23_0_g186 = ( ase_worldPos + appendResult142_g185 );
				float3 position4_g186 = temp_output_23_0_g186;
				float3 direction4_g186 = temp_output_79_0_g185;
				float temp_output_24_0_g186 = temp_output_82_0_g185;
				float phase4_g186 = temp_output_24_0_g186;
				float temp_output_25_0_g186 = _TimeParameters.x;
				float time4_g186 = temp_output_25_0_g186;
				float temp_output_26_0_g186 = temp_output_81_0_g185;
				float gravity4_g186 = temp_output_26_0_g186;
				float temp_output_27_0_g186 = temp_output_80_0_g185;
				float depth4_g186 = temp_output_27_0_g186;
				float amplitude4_g186 = temp_output_84_0_g185;
				float3 result4_g186 = float3( 0,0,0 );
				gerstner_float( position4_g186 , direction4_g186 , phase4_g186 , time4_g186 , gravity4_g186 , depth4_g186 , amplitude4_g186 , result4_g186 );
				float localgerstner9_g186 = ( 0.0 );
				float3 position9_g186 = temp_output_23_0_g186;
				float3 direction9_g186 = temp_output_78_0_g185;
				float phase9_g186 = temp_output_24_0_g186;
				float time9_g186 = temp_output_25_0_g186;
				float gravity9_g186 = temp_output_26_0_g186;
				float depth9_g186 = temp_output_27_0_g186;
				float amplitude9_g186 = temp_output_73_0_g185;
				float3 result9_g186 = float3( 0,0,0 );
				gerstner_float( position9_g186 , direction9_g186 , phase9_g186 , time9_g186 , gravity9_g186 , depth9_g186 , amplitude9_g186 , result9_g186 );
				float localgerstner14_g186 = ( 0.0 );
				float3 position14_g186 = temp_output_23_0_g186;
				float3 direction14_g186 = temp_output_77_0_g185;
				float phase14_g186 = temp_output_24_0_g186;
				float time14_g186 = temp_output_25_0_g186;
				float gravity14_g186 = temp_output_26_0_g186;
				float depth14_g186 = temp_output_27_0_g186;
				float amplitude14_g186 = temp_output_75_0_g185;
				float3 result14_g186 = float3( 0,0,0 );
				gerstner_float( position14_g186 , direction14_g186 , phase14_g186 , time14_g186 , gravity14_g186 , depth14_g186 , amplitude14_g186 , result14_g186 );
				float localgerstner15_g186 = ( 0.0 );
				float3 position15_g186 = temp_output_23_0_g186;
				float3 direction15_g186 = temp_output_76_0_g185;
				float phase15_g186 = temp_output_24_0_g186;
				float time15_g186 = temp_output_25_0_g186;
				float gravity15_g186 = temp_output_26_0_g186;
				float depth15_g186 = temp_output_27_0_g186;
				float amplitude15_g186 = temp_output_74_0_g185;
				float3 result15_g186 = float3( 0,0,0 );
				gerstner_float( position15_g186 , direction15_g186 , phase15_g186 , time15_g186 , gravity15_g186 , depth15_g186 , amplitude15_g186 , result15_g186 );
				float3 worldToObj156_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g186 + result9_g186 ) + ( result14_g186 + result15_g186 ) ) + temp_output_23_0_g186 ), 1 ) ).xyz;
				float3 temp_output_3_0_g188 = worldToObj155_g185;
				float3 normalizeResult8_g188 = normalize( ( worldToObj156_g185 - temp_output_3_0_g188 ) );
				float localgerstner4_g187 = ( 0.0 );
				float3 appendResult136_g185 = (float3(0.0 , 0.0 , temp_output_143_0_g185));
				float3 temp_output_23_0_g187 = ( ase_worldPos + appendResult136_g185 );
				float3 position4_g187 = temp_output_23_0_g187;
				float3 direction4_g187 = temp_output_79_0_g185;
				float temp_output_24_0_g187 = temp_output_82_0_g185;
				float phase4_g187 = temp_output_24_0_g187;
				float temp_output_25_0_g187 = _TimeParameters.x;
				float time4_g187 = temp_output_25_0_g187;
				float temp_output_26_0_g187 = temp_output_81_0_g185;
				float gravity4_g187 = temp_output_26_0_g187;
				float temp_output_27_0_g187 = temp_output_80_0_g185;
				float depth4_g187 = temp_output_27_0_g187;
				float amplitude4_g187 = temp_output_84_0_g185;
				float3 result4_g187 = float3( 0,0,0 );
				gerstner_float( position4_g187 , direction4_g187 , phase4_g187 , time4_g187 , gravity4_g187 , depth4_g187 , amplitude4_g187 , result4_g187 );
				float localgerstner9_g187 = ( 0.0 );
				float3 position9_g187 = temp_output_23_0_g187;
				float3 direction9_g187 = temp_output_78_0_g185;
				float phase9_g187 = temp_output_24_0_g187;
				float time9_g187 = temp_output_25_0_g187;
				float gravity9_g187 = temp_output_26_0_g187;
				float depth9_g187 = temp_output_27_0_g187;
				float amplitude9_g187 = temp_output_73_0_g185;
				float3 result9_g187 = float3( 0,0,0 );
				gerstner_float( position9_g187 , direction9_g187 , phase9_g187 , time9_g187 , gravity9_g187 , depth9_g187 , amplitude9_g187 , result9_g187 );
				float localgerstner14_g187 = ( 0.0 );
				float3 position14_g187 = temp_output_23_0_g187;
				float3 direction14_g187 = temp_output_77_0_g185;
				float phase14_g187 = temp_output_24_0_g187;
				float time14_g187 = temp_output_25_0_g187;
				float gravity14_g187 = temp_output_26_0_g187;
				float depth14_g187 = temp_output_27_0_g187;
				float amplitude14_g187 = temp_output_75_0_g185;
				float3 result14_g187 = float3( 0,0,0 );
				gerstner_float( position14_g187 , direction14_g187 , phase14_g187 , time14_g187 , gravity14_g187 , depth14_g187 , amplitude14_g187 , result14_g187 );
				float localgerstner15_g187 = ( 0.0 );
				float3 position15_g187 = temp_output_23_0_g187;
				float3 direction15_g187 = temp_output_76_0_g185;
				float phase15_g187 = temp_output_24_0_g187;
				float time15_g187 = temp_output_25_0_g187;
				float gravity15_g187 = temp_output_26_0_g187;
				float depth15_g187 = temp_output_27_0_g187;
				float amplitude15_g187 = temp_output_74_0_g185;
				float3 result15_g187 = float3( 0,0,0 );
				gerstner_float( position15_g187 , direction15_g187 , phase15_g187 , time15_g187 , gravity15_g187 , depth15_g187 , amplitude15_g187 , result15_g187 );
				float3 worldToObj164_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g187 + result9_g187 ) + ( result14_g187 + result15_g187 ) ) + temp_output_23_0_g187 ), 1 ) ).xyz;
				float3 normalizeResult9_g188 = normalize( ( temp_output_3_0_g188 - worldToObj164_g185 ) );
				float3 normalizeResult11_g188 = normalize( cross( normalizeResult8_g188 , normalizeResult9_g188 ) );
				float3 GerstNorm134 = normalizeResult11_g188;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = GerstPos132;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = GerstNorm134;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				o.clipPosV = positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth11_g132 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth11_g132 = saturate( abs( ( screenDepth11_g132 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _ColorDepth ) ) );
				float temp_output_298_0 = ( 1.0 - distanceDepth11_g132 );
				float WaterDepth187 = temp_output_298_0;
				float smoothstepResult91 = smoothstep( 0.0 , 0.2 , (1.0 + (temp_output_298_0 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
				float2 temp_cast_0 = (_TimeParameters.x).xx;
				float2 texCoord117 = IN.ase_texcoord3.xy * float2( 1,1 ) + temp_cast_0;
				float simplePerlin2D287 = snoise( texCoord117*0.2 );
				simplePerlin2D287 = simplePerlin2D287*0.5 + 0.5;
				float clampResult107 = clamp( ( ( ( 1.0 - pow( ( 1.0 / 1000.0 ) , temp_output_298_0 ) ) * sin( ( ( temp_output_298_0 * 100.0 ) + ( 4.0 * _TimeParameters.x ) ) ) ) * ( simplePerlin2D287 + 0.7 ) ) , 0.0 , 0.9 );
				float lerpResult143 = lerp( _WaveRiseThershold , 1.0 , _WaveRiseFallback);
				float2 texCoord118 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float cos121 = cos( radians( _Roataion ) );
				float sin121 = sin( radians( _Roataion ) );
				float2 rotator121 = mul( texCoord118 - float2( 0.5,0.5 ) , float2x2( cos121 , -sin121 , sin121 , cos121 )) + float2( 0.5,0.5 );
				float simplePerlin2D126 = snoise( rotator121*0.5 );
				simplePerlin2D126 = simplePerlin2D126*0.5 + 0.5;
				float localgerstner4_g186 = ( 0.0 );
				float temp_output_143_0_g185 = _NeighbourDistance;
				float3 appendResult142_g185 = (float3(temp_output_143_0_g185 , 0.0 , 0.0));
				float3 temp_output_23_0_g186 = ( WorldPosition + appendResult142_g185 );
				float3 position4_g186 = temp_output_23_0_g186;
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_79_0_g185 = rotatedValue387;
				float3 direction4_g186 = temp_output_79_0_g185;
				float temp_output_82_0_g185 = _Phase;
				float temp_output_24_0_g186 = temp_output_82_0_g185;
				float phase4_g186 = temp_output_24_0_g186;
				float temp_output_25_0_g186 = _TimeParameters.x;
				float time4_g186 = temp_output_25_0_g186;
				float temp_output_81_0_g185 = _Gravity;
				float temp_output_26_0_g186 = temp_output_81_0_g185;
				float gravity4_g186 = temp_output_26_0_g186;
				float temp_output_80_0_g185 = _Depth;
				float temp_output_27_0_g186 = temp_output_80_0_g185;
				float depth4_g186 = temp_output_27_0_g186;
				float temp_output_84_0_g185 = ( _Amplitude1 * _Intensity );
				float amplitude4_g186 = temp_output_84_0_g185;
				float3 result4_g186 = float3( 0,0,0 );
				gerstner_float( position4_g186 , direction4_g186 , phase4_g186 , time4_g186 , gravity4_g186 , depth4_g186 , amplitude4_g186 , result4_g186 );
				float localgerstner9_g186 = ( 0.0 );
				float3 position9_g186 = temp_output_23_0_g186;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_78_0_g185 = rotatedValue64;
				float3 direction9_g186 = temp_output_78_0_g185;
				float phase9_g186 = temp_output_24_0_g186;
				float time9_g186 = temp_output_25_0_g186;
				float gravity9_g186 = temp_output_26_0_g186;
				float depth9_g186 = temp_output_27_0_g186;
				float temp_output_73_0_g185 = ( _Intensity * _Amplitude2 );
				float amplitude9_g186 = temp_output_73_0_g185;
				float3 result9_g186 = float3( 0,0,0 );
				gerstner_float( position9_g186 , direction9_g186 , phase9_g186 , time9_g186 , gravity9_g186 , depth9_g186 , amplitude9_g186 , result9_g186 );
				float localgerstner14_g186 = ( 0.0 );
				float3 position14_g186 = temp_output_23_0_g186;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_77_0_g185 = rotatedValue65;
				float3 direction14_g186 = temp_output_77_0_g185;
				float phase14_g186 = temp_output_24_0_g186;
				float time14_g186 = temp_output_25_0_g186;
				float gravity14_g186 = temp_output_26_0_g186;
				float depth14_g186 = temp_output_27_0_g186;
				float temp_output_75_0_g185 = ( _Intensity * _Amplitude3 );
				float amplitude14_g186 = temp_output_75_0_g185;
				float3 result14_g186 = float3( 0,0,0 );
				gerstner_float( position14_g186 , direction14_g186 , phase14_g186 , time14_g186 , gravity14_g186 , depth14_g186 , amplitude14_g186 , result14_g186 );
				float localgerstner15_g186 = ( 0.0 );
				float3 position15_g186 = temp_output_23_0_g186;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_76_0_g185 = rotatedValue66;
				float3 direction15_g186 = temp_output_76_0_g185;
				float phase15_g186 = temp_output_24_0_g186;
				float time15_g186 = temp_output_25_0_g186;
				float gravity15_g186 = temp_output_26_0_g186;
				float depth15_g186 = temp_output_27_0_g186;
				float temp_output_74_0_g185 = ( _Amplitude4 * _Intensity );
				float amplitude15_g186 = temp_output_74_0_g185;
				float3 result15_g186 = float3( 0,0,0 );
				gerstner_float( position15_g186 , direction15_g186 , phase15_g186 , time15_g186 , gravity15_g186 , depth15_g186 , amplitude15_g186 , result15_g186 );
				float3 worldToObj156_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g186 + result9_g186 ) + ( result14_g186 + result15_g186 ) ) + temp_output_23_0_g186 ), 1 ) ).xyz;
				float localgerstner4_g189 = ( 0.0 );
				float3 appendResult69_g185 = (float3(0.0 , temp_output_143_0_g185 , 0.0));
				float3 temp_output_23_0_g189 = ( WorldPosition + appendResult69_g185 );
				float3 position4_g189 = temp_output_23_0_g189;
				float3 direction4_g189 = temp_output_79_0_g185;
				float temp_output_24_0_g189 = temp_output_82_0_g185;
				float phase4_g189 = temp_output_24_0_g189;
				float temp_output_25_0_g189 = _TimeParameters.x;
				float time4_g189 = temp_output_25_0_g189;
				float temp_output_26_0_g189 = temp_output_81_0_g185;
				float gravity4_g189 = temp_output_26_0_g189;
				float temp_output_27_0_g189 = temp_output_80_0_g185;
				float depth4_g189 = temp_output_27_0_g189;
				float amplitude4_g189 = temp_output_84_0_g185;
				float3 result4_g189 = float3( 0,0,0 );
				gerstner_float( position4_g189 , direction4_g189 , phase4_g189 , time4_g189 , gravity4_g189 , depth4_g189 , amplitude4_g189 , result4_g189 );
				float localgerstner9_g189 = ( 0.0 );
				float3 position9_g189 = temp_output_23_0_g189;
				float3 direction9_g189 = temp_output_78_0_g185;
				float phase9_g189 = temp_output_24_0_g189;
				float time9_g189 = temp_output_25_0_g189;
				float gravity9_g189 = temp_output_26_0_g189;
				float depth9_g189 = temp_output_27_0_g189;
				float amplitude9_g189 = temp_output_73_0_g185;
				float3 result9_g189 = float3( 0,0,0 );
				gerstner_float( position9_g189 , direction9_g189 , phase9_g189 , time9_g189 , gravity9_g189 , depth9_g189 , amplitude9_g189 , result9_g189 );
				float localgerstner14_g189 = ( 0.0 );
				float3 position14_g189 = temp_output_23_0_g189;
				float3 direction14_g189 = temp_output_77_0_g185;
				float phase14_g189 = temp_output_24_0_g189;
				float time14_g189 = temp_output_25_0_g189;
				float gravity14_g189 = temp_output_26_0_g189;
				float depth14_g189 = temp_output_27_0_g189;
				float amplitude14_g189 = temp_output_75_0_g185;
				float3 result14_g189 = float3( 0,0,0 );
				gerstner_float( position14_g189 , direction14_g189 , phase14_g189 , time14_g189 , gravity14_g189 , depth14_g189 , amplitude14_g189 , result14_g189 );
				float localgerstner15_g189 = ( 0.0 );
				float3 position15_g189 = temp_output_23_0_g189;
				float3 direction15_g189 = temp_output_76_0_g185;
				float phase15_g189 = temp_output_24_0_g189;
				float time15_g189 = temp_output_25_0_g189;
				float gravity15_g189 = temp_output_26_0_g189;
				float depth15_g189 = temp_output_27_0_g189;
				float amplitude15_g189 = temp_output_74_0_g185;
				float3 result15_g189 = float3( 0,0,0 );
				gerstner_float( position15_g189 , direction15_g189 , phase15_g189 , time15_g189 , gravity15_g189 , depth15_g189 , amplitude15_g189 , result15_g189 );
				float3 worldToObj155_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g189 + result9_g189 ) + ( result14_g189 + result15_g189 ) ) + temp_output_23_0_g189 ), 1 ) ).xyz;
				float3 temp_output_3_0_g188 = worldToObj155_g185;
				float3 normalizeResult8_g188 = normalize( ( worldToObj156_g185 - temp_output_3_0_g188 ) );
				float localgerstner4_g187 = ( 0.0 );
				float3 appendResult136_g185 = (float3(0.0 , 0.0 , temp_output_143_0_g185));
				float3 temp_output_23_0_g187 = ( WorldPosition + appendResult136_g185 );
				float3 position4_g187 = temp_output_23_0_g187;
				float3 direction4_g187 = temp_output_79_0_g185;
				float temp_output_24_0_g187 = temp_output_82_0_g185;
				float phase4_g187 = temp_output_24_0_g187;
				float temp_output_25_0_g187 = _TimeParameters.x;
				float time4_g187 = temp_output_25_0_g187;
				float temp_output_26_0_g187 = temp_output_81_0_g185;
				float gravity4_g187 = temp_output_26_0_g187;
				float temp_output_27_0_g187 = temp_output_80_0_g185;
				float depth4_g187 = temp_output_27_0_g187;
				float amplitude4_g187 = temp_output_84_0_g185;
				float3 result4_g187 = float3( 0,0,0 );
				gerstner_float( position4_g187 , direction4_g187 , phase4_g187 , time4_g187 , gravity4_g187 , depth4_g187 , amplitude4_g187 , result4_g187 );
				float localgerstner9_g187 = ( 0.0 );
				float3 position9_g187 = temp_output_23_0_g187;
				float3 direction9_g187 = temp_output_78_0_g185;
				float phase9_g187 = temp_output_24_0_g187;
				float time9_g187 = temp_output_25_0_g187;
				float gravity9_g187 = temp_output_26_0_g187;
				float depth9_g187 = temp_output_27_0_g187;
				float amplitude9_g187 = temp_output_73_0_g185;
				float3 result9_g187 = float3( 0,0,0 );
				gerstner_float( position9_g187 , direction9_g187 , phase9_g187 , time9_g187 , gravity9_g187 , depth9_g187 , amplitude9_g187 , result9_g187 );
				float localgerstner14_g187 = ( 0.0 );
				float3 position14_g187 = temp_output_23_0_g187;
				float3 direction14_g187 = temp_output_77_0_g185;
				float phase14_g187 = temp_output_24_0_g187;
				float time14_g187 = temp_output_25_0_g187;
				float gravity14_g187 = temp_output_26_0_g187;
				float depth14_g187 = temp_output_27_0_g187;
				float amplitude14_g187 = temp_output_75_0_g185;
				float3 result14_g187 = float3( 0,0,0 );
				gerstner_float( position14_g187 , direction14_g187 , phase14_g187 , time14_g187 , gravity14_g187 , depth14_g187 , amplitude14_g187 , result14_g187 );
				float localgerstner15_g187 = ( 0.0 );
				float3 position15_g187 = temp_output_23_0_g187;
				float3 direction15_g187 = temp_output_76_0_g185;
				float phase15_g187 = temp_output_24_0_g187;
				float time15_g187 = temp_output_25_0_g187;
				float gravity15_g187 = temp_output_26_0_g187;
				float depth15_g187 = temp_output_27_0_g187;
				float amplitude15_g187 = temp_output_74_0_g185;
				float3 result15_g187 = float3( 0,0,0 );
				gerstner_float( position15_g187 , direction15_g187 , phase15_g187 , time15_g187 , gravity15_g187 , depth15_g187 , amplitude15_g187 , result15_g187 );
				float3 worldToObj164_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g187 + result9_g187 ) + ( result14_g187 + result15_g187 ) ) + temp_output_23_0_g187 ), 1 ) ).xyz;
				float3 normalizeResult9_g188 = normalize( ( temp_output_3_0_g188 - worldToObj164_g185 ) );
				float3 normalizeResult11_g188 = normalize( cross( normalizeResult8_g188 , normalizeResult9_g188 ) );
				float3 GerstNorm134 = normalizeResult11_g188;
				float dotResult130 = dot( GerstNorm134 , float3( 0,0,1 ) );
				float2 temp_cast_1 = (_TimeParameters.x).xx;
				float2 texCoord140 = IN.ase_texcoord3.xy * float2( 1,1 ) + temp_cast_1;
				float simplePerlin2D138 = snoise( texCoord140*0.02 );
				simplePerlin2D138 = simplePerlin2D138*0.5 + 0.5;
				float smoothstepResult147 = smoothstep( _WaveRiseThershold , lerpResult143 , ( ( (-0.1 + (simplePerlin2D126 - 0.0) * (0.1 - -0.1) / (1.0 - 0.0)) + (1.0 + (dotResult130 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) + (-0.2 + (simplePerlin2D138 - 0.0) * (0.2 - -0.2) / (1.0 - 0.0)) ));
				float waterRise149 = smoothstepResult147;
				float foam153 = step( 0.4 , ( ( ( 1.0 - smoothstepResult91 ) * clampResult107 ) + waterRise149 ) );
				

				float Alpha = ( ( ( 1.0 - WaterDepth187 ) * _WaterThickness ) + foam153 );
				float AlphaClipThreshold = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.clipPos.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM

			#define ASE_FOG 1
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_DISTANCE_TESSELLATION
			#define _SPECULAR_SETUP 1
			#pragma shader_feature_local_fragment _SPECULAR_SETUP
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_DEPTH_WRITE_ON
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature EDITOR_VISUALIZATION

			#define SHADERPASS SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "../../CustomFunctions/GerstnerWave.hlsl"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord0 : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef EDITOR_VISUALIZATION
					float4 VizUV : TEXCOORD2;
					float4 LightCoord : TEXCOORD3;
				#endif
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Emission;
			float4 _NormalTexture2_ST;
			float4 _NormalTexture1_ST;
			float4 _DeepColor;
			float4 _FoamEmmision;
			float4 _ShallowColor;
			float3 _Direction4;
			float3 _Direction1;
			float3 _Direction2;
			float3 _Direction3;
			float _PanSpeed;
			float _WaveRiseFallback;
			float _WaveRiseThershold;
			float _ColorDepth;
			float _NeighbourDistance;
			float _Amplitude3;
			float _Amplitude2;
			float _Intensity;
			float _Amplitude1;
			float _Depth;
			float _Gravity;
			float _Phase;
			float _Roataion;
			float _Amplitude4;
			float _WaterThickness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			uniform float4 _CameraDepthTexture_TexelSize;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float localgerstner4_g189 = ( 0.0 );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float temp_output_143_0_g185 = _NeighbourDistance;
				float3 appendResult69_g185 = (float3(0.0 , temp_output_143_0_g185 , 0.0));
				float3 temp_output_23_0_g189 = ( ase_worldPos + appendResult69_g185 );
				float3 position4_g189 = temp_output_23_0_g189;
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_79_0_g185 = rotatedValue387;
				float3 direction4_g189 = temp_output_79_0_g185;
				float temp_output_82_0_g185 = _Phase;
				float temp_output_24_0_g189 = temp_output_82_0_g185;
				float phase4_g189 = temp_output_24_0_g189;
				float temp_output_25_0_g189 = _TimeParameters.x;
				float time4_g189 = temp_output_25_0_g189;
				float temp_output_81_0_g185 = _Gravity;
				float temp_output_26_0_g189 = temp_output_81_0_g185;
				float gravity4_g189 = temp_output_26_0_g189;
				float temp_output_80_0_g185 = _Depth;
				float temp_output_27_0_g189 = temp_output_80_0_g185;
				float depth4_g189 = temp_output_27_0_g189;
				float temp_output_84_0_g185 = ( _Amplitude1 * _Intensity );
				float amplitude4_g189 = temp_output_84_0_g185;
				float3 result4_g189 = float3( 0,0,0 );
				gerstner_float( position4_g189 , direction4_g189 , phase4_g189 , time4_g189 , gravity4_g189 , depth4_g189 , amplitude4_g189 , result4_g189 );
				float localgerstner9_g189 = ( 0.0 );
				float3 position9_g189 = temp_output_23_0_g189;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_78_0_g185 = rotatedValue64;
				float3 direction9_g189 = temp_output_78_0_g185;
				float phase9_g189 = temp_output_24_0_g189;
				float time9_g189 = temp_output_25_0_g189;
				float gravity9_g189 = temp_output_26_0_g189;
				float depth9_g189 = temp_output_27_0_g189;
				float temp_output_73_0_g185 = ( _Intensity * _Amplitude2 );
				float amplitude9_g189 = temp_output_73_0_g185;
				float3 result9_g189 = float3( 0,0,0 );
				gerstner_float( position9_g189 , direction9_g189 , phase9_g189 , time9_g189 , gravity9_g189 , depth9_g189 , amplitude9_g189 , result9_g189 );
				float localgerstner14_g189 = ( 0.0 );
				float3 position14_g189 = temp_output_23_0_g189;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_77_0_g185 = rotatedValue65;
				float3 direction14_g189 = temp_output_77_0_g185;
				float phase14_g189 = temp_output_24_0_g189;
				float time14_g189 = temp_output_25_0_g189;
				float gravity14_g189 = temp_output_26_0_g189;
				float depth14_g189 = temp_output_27_0_g189;
				float temp_output_75_0_g185 = ( _Intensity * _Amplitude3 );
				float amplitude14_g189 = temp_output_75_0_g185;
				float3 result14_g189 = float3( 0,0,0 );
				gerstner_float( position14_g189 , direction14_g189 , phase14_g189 , time14_g189 , gravity14_g189 , depth14_g189 , amplitude14_g189 , result14_g189 );
				float localgerstner15_g189 = ( 0.0 );
				float3 position15_g189 = temp_output_23_0_g189;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_76_0_g185 = rotatedValue66;
				float3 direction15_g189 = temp_output_76_0_g185;
				float phase15_g189 = temp_output_24_0_g189;
				float time15_g189 = temp_output_25_0_g189;
				float gravity15_g189 = temp_output_26_0_g189;
				float depth15_g189 = temp_output_27_0_g189;
				float temp_output_74_0_g185 = ( _Amplitude4 * _Intensity );
				float amplitude15_g189 = temp_output_74_0_g185;
				float3 result15_g189 = float3( 0,0,0 );
				gerstner_float( position15_g189 , direction15_g189 , phase15_g189 , time15_g189 , gravity15_g189 , depth15_g189 , amplitude15_g189 , result15_g189 );
				float3 worldToObj155_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g189 + result9_g189 ) + ( result14_g189 + result15_g189 ) ) + temp_output_23_0_g189 ), 1 ) ).xyz;
				float3 GerstPos132 = worldToObj155_g185;
				
				float localgerstner4_g186 = ( 0.0 );
				float3 appendResult142_g185 = (float3(temp_output_143_0_g185 , 0.0 , 0.0));
				float3 temp_output_23_0_g186 = ( ase_worldPos + appendResult142_g185 );
				float3 position4_g186 = temp_output_23_0_g186;
				float3 direction4_g186 = temp_output_79_0_g185;
				float temp_output_24_0_g186 = temp_output_82_0_g185;
				float phase4_g186 = temp_output_24_0_g186;
				float temp_output_25_0_g186 = _TimeParameters.x;
				float time4_g186 = temp_output_25_0_g186;
				float temp_output_26_0_g186 = temp_output_81_0_g185;
				float gravity4_g186 = temp_output_26_0_g186;
				float temp_output_27_0_g186 = temp_output_80_0_g185;
				float depth4_g186 = temp_output_27_0_g186;
				float amplitude4_g186 = temp_output_84_0_g185;
				float3 result4_g186 = float3( 0,0,0 );
				gerstner_float( position4_g186 , direction4_g186 , phase4_g186 , time4_g186 , gravity4_g186 , depth4_g186 , amplitude4_g186 , result4_g186 );
				float localgerstner9_g186 = ( 0.0 );
				float3 position9_g186 = temp_output_23_0_g186;
				float3 direction9_g186 = temp_output_78_0_g185;
				float phase9_g186 = temp_output_24_0_g186;
				float time9_g186 = temp_output_25_0_g186;
				float gravity9_g186 = temp_output_26_0_g186;
				float depth9_g186 = temp_output_27_0_g186;
				float amplitude9_g186 = temp_output_73_0_g185;
				float3 result9_g186 = float3( 0,0,0 );
				gerstner_float( position9_g186 , direction9_g186 , phase9_g186 , time9_g186 , gravity9_g186 , depth9_g186 , amplitude9_g186 , result9_g186 );
				float localgerstner14_g186 = ( 0.0 );
				float3 position14_g186 = temp_output_23_0_g186;
				float3 direction14_g186 = temp_output_77_0_g185;
				float phase14_g186 = temp_output_24_0_g186;
				float time14_g186 = temp_output_25_0_g186;
				float gravity14_g186 = temp_output_26_0_g186;
				float depth14_g186 = temp_output_27_0_g186;
				float amplitude14_g186 = temp_output_75_0_g185;
				float3 result14_g186 = float3( 0,0,0 );
				gerstner_float( position14_g186 , direction14_g186 , phase14_g186 , time14_g186 , gravity14_g186 , depth14_g186 , amplitude14_g186 , result14_g186 );
				float localgerstner15_g186 = ( 0.0 );
				float3 position15_g186 = temp_output_23_0_g186;
				float3 direction15_g186 = temp_output_76_0_g185;
				float phase15_g186 = temp_output_24_0_g186;
				float time15_g186 = temp_output_25_0_g186;
				float gravity15_g186 = temp_output_26_0_g186;
				float depth15_g186 = temp_output_27_0_g186;
				float amplitude15_g186 = temp_output_74_0_g185;
				float3 result15_g186 = float3( 0,0,0 );
				gerstner_float( position15_g186 , direction15_g186 , phase15_g186 , time15_g186 , gravity15_g186 , depth15_g186 , amplitude15_g186 , result15_g186 );
				float3 worldToObj156_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g186 + result9_g186 ) + ( result14_g186 + result15_g186 ) ) + temp_output_23_0_g186 ), 1 ) ).xyz;
				float3 temp_output_3_0_g188 = worldToObj155_g185;
				float3 normalizeResult8_g188 = normalize( ( worldToObj156_g185 - temp_output_3_0_g188 ) );
				float localgerstner4_g187 = ( 0.0 );
				float3 appendResult136_g185 = (float3(0.0 , 0.0 , temp_output_143_0_g185));
				float3 temp_output_23_0_g187 = ( ase_worldPos + appendResult136_g185 );
				float3 position4_g187 = temp_output_23_0_g187;
				float3 direction4_g187 = temp_output_79_0_g185;
				float temp_output_24_0_g187 = temp_output_82_0_g185;
				float phase4_g187 = temp_output_24_0_g187;
				float temp_output_25_0_g187 = _TimeParameters.x;
				float time4_g187 = temp_output_25_0_g187;
				float temp_output_26_0_g187 = temp_output_81_0_g185;
				float gravity4_g187 = temp_output_26_0_g187;
				float temp_output_27_0_g187 = temp_output_80_0_g185;
				float depth4_g187 = temp_output_27_0_g187;
				float amplitude4_g187 = temp_output_84_0_g185;
				float3 result4_g187 = float3( 0,0,0 );
				gerstner_float( position4_g187 , direction4_g187 , phase4_g187 , time4_g187 , gravity4_g187 , depth4_g187 , amplitude4_g187 , result4_g187 );
				float localgerstner9_g187 = ( 0.0 );
				float3 position9_g187 = temp_output_23_0_g187;
				float3 direction9_g187 = temp_output_78_0_g185;
				float phase9_g187 = temp_output_24_0_g187;
				float time9_g187 = temp_output_25_0_g187;
				float gravity9_g187 = temp_output_26_0_g187;
				float depth9_g187 = temp_output_27_0_g187;
				float amplitude9_g187 = temp_output_73_0_g185;
				float3 result9_g187 = float3( 0,0,0 );
				gerstner_float( position9_g187 , direction9_g187 , phase9_g187 , time9_g187 , gravity9_g187 , depth9_g187 , amplitude9_g187 , result9_g187 );
				float localgerstner14_g187 = ( 0.0 );
				float3 position14_g187 = temp_output_23_0_g187;
				float3 direction14_g187 = temp_output_77_0_g185;
				float phase14_g187 = temp_output_24_0_g187;
				float time14_g187 = temp_output_25_0_g187;
				float gravity14_g187 = temp_output_26_0_g187;
				float depth14_g187 = temp_output_27_0_g187;
				float amplitude14_g187 = temp_output_75_0_g185;
				float3 result14_g187 = float3( 0,0,0 );
				gerstner_float( position14_g187 , direction14_g187 , phase14_g187 , time14_g187 , gravity14_g187 , depth14_g187 , amplitude14_g187 , result14_g187 );
				float localgerstner15_g187 = ( 0.0 );
				float3 position15_g187 = temp_output_23_0_g187;
				float3 direction15_g187 = temp_output_76_0_g185;
				float phase15_g187 = temp_output_24_0_g187;
				float time15_g187 = temp_output_25_0_g187;
				float gravity15_g187 = temp_output_26_0_g187;
				float depth15_g187 = temp_output_27_0_g187;
				float amplitude15_g187 = temp_output_74_0_g185;
				float3 result15_g187 = float3( 0,0,0 );
				gerstner_float( position15_g187 , direction15_g187 , phase15_g187 , time15_g187 , gravity15_g187 , depth15_g187 , amplitude15_g187 , result15_g187 );
				float3 worldToObj164_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g187 + result9_g187 ) + ( result14_g187 + result15_g187 ) ) + temp_output_23_0_g187 ), 1 ) ).xyz;
				float3 normalizeResult9_g188 = normalize( ( temp_output_3_0_g188 - worldToObj164_g185 ) );
				float3 normalizeResult11_g188 = normalize( cross( normalizeResult8_g188 , normalizeResult9_g188 ) );
				float3 GerstNorm134 = normalizeResult11_g188;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.ase_texcoord5.xy = v.texcoord0.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord5.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = GerstPos132;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = GerstNorm134;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );

				#ifdef EDITOR_VISUALIZATION
					float2 VizUV = 0;
					float4 LightCoord = 0;
					UnityEditorVizData(v.vertex.xyz, v.texcoord0.xy, v.texcoord1.xy, v.texcoord2.xy, VizUV, LightCoord);
					o.VizUV = float4(VizUV, 0, 0);
					o.LightCoord = LightCoord;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 texcoord0 : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.texcoord0 = v.texcoord0;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.texcoord0 = patch[0].texcoord0 * bary.x + patch[1].texcoord0 * bary.y + patch[2].texcoord0 * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float4 screenPos = IN.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth11_g132 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth11_g132 = saturate( abs( ( screenDepth11_g132 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _ColorDepth ) ) );
				float temp_output_298_0 = ( 1.0 - distanceDepth11_g132 );
				float smoothstepResult91 = smoothstep( 0.0 , 0.2 , (1.0 + (temp_output_298_0 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
				float2 temp_cast_0 = (_TimeParameters.x).xx;
				float2 texCoord117 = IN.ase_texcoord5.xy * float2( 1,1 ) + temp_cast_0;
				float simplePerlin2D287 = snoise( texCoord117*0.2 );
				simplePerlin2D287 = simplePerlin2D287*0.5 + 0.5;
				float clampResult107 = clamp( ( ( ( 1.0 - pow( ( 1.0 / 1000.0 ) , temp_output_298_0 ) ) * sin( ( ( temp_output_298_0 * 100.0 ) + ( 4.0 * _TimeParameters.x ) ) ) ) * ( simplePerlin2D287 + 0.7 ) ) , 0.0 , 0.9 );
				float lerpResult143 = lerp( _WaveRiseThershold , 1.0 , _WaveRiseFallback);
				float2 texCoord118 = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float cos121 = cos( radians( _Roataion ) );
				float sin121 = sin( radians( _Roataion ) );
				float2 rotator121 = mul( texCoord118 - float2( 0.5,0.5 ) , float2x2( cos121 , -sin121 , sin121 , cos121 )) + float2( 0.5,0.5 );
				float simplePerlin2D126 = snoise( rotator121*0.5 );
				simplePerlin2D126 = simplePerlin2D126*0.5 + 0.5;
				float localgerstner4_g186 = ( 0.0 );
				float temp_output_143_0_g185 = _NeighbourDistance;
				float3 appendResult142_g185 = (float3(temp_output_143_0_g185 , 0.0 , 0.0));
				float3 temp_output_23_0_g186 = ( WorldPosition + appendResult142_g185 );
				float3 position4_g186 = temp_output_23_0_g186;
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_79_0_g185 = rotatedValue387;
				float3 direction4_g186 = temp_output_79_0_g185;
				float temp_output_82_0_g185 = _Phase;
				float temp_output_24_0_g186 = temp_output_82_0_g185;
				float phase4_g186 = temp_output_24_0_g186;
				float temp_output_25_0_g186 = _TimeParameters.x;
				float time4_g186 = temp_output_25_0_g186;
				float temp_output_81_0_g185 = _Gravity;
				float temp_output_26_0_g186 = temp_output_81_0_g185;
				float gravity4_g186 = temp_output_26_0_g186;
				float temp_output_80_0_g185 = _Depth;
				float temp_output_27_0_g186 = temp_output_80_0_g185;
				float depth4_g186 = temp_output_27_0_g186;
				float temp_output_84_0_g185 = ( _Amplitude1 * _Intensity );
				float amplitude4_g186 = temp_output_84_0_g185;
				float3 result4_g186 = float3( 0,0,0 );
				gerstner_float( position4_g186 , direction4_g186 , phase4_g186 , time4_g186 , gravity4_g186 , depth4_g186 , amplitude4_g186 , result4_g186 );
				float localgerstner9_g186 = ( 0.0 );
				float3 position9_g186 = temp_output_23_0_g186;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_78_0_g185 = rotatedValue64;
				float3 direction9_g186 = temp_output_78_0_g185;
				float phase9_g186 = temp_output_24_0_g186;
				float time9_g186 = temp_output_25_0_g186;
				float gravity9_g186 = temp_output_26_0_g186;
				float depth9_g186 = temp_output_27_0_g186;
				float temp_output_73_0_g185 = ( _Intensity * _Amplitude2 );
				float amplitude9_g186 = temp_output_73_0_g185;
				float3 result9_g186 = float3( 0,0,0 );
				gerstner_float( position9_g186 , direction9_g186 , phase9_g186 , time9_g186 , gravity9_g186 , depth9_g186 , amplitude9_g186 , result9_g186 );
				float localgerstner14_g186 = ( 0.0 );
				float3 position14_g186 = temp_output_23_0_g186;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_77_0_g185 = rotatedValue65;
				float3 direction14_g186 = temp_output_77_0_g185;
				float phase14_g186 = temp_output_24_0_g186;
				float time14_g186 = temp_output_25_0_g186;
				float gravity14_g186 = temp_output_26_0_g186;
				float depth14_g186 = temp_output_27_0_g186;
				float temp_output_75_0_g185 = ( _Intensity * _Amplitude3 );
				float amplitude14_g186 = temp_output_75_0_g185;
				float3 result14_g186 = float3( 0,0,0 );
				gerstner_float( position14_g186 , direction14_g186 , phase14_g186 , time14_g186 , gravity14_g186 , depth14_g186 , amplitude14_g186 , result14_g186 );
				float localgerstner15_g186 = ( 0.0 );
				float3 position15_g186 = temp_output_23_0_g186;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_76_0_g185 = rotatedValue66;
				float3 direction15_g186 = temp_output_76_0_g185;
				float phase15_g186 = temp_output_24_0_g186;
				float time15_g186 = temp_output_25_0_g186;
				float gravity15_g186 = temp_output_26_0_g186;
				float depth15_g186 = temp_output_27_0_g186;
				float temp_output_74_0_g185 = ( _Amplitude4 * _Intensity );
				float amplitude15_g186 = temp_output_74_0_g185;
				float3 result15_g186 = float3( 0,0,0 );
				gerstner_float( position15_g186 , direction15_g186 , phase15_g186 , time15_g186 , gravity15_g186 , depth15_g186 , amplitude15_g186 , result15_g186 );
				float3 worldToObj156_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g186 + result9_g186 ) + ( result14_g186 + result15_g186 ) ) + temp_output_23_0_g186 ), 1 ) ).xyz;
				float localgerstner4_g189 = ( 0.0 );
				float3 appendResult69_g185 = (float3(0.0 , temp_output_143_0_g185 , 0.0));
				float3 temp_output_23_0_g189 = ( WorldPosition + appendResult69_g185 );
				float3 position4_g189 = temp_output_23_0_g189;
				float3 direction4_g189 = temp_output_79_0_g185;
				float temp_output_24_0_g189 = temp_output_82_0_g185;
				float phase4_g189 = temp_output_24_0_g189;
				float temp_output_25_0_g189 = _TimeParameters.x;
				float time4_g189 = temp_output_25_0_g189;
				float temp_output_26_0_g189 = temp_output_81_0_g185;
				float gravity4_g189 = temp_output_26_0_g189;
				float temp_output_27_0_g189 = temp_output_80_0_g185;
				float depth4_g189 = temp_output_27_0_g189;
				float amplitude4_g189 = temp_output_84_0_g185;
				float3 result4_g189 = float3( 0,0,0 );
				gerstner_float( position4_g189 , direction4_g189 , phase4_g189 , time4_g189 , gravity4_g189 , depth4_g189 , amplitude4_g189 , result4_g189 );
				float localgerstner9_g189 = ( 0.0 );
				float3 position9_g189 = temp_output_23_0_g189;
				float3 direction9_g189 = temp_output_78_0_g185;
				float phase9_g189 = temp_output_24_0_g189;
				float time9_g189 = temp_output_25_0_g189;
				float gravity9_g189 = temp_output_26_0_g189;
				float depth9_g189 = temp_output_27_0_g189;
				float amplitude9_g189 = temp_output_73_0_g185;
				float3 result9_g189 = float3( 0,0,0 );
				gerstner_float( position9_g189 , direction9_g189 , phase9_g189 , time9_g189 , gravity9_g189 , depth9_g189 , amplitude9_g189 , result9_g189 );
				float localgerstner14_g189 = ( 0.0 );
				float3 position14_g189 = temp_output_23_0_g189;
				float3 direction14_g189 = temp_output_77_0_g185;
				float phase14_g189 = temp_output_24_0_g189;
				float time14_g189 = temp_output_25_0_g189;
				float gravity14_g189 = temp_output_26_0_g189;
				float depth14_g189 = temp_output_27_0_g189;
				float amplitude14_g189 = temp_output_75_0_g185;
				float3 result14_g189 = float3( 0,0,0 );
				gerstner_float( position14_g189 , direction14_g189 , phase14_g189 , time14_g189 , gravity14_g189 , depth14_g189 , amplitude14_g189 , result14_g189 );
				float localgerstner15_g189 = ( 0.0 );
				float3 position15_g189 = temp_output_23_0_g189;
				float3 direction15_g189 = temp_output_76_0_g185;
				float phase15_g189 = temp_output_24_0_g189;
				float time15_g189 = temp_output_25_0_g189;
				float gravity15_g189 = temp_output_26_0_g189;
				float depth15_g189 = temp_output_27_0_g189;
				float amplitude15_g189 = temp_output_74_0_g185;
				float3 result15_g189 = float3( 0,0,0 );
				gerstner_float( position15_g189 , direction15_g189 , phase15_g189 , time15_g189 , gravity15_g189 , depth15_g189 , amplitude15_g189 , result15_g189 );
				float3 worldToObj155_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g189 + result9_g189 ) + ( result14_g189 + result15_g189 ) ) + temp_output_23_0_g189 ), 1 ) ).xyz;
				float3 temp_output_3_0_g188 = worldToObj155_g185;
				float3 normalizeResult8_g188 = normalize( ( worldToObj156_g185 - temp_output_3_0_g188 ) );
				float localgerstner4_g187 = ( 0.0 );
				float3 appendResult136_g185 = (float3(0.0 , 0.0 , temp_output_143_0_g185));
				float3 temp_output_23_0_g187 = ( WorldPosition + appendResult136_g185 );
				float3 position4_g187 = temp_output_23_0_g187;
				float3 direction4_g187 = temp_output_79_0_g185;
				float temp_output_24_0_g187 = temp_output_82_0_g185;
				float phase4_g187 = temp_output_24_0_g187;
				float temp_output_25_0_g187 = _TimeParameters.x;
				float time4_g187 = temp_output_25_0_g187;
				float temp_output_26_0_g187 = temp_output_81_0_g185;
				float gravity4_g187 = temp_output_26_0_g187;
				float temp_output_27_0_g187 = temp_output_80_0_g185;
				float depth4_g187 = temp_output_27_0_g187;
				float amplitude4_g187 = temp_output_84_0_g185;
				float3 result4_g187 = float3( 0,0,0 );
				gerstner_float( position4_g187 , direction4_g187 , phase4_g187 , time4_g187 , gravity4_g187 , depth4_g187 , amplitude4_g187 , result4_g187 );
				float localgerstner9_g187 = ( 0.0 );
				float3 position9_g187 = temp_output_23_0_g187;
				float3 direction9_g187 = temp_output_78_0_g185;
				float phase9_g187 = temp_output_24_0_g187;
				float time9_g187 = temp_output_25_0_g187;
				float gravity9_g187 = temp_output_26_0_g187;
				float depth9_g187 = temp_output_27_0_g187;
				float amplitude9_g187 = temp_output_73_0_g185;
				float3 result9_g187 = float3( 0,0,0 );
				gerstner_float( position9_g187 , direction9_g187 , phase9_g187 , time9_g187 , gravity9_g187 , depth9_g187 , amplitude9_g187 , result9_g187 );
				float localgerstner14_g187 = ( 0.0 );
				float3 position14_g187 = temp_output_23_0_g187;
				float3 direction14_g187 = temp_output_77_0_g185;
				float phase14_g187 = temp_output_24_0_g187;
				float time14_g187 = temp_output_25_0_g187;
				float gravity14_g187 = temp_output_26_0_g187;
				float depth14_g187 = temp_output_27_0_g187;
				float amplitude14_g187 = temp_output_75_0_g185;
				float3 result14_g187 = float3( 0,0,0 );
				gerstner_float( position14_g187 , direction14_g187 , phase14_g187 , time14_g187 , gravity14_g187 , depth14_g187 , amplitude14_g187 , result14_g187 );
				float localgerstner15_g187 = ( 0.0 );
				float3 position15_g187 = temp_output_23_0_g187;
				float3 direction15_g187 = temp_output_76_0_g185;
				float phase15_g187 = temp_output_24_0_g187;
				float time15_g187 = temp_output_25_0_g187;
				float gravity15_g187 = temp_output_26_0_g187;
				float depth15_g187 = temp_output_27_0_g187;
				float amplitude15_g187 = temp_output_74_0_g185;
				float3 result15_g187 = float3( 0,0,0 );
				gerstner_float( position15_g187 , direction15_g187 , phase15_g187 , time15_g187 , gravity15_g187 , depth15_g187 , amplitude15_g187 , result15_g187 );
				float3 worldToObj164_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g187 + result9_g187 ) + ( result14_g187 + result15_g187 ) ) + temp_output_23_0_g187 ), 1 ) ).xyz;
				float3 normalizeResult9_g188 = normalize( ( temp_output_3_0_g188 - worldToObj164_g185 ) );
				float3 normalizeResult11_g188 = normalize( cross( normalizeResult8_g188 , normalizeResult9_g188 ) );
				float3 GerstNorm134 = normalizeResult11_g188;
				float dotResult130 = dot( GerstNorm134 , float3( 0,0,1 ) );
				float2 temp_cast_1 = (_TimeParameters.x).xx;
				float2 texCoord140 = IN.ase_texcoord5.xy * float2( 1,1 ) + temp_cast_1;
				float simplePerlin2D138 = snoise( texCoord140*0.02 );
				simplePerlin2D138 = simplePerlin2D138*0.5 + 0.5;
				float smoothstepResult147 = smoothstep( _WaveRiseThershold , lerpResult143 , ( ( (-0.1 + (simplePerlin2D126 - 0.0) * (0.1 - -0.1) / (1.0 - 0.0)) + (1.0 + (dotResult130 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) + (-0.2 + (simplePerlin2D138 - 0.0) * (0.2 - -0.2) / (1.0 - 0.0)) ));
				float waterRise149 = smoothstepResult147;
				float foam153 = step( 0.4 , ( ( ( 1.0 - smoothstepResult91 ) * clampResult107 ) + waterRise149 ) );
				float4 lerpResult284 = lerp( _ShallowColor , _DeepColor , foam153);
				
				float4 lerpResult304 = lerp( _Emission , _FoamEmmision , foam153);
				
				float WaterDepth187 = temp_output_298_0;
				

				float3 BaseColor = lerpResult284.rgb;
				float3 Emission = lerpResult304.rgb;
				float Alpha = ( ( ( 1.0 - WaterDepth187 ) * _WaterThickness ) + foam153 );
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = BaseColor;
				metaInput.Emission = Emission;
				#ifdef EDITOR_VISUALIZATION
					metaInput.VizUV = IN.VizUV.xy;
					metaInput.LightCoord = IN.LightCoord;
				#endif

				return UnityMetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM

			#define ASE_FOG 1
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_DISTANCE_TESSELLATION
			#define _SPECULAR_SETUP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_DEPTH_WRITE_ON
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "../../CustomFunctions/GerstnerWave.hlsl"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Emission;
			float4 _NormalTexture2_ST;
			float4 _NormalTexture1_ST;
			float4 _DeepColor;
			float4 _FoamEmmision;
			float4 _ShallowColor;
			float3 _Direction4;
			float3 _Direction1;
			float3 _Direction2;
			float3 _Direction3;
			float _PanSpeed;
			float _WaveRiseFallback;
			float _WaveRiseThershold;
			float _ColorDepth;
			float _NeighbourDistance;
			float _Amplitude3;
			float _Amplitude2;
			float _Intensity;
			float _Amplitude1;
			float _Depth;
			float _Gravity;
			float _Phase;
			float _Roataion;
			float _Amplitude4;
			float _WaterThickness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			uniform float4 _CameraDepthTexture_TexelSize;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float localgerstner4_g189 = ( 0.0 );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float temp_output_143_0_g185 = _NeighbourDistance;
				float3 appendResult69_g185 = (float3(0.0 , temp_output_143_0_g185 , 0.0));
				float3 temp_output_23_0_g189 = ( ase_worldPos + appendResult69_g185 );
				float3 position4_g189 = temp_output_23_0_g189;
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_79_0_g185 = rotatedValue387;
				float3 direction4_g189 = temp_output_79_0_g185;
				float temp_output_82_0_g185 = _Phase;
				float temp_output_24_0_g189 = temp_output_82_0_g185;
				float phase4_g189 = temp_output_24_0_g189;
				float temp_output_25_0_g189 = _TimeParameters.x;
				float time4_g189 = temp_output_25_0_g189;
				float temp_output_81_0_g185 = _Gravity;
				float temp_output_26_0_g189 = temp_output_81_0_g185;
				float gravity4_g189 = temp_output_26_0_g189;
				float temp_output_80_0_g185 = _Depth;
				float temp_output_27_0_g189 = temp_output_80_0_g185;
				float depth4_g189 = temp_output_27_0_g189;
				float temp_output_84_0_g185 = ( _Amplitude1 * _Intensity );
				float amplitude4_g189 = temp_output_84_0_g185;
				float3 result4_g189 = float3( 0,0,0 );
				gerstner_float( position4_g189 , direction4_g189 , phase4_g189 , time4_g189 , gravity4_g189 , depth4_g189 , amplitude4_g189 , result4_g189 );
				float localgerstner9_g189 = ( 0.0 );
				float3 position9_g189 = temp_output_23_0_g189;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_78_0_g185 = rotatedValue64;
				float3 direction9_g189 = temp_output_78_0_g185;
				float phase9_g189 = temp_output_24_0_g189;
				float time9_g189 = temp_output_25_0_g189;
				float gravity9_g189 = temp_output_26_0_g189;
				float depth9_g189 = temp_output_27_0_g189;
				float temp_output_73_0_g185 = ( _Intensity * _Amplitude2 );
				float amplitude9_g189 = temp_output_73_0_g185;
				float3 result9_g189 = float3( 0,0,0 );
				gerstner_float( position9_g189 , direction9_g189 , phase9_g189 , time9_g189 , gravity9_g189 , depth9_g189 , amplitude9_g189 , result9_g189 );
				float localgerstner14_g189 = ( 0.0 );
				float3 position14_g189 = temp_output_23_0_g189;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_77_0_g185 = rotatedValue65;
				float3 direction14_g189 = temp_output_77_0_g185;
				float phase14_g189 = temp_output_24_0_g189;
				float time14_g189 = temp_output_25_0_g189;
				float gravity14_g189 = temp_output_26_0_g189;
				float depth14_g189 = temp_output_27_0_g189;
				float temp_output_75_0_g185 = ( _Intensity * _Amplitude3 );
				float amplitude14_g189 = temp_output_75_0_g185;
				float3 result14_g189 = float3( 0,0,0 );
				gerstner_float( position14_g189 , direction14_g189 , phase14_g189 , time14_g189 , gravity14_g189 , depth14_g189 , amplitude14_g189 , result14_g189 );
				float localgerstner15_g189 = ( 0.0 );
				float3 position15_g189 = temp_output_23_0_g189;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_76_0_g185 = rotatedValue66;
				float3 direction15_g189 = temp_output_76_0_g185;
				float phase15_g189 = temp_output_24_0_g189;
				float time15_g189 = temp_output_25_0_g189;
				float gravity15_g189 = temp_output_26_0_g189;
				float depth15_g189 = temp_output_27_0_g189;
				float temp_output_74_0_g185 = ( _Amplitude4 * _Intensity );
				float amplitude15_g189 = temp_output_74_0_g185;
				float3 result15_g189 = float3( 0,0,0 );
				gerstner_float( position15_g189 , direction15_g189 , phase15_g189 , time15_g189 , gravity15_g189 , depth15_g189 , amplitude15_g189 , result15_g189 );
				float3 worldToObj155_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g189 + result9_g189 ) + ( result14_g189 + result15_g189 ) ) + temp_output_23_0_g189 ), 1 ) ).xyz;
				float3 GerstPos132 = worldToObj155_g185;
				
				float localgerstner4_g186 = ( 0.0 );
				float3 appendResult142_g185 = (float3(temp_output_143_0_g185 , 0.0 , 0.0));
				float3 temp_output_23_0_g186 = ( ase_worldPos + appendResult142_g185 );
				float3 position4_g186 = temp_output_23_0_g186;
				float3 direction4_g186 = temp_output_79_0_g185;
				float temp_output_24_0_g186 = temp_output_82_0_g185;
				float phase4_g186 = temp_output_24_0_g186;
				float temp_output_25_0_g186 = _TimeParameters.x;
				float time4_g186 = temp_output_25_0_g186;
				float temp_output_26_0_g186 = temp_output_81_0_g185;
				float gravity4_g186 = temp_output_26_0_g186;
				float temp_output_27_0_g186 = temp_output_80_0_g185;
				float depth4_g186 = temp_output_27_0_g186;
				float amplitude4_g186 = temp_output_84_0_g185;
				float3 result4_g186 = float3( 0,0,0 );
				gerstner_float( position4_g186 , direction4_g186 , phase4_g186 , time4_g186 , gravity4_g186 , depth4_g186 , amplitude4_g186 , result4_g186 );
				float localgerstner9_g186 = ( 0.0 );
				float3 position9_g186 = temp_output_23_0_g186;
				float3 direction9_g186 = temp_output_78_0_g185;
				float phase9_g186 = temp_output_24_0_g186;
				float time9_g186 = temp_output_25_0_g186;
				float gravity9_g186 = temp_output_26_0_g186;
				float depth9_g186 = temp_output_27_0_g186;
				float amplitude9_g186 = temp_output_73_0_g185;
				float3 result9_g186 = float3( 0,0,0 );
				gerstner_float( position9_g186 , direction9_g186 , phase9_g186 , time9_g186 , gravity9_g186 , depth9_g186 , amplitude9_g186 , result9_g186 );
				float localgerstner14_g186 = ( 0.0 );
				float3 position14_g186 = temp_output_23_0_g186;
				float3 direction14_g186 = temp_output_77_0_g185;
				float phase14_g186 = temp_output_24_0_g186;
				float time14_g186 = temp_output_25_0_g186;
				float gravity14_g186 = temp_output_26_0_g186;
				float depth14_g186 = temp_output_27_0_g186;
				float amplitude14_g186 = temp_output_75_0_g185;
				float3 result14_g186 = float3( 0,0,0 );
				gerstner_float( position14_g186 , direction14_g186 , phase14_g186 , time14_g186 , gravity14_g186 , depth14_g186 , amplitude14_g186 , result14_g186 );
				float localgerstner15_g186 = ( 0.0 );
				float3 position15_g186 = temp_output_23_0_g186;
				float3 direction15_g186 = temp_output_76_0_g185;
				float phase15_g186 = temp_output_24_0_g186;
				float time15_g186 = temp_output_25_0_g186;
				float gravity15_g186 = temp_output_26_0_g186;
				float depth15_g186 = temp_output_27_0_g186;
				float amplitude15_g186 = temp_output_74_0_g185;
				float3 result15_g186 = float3( 0,0,0 );
				gerstner_float( position15_g186 , direction15_g186 , phase15_g186 , time15_g186 , gravity15_g186 , depth15_g186 , amplitude15_g186 , result15_g186 );
				float3 worldToObj156_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g186 + result9_g186 ) + ( result14_g186 + result15_g186 ) ) + temp_output_23_0_g186 ), 1 ) ).xyz;
				float3 temp_output_3_0_g188 = worldToObj155_g185;
				float3 normalizeResult8_g188 = normalize( ( worldToObj156_g185 - temp_output_3_0_g188 ) );
				float localgerstner4_g187 = ( 0.0 );
				float3 appendResult136_g185 = (float3(0.0 , 0.0 , temp_output_143_0_g185));
				float3 temp_output_23_0_g187 = ( ase_worldPos + appendResult136_g185 );
				float3 position4_g187 = temp_output_23_0_g187;
				float3 direction4_g187 = temp_output_79_0_g185;
				float temp_output_24_0_g187 = temp_output_82_0_g185;
				float phase4_g187 = temp_output_24_0_g187;
				float temp_output_25_0_g187 = _TimeParameters.x;
				float time4_g187 = temp_output_25_0_g187;
				float temp_output_26_0_g187 = temp_output_81_0_g185;
				float gravity4_g187 = temp_output_26_0_g187;
				float temp_output_27_0_g187 = temp_output_80_0_g185;
				float depth4_g187 = temp_output_27_0_g187;
				float amplitude4_g187 = temp_output_84_0_g185;
				float3 result4_g187 = float3( 0,0,0 );
				gerstner_float( position4_g187 , direction4_g187 , phase4_g187 , time4_g187 , gravity4_g187 , depth4_g187 , amplitude4_g187 , result4_g187 );
				float localgerstner9_g187 = ( 0.0 );
				float3 position9_g187 = temp_output_23_0_g187;
				float3 direction9_g187 = temp_output_78_0_g185;
				float phase9_g187 = temp_output_24_0_g187;
				float time9_g187 = temp_output_25_0_g187;
				float gravity9_g187 = temp_output_26_0_g187;
				float depth9_g187 = temp_output_27_0_g187;
				float amplitude9_g187 = temp_output_73_0_g185;
				float3 result9_g187 = float3( 0,0,0 );
				gerstner_float( position9_g187 , direction9_g187 , phase9_g187 , time9_g187 , gravity9_g187 , depth9_g187 , amplitude9_g187 , result9_g187 );
				float localgerstner14_g187 = ( 0.0 );
				float3 position14_g187 = temp_output_23_0_g187;
				float3 direction14_g187 = temp_output_77_0_g185;
				float phase14_g187 = temp_output_24_0_g187;
				float time14_g187 = temp_output_25_0_g187;
				float gravity14_g187 = temp_output_26_0_g187;
				float depth14_g187 = temp_output_27_0_g187;
				float amplitude14_g187 = temp_output_75_0_g185;
				float3 result14_g187 = float3( 0,0,0 );
				gerstner_float( position14_g187 , direction14_g187 , phase14_g187 , time14_g187 , gravity14_g187 , depth14_g187 , amplitude14_g187 , result14_g187 );
				float localgerstner15_g187 = ( 0.0 );
				float3 position15_g187 = temp_output_23_0_g187;
				float3 direction15_g187 = temp_output_76_0_g185;
				float phase15_g187 = temp_output_24_0_g187;
				float time15_g187 = temp_output_25_0_g187;
				float gravity15_g187 = temp_output_26_0_g187;
				float depth15_g187 = temp_output_27_0_g187;
				float amplitude15_g187 = temp_output_74_0_g185;
				float3 result15_g187 = float3( 0,0,0 );
				gerstner_float( position15_g187 , direction15_g187 , phase15_g187 , time15_g187 , gravity15_g187 , depth15_g187 , amplitude15_g187 , result15_g187 );
				float3 worldToObj164_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g187 + result9_g187 ) + ( result14_g187 + result15_g187 ) ) + temp_output_23_0_g187 ), 1 ) ).xyz;
				float3 normalizeResult9_g188 = normalize( ( temp_output_3_0_g188 - worldToObj164_g185 ) );
				float3 normalizeResult11_g188 = normalize( cross( normalizeResult8_g188 , normalizeResult9_g188 ) );
				float3 GerstNorm134 = normalizeResult11_g188;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = GerstPos132;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = GerstNorm134;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float4 screenPos = IN.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth11_g132 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth11_g132 = saturate( abs( ( screenDepth11_g132 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _ColorDepth ) ) );
				float temp_output_298_0 = ( 1.0 - distanceDepth11_g132 );
				float smoothstepResult91 = smoothstep( 0.0 , 0.2 , (1.0 + (temp_output_298_0 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
				float2 temp_cast_0 = (_TimeParameters.x).xx;
				float2 texCoord117 = IN.ase_texcoord3.xy * float2( 1,1 ) + temp_cast_0;
				float simplePerlin2D287 = snoise( texCoord117*0.2 );
				simplePerlin2D287 = simplePerlin2D287*0.5 + 0.5;
				float clampResult107 = clamp( ( ( ( 1.0 - pow( ( 1.0 / 1000.0 ) , temp_output_298_0 ) ) * sin( ( ( temp_output_298_0 * 100.0 ) + ( 4.0 * _TimeParameters.x ) ) ) ) * ( simplePerlin2D287 + 0.7 ) ) , 0.0 , 0.9 );
				float lerpResult143 = lerp( _WaveRiseThershold , 1.0 , _WaveRiseFallback);
				float2 texCoord118 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float cos121 = cos( radians( _Roataion ) );
				float sin121 = sin( radians( _Roataion ) );
				float2 rotator121 = mul( texCoord118 - float2( 0.5,0.5 ) , float2x2( cos121 , -sin121 , sin121 , cos121 )) + float2( 0.5,0.5 );
				float simplePerlin2D126 = snoise( rotator121*0.5 );
				simplePerlin2D126 = simplePerlin2D126*0.5 + 0.5;
				float localgerstner4_g186 = ( 0.0 );
				float temp_output_143_0_g185 = _NeighbourDistance;
				float3 appendResult142_g185 = (float3(temp_output_143_0_g185 , 0.0 , 0.0));
				float3 temp_output_23_0_g186 = ( WorldPosition + appendResult142_g185 );
				float3 position4_g186 = temp_output_23_0_g186;
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_79_0_g185 = rotatedValue387;
				float3 direction4_g186 = temp_output_79_0_g185;
				float temp_output_82_0_g185 = _Phase;
				float temp_output_24_0_g186 = temp_output_82_0_g185;
				float phase4_g186 = temp_output_24_0_g186;
				float temp_output_25_0_g186 = _TimeParameters.x;
				float time4_g186 = temp_output_25_0_g186;
				float temp_output_81_0_g185 = _Gravity;
				float temp_output_26_0_g186 = temp_output_81_0_g185;
				float gravity4_g186 = temp_output_26_0_g186;
				float temp_output_80_0_g185 = _Depth;
				float temp_output_27_0_g186 = temp_output_80_0_g185;
				float depth4_g186 = temp_output_27_0_g186;
				float temp_output_84_0_g185 = ( _Amplitude1 * _Intensity );
				float amplitude4_g186 = temp_output_84_0_g185;
				float3 result4_g186 = float3( 0,0,0 );
				gerstner_float( position4_g186 , direction4_g186 , phase4_g186 , time4_g186 , gravity4_g186 , depth4_g186 , amplitude4_g186 , result4_g186 );
				float localgerstner9_g186 = ( 0.0 );
				float3 position9_g186 = temp_output_23_0_g186;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_78_0_g185 = rotatedValue64;
				float3 direction9_g186 = temp_output_78_0_g185;
				float phase9_g186 = temp_output_24_0_g186;
				float time9_g186 = temp_output_25_0_g186;
				float gravity9_g186 = temp_output_26_0_g186;
				float depth9_g186 = temp_output_27_0_g186;
				float temp_output_73_0_g185 = ( _Intensity * _Amplitude2 );
				float amplitude9_g186 = temp_output_73_0_g185;
				float3 result9_g186 = float3( 0,0,0 );
				gerstner_float( position9_g186 , direction9_g186 , phase9_g186 , time9_g186 , gravity9_g186 , depth9_g186 , amplitude9_g186 , result9_g186 );
				float localgerstner14_g186 = ( 0.0 );
				float3 position14_g186 = temp_output_23_0_g186;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_77_0_g185 = rotatedValue65;
				float3 direction14_g186 = temp_output_77_0_g185;
				float phase14_g186 = temp_output_24_0_g186;
				float time14_g186 = temp_output_25_0_g186;
				float gravity14_g186 = temp_output_26_0_g186;
				float depth14_g186 = temp_output_27_0_g186;
				float temp_output_75_0_g185 = ( _Intensity * _Amplitude3 );
				float amplitude14_g186 = temp_output_75_0_g185;
				float3 result14_g186 = float3( 0,0,0 );
				gerstner_float( position14_g186 , direction14_g186 , phase14_g186 , time14_g186 , gravity14_g186 , depth14_g186 , amplitude14_g186 , result14_g186 );
				float localgerstner15_g186 = ( 0.0 );
				float3 position15_g186 = temp_output_23_0_g186;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_76_0_g185 = rotatedValue66;
				float3 direction15_g186 = temp_output_76_0_g185;
				float phase15_g186 = temp_output_24_0_g186;
				float time15_g186 = temp_output_25_0_g186;
				float gravity15_g186 = temp_output_26_0_g186;
				float depth15_g186 = temp_output_27_0_g186;
				float temp_output_74_0_g185 = ( _Amplitude4 * _Intensity );
				float amplitude15_g186 = temp_output_74_0_g185;
				float3 result15_g186 = float3( 0,0,0 );
				gerstner_float( position15_g186 , direction15_g186 , phase15_g186 , time15_g186 , gravity15_g186 , depth15_g186 , amplitude15_g186 , result15_g186 );
				float3 worldToObj156_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g186 + result9_g186 ) + ( result14_g186 + result15_g186 ) ) + temp_output_23_0_g186 ), 1 ) ).xyz;
				float localgerstner4_g189 = ( 0.0 );
				float3 appendResult69_g185 = (float3(0.0 , temp_output_143_0_g185 , 0.0));
				float3 temp_output_23_0_g189 = ( WorldPosition + appendResult69_g185 );
				float3 position4_g189 = temp_output_23_0_g189;
				float3 direction4_g189 = temp_output_79_0_g185;
				float temp_output_24_0_g189 = temp_output_82_0_g185;
				float phase4_g189 = temp_output_24_0_g189;
				float temp_output_25_0_g189 = _TimeParameters.x;
				float time4_g189 = temp_output_25_0_g189;
				float temp_output_26_0_g189 = temp_output_81_0_g185;
				float gravity4_g189 = temp_output_26_0_g189;
				float temp_output_27_0_g189 = temp_output_80_0_g185;
				float depth4_g189 = temp_output_27_0_g189;
				float amplitude4_g189 = temp_output_84_0_g185;
				float3 result4_g189 = float3( 0,0,0 );
				gerstner_float( position4_g189 , direction4_g189 , phase4_g189 , time4_g189 , gravity4_g189 , depth4_g189 , amplitude4_g189 , result4_g189 );
				float localgerstner9_g189 = ( 0.0 );
				float3 position9_g189 = temp_output_23_0_g189;
				float3 direction9_g189 = temp_output_78_0_g185;
				float phase9_g189 = temp_output_24_0_g189;
				float time9_g189 = temp_output_25_0_g189;
				float gravity9_g189 = temp_output_26_0_g189;
				float depth9_g189 = temp_output_27_0_g189;
				float amplitude9_g189 = temp_output_73_0_g185;
				float3 result9_g189 = float3( 0,0,0 );
				gerstner_float( position9_g189 , direction9_g189 , phase9_g189 , time9_g189 , gravity9_g189 , depth9_g189 , amplitude9_g189 , result9_g189 );
				float localgerstner14_g189 = ( 0.0 );
				float3 position14_g189 = temp_output_23_0_g189;
				float3 direction14_g189 = temp_output_77_0_g185;
				float phase14_g189 = temp_output_24_0_g189;
				float time14_g189 = temp_output_25_0_g189;
				float gravity14_g189 = temp_output_26_0_g189;
				float depth14_g189 = temp_output_27_0_g189;
				float amplitude14_g189 = temp_output_75_0_g185;
				float3 result14_g189 = float3( 0,0,0 );
				gerstner_float( position14_g189 , direction14_g189 , phase14_g189 , time14_g189 , gravity14_g189 , depth14_g189 , amplitude14_g189 , result14_g189 );
				float localgerstner15_g189 = ( 0.0 );
				float3 position15_g189 = temp_output_23_0_g189;
				float3 direction15_g189 = temp_output_76_0_g185;
				float phase15_g189 = temp_output_24_0_g189;
				float time15_g189 = temp_output_25_0_g189;
				float gravity15_g189 = temp_output_26_0_g189;
				float depth15_g189 = temp_output_27_0_g189;
				float amplitude15_g189 = temp_output_74_0_g185;
				float3 result15_g189 = float3( 0,0,0 );
				gerstner_float( position15_g189 , direction15_g189 , phase15_g189 , time15_g189 , gravity15_g189 , depth15_g189 , amplitude15_g189 , result15_g189 );
				float3 worldToObj155_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g189 + result9_g189 ) + ( result14_g189 + result15_g189 ) ) + temp_output_23_0_g189 ), 1 ) ).xyz;
				float3 temp_output_3_0_g188 = worldToObj155_g185;
				float3 normalizeResult8_g188 = normalize( ( worldToObj156_g185 - temp_output_3_0_g188 ) );
				float localgerstner4_g187 = ( 0.0 );
				float3 appendResult136_g185 = (float3(0.0 , 0.0 , temp_output_143_0_g185));
				float3 temp_output_23_0_g187 = ( WorldPosition + appendResult136_g185 );
				float3 position4_g187 = temp_output_23_0_g187;
				float3 direction4_g187 = temp_output_79_0_g185;
				float temp_output_24_0_g187 = temp_output_82_0_g185;
				float phase4_g187 = temp_output_24_0_g187;
				float temp_output_25_0_g187 = _TimeParameters.x;
				float time4_g187 = temp_output_25_0_g187;
				float temp_output_26_0_g187 = temp_output_81_0_g185;
				float gravity4_g187 = temp_output_26_0_g187;
				float temp_output_27_0_g187 = temp_output_80_0_g185;
				float depth4_g187 = temp_output_27_0_g187;
				float amplitude4_g187 = temp_output_84_0_g185;
				float3 result4_g187 = float3( 0,0,0 );
				gerstner_float( position4_g187 , direction4_g187 , phase4_g187 , time4_g187 , gravity4_g187 , depth4_g187 , amplitude4_g187 , result4_g187 );
				float localgerstner9_g187 = ( 0.0 );
				float3 position9_g187 = temp_output_23_0_g187;
				float3 direction9_g187 = temp_output_78_0_g185;
				float phase9_g187 = temp_output_24_0_g187;
				float time9_g187 = temp_output_25_0_g187;
				float gravity9_g187 = temp_output_26_0_g187;
				float depth9_g187 = temp_output_27_0_g187;
				float amplitude9_g187 = temp_output_73_0_g185;
				float3 result9_g187 = float3( 0,0,0 );
				gerstner_float( position9_g187 , direction9_g187 , phase9_g187 , time9_g187 , gravity9_g187 , depth9_g187 , amplitude9_g187 , result9_g187 );
				float localgerstner14_g187 = ( 0.0 );
				float3 position14_g187 = temp_output_23_0_g187;
				float3 direction14_g187 = temp_output_77_0_g185;
				float phase14_g187 = temp_output_24_0_g187;
				float time14_g187 = temp_output_25_0_g187;
				float gravity14_g187 = temp_output_26_0_g187;
				float depth14_g187 = temp_output_27_0_g187;
				float amplitude14_g187 = temp_output_75_0_g185;
				float3 result14_g187 = float3( 0,0,0 );
				gerstner_float( position14_g187 , direction14_g187 , phase14_g187 , time14_g187 , gravity14_g187 , depth14_g187 , amplitude14_g187 , result14_g187 );
				float localgerstner15_g187 = ( 0.0 );
				float3 position15_g187 = temp_output_23_0_g187;
				float3 direction15_g187 = temp_output_76_0_g185;
				float phase15_g187 = temp_output_24_0_g187;
				float time15_g187 = temp_output_25_0_g187;
				float gravity15_g187 = temp_output_26_0_g187;
				float depth15_g187 = temp_output_27_0_g187;
				float amplitude15_g187 = temp_output_74_0_g185;
				float3 result15_g187 = float3( 0,0,0 );
				gerstner_float( position15_g187 , direction15_g187 , phase15_g187 , time15_g187 , gravity15_g187 , depth15_g187 , amplitude15_g187 , result15_g187 );
				float3 worldToObj164_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g187 + result9_g187 ) + ( result14_g187 + result15_g187 ) ) + temp_output_23_0_g187 ), 1 ) ).xyz;
				float3 normalizeResult9_g188 = normalize( ( temp_output_3_0_g188 - worldToObj164_g185 ) );
				float3 normalizeResult11_g188 = normalize( cross( normalizeResult8_g188 , normalizeResult9_g188 ) );
				float3 GerstNorm134 = normalizeResult11_g188;
				float dotResult130 = dot( GerstNorm134 , float3( 0,0,1 ) );
				float2 temp_cast_1 = (_TimeParameters.x).xx;
				float2 texCoord140 = IN.ase_texcoord3.xy * float2( 1,1 ) + temp_cast_1;
				float simplePerlin2D138 = snoise( texCoord140*0.02 );
				simplePerlin2D138 = simplePerlin2D138*0.5 + 0.5;
				float smoothstepResult147 = smoothstep( _WaveRiseThershold , lerpResult143 , ( ( (-0.1 + (simplePerlin2D126 - 0.0) * (0.1 - -0.1) / (1.0 - 0.0)) + (1.0 + (dotResult130 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) + (-0.2 + (simplePerlin2D138 - 0.0) * (0.2 - -0.2) / (1.0 - 0.0)) ));
				float waterRise149 = smoothstepResult147;
				float foam153 = step( 0.4 , ( ( ( 1.0 - smoothstepResult91 ) * clampResult107 ) + waterRise149 ) );
				float4 lerpResult284 = lerp( _ShallowColor , _DeepColor , foam153);
				
				float WaterDepth187 = temp_output_298_0;
				

				float3 BaseColor = lerpResult284.rgb;
				float Alpha = ( ( ( 1.0 - WaterDepth187 ) * _WaterThickness ) + foam153 );
				float AlphaClipThreshold = 0.5;

				half4 color = half4(BaseColor, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormalsOnly" }

			ZWrite On
			Blend One Zero
			ZTest LEqual
			ZWrite On

			HLSLPROGRAM

			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_DISTANCE_TESSELLATION
			#define _SPECULAR_SETUP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_DEPTH_WRITE_ON
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#include "../../CustomFunctions/GerstnerWave.hlsl"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SCREEN_POSITION


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 clipPos : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float4 worldTangent : TEXCOORD2;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD3;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD4;
				#endif
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Emission;
			float4 _NormalTexture2_ST;
			float4 _NormalTexture1_ST;
			float4 _DeepColor;
			float4 _FoamEmmision;
			float4 _ShallowColor;
			float3 _Direction4;
			float3 _Direction1;
			float3 _Direction2;
			float3 _Direction3;
			float _PanSpeed;
			float _WaveRiseFallback;
			float _WaveRiseThershold;
			float _ColorDepth;
			float _NeighbourDistance;
			float _Amplitude3;
			float _Amplitude2;
			float _Intensity;
			float _Amplitude1;
			float _Depth;
			float _Gravity;
			float _Phase;
			float _Roataion;
			float _Amplitude4;
			float _WaterThickness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _NormalTexture1;
			sampler2D _NormalTexture2;
			uniform float4 _CameraDepthTexture_TexelSize;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float localgerstner4_g189 = ( 0.0 );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float temp_output_143_0_g185 = _NeighbourDistance;
				float3 appendResult69_g185 = (float3(0.0 , temp_output_143_0_g185 , 0.0));
				float3 temp_output_23_0_g189 = ( ase_worldPos + appendResult69_g185 );
				float3 position4_g189 = temp_output_23_0_g189;
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_79_0_g185 = rotatedValue387;
				float3 direction4_g189 = temp_output_79_0_g185;
				float temp_output_82_0_g185 = _Phase;
				float temp_output_24_0_g189 = temp_output_82_0_g185;
				float phase4_g189 = temp_output_24_0_g189;
				float temp_output_25_0_g189 = _TimeParameters.x;
				float time4_g189 = temp_output_25_0_g189;
				float temp_output_81_0_g185 = _Gravity;
				float temp_output_26_0_g189 = temp_output_81_0_g185;
				float gravity4_g189 = temp_output_26_0_g189;
				float temp_output_80_0_g185 = _Depth;
				float temp_output_27_0_g189 = temp_output_80_0_g185;
				float depth4_g189 = temp_output_27_0_g189;
				float temp_output_84_0_g185 = ( _Amplitude1 * _Intensity );
				float amplitude4_g189 = temp_output_84_0_g185;
				float3 result4_g189 = float3( 0,0,0 );
				gerstner_float( position4_g189 , direction4_g189 , phase4_g189 , time4_g189 , gravity4_g189 , depth4_g189 , amplitude4_g189 , result4_g189 );
				float localgerstner9_g189 = ( 0.0 );
				float3 position9_g189 = temp_output_23_0_g189;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_78_0_g185 = rotatedValue64;
				float3 direction9_g189 = temp_output_78_0_g185;
				float phase9_g189 = temp_output_24_0_g189;
				float time9_g189 = temp_output_25_0_g189;
				float gravity9_g189 = temp_output_26_0_g189;
				float depth9_g189 = temp_output_27_0_g189;
				float temp_output_73_0_g185 = ( _Intensity * _Amplitude2 );
				float amplitude9_g189 = temp_output_73_0_g185;
				float3 result9_g189 = float3( 0,0,0 );
				gerstner_float( position9_g189 , direction9_g189 , phase9_g189 , time9_g189 , gravity9_g189 , depth9_g189 , amplitude9_g189 , result9_g189 );
				float localgerstner14_g189 = ( 0.0 );
				float3 position14_g189 = temp_output_23_0_g189;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_77_0_g185 = rotatedValue65;
				float3 direction14_g189 = temp_output_77_0_g185;
				float phase14_g189 = temp_output_24_0_g189;
				float time14_g189 = temp_output_25_0_g189;
				float gravity14_g189 = temp_output_26_0_g189;
				float depth14_g189 = temp_output_27_0_g189;
				float temp_output_75_0_g185 = ( _Intensity * _Amplitude3 );
				float amplitude14_g189 = temp_output_75_0_g185;
				float3 result14_g189 = float3( 0,0,0 );
				gerstner_float( position14_g189 , direction14_g189 , phase14_g189 , time14_g189 , gravity14_g189 , depth14_g189 , amplitude14_g189 , result14_g189 );
				float localgerstner15_g189 = ( 0.0 );
				float3 position15_g189 = temp_output_23_0_g189;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_76_0_g185 = rotatedValue66;
				float3 direction15_g189 = temp_output_76_0_g185;
				float phase15_g189 = temp_output_24_0_g189;
				float time15_g189 = temp_output_25_0_g189;
				float gravity15_g189 = temp_output_26_0_g189;
				float depth15_g189 = temp_output_27_0_g189;
				float temp_output_74_0_g185 = ( _Amplitude4 * _Intensity );
				float amplitude15_g189 = temp_output_74_0_g185;
				float3 result15_g189 = float3( 0,0,0 );
				gerstner_float( position15_g189 , direction15_g189 , phase15_g189 , time15_g189 , gravity15_g189 , depth15_g189 , amplitude15_g189 , result15_g189 );
				float3 worldToObj155_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g189 + result9_g189 ) + ( result14_g189 + result15_g189 ) ) + temp_output_23_0_g189 ), 1 ) ).xyz;
				float3 GerstPos132 = worldToObj155_g185;
				
				float localgerstner4_g186 = ( 0.0 );
				float3 appendResult142_g185 = (float3(temp_output_143_0_g185 , 0.0 , 0.0));
				float3 temp_output_23_0_g186 = ( ase_worldPos + appendResult142_g185 );
				float3 position4_g186 = temp_output_23_0_g186;
				float3 direction4_g186 = temp_output_79_0_g185;
				float temp_output_24_0_g186 = temp_output_82_0_g185;
				float phase4_g186 = temp_output_24_0_g186;
				float temp_output_25_0_g186 = _TimeParameters.x;
				float time4_g186 = temp_output_25_0_g186;
				float temp_output_26_0_g186 = temp_output_81_0_g185;
				float gravity4_g186 = temp_output_26_0_g186;
				float temp_output_27_0_g186 = temp_output_80_0_g185;
				float depth4_g186 = temp_output_27_0_g186;
				float amplitude4_g186 = temp_output_84_0_g185;
				float3 result4_g186 = float3( 0,0,0 );
				gerstner_float( position4_g186 , direction4_g186 , phase4_g186 , time4_g186 , gravity4_g186 , depth4_g186 , amplitude4_g186 , result4_g186 );
				float localgerstner9_g186 = ( 0.0 );
				float3 position9_g186 = temp_output_23_0_g186;
				float3 direction9_g186 = temp_output_78_0_g185;
				float phase9_g186 = temp_output_24_0_g186;
				float time9_g186 = temp_output_25_0_g186;
				float gravity9_g186 = temp_output_26_0_g186;
				float depth9_g186 = temp_output_27_0_g186;
				float amplitude9_g186 = temp_output_73_0_g185;
				float3 result9_g186 = float3( 0,0,0 );
				gerstner_float( position9_g186 , direction9_g186 , phase9_g186 , time9_g186 , gravity9_g186 , depth9_g186 , amplitude9_g186 , result9_g186 );
				float localgerstner14_g186 = ( 0.0 );
				float3 position14_g186 = temp_output_23_0_g186;
				float3 direction14_g186 = temp_output_77_0_g185;
				float phase14_g186 = temp_output_24_0_g186;
				float time14_g186 = temp_output_25_0_g186;
				float gravity14_g186 = temp_output_26_0_g186;
				float depth14_g186 = temp_output_27_0_g186;
				float amplitude14_g186 = temp_output_75_0_g185;
				float3 result14_g186 = float3( 0,0,0 );
				gerstner_float( position14_g186 , direction14_g186 , phase14_g186 , time14_g186 , gravity14_g186 , depth14_g186 , amplitude14_g186 , result14_g186 );
				float localgerstner15_g186 = ( 0.0 );
				float3 position15_g186 = temp_output_23_0_g186;
				float3 direction15_g186 = temp_output_76_0_g185;
				float phase15_g186 = temp_output_24_0_g186;
				float time15_g186 = temp_output_25_0_g186;
				float gravity15_g186 = temp_output_26_0_g186;
				float depth15_g186 = temp_output_27_0_g186;
				float amplitude15_g186 = temp_output_74_0_g185;
				float3 result15_g186 = float3( 0,0,0 );
				gerstner_float( position15_g186 , direction15_g186 , phase15_g186 , time15_g186 , gravity15_g186 , depth15_g186 , amplitude15_g186 , result15_g186 );
				float3 worldToObj156_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g186 + result9_g186 ) + ( result14_g186 + result15_g186 ) ) + temp_output_23_0_g186 ), 1 ) ).xyz;
				float3 temp_output_3_0_g188 = worldToObj155_g185;
				float3 normalizeResult8_g188 = normalize( ( worldToObj156_g185 - temp_output_3_0_g188 ) );
				float localgerstner4_g187 = ( 0.0 );
				float3 appendResult136_g185 = (float3(0.0 , 0.0 , temp_output_143_0_g185));
				float3 temp_output_23_0_g187 = ( ase_worldPos + appendResult136_g185 );
				float3 position4_g187 = temp_output_23_0_g187;
				float3 direction4_g187 = temp_output_79_0_g185;
				float temp_output_24_0_g187 = temp_output_82_0_g185;
				float phase4_g187 = temp_output_24_0_g187;
				float temp_output_25_0_g187 = _TimeParameters.x;
				float time4_g187 = temp_output_25_0_g187;
				float temp_output_26_0_g187 = temp_output_81_0_g185;
				float gravity4_g187 = temp_output_26_0_g187;
				float temp_output_27_0_g187 = temp_output_80_0_g185;
				float depth4_g187 = temp_output_27_0_g187;
				float amplitude4_g187 = temp_output_84_0_g185;
				float3 result4_g187 = float3( 0,0,0 );
				gerstner_float( position4_g187 , direction4_g187 , phase4_g187 , time4_g187 , gravity4_g187 , depth4_g187 , amplitude4_g187 , result4_g187 );
				float localgerstner9_g187 = ( 0.0 );
				float3 position9_g187 = temp_output_23_0_g187;
				float3 direction9_g187 = temp_output_78_0_g185;
				float phase9_g187 = temp_output_24_0_g187;
				float time9_g187 = temp_output_25_0_g187;
				float gravity9_g187 = temp_output_26_0_g187;
				float depth9_g187 = temp_output_27_0_g187;
				float amplitude9_g187 = temp_output_73_0_g185;
				float3 result9_g187 = float3( 0,0,0 );
				gerstner_float( position9_g187 , direction9_g187 , phase9_g187 , time9_g187 , gravity9_g187 , depth9_g187 , amplitude9_g187 , result9_g187 );
				float localgerstner14_g187 = ( 0.0 );
				float3 position14_g187 = temp_output_23_0_g187;
				float3 direction14_g187 = temp_output_77_0_g185;
				float phase14_g187 = temp_output_24_0_g187;
				float time14_g187 = temp_output_25_0_g187;
				float gravity14_g187 = temp_output_26_0_g187;
				float depth14_g187 = temp_output_27_0_g187;
				float amplitude14_g187 = temp_output_75_0_g185;
				float3 result14_g187 = float3( 0,0,0 );
				gerstner_float( position14_g187 , direction14_g187 , phase14_g187 , time14_g187 , gravity14_g187 , depth14_g187 , amplitude14_g187 , result14_g187 );
				float localgerstner15_g187 = ( 0.0 );
				float3 position15_g187 = temp_output_23_0_g187;
				float3 direction15_g187 = temp_output_76_0_g185;
				float phase15_g187 = temp_output_24_0_g187;
				float time15_g187 = temp_output_25_0_g187;
				float gravity15_g187 = temp_output_26_0_g187;
				float depth15_g187 = temp_output_27_0_g187;
				float amplitude15_g187 = temp_output_74_0_g185;
				float3 result15_g187 = float3( 0,0,0 );
				gerstner_float( position15_g187 , direction15_g187 , phase15_g187 , time15_g187 , gravity15_g187 , depth15_g187 , amplitude15_g187 , result15_g187 );
				float3 worldToObj164_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g187 + result9_g187 ) + ( result14_g187 + result15_g187 ) ) + temp_output_23_0_g187 ), 1 ) ).xyz;
				float3 normalizeResult9_g188 = normalize( ( temp_output_3_0_g188 - worldToObj164_g185 ) );
				float3 normalizeResult11_g188 = normalize( cross( normalizeResult8_g188 , normalizeResult9_g188 ) );
				float3 GerstNorm134 = normalizeResult11_g188;
				
				o.ase_texcoord5.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord5.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = GerstPos132;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = GerstNorm134;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal( v.ase_normal );
				float4 tangentWS = float4(TransformObjectToWorldDir( v.ase_tangent.xyz), v.ase_tangent.w);
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				o.worldNormal = normalWS;
				o.worldTangent = tangentWS;

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				o.clipPosV = positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			void frag(	VertexOutput IN
						, out half4 outNormalWS : SV_Target0
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						, out float4 outRenderingLayers : SV_Target1
						#endif
						 )
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				float3 WorldNormal = IN.worldNormal;
				float4 WorldTangent = IN.worldTangent;

				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 appendResult415 = (float2(WorldPosition.x , WorldPosition.y));
				float2 texCoord394 = IN.ase_texcoord5.xy * _NormalTexture1_ST.xy + ( ( ( float2( 0.4,1.17 ) * _PanSpeed ) * _TimeParameters.x ) + appendResult415 );
				float2 texCoord390 = IN.ase_texcoord5.xy * _NormalTexture2_ST.xy + ( appendResult415 + ( _TimeParameters.x * ( _PanSpeed * float2( -0.5,0.2 ) ) ) );
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth11_g132 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth11_g132 = saturate( abs( ( screenDepth11_g132 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _ColorDepth ) ) );
				float temp_output_298_0 = ( 1.0 - distanceDepth11_g132 );
				float smoothstepResult91 = smoothstep( 0.0 , 0.2 , (1.0 + (temp_output_298_0 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
				float2 temp_cast_0 = (_TimeParameters.x).xx;
				float2 texCoord117 = IN.ase_texcoord5.xy * float2( 1,1 ) + temp_cast_0;
				float simplePerlin2D287 = snoise( texCoord117*0.2 );
				simplePerlin2D287 = simplePerlin2D287*0.5 + 0.5;
				float clampResult107 = clamp( ( ( ( 1.0 - pow( ( 1.0 / 1000.0 ) , temp_output_298_0 ) ) * sin( ( ( temp_output_298_0 * 100.0 ) + ( 4.0 * _TimeParameters.x ) ) ) ) * ( simplePerlin2D287 + 0.7 ) ) , 0.0 , 0.9 );
				float lerpResult143 = lerp( _WaveRiseThershold , 1.0 , _WaveRiseFallback);
				float2 texCoord118 = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float cos121 = cos( radians( _Roataion ) );
				float sin121 = sin( radians( _Roataion ) );
				float2 rotator121 = mul( texCoord118 - float2( 0.5,0.5 ) , float2x2( cos121 , -sin121 , sin121 , cos121 )) + float2( 0.5,0.5 );
				float simplePerlin2D126 = snoise( rotator121*0.5 );
				simplePerlin2D126 = simplePerlin2D126*0.5 + 0.5;
				float localgerstner4_g186 = ( 0.0 );
				float temp_output_143_0_g185 = _NeighbourDistance;
				float3 appendResult142_g185 = (float3(temp_output_143_0_g185 , 0.0 , 0.0));
				float3 temp_output_23_0_g186 = ( WorldPosition + appendResult142_g185 );
				float3 position4_g186 = temp_output_23_0_g186;
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_79_0_g185 = rotatedValue387;
				float3 direction4_g186 = temp_output_79_0_g185;
				float temp_output_82_0_g185 = _Phase;
				float temp_output_24_0_g186 = temp_output_82_0_g185;
				float phase4_g186 = temp_output_24_0_g186;
				float temp_output_25_0_g186 = _TimeParameters.x;
				float time4_g186 = temp_output_25_0_g186;
				float temp_output_81_0_g185 = _Gravity;
				float temp_output_26_0_g186 = temp_output_81_0_g185;
				float gravity4_g186 = temp_output_26_0_g186;
				float temp_output_80_0_g185 = _Depth;
				float temp_output_27_0_g186 = temp_output_80_0_g185;
				float depth4_g186 = temp_output_27_0_g186;
				float temp_output_84_0_g185 = ( _Amplitude1 * _Intensity );
				float amplitude4_g186 = temp_output_84_0_g185;
				float3 result4_g186 = float3( 0,0,0 );
				gerstner_float( position4_g186 , direction4_g186 , phase4_g186 , time4_g186 , gravity4_g186 , depth4_g186 , amplitude4_g186 , result4_g186 );
				float localgerstner9_g186 = ( 0.0 );
				float3 position9_g186 = temp_output_23_0_g186;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_78_0_g185 = rotatedValue64;
				float3 direction9_g186 = temp_output_78_0_g185;
				float phase9_g186 = temp_output_24_0_g186;
				float time9_g186 = temp_output_25_0_g186;
				float gravity9_g186 = temp_output_26_0_g186;
				float depth9_g186 = temp_output_27_0_g186;
				float temp_output_73_0_g185 = ( _Intensity * _Amplitude2 );
				float amplitude9_g186 = temp_output_73_0_g185;
				float3 result9_g186 = float3( 0,0,0 );
				gerstner_float( position9_g186 , direction9_g186 , phase9_g186 , time9_g186 , gravity9_g186 , depth9_g186 , amplitude9_g186 , result9_g186 );
				float localgerstner14_g186 = ( 0.0 );
				float3 position14_g186 = temp_output_23_0_g186;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_77_0_g185 = rotatedValue65;
				float3 direction14_g186 = temp_output_77_0_g185;
				float phase14_g186 = temp_output_24_0_g186;
				float time14_g186 = temp_output_25_0_g186;
				float gravity14_g186 = temp_output_26_0_g186;
				float depth14_g186 = temp_output_27_0_g186;
				float temp_output_75_0_g185 = ( _Intensity * _Amplitude3 );
				float amplitude14_g186 = temp_output_75_0_g185;
				float3 result14_g186 = float3( 0,0,0 );
				gerstner_float( position14_g186 , direction14_g186 , phase14_g186 , time14_g186 , gravity14_g186 , depth14_g186 , amplitude14_g186 , result14_g186 );
				float localgerstner15_g186 = ( 0.0 );
				float3 position15_g186 = temp_output_23_0_g186;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_76_0_g185 = rotatedValue66;
				float3 direction15_g186 = temp_output_76_0_g185;
				float phase15_g186 = temp_output_24_0_g186;
				float time15_g186 = temp_output_25_0_g186;
				float gravity15_g186 = temp_output_26_0_g186;
				float depth15_g186 = temp_output_27_0_g186;
				float temp_output_74_0_g185 = ( _Amplitude4 * _Intensity );
				float amplitude15_g186 = temp_output_74_0_g185;
				float3 result15_g186 = float3( 0,0,0 );
				gerstner_float( position15_g186 , direction15_g186 , phase15_g186 , time15_g186 , gravity15_g186 , depth15_g186 , amplitude15_g186 , result15_g186 );
				float3 worldToObj156_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g186 + result9_g186 ) + ( result14_g186 + result15_g186 ) ) + temp_output_23_0_g186 ), 1 ) ).xyz;
				float localgerstner4_g189 = ( 0.0 );
				float3 appendResult69_g185 = (float3(0.0 , temp_output_143_0_g185 , 0.0));
				float3 temp_output_23_0_g189 = ( WorldPosition + appendResult69_g185 );
				float3 position4_g189 = temp_output_23_0_g189;
				float3 direction4_g189 = temp_output_79_0_g185;
				float temp_output_24_0_g189 = temp_output_82_0_g185;
				float phase4_g189 = temp_output_24_0_g189;
				float temp_output_25_0_g189 = _TimeParameters.x;
				float time4_g189 = temp_output_25_0_g189;
				float temp_output_26_0_g189 = temp_output_81_0_g185;
				float gravity4_g189 = temp_output_26_0_g189;
				float temp_output_27_0_g189 = temp_output_80_0_g185;
				float depth4_g189 = temp_output_27_0_g189;
				float amplitude4_g189 = temp_output_84_0_g185;
				float3 result4_g189 = float3( 0,0,0 );
				gerstner_float( position4_g189 , direction4_g189 , phase4_g189 , time4_g189 , gravity4_g189 , depth4_g189 , amplitude4_g189 , result4_g189 );
				float localgerstner9_g189 = ( 0.0 );
				float3 position9_g189 = temp_output_23_0_g189;
				float3 direction9_g189 = temp_output_78_0_g185;
				float phase9_g189 = temp_output_24_0_g189;
				float time9_g189 = temp_output_25_0_g189;
				float gravity9_g189 = temp_output_26_0_g189;
				float depth9_g189 = temp_output_27_0_g189;
				float amplitude9_g189 = temp_output_73_0_g185;
				float3 result9_g189 = float3( 0,0,0 );
				gerstner_float( position9_g189 , direction9_g189 , phase9_g189 , time9_g189 , gravity9_g189 , depth9_g189 , amplitude9_g189 , result9_g189 );
				float localgerstner14_g189 = ( 0.0 );
				float3 position14_g189 = temp_output_23_0_g189;
				float3 direction14_g189 = temp_output_77_0_g185;
				float phase14_g189 = temp_output_24_0_g189;
				float time14_g189 = temp_output_25_0_g189;
				float gravity14_g189 = temp_output_26_0_g189;
				float depth14_g189 = temp_output_27_0_g189;
				float amplitude14_g189 = temp_output_75_0_g185;
				float3 result14_g189 = float3( 0,0,0 );
				gerstner_float( position14_g189 , direction14_g189 , phase14_g189 , time14_g189 , gravity14_g189 , depth14_g189 , amplitude14_g189 , result14_g189 );
				float localgerstner15_g189 = ( 0.0 );
				float3 position15_g189 = temp_output_23_0_g189;
				float3 direction15_g189 = temp_output_76_0_g185;
				float phase15_g189 = temp_output_24_0_g189;
				float time15_g189 = temp_output_25_0_g189;
				float gravity15_g189 = temp_output_26_0_g189;
				float depth15_g189 = temp_output_27_0_g189;
				float amplitude15_g189 = temp_output_74_0_g185;
				float3 result15_g189 = float3( 0,0,0 );
				gerstner_float( position15_g189 , direction15_g189 , phase15_g189 , time15_g189 , gravity15_g189 , depth15_g189 , amplitude15_g189 , result15_g189 );
				float3 worldToObj155_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g189 + result9_g189 ) + ( result14_g189 + result15_g189 ) ) + temp_output_23_0_g189 ), 1 ) ).xyz;
				float3 temp_output_3_0_g188 = worldToObj155_g185;
				float3 normalizeResult8_g188 = normalize( ( worldToObj156_g185 - temp_output_3_0_g188 ) );
				float localgerstner4_g187 = ( 0.0 );
				float3 appendResult136_g185 = (float3(0.0 , 0.0 , temp_output_143_0_g185));
				float3 temp_output_23_0_g187 = ( WorldPosition + appendResult136_g185 );
				float3 position4_g187 = temp_output_23_0_g187;
				float3 direction4_g187 = temp_output_79_0_g185;
				float temp_output_24_0_g187 = temp_output_82_0_g185;
				float phase4_g187 = temp_output_24_0_g187;
				float temp_output_25_0_g187 = _TimeParameters.x;
				float time4_g187 = temp_output_25_0_g187;
				float temp_output_26_0_g187 = temp_output_81_0_g185;
				float gravity4_g187 = temp_output_26_0_g187;
				float temp_output_27_0_g187 = temp_output_80_0_g185;
				float depth4_g187 = temp_output_27_0_g187;
				float amplitude4_g187 = temp_output_84_0_g185;
				float3 result4_g187 = float3( 0,0,0 );
				gerstner_float( position4_g187 , direction4_g187 , phase4_g187 , time4_g187 , gravity4_g187 , depth4_g187 , amplitude4_g187 , result4_g187 );
				float localgerstner9_g187 = ( 0.0 );
				float3 position9_g187 = temp_output_23_0_g187;
				float3 direction9_g187 = temp_output_78_0_g185;
				float phase9_g187 = temp_output_24_0_g187;
				float time9_g187 = temp_output_25_0_g187;
				float gravity9_g187 = temp_output_26_0_g187;
				float depth9_g187 = temp_output_27_0_g187;
				float amplitude9_g187 = temp_output_73_0_g185;
				float3 result9_g187 = float3( 0,0,0 );
				gerstner_float( position9_g187 , direction9_g187 , phase9_g187 , time9_g187 , gravity9_g187 , depth9_g187 , amplitude9_g187 , result9_g187 );
				float localgerstner14_g187 = ( 0.0 );
				float3 position14_g187 = temp_output_23_0_g187;
				float3 direction14_g187 = temp_output_77_0_g185;
				float phase14_g187 = temp_output_24_0_g187;
				float time14_g187 = temp_output_25_0_g187;
				float gravity14_g187 = temp_output_26_0_g187;
				float depth14_g187 = temp_output_27_0_g187;
				float amplitude14_g187 = temp_output_75_0_g185;
				float3 result14_g187 = float3( 0,0,0 );
				gerstner_float( position14_g187 , direction14_g187 , phase14_g187 , time14_g187 , gravity14_g187 , depth14_g187 , amplitude14_g187 , result14_g187 );
				float localgerstner15_g187 = ( 0.0 );
				float3 position15_g187 = temp_output_23_0_g187;
				float3 direction15_g187 = temp_output_76_0_g185;
				float phase15_g187 = temp_output_24_0_g187;
				float time15_g187 = temp_output_25_0_g187;
				float gravity15_g187 = temp_output_26_0_g187;
				float depth15_g187 = temp_output_27_0_g187;
				float amplitude15_g187 = temp_output_74_0_g185;
				float3 result15_g187 = float3( 0,0,0 );
				gerstner_float( position15_g187 , direction15_g187 , phase15_g187 , time15_g187 , gravity15_g187 , depth15_g187 , amplitude15_g187 , result15_g187 );
				float3 worldToObj164_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g187 + result9_g187 ) + ( result14_g187 + result15_g187 ) ) + temp_output_23_0_g187 ), 1 ) ).xyz;
				float3 normalizeResult9_g188 = normalize( ( temp_output_3_0_g188 - worldToObj164_g185 ) );
				float3 normalizeResult11_g188 = normalize( cross( normalizeResult8_g188 , normalizeResult9_g188 ) );
				float3 GerstNorm134 = normalizeResult11_g188;
				float dotResult130 = dot( GerstNorm134 , float3( 0,0,1 ) );
				float2 temp_cast_1 = (_TimeParameters.x).xx;
				float2 texCoord140 = IN.ase_texcoord5.xy * float2( 1,1 ) + temp_cast_1;
				float simplePerlin2D138 = snoise( texCoord140*0.02 );
				simplePerlin2D138 = simplePerlin2D138*0.5 + 0.5;
				float smoothstepResult147 = smoothstep( _WaveRiseThershold , lerpResult143 , ( ( (-0.1 + (simplePerlin2D126 - 0.0) * (0.1 - -0.1) / (1.0 - 0.0)) + (1.0 + (dotResult130 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) + (-0.2 + (simplePerlin2D138 - 0.0) * (0.2 - -0.2) / (1.0 - 0.0)) ));
				float waterRise149 = smoothstepResult147;
				float foam153 = step( 0.4 , ( ( ( 1.0 - smoothstepResult91 ) * clampResult107 ) + waterRise149 ) );
				float3 lerpResult181 = lerp( BlendNormal( UnpackNormalScale( tex2D( _NormalTexture1, texCoord394 ), 1.0f ) , UnpackNormalScale( tex2D( _NormalTexture2, texCoord390 ), 1.0f ) ) , float3( 0,1,0 ) , foam153);
				
				float WaterDepth187 = temp_output_298_0;
				

				float3 Normal = lerpResult181;
				float Alpha = ( ( ( 1.0 - WaterDepth187 ) * _WaterThickness ) + foam153 );
				float AlphaClipThreshold = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.clipPos.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float2 octNormalWS = PackNormalOctQuadEncode(WorldNormal);
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);
					outNormalWS = half4(packedNormalWS, 0.0);
				#else
					#if defined(_NORMALMAP)
						#if _NORMAL_DROPOFF_TS
							float crossSign = (WorldTangent.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
							float3 bitangent = crossSign * cross(WorldNormal.xyz, WorldTangent.xyz);
							float3 normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent.xyz, bitangent, WorldNormal.xyz));
						#elif _NORMAL_DROPOFF_OS
							float3 normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							float3 normalWS = Normal;
						#endif
					#else
						float3 normalWS = WorldNormal;
					#endif
					outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "GBuffer"
			Tags { "LightMode"="UniversalGBuffer" }

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_DISTANCE_TESSELLATION
			#define _SPECULAR_SETUP 1
			#pragma shader_feature_local_fragment _SPECULAR_SETUP
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_DEPTH_WRITE_ON
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
			#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_GBUFFER

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif
			
			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#include "../../CustomFunctions/GerstnerWave.hlsl"
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				ASE_SV_POSITION_QUALIFIERS float4 clipPos : SV_POSITION;
				float4 clipPosV : TEXCOORD0;
				float4 lightmapUVOrVertexSH : TEXCOORD1;
				half4 fogFactorAndVertexLight : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD6;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
				float2 dynamicLightmapUV : TEXCOORD7;
				#endif
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Emission;
			float4 _NormalTexture2_ST;
			float4 _NormalTexture1_ST;
			float4 _DeepColor;
			float4 _FoamEmmision;
			float4 _ShallowColor;
			float3 _Direction4;
			float3 _Direction1;
			float3 _Direction2;
			float3 _Direction3;
			float _PanSpeed;
			float _WaveRiseFallback;
			float _WaveRiseThershold;
			float _ColorDepth;
			float _NeighbourDistance;
			float _Amplitude3;
			float _Amplitude2;
			float _Intensity;
			float _Amplitude1;
			float _Depth;
			float _Gravity;
			float _Phase;
			float _Roataion;
			float _Amplitude4;
			float _WaterThickness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _NormalTexture1;
			sampler2D _NormalTexture2;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float localgerstner4_g189 = ( 0.0 );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float temp_output_143_0_g185 = _NeighbourDistance;
				float3 appendResult69_g185 = (float3(0.0 , temp_output_143_0_g185 , 0.0));
				float3 temp_output_23_0_g189 = ( ase_worldPos + appendResult69_g185 );
				float3 position4_g189 = temp_output_23_0_g189;
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_79_0_g185 = rotatedValue387;
				float3 direction4_g189 = temp_output_79_0_g185;
				float temp_output_82_0_g185 = _Phase;
				float temp_output_24_0_g189 = temp_output_82_0_g185;
				float phase4_g189 = temp_output_24_0_g189;
				float temp_output_25_0_g189 = _TimeParameters.x;
				float time4_g189 = temp_output_25_0_g189;
				float temp_output_81_0_g185 = _Gravity;
				float temp_output_26_0_g189 = temp_output_81_0_g185;
				float gravity4_g189 = temp_output_26_0_g189;
				float temp_output_80_0_g185 = _Depth;
				float temp_output_27_0_g189 = temp_output_80_0_g185;
				float depth4_g189 = temp_output_27_0_g189;
				float temp_output_84_0_g185 = ( _Amplitude1 * _Intensity );
				float amplitude4_g189 = temp_output_84_0_g185;
				float3 result4_g189 = float3( 0,0,0 );
				gerstner_float( position4_g189 , direction4_g189 , phase4_g189 , time4_g189 , gravity4_g189 , depth4_g189 , amplitude4_g189 , result4_g189 );
				float localgerstner9_g189 = ( 0.0 );
				float3 position9_g189 = temp_output_23_0_g189;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_78_0_g185 = rotatedValue64;
				float3 direction9_g189 = temp_output_78_0_g185;
				float phase9_g189 = temp_output_24_0_g189;
				float time9_g189 = temp_output_25_0_g189;
				float gravity9_g189 = temp_output_26_0_g189;
				float depth9_g189 = temp_output_27_0_g189;
				float temp_output_73_0_g185 = ( _Intensity * _Amplitude2 );
				float amplitude9_g189 = temp_output_73_0_g185;
				float3 result9_g189 = float3( 0,0,0 );
				gerstner_float( position9_g189 , direction9_g189 , phase9_g189 , time9_g189 , gravity9_g189 , depth9_g189 , amplitude9_g189 , result9_g189 );
				float localgerstner14_g189 = ( 0.0 );
				float3 position14_g189 = temp_output_23_0_g189;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_77_0_g185 = rotatedValue65;
				float3 direction14_g189 = temp_output_77_0_g185;
				float phase14_g189 = temp_output_24_0_g189;
				float time14_g189 = temp_output_25_0_g189;
				float gravity14_g189 = temp_output_26_0_g189;
				float depth14_g189 = temp_output_27_0_g189;
				float temp_output_75_0_g185 = ( _Intensity * _Amplitude3 );
				float amplitude14_g189 = temp_output_75_0_g185;
				float3 result14_g189 = float3( 0,0,0 );
				gerstner_float( position14_g189 , direction14_g189 , phase14_g189 , time14_g189 , gravity14_g189 , depth14_g189 , amplitude14_g189 , result14_g189 );
				float localgerstner15_g189 = ( 0.0 );
				float3 position15_g189 = temp_output_23_0_g189;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_76_0_g185 = rotatedValue66;
				float3 direction15_g189 = temp_output_76_0_g185;
				float phase15_g189 = temp_output_24_0_g189;
				float time15_g189 = temp_output_25_0_g189;
				float gravity15_g189 = temp_output_26_0_g189;
				float depth15_g189 = temp_output_27_0_g189;
				float temp_output_74_0_g185 = ( _Amplitude4 * _Intensity );
				float amplitude15_g189 = temp_output_74_0_g185;
				float3 result15_g189 = float3( 0,0,0 );
				gerstner_float( position15_g189 , direction15_g189 , phase15_g189 , time15_g189 , gravity15_g189 , depth15_g189 , amplitude15_g189 , result15_g189 );
				float3 worldToObj155_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g189 + result9_g189 ) + ( result14_g189 + result15_g189 ) ) + temp_output_23_0_g189 ), 1 ) ).xyz;
				float3 GerstPos132 = worldToObj155_g185;
				
				float localgerstner4_g186 = ( 0.0 );
				float3 appendResult142_g185 = (float3(temp_output_143_0_g185 , 0.0 , 0.0));
				float3 temp_output_23_0_g186 = ( ase_worldPos + appendResult142_g185 );
				float3 position4_g186 = temp_output_23_0_g186;
				float3 direction4_g186 = temp_output_79_0_g185;
				float temp_output_24_0_g186 = temp_output_82_0_g185;
				float phase4_g186 = temp_output_24_0_g186;
				float temp_output_25_0_g186 = _TimeParameters.x;
				float time4_g186 = temp_output_25_0_g186;
				float temp_output_26_0_g186 = temp_output_81_0_g185;
				float gravity4_g186 = temp_output_26_0_g186;
				float temp_output_27_0_g186 = temp_output_80_0_g185;
				float depth4_g186 = temp_output_27_0_g186;
				float amplitude4_g186 = temp_output_84_0_g185;
				float3 result4_g186 = float3( 0,0,0 );
				gerstner_float( position4_g186 , direction4_g186 , phase4_g186 , time4_g186 , gravity4_g186 , depth4_g186 , amplitude4_g186 , result4_g186 );
				float localgerstner9_g186 = ( 0.0 );
				float3 position9_g186 = temp_output_23_0_g186;
				float3 direction9_g186 = temp_output_78_0_g185;
				float phase9_g186 = temp_output_24_0_g186;
				float time9_g186 = temp_output_25_0_g186;
				float gravity9_g186 = temp_output_26_0_g186;
				float depth9_g186 = temp_output_27_0_g186;
				float amplitude9_g186 = temp_output_73_0_g185;
				float3 result9_g186 = float3( 0,0,0 );
				gerstner_float( position9_g186 , direction9_g186 , phase9_g186 , time9_g186 , gravity9_g186 , depth9_g186 , amplitude9_g186 , result9_g186 );
				float localgerstner14_g186 = ( 0.0 );
				float3 position14_g186 = temp_output_23_0_g186;
				float3 direction14_g186 = temp_output_77_0_g185;
				float phase14_g186 = temp_output_24_0_g186;
				float time14_g186 = temp_output_25_0_g186;
				float gravity14_g186 = temp_output_26_0_g186;
				float depth14_g186 = temp_output_27_0_g186;
				float amplitude14_g186 = temp_output_75_0_g185;
				float3 result14_g186 = float3( 0,0,0 );
				gerstner_float( position14_g186 , direction14_g186 , phase14_g186 , time14_g186 , gravity14_g186 , depth14_g186 , amplitude14_g186 , result14_g186 );
				float localgerstner15_g186 = ( 0.0 );
				float3 position15_g186 = temp_output_23_0_g186;
				float3 direction15_g186 = temp_output_76_0_g185;
				float phase15_g186 = temp_output_24_0_g186;
				float time15_g186 = temp_output_25_0_g186;
				float gravity15_g186 = temp_output_26_0_g186;
				float depth15_g186 = temp_output_27_0_g186;
				float amplitude15_g186 = temp_output_74_0_g185;
				float3 result15_g186 = float3( 0,0,0 );
				gerstner_float( position15_g186 , direction15_g186 , phase15_g186 , time15_g186 , gravity15_g186 , depth15_g186 , amplitude15_g186 , result15_g186 );
				float3 worldToObj156_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g186 + result9_g186 ) + ( result14_g186 + result15_g186 ) ) + temp_output_23_0_g186 ), 1 ) ).xyz;
				float3 temp_output_3_0_g188 = worldToObj155_g185;
				float3 normalizeResult8_g188 = normalize( ( worldToObj156_g185 - temp_output_3_0_g188 ) );
				float localgerstner4_g187 = ( 0.0 );
				float3 appendResult136_g185 = (float3(0.0 , 0.0 , temp_output_143_0_g185));
				float3 temp_output_23_0_g187 = ( ase_worldPos + appendResult136_g185 );
				float3 position4_g187 = temp_output_23_0_g187;
				float3 direction4_g187 = temp_output_79_0_g185;
				float temp_output_24_0_g187 = temp_output_82_0_g185;
				float phase4_g187 = temp_output_24_0_g187;
				float temp_output_25_0_g187 = _TimeParameters.x;
				float time4_g187 = temp_output_25_0_g187;
				float temp_output_26_0_g187 = temp_output_81_0_g185;
				float gravity4_g187 = temp_output_26_0_g187;
				float temp_output_27_0_g187 = temp_output_80_0_g185;
				float depth4_g187 = temp_output_27_0_g187;
				float amplitude4_g187 = temp_output_84_0_g185;
				float3 result4_g187 = float3( 0,0,0 );
				gerstner_float( position4_g187 , direction4_g187 , phase4_g187 , time4_g187 , gravity4_g187 , depth4_g187 , amplitude4_g187 , result4_g187 );
				float localgerstner9_g187 = ( 0.0 );
				float3 position9_g187 = temp_output_23_0_g187;
				float3 direction9_g187 = temp_output_78_0_g185;
				float phase9_g187 = temp_output_24_0_g187;
				float time9_g187 = temp_output_25_0_g187;
				float gravity9_g187 = temp_output_26_0_g187;
				float depth9_g187 = temp_output_27_0_g187;
				float amplitude9_g187 = temp_output_73_0_g185;
				float3 result9_g187 = float3( 0,0,0 );
				gerstner_float( position9_g187 , direction9_g187 , phase9_g187 , time9_g187 , gravity9_g187 , depth9_g187 , amplitude9_g187 , result9_g187 );
				float localgerstner14_g187 = ( 0.0 );
				float3 position14_g187 = temp_output_23_0_g187;
				float3 direction14_g187 = temp_output_77_0_g185;
				float phase14_g187 = temp_output_24_0_g187;
				float time14_g187 = temp_output_25_0_g187;
				float gravity14_g187 = temp_output_26_0_g187;
				float depth14_g187 = temp_output_27_0_g187;
				float amplitude14_g187 = temp_output_75_0_g185;
				float3 result14_g187 = float3( 0,0,0 );
				gerstner_float( position14_g187 , direction14_g187 , phase14_g187 , time14_g187 , gravity14_g187 , depth14_g187 , amplitude14_g187 , result14_g187 );
				float localgerstner15_g187 = ( 0.0 );
				float3 position15_g187 = temp_output_23_0_g187;
				float3 direction15_g187 = temp_output_76_0_g185;
				float phase15_g187 = temp_output_24_0_g187;
				float time15_g187 = temp_output_25_0_g187;
				float gravity15_g187 = temp_output_26_0_g187;
				float depth15_g187 = temp_output_27_0_g187;
				float amplitude15_g187 = temp_output_74_0_g185;
				float3 result15_g187 = float3( 0,0,0 );
				gerstner_float( position15_g187 , direction15_g187 , phase15_g187 , time15_g187 , gravity15_g187 , depth15_g187 , amplitude15_g187 , result15_g187 );
				float3 worldToObj164_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g187 + result9_g187 ) + ( result14_g187 + result15_g187 ) ) + temp_output_23_0_g187 ), 1 ) ).xyz;
				float3 normalizeResult9_g188 = normalize( ( temp_output_3_0_g188 - worldToObj164_g185 ) );
				float3 normalizeResult11_g188 = normalize( cross( normalizeResult8_g188 , normalizeResult9_g188 ) );
				float3 GerstNorm134 = normalizeResult11_g188;
				
				o.ase_texcoord8.xy = v.texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord8.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = GerstPos132;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = GerstNorm134;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					o.dynamicLightmapUV.xy = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if !defined(LIGHTMAP_ON)
					OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord.xy;
					o.lightmapUVOrVertexSH.xy = v.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );

				o.fogFactorAndVertexLight = half4(0, vertexLight);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				o.clipPosV = positionCS;
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			FragmentOutput frag ( VertexOutput IN
								#ifdef ASE_DEPTH_WRITE_ON
								,out float outputDepth : ASE_SV_DEPTH
								#endif
								 )
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif

				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				float4 ClipPos = IN.clipPosV;
				float4 ScreenPos = ComputeScreenPos( IN.clipPosV );

				float2 NormalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#else
					ShadowCoords = float4(0, 0, 0, 0);
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth11_g132 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth11_g132 = saturate( abs( ( screenDepth11_g132 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _ColorDepth ) ) );
				float temp_output_298_0 = ( 1.0 - distanceDepth11_g132 );
				float smoothstepResult91 = smoothstep( 0.0 , 0.2 , (1.0 + (temp_output_298_0 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
				float2 temp_cast_0 = (_TimeParameters.x).xx;
				float2 texCoord117 = IN.ase_texcoord8.xy * float2( 1,1 ) + temp_cast_0;
				float simplePerlin2D287 = snoise( texCoord117*0.2 );
				simplePerlin2D287 = simplePerlin2D287*0.5 + 0.5;
				float clampResult107 = clamp( ( ( ( 1.0 - pow( ( 1.0 / 1000.0 ) , temp_output_298_0 ) ) * sin( ( ( temp_output_298_0 * 100.0 ) + ( 4.0 * _TimeParameters.x ) ) ) ) * ( simplePerlin2D287 + 0.7 ) ) , 0.0 , 0.9 );
				float lerpResult143 = lerp( _WaveRiseThershold , 1.0 , _WaveRiseFallback);
				float2 texCoord118 = IN.ase_texcoord8.xy * float2( 1,1 ) + float2( 0,0 );
				float cos121 = cos( radians( _Roataion ) );
				float sin121 = sin( radians( _Roataion ) );
				float2 rotator121 = mul( texCoord118 - float2( 0.5,0.5 ) , float2x2( cos121 , -sin121 , sin121 , cos121 )) + float2( 0.5,0.5 );
				float simplePerlin2D126 = snoise( rotator121*0.5 );
				simplePerlin2D126 = simplePerlin2D126*0.5 + 0.5;
				float localgerstner4_g186 = ( 0.0 );
				float temp_output_143_0_g185 = _NeighbourDistance;
				float3 appendResult142_g185 = (float3(temp_output_143_0_g185 , 0.0 , 0.0));
				float3 temp_output_23_0_g186 = ( WorldPosition + appendResult142_g185 );
				float3 position4_g186 = temp_output_23_0_g186;
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_79_0_g185 = rotatedValue387;
				float3 direction4_g186 = temp_output_79_0_g185;
				float temp_output_82_0_g185 = _Phase;
				float temp_output_24_0_g186 = temp_output_82_0_g185;
				float phase4_g186 = temp_output_24_0_g186;
				float temp_output_25_0_g186 = _TimeParameters.x;
				float time4_g186 = temp_output_25_0_g186;
				float temp_output_81_0_g185 = _Gravity;
				float temp_output_26_0_g186 = temp_output_81_0_g185;
				float gravity4_g186 = temp_output_26_0_g186;
				float temp_output_80_0_g185 = _Depth;
				float temp_output_27_0_g186 = temp_output_80_0_g185;
				float depth4_g186 = temp_output_27_0_g186;
				float temp_output_84_0_g185 = ( _Amplitude1 * _Intensity );
				float amplitude4_g186 = temp_output_84_0_g185;
				float3 result4_g186 = float3( 0,0,0 );
				gerstner_float( position4_g186 , direction4_g186 , phase4_g186 , time4_g186 , gravity4_g186 , depth4_g186 , amplitude4_g186 , result4_g186 );
				float localgerstner9_g186 = ( 0.0 );
				float3 position9_g186 = temp_output_23_0_g186;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_78_0_g185 = rotatedValue64;
				float3 direction9_g186 = temp_output_78_0_g185;
				float phase9_g186 = temp_output_24_0_g186;
				float time9_g186 = temp_output_25_0_g186;
				float gravity9_g186 = temp_output_26_0_g186;
				float depth9_g186 = temp_output_27_0_g186;
				float temp_output_73_0_g185 = ( _Intensity * _Amplitude2 );
				float amplitude9_g186 = temp_output_73_0_g185;
				float3 result9_g186 = float3( 0,0,0 );
				gerstner_float( position9_g186 , direction9_g186 , phase9_g186 , time9_g186 , gravity9_g186 , depth9_g186 , amplitude9_g186 , result9_g186 );
				float localgerstner14_g186 = ( 0.0 );
				float3 position14_g186 = temp_output_23_0_g186;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_77_0_g185 = rotatedValue65;
				float3 direction14_g186 = temp_output_77_0_g185;
				float phase14_g186 = temp_output_24_0_g186;
				float time14_g186 = temp_output_25_0_g186;
				float gravity14_g186 = temp_output_26_0_g186;
				float depth14_g186 = temp_output_27_0_g186;
				float temp_output_75_0_g185 = ( _Intensity * _Amplitude3 );
				float amplitude14_g186 = temp_output_75_0_g185;
				float3 result14_g186 = float3( 0,0,0 );
				gerstner_float( position14_g186 , direction14_g186 , phase14_g186 , time14_g186 , gravity14_g186 , depth14_g186 , amplitude14_g186 , result14_g186 );
				float localgerstner15_g186 = ( 0.0 );
				float3 position15_g186 = temp_output_23_0_g186;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_76_0_g185 = rotatedValue66;
				float3 direction15_g186 = temp_output_76_0_g185;
				float phase15_g186 = temp_output_24_0_g186;
				float time15_g186 = temp_output_25_0_g186;
				float gravity15_g186 = temp_output_26_0_g186;
				float depth15_g186 = temp_output_27_0_g186;
				float temp_output_74_0_g185 = ( _Amplitude4 * _Intensity );
				float amplitude15_g186 = temp_output_74_0_g185;
				float3 result15_g186 = float3( 0,0,0 );
				gerstner_float( position15_g186 , direction15_g186 , phase15_g186 , time15_g186 , gravity15_g186 , depth15_g186 , amplitude15_g186 , result15_g186 );
				float3 worldToObj156_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g186 + result9_g186 ) + ( result14_g186 + result15_g186 ) ) + temp_output_23_0_g186 ), 1 ) ).xyz;
				float localgerstner4_g189 = ( 0.0 );
				float3 appendResult69_g185 = (float3(0.0 , temp_output_143_0_g185 , 0.0));
				float3 temp_output_23_0_g189 = ( WorldPosition + appendResult69_g185 );
				float3 position4_g189 = temp_output_23_0_g189;
				float3 direction4_g189 = temp_output_79_0_g185;
				float temp_output_24_0_g189 = temp_output_82_0_g185;
				float phase4_g189 = temp_output_24_0_g189;
				float temp_output_25_0_g189 = _TimeParameters.x;
				float time4_g189 = temp_output_25_0_g189;
				float temp_output_26_0_g189 = temp_output_81_0_g185;
				float gravity4_g189 = temp_output_26_0_g189;
				float temp_output_27_0_g189 = temp_output_80_0_g185;
				float depth4_g189 = temp_output_27_0_g189;
				float amplitude4_g189 = temp_output_84_0_g185;
				float3 result4_g189 = float3( 0,0,0 );
				gerstner_float( position4_g189 , direction4_g189 , phase4_g189 , time4_g189 , gravity4_g189 , depth4_g189 , amplitude4_g189 , result4_g189 );
				float localgerstner9_g189 = ( 0.0 );
				float3 position9_g189 = temp_output_23_0_g189;
				float3 direction9_g189 = temp_output_78_0_g185;
				float phase9_g189 = temp_output_24_0_g189;
				float time9_g189 = temp_output_25_0_g189;
				float gravity9_g189 = temp_output_26_0_g189;
				float depth9_g189 = temp_output_27_0_g189;
				float amplitude9_g189 = temp_output_73_0_g185;
				float3 result9_g189 = float3( 0,0,0 );
				gerstner_float( position9_g189 , direction9_g189 , phase9_g189 , time9_g189 , gravity9_g189 , depth9_g189 , amplitude9_g189 , result9_g189 );
				float localgerstner14_g189 = ( 0.0 );
				float3 position14_g189 = temp_output_23_0_g189;
				float3 direction14_g189 = temp_output_77_0_g185;
				float phase14_g189 = temp_output_24_0_g189;
				float time14_g189 = temp_output_25_0_g189;
				float gravity14_g189 = temp_output_26_0_g189;
				float depth14_g189 = temp_output_27_0_g189;
				float amplitude14_g189 = temp_output_75_0_g185;
				float3 result14_g189 = float3( 0,0,0 );
				gerstner_float( position14_g189 , direction14_g189 , phase14_g189 , time14_g189 , gravity14_g189 , depth14_g189 , amplitude14_g189 , result14_g189 );
				float localgerstner15_g189 = ( 0.0 );
				float3 position15_g189 = temp_output_23_0_g189;
				float3 direction15_g189 = temp_output_76_0_g185;
				float phase15_g189 = temp_output_24_0_g189;
				float time15_g189 = temp_output_25_0_g189;
				float gravity15_g189 = temp_output_26_0_g189;
				float depth15_g189 = temp_output_27_0_g189;
				float amplitude15_g189 = temp_output_74_0_g185;
				float3 result15_g189 = float3( 0,0,0 );
				gerstner_float( position15_g189 , direction15_g189 , phase15_g189 , time15_g189 , gravity15_g189 , depth15_g189 , amplitude15_g189 , result15_g189 );
				float3 worldToObj155_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g189 + result9_g189 ) + ( result14_g189 + result15_g189 ) ) + temp_output_23_0_g189 ), 1 ) ).xyz;
				float3 temp_output_3_0_g188 = worldToObj155_g185;
				float3 normalizeResult8_g188 = normalize( ( worldToObj156_g185 - temp_output_3_0_g188 ) );
				float localgerstner4_g187 = ( 0.0 );
				float3 appendResult136_g185 = (float3(0.0 , 0.0 , temp_output_143_0_g185));
				float3 temp_output_23_0_g187 = ( WorldPosition + appendResult136_g185 );
				float3 position4_g187 = temp_output_23_0_g187;
				float3 direction4_g187 = temp_output_79_0_g185;
				float temp_output_24_0_g187 = temp_output_82_0_g185;
				float phase4_g187 = temp_output_24_0_g187;
				float temp_output_25_0_g187 = _TimeParameters.x;
				float time4_g187 = temp_output_25_0_g187;
				float temp_output_26_0_g187 = temp_output_81_0_g185;
				float gravity4_g187 = temp_output_26_0_g187;
				float temp_output_27_0_g187 = temp_output_80_0_g185;
				float depth4_g187 = temp_output_27_0_g187;
				float amplitude4_g187 = temp_output_84_0_g185;
				float3 result4_g187 = float3( 0,0,0 );
				gerstner_float( position4_g187 , direction4_g187 , phase4_g187 , time4_g187 , gravity4_g187 , depth4_g187 , amplitude4_g187 , result4_g187 );
				float localgerstner9_g187 = ( 0.0 );
				float3 position9_g187 = temp_output_23_0_g187;
				float3 direction9_g187 = temp_output_78_0_g185;
				float phase9_g187 = temp_output_24_0_g187;
				float time9_g187 = temp_output_25_0_g187;
				float gravity9_g187 = temp_output_26_0_g187;
				float depth9_g187 = temp_output_27_0_g187;
				float amplitude9_g187 = temp_output_73_0_g185;
				float3 result9_g187 = float3( 0,0,0 );
				gerstner_float( position9_g187 , direction9_g187 , phase9_g187 , time9_g187 , gravity9_g187 , depth9_g187 , amplitude9_g187 , result9_g187 );
				float localgerstner14_g187 = ( 0.0 );
				float3 position14_g187 = temp_output_23_0_g187;
				float3 direction14_g187 = temp_output_77_0_g185;
				float phase14_g187 = temp_output_24_0_g187;
				float time14_g187 = temp_output_25_0_g187;
				float gravity14_g187 = temp_output_26_0_g187;
				float depth14_g187 = temp_output_27_0_g187;
				float amplitude14_g187 = temp_output_75_0_g185;
				float3 result14_g187 = float3( 0,0,0 );
				gerstner_float( position14_g187 , direction14_g187 , phase14_g187 , time14_g187 , gravity14_g187 , depth14_g187 , amplitude14_g187 , result14_g187 );
				float localgerstner15_g187 = ( 0.0 );
				float3 position15_g187 = temp_output_23_0_g187;
				float3 direction15_g187 = temp_output_76_0_g185;
				float phase15_g187 = temp_output_24_0_g187;
				float time15_g187 = temp_output_25_0_g187;
				float gravity15_g187 = temp_output_26_0_g187;
				float depth15_g187 = temp_output_27_0_g187;
				float amplitude15_g187 = temp_output_74_0_g185;
				float3 result15_g187 = float3( 0,0,0 );
				gerstner_float( position15_g187 , direction15_g187 , phase15_g187 , time15_g187 , gravity15_g187 , depth15_g187 , amplitude15_g187 , result15_g187 );
				float3 worldToObj164_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g187 + result9_g187 ) + ( result14_g187 + result15_g187 ) ) + temp_output_23_0_g187 ), 1 ) ).xyz;
				float3 normalizeResult9_g188 = normalize( ( temp_output_3_0_g188 - worldToObj164_g185 ) );
				float3 normalizeResult11_g188 = normalize( cross( normalizeResult8_g188 , normalizeResult9_g188 ) );
				float3 GerstNorm134 = normalizeResult11_g188;
				float dotResult130 = dot( GerstNorm134 , float3( 0,0,1 ) );
				float2 temp_cast_1 = (_TimeParameters.x).xx;
				float2 texCoord140 = IN.ase_texcoord8.xy * float2( 1,1 ) + temp_cast_1;
				float simplePerlin2D138 = snoise( texCoord140*0.02 );
				simplePerlin2D138 = simplePerlin2D138*0.5 + 0.5;
				float smoothstepResult147 = smoothstep( _WaveRiseThershold , lerpResult143 , ( ( (-0.1 + (simplePerlin2D126 - 0.0) * (0.1 - -0.1) / (1.0 - 0.0)) + (1.0 + (dotResult130 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) + (-0.2 + (simplePerlin2D138 - 0.0) * (0.2 - -0.2) / (1.0 - 0.0)) ));
				float waterRise149 = smoothstepResult147;
				float foam153 = step( 0.4 , ( ( ( 1.0 - smoothstepResult91 ) * clampResult107 ) + waterRise149 ) );
				float4 lerpResult284 = lerp( _ShallowColor , _DeepColor , foam153);
				
				float2 appendResult415 = (float2(WorldPosition.x , WorldPosition.y));
				float2 texCoord394 = IN.ase_texcoord8.xy * _NormalTexture1_ST.xy + ( ( ( float2( 0.4,1.17 ) * _PanSpeed ) * _TimeParameters.x ) + appendResult415 );
				float2 texCoord390 = IN.ase_texcoord8.xy * _NormalTexture2_ST.xy + ( appendResult415 + ( _TimeParameters.x * ( _PanSpeed * float2( -0.5,0.2 ) ) ) );
				float3 lerpResult181 = lerp( BlendNormal( UnpackNormalScale( tex2D( _NormalTexture1, texCoord394 ), 1.0f ) , UnpackNormalScale( tex2D( _NormalTexture2, texCoord390 ), 1.0f ) ) , float3( 0,1,0 ) , foam153);
				
				float4 lerpResult304 = lerp( _Emission , _FoamEmmision , foam153);
				
				float WaterDepth187 = temp_output_298_0;
				

				float3 BaseColor = lerpResult284.rgb;
				float3 Normal = lerpResult181;
				float3 Emission = lerpResult304.rgb;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = 1.0;
				float Occlusion = 0.0;
				float Alpha = ( ( ( 1.0 - WaterDepth187 ) * _WaterThickness ) + foam153 );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = IN.clipPos.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = WorldPosition;
				inputData.positionCS = IN.clipPos;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
						inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
					#elif _NORMAL_DROPOFF_OS
						inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
						inputData.normalWS = Normal;
					#endif
				#else
					inputData.normalWS = WorldNormal;
				#endif

				inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				inputData.viewDirectionWS = SafeNormalize( WorldViewDirection );

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#else
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, IN.dynamicLightmapUV.xy, SH, inputData.normalWS);
					#else
						inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
					#endif
				#endif

				inputData.normalizedScreenSpaceUV = NormalizedScreenSpaceUV;
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

				#if defined(DEBUG_DISPLAY)
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = IN.dynamicLightmapUV.xy;
						#endif
					#if defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = IN.lightmapUVOrVertexSH.xy;
					#else
						inputData.vertexSH = SH;
					#endif
				#endif

				#ifdef _DBUFFER
					ApplyDecal(IN.clipPos,
						BaseColor,
						Specular,
						inputData.normalWS,
						Metallic,
						Occlusion,
						Smoothness);
				#endif

				BRDFData brdfData;
				InitializeBRDFData
				(BaseColor, Metallic, Specular, Smoothness, Alpha, brdfData);

				Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
				half4 color;
				MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, inputData.shadowMask);
				color.rgb = GlobalIllumination(brdfData, inputData.bakedGI, Occlusion, inputData.positionWS, inputData.normalWS, inputData.viewDirectionWS);
				color.a = Alpha;

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return BRDFDataToGbuffer(brdfData, inputData, Smoothness, Emission + color.rgb, Occlusion);
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "SceneSelectionPass"
			Tags { "LightMode"="SceneSelectionPass" }

			Cull Off

			HLSLPROGRAM

			#define ASE_FOG 1
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_DISTANCE_TESSELLATION
			#define _SPECULAR_SETUP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_DEPTH_WRITE_ON
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#define SCENESELECTIONPASS 1

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "../../CustomFunctions/GerstnerWave.hlsl"


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Emission;
			float4 _NormalTexture2_ST;
			float4 _NormalTexture1_ST;
			float4 _DeepColor;
			float4 _FoamEmmision;
			float4 _ShallowColor;
			float3 _Direction4;
			float3 _Direction1;
			float3 _Direction2;
			float3 _Direction3;
			float _PanSpeed;
			float _WaveRiseFallback;
			float _WaveRiseThershold;
			float _ColorDepth;
			float _NeighbourDistance;
			float _Amplitude3;
			float _Amplitude2;
			float _Intensity;
			float _Amplitude1;
			float _Depth;
			float _Gravity;
			float _Phase;
			float _Roataion;
			float _Amplitude4;
			float _WaterThickness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			uniform float4 _CameraDepthTexture_TexelSize;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float localgerstner4_g189 = ( 0.0 );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float temp_output_143_0_g185 = _NeighbourDistance;
				float3 appendResult69_g185 = (float3(0.0 , temp_output_143_0_g185 , 0.0));
				float3 temp_output_23_0_g189 = ( ase_worldPos + appendResult69_g185 );
				float3 position4_g189 = temp_output_23_0_g189;
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_79_0_g185 = rotatedValue387;
				float3 direction4_g189 = temp_output_79_0_g185;
				float temp_output_82_0_g185 = _Phase;
				float temp_output_24_0_g189 = temp_output_82_0_g185;
				float phase4_g189 = temp_output_24_0_g189;
				float temp_output_25_0_g189 = _TimeParameters.x;
				float time4_g189 = temp_output_25_0_g189;
				float temp_output_81_0_g185 = _Gravity;
				float temp_output_26_0_g189 = temp_output_81_0_g185;
				float gravity4_g189 = temp_output_26_0_g189;
				float temp_output_80_0_g185 = _Depth;
				float temp_output_27_0_g189 = temp_output_80_0_g185;
				float depth4_g189 = temp_output_27_0_g189;
				float temp_output_84_0_g185 = ( _Amplitude1 * _Intensity );
				float amplitude4_g189 = temp_output_84_0_g185;
				float3 result4_g189 = float3( 0,0,0 );
				gerstner_float( position4_g189 , direction4_g189 , phase4_g189 , time4_g189 , gravity4_g189 , depth4_g189 , amplitude4_g189 , result4_g189 );
				float localgerstner9_g189 = ( 0.0 );
				float3 position9_g189 = temp_output_23_0_g189;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_78_0_g185 = rotatedValue64;
				float3 direction9_g189 = temp_output_78_0_g185;
				float phase9_g189 = temp_output_24_0_g189;
				float time9_g189 = temp_output_25_0_g189;
				float gravity9_g189 = temp_output_26_0_g189;
				float depth9_g189 = temp_output_27_0_g189;
				float temp_output_73_0_g185 = ( _Intensity * _Amplitude2 );
				float amplitude9_g189 = temp_output_73_0_g185;
				float3 result9_g189 = float3( 0,0,0 );
				gerstner_float( position9_g189 , direction9_g189 , phase9_g189 , time9_g189 , gravity9_g189 , depth9_g189 , amplitude9_g189 , result9_g189 );
				float localgerstner14_g189 = ( 0.0 );
				float3 position14_g189 = temp_output_23_0_g189;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_77_0_g185 = rotatedValue65;
				float3 direction14_g189 = temp_output_77_0_g185;
				float phase14_g189 = temp_output_24_0_g189;
				float time14_g189 = temp_output_25_0_g189;
				float gravity14_g189 = temp_output_26_0_g189;
				float depth14_g189 = temp_output_27_0_g189;
				float temp_output_75_0_g185 = ( _Intensity * _Amplitude3 );
				float amplitude14_g189 = temp_output_75_0_g185;
				float3 result14_g189 = float3( 0,0,0 );
				gerstner_float( position14_g189 , direction14_g189 , phase14_g189 , time14_g189 , gravity14_g189 , depth14_g189 , amplitude14_g189 , result14_g189 );
				float localgerstner15_g189 = ( 0.0 );
				float3 position15_g189 = temp_output_23_0_g189;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_76_0_g185 = rotatedValue66;
				float3 direction15_g189 = temp_output_76_0_g185;
				float phase15_g189 = temp_output_24_0_g189;
				float time15_g189 = temp_output_25_0_g189;
				float gravity15_g189 = temp_output_26_0_g189;
				float depth15_g189 = temp_output_27_0_g189;
				float temp_output_74_0_g185 = ( _Amplitude4 * _Intensity );
				float amplitude15_g189 = temp_output_74_0_g185;
				float3 result15_g189 = float3( 0,0,0 );
				gerstner_float( position15_g189 , direction15_g189 , phase15_g189 , time15_g189 , gravity15_g189 , depth15_g189 , amplitude15_g189 , result15_g189 );
				float3 worldToObj155_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g189 + result9_g189 ) + ( result14_g189 + result15_g189 ) ) + temp_output_23_0_g189 ), 1 ) ).xyz;
				float3 GerstPos132 = worldToObj155_g185;
				
				float localgerstner4_g186 = ( 0.0 );
				float3 appendResult142_g185 = (float3(temp_output_143_0_g185 , 0.0 , 0.0));
				float3 temp_output_23_0_g186 = ( ase_worldPos + appendResult142_g185 );
				float3 position4_g186 = temp_output_23_0_g186;
				float3 direction4_g186 = temp_output_79_0_g185;
				float temp_output_24_0_g186 = temp_output_82_0_g185;
				float phase4_g186 = temp_output_24_0_g186;
				float temp_output_25_0_g186 = _TimeParameters.x;
				float time4_g186 = temp_output_25_0_g186;
				float temp_output_26_0_g186 = temp_output_81_0_g185;
				float gravity4_g186 = temp_output_26_0_g186;
				float temp_output_27_0_g186 = temp_output_80_0_g185;
				float depth4_g186 = temp_output_27_0_g186;
				float amplitude4_g186 = temp_output_84_0_g185;
				float3 result4_g186 = float3( 0,0,0 );
				gerstner_float( position4_g186 , direction4_g186 , phase4_g186 , time4_g186 , gravity4_g186 , depth4_g186 , amplitude4_g186 , result4_g186 );
				float localgerstner9_g186 = ( 0.0 );
				float3 position9_g186 = temp_output_23_0_g186;
				float3 direction9_g186 = temp_output_78_0_g185;
				float phase9_g186 = temp_output_24_0_g186;
				float time9_g186 = temp_output_25_0_g186;
				float gravity9_g186 = temp_output_26_0_g186;
				float depth9_g186 = temp_output_27_0_g186;
				float amplitude9_g186 = temp_output_73_0_g185;
				float3 result9_g186 = float3( 0,0,0 );
				gerstner_float( position9_g186 , direction9_g186 , phase9_g186 , time9_g186 , gravity9_g186 , depth9_g186 , amplitude9_g186 , result9_g186 );
				float localgerstner14_g186 = ( 0.0 );
				float3 position14_g186 = temp_output_23_0_g186;
				float3 direction14_g186 = temp_output_77_0_g185;
				float phase14_g186 = temp_output_24_0_g186;
				float time14_g186 = temp_output_25_0_g186;
				float gravity14_g186 = temp_output_26_0_g186;
				float depth14_g186 = temp_output_27_0_g186;
				float amplitude14_g186 = temp_output_75_0_g185;
				float3 result14_g186 = float3( 0,0,0 );
				gerstner_float( position14_g186 , direction14_g186 , phase14_g186 , time14_g186 , gravity14_g186 , depth14_g186 , amplitude14_g186 , result14_g186 );
				float localgerstner15_g186 = ( 0.0 );
				float3 position15_g186 = temp_output_23_0_g186;
				float3 direction15_g186 = temp_output_76_0_g185;
				float phase15_g186 = temp_output_24_0_g186;
				float time15_g186 = temp_output_25_0_g186;
				float gravity15_g186 = temp_output_26_0_g186;
				float depth15_g186 = temp_output_27_0_g186;
				float amplitude15_g186 = temp_output_74_0_g185;
				float3 result15_g186 = float3( 0,0,0 );
				gerstner_float( position15_g186 , direction15_g186 , phase15_g186 , time15_g186 , gravity15_g186 , depth15_g186 , amplitude15_g186 , result15_g186 );
				float3 worldToObj156_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g186 + result9_g186 ) + ( result14_g186 + result15_g186 ) ) + temp_output_23_0_g186 ), 1 ) ).xyz;
				float3 temp_output_3_0_g188 = worldToObj155_g185;
				float3 normalizeResult8_g188 = normalize( ( worldToObj156_g185 - temp_output_3_0_g188 ) );
				float localgerstner4_g187 = ( 0.0 );
				float3 appendResult136_g185 = (float3(0.0 , 0.0 , temp_output_143_0_g185));
				float3 temp_output_23_0_g187 = ( ase_worldPos + appendResult136_g185 );
				float3 position4_g187 = temp_output_23_0_g187;
				float3 direction4_g187 = temp_output_79_0_g185;
				float temp_output_24_0_g187 = temp_output_82_0_g185;
				float phase4_g187 = temp_output_24_0_g187;
				float temp_output_25_0_g187 = _TimeParameters.x;
				float time4_g187 = temp_output_25_0_g187;
				float temp_output_26_0_g187 = temp_output_81_0_g185;
				float gravity4_g187 = temp_output_26_0_g187;
				float temp_output_27_0_g187 = temp_output_80_0_g185;
				float depth4_g187 = temp_output_27_0_g187;
				float amplitude4_g187 = temp_output_84_0_g185;
				float3 result4_g187 = float3( 0,0,0 );
				gerstner_float( position4_g187 , direction4_g187 , phase4_g187 , time4_g187 , gravity4_g187 , depth4_g187 , amplitude4_g187 , result4_g187 );
				float localgerstner9_g187 = ( 0.0 );
				float3 position9_g187 = temp_output_23_0_g187;
				float3 direction9_g187 = temp_output_78_0_g185;
				float phase9_g187 = temp_output_24_0_g187;
				float time9_g187 = temp_output_25_0_g187;
				float gravity9_g187 = temp_output_26_0_g187;
				float depth9_g187 = temp_output_27_0_g187;
				float amplitude9_g187 = temp_output_73_0_g185;
				float3 result9_g187 = float3( 0,0,0 );
				gerstner_float( position9_g187 , direction9_g187 , phase9_g187 , time9_g187 , gravity9_g187 , depth9_g187 , amplitude9_g187 , result9_g187 );
				float localgerstner14_g187 = ( 0.0 );
				float3 position14_g187 = temp_output_23_0_g187;
				float3 direction14_g187 = temp_output_77_0_g185;
				float phase14_g187 = temp_output_24_0_g187;
				float time14_g187 = temp_output_25_0_g187;
				float gravity14_g187 = temp_output_26_0_g187;
				float depth14_g187 = temp_output_27_0_g187;
				float amplitude14_g187 = temp_output_75_0_g185;
				float3 result14_g187 = float3( 0,0,0 );
				gerstner_float( position14_g187 , direction14_g187 , phase14_g187 , time14_g187 , gravity14_g187 , depth14_g187 , amplitude14_g187 , result14_g187 );
				float localgerstner15_g187 = ( 0.0 );
				float3 position15_g187 = temp_output_23_0_g187;
				float3 direction15_g187 = temp_output_76_0_g185;
				float phase15_g187 = temp_output_24_0_g187;
				float time15_g187 = temp_output_25_0_g187;
				float gravity15_g187 = temp_output_26_0_g187;
				float depth15_g187 = temp_output_27_0_g187;
				float amplitude15_g187 = temp_output_74_0_g185;
				float3 result15_g187 = float3( 0,0,0 );
				gerstner_float( position15_g187 , direction15_g187 , phase15_g187 , time15_g187 , gravity15_g187 , depth15_g187 , amplitude15_g187 , result15_g187 );
				float3 worldToObj164_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g187 + result9_g187 ) + ( result14_g187 + result15_g187 ) ) + temp_output_23_0_g187 ), 1 ) ).xyz;
				float3 normalizeResult9_g188 = normalize( ( temp_output_3_0_g188 - worldToObj164_g185 ) );
				float3 normalizeResult11_g188 = normalize( cross( normalizeResult8_g188 , normalizeResult9_g188 ) );
				float3 GerstNorm134 = normalizeResult11_g188;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord = screenPos;
				o.ase_texcoord2.xyz = ase_worldPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = GerstPos132;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = GerstNorm134;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				o.clipPos = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float4 screenPos = IN.ase_texcoord;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth11_g132 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth11_g132 = saturate( abs( ( screenDepth11_g132 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _ColorDepth ) ) );
				float temp_output_298_0 = ( 1.0 - distanceDepth11_g132 );
				float WaterDepth187 = temp_output_298_0;
				float smoothstepResult91 = smoothstep( 0.0 , 0.2 , (1.0 + (temp_output_298_0 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
				float2 temp_cast_0 = (_TimeParameters.x).xx;
				float2 texCoord117 = IN.ase_texcoord1.xy * float2( 1,1 ) + temp_cast_0;
				float simplePerlin2D287 = snoise( texCoord117*0.2 );
				simplePerlin2D287 = simplePerlin2D287*0.5 + 0.5;
				float clampResult107 = clamp( ( ( ( 1.0 - pow( ( 1.0 / 1000.0 ) , temp_output_298_0 ) ) * sin( ( ( temp_output_298_0 * 100.0 ) + ( 4.0 * _TimeParameters.x ) ) ) ) * ( simplePerlin2D287 + 0.7 ) ) , 0.0 , 0.9 );
				float lerpResult143 = lerp( _WaveRiseThershold , 1.0 , _WaveRiseFallback);
				float2 texCoord118 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float cos121 = cos( radians( _Roataion ) );
				float sin121 = sin( radians( _Roataion ) );
				float2 rotator121 = mul( texCoord118 - float2( 0.5,0.5 ) , float2x2( cos121 , -sin121 , sin121 , cos121 )) + float2( 0.5,0.5 );
				float simplePerlin2D126 = snoise( rotator121*0.5 );
				simplePerlin2D126 = simplePerlin2D126*0.5 + 0.5;
				float localgerstner4_g186 = ( 0.0 );
				float3 ase_worldPos = IN.ase_texcoord2.xyz;
				float temp_output_143_0_g185 = _NeighbourDistance;
				float3 appendResult142_g185 = (float3(temp_output_143_0_g185 , 0.0 , 0.0));
				float3 temp_output_23_0_g186 = ( ase_worldPos + appendResult142_g185 );
				float3 position4_g186 = temp_output_23_0_g186;
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_79_0_g185 = rotatedValue387;
				float3 direction4_g186 = temp_output_79_0_g185;
				float temp_output_82_0_g185 = _Phase;
				float temp_output_24_0_g186 = temp_output_82_0_g185;
				float phase4_g186 = temp_output_24_0_g186;
				float temp_output_25_0_g186 = _TimeParameters.x;
				float time4_g186 = temp_output_25_0_g186;
				float temp_output_81_0_g185 = _Gravity;
				float temp_output_26_0_g186 = temp_output_81_0_g185;
				float gravity4_g186 = temp_output_26_0_g186;
				float temp_output_80_0_g185 = _Depth;
				float temp_output_27_0_g186 = temp_output_80_0_g185;
				float depth4_g186 = temp_output_27_0_g186;
				float temp_output_84_0_g185 = ( _Amplitude1 * _Intensity );
				float amplitude4_g186 = temp_output_84_0_g185;
				float3 result4_g186 = float3( 0,0,0 );
				gerstner_float( position4_g186 , direction4_g186 , phase4_g186 , time4_g186 , gravity4_g186 , depth4_g186 , amplitude4_g186 , result4_g186 );
				float localgerstner9_g186 = ( 0.0 );
				float3 position9_g186 = temp_output_23_0_g186;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_78_0_g185 = rotatedValue64;
				float3 direction9_g186 = temp_output_78_0_g185;
				float phase9_g186 = temp_output_24_0_g186;
				float time9_g186 = temp_output_25_0_g186;
				float gravity9_g186 = temp_output_26_0_g186;
				float depth9_g186 = temp_output_27_0_g186;
				float temp_output_73_0_g185 = ( _Intensity * _Amplitude2 );
				float amplitude9_g186 = temp_output_73_0_g185;
				float3 result9_g186 = float3( 0,0,0 );
				gerstner_float( position9_g186 , direction9_g186 , phase9_g186 , time9_g186 , gravity9_g186 , depth9_g186 , amplitude9_g186 , result9_g186 );
				float localgerstner14_g186 = ( 0.0 );
				float3 position14_g186 = temp_output_23_0_g186;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_77_0_g185 = rotatedValue65;
				float3 direction14_g186 = temp_output_77_0_g185;
				float phase14_g186 = temp_output_24_0_g186;
				float time14_g186 = temp_output_25_0_g186;
				float gravity14_g186 = temp_output_26_0_g186;
				float depth14_g186 = temp_output_27_0_g186;
				float temp_output_75_0_g185 = ( _Intensity * _Amplitude3 );
				float amplitude14_g186 = temp_output_75_0_g185;
				float3 result14_g186 = float3( 0,0,0 );
				gerstner_float( position14_g186 , direction14_g186 , phase14_g186 , time14_g186 , gravity14_g186 , depth14_g186 , amplitude14_g186 , result14_g186 );
				float localgerstner15_g186 = ( 0.0 );
				float3 position15_g186 = temp_output_23_0_g186;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_76_0_g185 = rotatedValue66;
				float3 direction15_g186 = temp_output_76_0_g185;
				float phase15_g186 = temp_output_24_0_g186;
				float time15_g186 = temp_output_25_0_g186;
				float gravity15_g186 = temp_output_26_0_g186;
				float depth15_g186 = temp_output_27_0_g186;
				float temp_output_74_0_g185 = ( _Amplitude4 * _Intensity );
				float amplitude15_g186 = temp_output_74_0_g185;
				float3 result15_g186 = float3( 0,0,0 );
				gerstner_float( position15_g186 , direction15_g186 , phase15_g186 , time15_g186 , gravity15_g186 , depth15_g186 , amplitude15_g186 , result15_g186 );
				float3 worldToObj156_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g186 + result9_g186 ) + ( result14_g186 + result15_g186 ) ) + temp_output_23_0_g186 ), 1 ) ).xyz;
				float localgerstner4_g189 = ( 0.0 );
				float3 appendResult69_g185 = (float3(0.0 , temp_output_143_0_g185 , 0.0));
				float3 temp_output_23_0_g189 = ( ase_worldPos + appendResult69_g185 );
				float3 position4_g189 = temp_output_23_0_g189;
				float3 direction4_g189 = temp_output_79_0_g185;
				float temp_output_24_0_g189 = temp_output_82_0_g185;
				float phase4_g189 = temp_output_24_0_g189;
				float temp_output_25_0_g189 = _TimeParameters.x;
				float time4_g189 = temp_output_25_0_g189;
				float temp_output_26_0_g189 = temp_output_81_0_g185;
				float gravity4_g189 = temp_output_26_0_g189;
				float temp_output_27_0_g189 = temp_output_80_0_g185;
				float depth4_g189 = temp_output_27_0_g189;
				float amplitude4_g189 = temp_output_84_0_g185;
				float3 result4_g189 = float3( 0,0,0 );
				gerstner_float( position4_g189 , direction4_g189 , phase4_g189 , time4_g189 , gravity4_g189 , depth4_g189 , amplitude4_g189 , result4_g189 );
				float localgerstner9_g189 = ( 0.0 );
				float3 position9_g189 = temp_output_23_0_g189;
				float3 direction9_g189 = temp_output_78_0_g185;
				float phase9_g189 = temp_output_24_0_g189;
				float time9_g189 = temp_output_25_0_g189;
				float gravity9_g189 = temp_output_26_0_g189;
				float depth9_g189 = temp_output_27_0_g189;
				float amplitude9_g189 = temp_output_73_0_g185;
				float3 result9_g189 = float3( 0,0,0 );
				gerstner_float( position9_g189 , direction9_g189 , phase9_g189 , time9_g189 , gravity9_g189 , depth9_g189 , amplitude9_g189 , result9_g189 );
				float localgerstner14_g189 = ( 0.0 );
				float3 position14_g189 = temp_output_23_0_g189;
				float3 direction14_g189 = temp_output_77_0_g185;
				float phase14_g189 = temp_output_24_0_g189;
				float time14_g189 = temp_output_25_0_g189;
				float gravity14_g189 = temp_output_26_0_g189;
				float depth14_g189 = temp_output_27_0_g189;
				float amplitude14_g189 = temp_output_75_0_g185;
				float3 result14_g189 = float3( 0,0,0 );
				gerstner_float( position14_g189 , direction14_g189 , phase14_g189 , time14_g189 , gravity14_g189 , depth14_g189 , amplitude14_g189 , result14_g189 );
				float localgerstner15_g189 = ( 0.0 );
				float3 position15_g189 = temp_output_23_0_g189;
				float3 direction15_g189 = temp_output_76_0_g185;
				float phase15_g189 = temp_output_24_0_g189;
				float time15_g189 = temp_output_25_0_g189;
				float gravity15_g189 = temp_output_26_0_g189;
				float depth15_g189 = temp_output_27_0_g189;
				float amplitude15_g189 = temp_output_74_0_g185;
				float3 result15_g189 = float3( 0,0,0 );
				gerstner_float( position15_g189 , direction15_g189 , phase15_g189 , time15_g189 , gravity15_g189 , depth15_g189 , amplitude15_g189 , result15_g189 );
				float3 worldToObj155_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g189 + result9_g189 ) + ( result14_g189 + result15_g189 ) ) + temp_output_23_0_g189 ), 1 ) ).xyz;
				float3 temp_output_3_0_g188 = worldToObj155_g185;
				float3 normalizeResult8_g188 = normalize( ( worldToObj156_g185 - temp_output_3_0_g188 ) );
				float localgerstner4_g187 = ( 0.0 );
				float3 appendResult136_g185 = (float3(0.0 , 0.0 , temp_output_143_0_g185));
				float3 temp_output_23_0_g187 = ( ase_worldPos + appendResult136_g185 );
				float3 position4_g187 = temp_output_23_0_g187;
				float3 direction4_g187 = temp_output_79_0_g185;
				float temp_output_24_0_g187 = temp_output_82_0_g185;
				float phase4_g187 = temp_output_24_0_g187;
				float temp_output_25_0_g187 = _TimeParameters.x;
				float time4_g187 = temp_output_25_0_g187;
				float temp_output_26_0_g187 = temp_output_81_0_g185;
				float gravity4_g187 = temp_output_26_0_g187;
				float temp_output_27_0_g187 = temp_output_80_0_g185;
				float depth4_g187 = temp_output_27_0_g187;
				float amplitude4_g187 = temp_output_84_0_g185;
				float3 result4_g187 = float3( 0,0,0 );
				gerstner_float( position4_g187 , direction4_g187 , phase4_g187 , time4_g187 , gravity4_g187 , depth4_g187 , amplitude4_g187 , result4_g187 );
				float localgerstner9_g187 = ( 0.0 );
				float3 position9_g187 = temp_output_23_0_g187;
				float3 direction9_g187 = temp_output_78_0_g185;
				float phase9_g187 = temp_output_24_0_g187;
				float time9_g187 = temp_output_25_0_g187;
				float gravity9_g187 = temp_output_26_0_g187;
				float depth9_g187 = temp_output_27_0_g187;
				float amplitude9_g187 = temp_output_73_0_g185;
				float3 result9_g187 = float3( 0,0,0 );
				gerstner_float( position9_g187 , direction9_g187 , phase9_g187 , time9_g187 , gravity9_g187 , depth9_g187 , amplitude9_g187 , result9_g187 );
				float localgerstner14_g187 = ( 0.0 );
				float3 position14_g187 = temp_output_23_0_g187;
				float3 direction14_g187 = temp_output_77_0_g185;
				float phase14_g187 = temp_output_24_0_g187;
				float time14_g187 = temp_output_25_0_g187;
				float gravity14_g187 = temp_output_26_0_g187;
				float depth14_g187 = temp_output_27_0_g187;
				float amplitude14_g187 = temp_output_75_0_g185;
				float3 result14_g187 = float3( 0,0,0 );
				gerstner_float( position14_g187 , direction14_g187 , phase14_g187 , time14_g187 , gravity14_g187 , depth14_g187 , amplitude14_g187 , result14_g187 );
				float localgerstner15_g187 = ( 0.0 );
				float3 position15_g187 = temp_output_23_0_g187;
				float3 direction15_g187 = temp_output_76_0_g185;
				float phase15_g187 = temp_output_24_0_g187;
				float time15_g187 = temp_output_25_0_g187;
				float gravity15_g187 = temp_output_26_0_g187;
				float depth15_g187 = temp_output_27_0_g187;
				float amplitude15_g187 = temp_output_74_0_g185;
				float3 result15_g187 = float3( 0,0,0 );
				gerstner_float( position15_g187 , direction15_g187 , phase15_g187 , time15_g187 , gravity15_g187 , depth15_g187 , amplitude15_g187 , result15_g187 );
				float3 worldToObj164_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g187 + result9_g187 ) + ( result14_g187 + result15_g187 ) ) + temp_output_23_0_g187 ), 1 ) ).xyz;
				float3 normalizeResult9_g188 = normalize( ( temp_output_3_0_g188 - worldToObj164_g185 ) );
				float3 normalizeResult11_g188 = normalize( cross( normalizeResult8_g188 , normalizeResult9_g188 ) );
				float3 GerstNorm134 = normalizeResult11_g188;
				float dotResult130 = dot( GerstNorm134 , float3( 0,0,1 ) );
				float2 temp_cast_1 = (_TimeParameters.x).xx;
				float2 texCoord140 = IN.ase_texcoord1.xy * float2( 1,1 ) + temp_cast_1;
				float simplePerlin2D138 = snoise( texCoord140*0.02 );
				simplePerlin2D138 = simplePerlin2D138*0.5 + 0.5;
				float smoothstepResult147 = smoothstep( _WaveRiseThershold , lerpResult143 , ( ( (-0.1 + (simplePerlin2D126 - 0.0) * (0.1 - -0.1) / (1.0 - 0.0)) + (1.0 + (dotResult130 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) + (-0.2 + (simplePerlin2D138 - 0.0) * (0.2 - -0.2) / (1.0 - 0.0)) ));
				float waterRise149 = smoothstepResult147;
				float foam153 = step( 0.4 , ( ( ( 1.0 - smoothstepResult91 ) * clampResult107 ) + waterRise149 ) );
				

				surfaceDescription.Alpha = ( ( ( 1.0 - WaterDepth187 ) * _WaterThickness ) + foam153 );
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;

				#ifdef SCENESELECTIONPASS
					outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				#elif defined(SCENEPICKINGPASS)
					outColor = _SelectionID;
				#endif

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ScenePickingPass"
			Tags { "LightMode"="Picking" }

			HLSLPROGRAM

			#define ASE_FOG 1
			#define ASE_TESSELLATION 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_DISTANCE_TESSELLATION
			#define _SPECULAR_SETUP 1
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_DEPTH_WRITE_ON
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

		    #define SCENEPICKINGPASS 1

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "../../CustomFunctions/GerstnerWave.hlsl"


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Emission;
			float4 _NormalTexture2_ST;
			float4 _NormalTexture1_ST;
			float4 _DeepColor;
			float4 _FoamEmmision;
			float4 _ShallowColor;
			float3 _Direction4;
			float3 _Direction1;
			float3 _Direction2;
			float3 _Direction3;
			float _PanSpeed;
			float _WaveRiseFallback;
			float _WaveRiseThershold;
			float _ColorDepth;
			float _NeighbourDistance;
			float _Amplitude3;
			float _Amplitude2;
			float _Intensity;
			float _Amplitude1;
			float _Depth;
			float _Gravity;
			float _Phase;
			float _Roataion;
			float _Amplitude4;
			float _WaterThickness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			uniform float4 _CameraDepthTexture_TexelSize;


			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			//#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

			//#ifdef HAVE_VFX_MODIFICATION
			//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
			//#endif

			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float localgerstner4_g189 = ( 0.0 );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float temp_output_143_0_g185 = _NeighbourDistance;
				float3 appendResult69_g185 = (float3(0.0 , temp_output_143_0_g185 , 0.0));
				float3 temp_output_23_0_g189 = ( ase_worldPos + appendResult69_g185 );
				float3 position4_g189 = temp_output_23_0_g189;
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_79_0_g185 = rotatedValue387;
				float3 direction4_g189 = temp_output_79_0_g185;
				float temp_output_82_0_g185 = _Phase;
				float temp_output_24_0_g189 = temp_output_82_0_g185;
				float phase4_g189 = temp_output_24_0_g189;
				float temp_output_25_0_g189 = _TimeParameters.x;
				float time4_g189 = temp_output_25_0_g189;
				float temp_output_81_0_g185 = _Gravity;
				float temp_output_26_0_g189 = temp_output_81_0_g185;
				float gravity4_g189 = temp_output_26_0_g189;
				float temp_output_80_0_g185 = _Depth;
				float temp_output_27_0_g189 = temp_output_80_0_g185;
				float depth4_g189 = temp_output_27_0_g189;
				float temp_output_84_0_g185 = ( _Amplitude1 * _Intensity );
				float amplitude4_g189 = temp_output_84_0_g185;
				float3 result4_g189 = float3( 0,0,0 );
				gerstner_float( position4_g189 , direction4_g189 , phase4_g189 , time4_g189 , gravity4_g189 , depth4_g189 , amplitude4_g189 , result4_g189 );
				float localgerstner9_g189 = ( 0.0 );
				float3 position9_g189 = temp_output_23_0_g189;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_78_0_g185 = rotatedValue64;
				float3 direction9_g189 = temp_output_78_0_g185;
				float phase9_g189 = temp_output_24_0_g189;
				float time9_g189 = temp_output_25_0_g189;
				float gravity9_g189 = temp_output_26_0_g189;
				float depth9_g189 = temp_output_27_0_g189;
				float temp_output_73_0_g185 = ( _Intensity * _Amplitude2 );
				float amplitude9_g189 = temp_output_73_0_g185;
				float3 result9_g189 = float3( 0,0,0 );
				gerstner_float( position9_g189 , direction9_g189 , phase9_g189 , time9_g189 , gravity9_g189 , depth9_g189 , amplitude9_g189 , result9_g189 );
				float localgerstner14_g189 = ( 0.0 );
				float3 position14_g189 = temp_output_23_0_g189;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_77_0_g185 = rotatedValue65;
				float3 direction14_g189 = temp_output_77_0_g185;
				float phase14_g189 = temp_output_24_0_g189;
				float time14_g189 = temp_output_25_0_g189;
				float gravity14_g189 = temp_output_26_0_g189;
				float depth14_g189 = temp_output_27_0_g189;
				float temp_output_75_0_g185 = ( _Intensity * _Amplitude3 );
				float amplitude14_g189 = temp_output_75_0_g185;
				float3 result14_g189 = float3( 0,0,0 );
				gerstner_float( position14_g189 , direction14_g189 , phase14_g189 , time14_g189 , gravity14_g189 , depth14_g189 , amplitude14_g189 , result14_g189 );
				float localgerstner15_g189 = ( 0.0 );
				float3 position15_g189 = temp_output_23_0_g189;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_76_0_g185 = rotatedValue66;
				float3 direction15_g189 = temp_output_76_0_g185;
				float phase15_g189 = temp_output_24_0_g189;
				float time15_g189 = temp_output_25_0_g189;
				float gravity15_g189 = temp_output_26_0_g189;
				float depth15_g189 = temp_output_27_0_g189;
				float temp_output_74_0_g185 = ( _Amplitude4 * _Intensity );
				float amplitude15_g189 = temp_output_74_0_g185;
				float3 result15_g189 = float3( 0,0,0 );
				gerstner_float( position15_g189 , direction15_g189 , phase15_g189 , time15_g189 , gravity15_g189 , depth15_g189 , amplitude15_g189 , result15_g189 );
				float3 worldToObj155_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g189 + result9_g189 ) + ( result14_g189 + result15_g189 ) ) + temp_output_23_0_g189 ), 1 ) ).xyz;
				float3 GerstPos132 = worldToObj155_g185;
				
				float localgerstner4_g186 = ( 0.0 );
				float3 appendResult142_g185 = (float3(temp_output_143_0_g185 , 0.0 , 0.0));
				float3 temp_output_23_0_g186 = ( ase_worldPos + appendResult142_g185 );
				float3 position4_g186 = temp_output_23_0_g186;
				float3 direction4_g186 = temp_output_79_0_g185;
				float temp_output_24_0_g186 = temp_output_82_0_g185;
				float phase4_g186 = temp_output_24_0_g186;
				float temp_output_25_0_g186 = _TimeParameters.x;
				float time4_g186 = temp_output_25_0_g186;
				float temp_output_26_0_g186 = temp_output_81_0_g185;
				float gravity4_g186 = temp_output_26_0_g186;
				float temp_output_27_0_g186 = temp_output_80_0_g185;
				float depth4_g186 = temp_output_27_0_g186;
				float amplitude4_g186 = temp_output_84_0_g185;
				float3 result4_g186 = float3( 0,0,0 );
				gerstner_float( position4_g186 , direction4_g186 , phase4_g186 , time4_g186 , gravity4_g186 , depth4_g186 , amplitude4_g186 , result4_g186 );
				float localgerstner9_g186 = ( 0.0 );
				float3 position9_g186 = temp_output_23_0_g186;
				float3 direction9_g186 = temp_output_78_0_g185;
				float phase9_g186 = temp_output_24_0_g186;
				float time9_g186 = temp_output_25_0_g186;
				float gravity9_g186 = temp_output_26_0_g186;
				float depth9_g186 = temp_output_27_0_g186;
				float amplitude9_g186 = temp_output_73_0_g185;
				float3 result9_g186 = float3( 0,0,0 );
				gerstner_float( position9_g186 , direction9_g186 , phase9_g186 , time9_g186 , gravity9_g186 , depth9_g186 , amplitude9_g186 , result9_g186 );
				float localgerstner14_g186 = ( 0.0 );
				float3 position14_g186 = temp_output_23_0_g186;
				float3 direction14_g186 = temp_output_77_0_g185;
				float phase14_g186 = temp_output_24_0_g186;
				float time14_g186 = temp_output_25_0_g186;
				float gravity14_g186 = temp_output_26_0_g186;
				float depth14_g186 = temp_output_27_0_g186;
				float amplitude14_g186 = temp_output_75_0_g185;
				float3 result14_g186 = float3( 0,0,0 );
				gerstner_float( position14_g186 , direction14_g186 , phase14_g186 , time14_g186 , gravity14_g186 , depth14_g186 , amplitude14_g186 , result14_g186 );
				float localgerstner15_g186 = ( 0.0 );
				float3 position15_g186 = temp_output_23_0_g186;
				float3 direction15_g186 = temp_output_76_0_g185;
				float phase15_g186 = temp_output_24_0_g186;
				float time15_g186 = temp_output_25_0_g186;
				float gravity15_g186 = temp_output_26_0_g186;
				float depth15_g186 = temp_output_27_0_g186;
				float amplitude15_g186 = temp_output_74_0_g185;
				float3 result15_g186 = float3( 0,0,0 );
				gerstner_float( position15_g186 , direction15_g186 , phase15_g186 , time15_g186 , gravity15_g186 , depth15_g186 , amplitude15_g186 , result15_g186 );
				float3 worldToObj156_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g186 + result9_g186 ) + ( result14_g186 + result15_g186 ) ) + temp_output_23_0_g186 ), 1 ) ).xyz;
				float3 temp_output_3_0_g188 = worldToObj155_g185;
				float3 normalizeResult8_g188 = normalize( ( worldToObj156_g185 - temp_output_3_0_g188 ) );
				float localgerstner4_g187 = ( 0.0 );
				float3 appendResult136_g185 = (float3(0.0 , 0.0 , temp_output_143_0_g185));
				float3 temp_output_23_0_g187 = ( ase_worldPos + appendResult136_g185 );
				float3 position4_g187 = temp_output_23_0_g187;
				float3 direction4_g187 = temp_output_79_0_g185;
				float temp_output_24_0_g187 = temp_output_82_0_g185;
				float phase4_g187 = temp_output_24_0_g187;
				float temp_output_25_0_g187 = _TimeParameters.x;
				float time4_g187 = temp_output_25_0_g187;
				float temp_output_26_0_g187 = temp_output_81_0_g185;
				float gravity4_g187 = temp_output_26_0_g187;
				float temp_output_27_0_g187 = temp_output_80_0_g185;
				float depth4_g187 = temp_output_27_0_g187;
				float amplitude4_g187 = temp_output_84_0_g185;
				float3 result4_g187 = float3( 0,0,0 );
				gerstner_float( position4_g187 , direction4_g187 , phase4_g187 , time4_g187 , gravity4_g187 , depth4_g187 , amplitude4_g187 , result4_g187 );
				float localgerstner9_g187 = ( 0.0 );
				float3 position9_g187 = temp_output_23_0_g187;
				float3 direction9_g187 = temp_output_78_0_g185;
				float phase9_g187 = temp_output_24_0_g187;
				float time9_g187 = temp_output_25_0_g187;
				float gravity9_g187 = temp_output_26_0_g187;
				float depth9_g187 = temp_output_27_0_g187;
				float amplitude9_g187 = temp_output_73_0_g185;
				float3 result9_g187 = float3( 0,0,0 );
				gerstner_float( position9_g187 , direction9_g187 , phase9_g187 , time9_g187 , gravity9_g187 , depth9_g187 , amplitude9_g187 , result9_g187 );
				float localgerstner14_g187 = ( 0.0 );
				float3 position14_g187 = temp_output_23_0_g187;
				float3 direction14_g187 = temp_output_77_0_g185;
				float phase14_g187 = temp_output_24_0_g187;
				float time14_g187 = temp_output_25_0_g187;
				float gravity14_g187 = temp_output_26_0_g187;
				float depth14_g187 = temp_output_27_0_g187;
				float amplitude14_g187 = temp_output_75_0_g185;
				float3 result14_g187 = float3( 0,0,0 );
				gerstner_float( position14_g187 , direction14_g187 , phase14_g187 , time14_g187 , gravity14_g187 , depth14_g187 , amplitude14_g187 , result14_g187 );
				float localgerstner15_g187 = ( 0.0 );
				float3 position15_g187 = temp_output_23_0_g187;
				float3 direction15_g187 = temp_output_76_0_g185;
				float phase15_g187 = temp_output_24_0_g187;
				float time15_g187 = temp_output_25_0_g187;
				float gravity15_g187 = temp_output_26_0_g187;
				float depth15_g187 = temp_output_27_0_g187;
				float amplitude15_g187 = temp_output_74_0_g185;
				float3 result15_g187 = float3( 0,0,0 );
				gerstner_float( position15_g187 , direction15_g187 , phase15_g187 , time15_g187 , gravity15_g187 , depth15_g187 , amplitude15_g187 , result15_g187 );
				float3 worldToObj164_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g187 + result9_g187 ) + ( result14_g187 + result15_g187 ) ) + temp_output_23_0_g187 ), 1 ) ).xyz;
				float3 normalizeResult9_g188 = normalize( ( temp_output_3_0_g188 - worldToObj164_g185 ) );
				float3 normalizeResult11_g188 = normalize( cross( normalizeResult8_g188 , normalizeResult9_g188 ) );
				float3 GerstNorm134 = normalizeResult11_g188;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord = screenPos;
				o.ase_texcoord2.xyz = ase_worldPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = GerstPos132;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = GerstNorm134;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float4 screenPos = IN.ase_texcoord;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth11_g132 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth11_g132 = saturate( abs( ( screenDepth11_g132 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _ColorDepth ) ) );
				float temp_output_298_0 = ( 1.0 - distanceDepth11_g132 );
				float WaterDepth187 = temp_output_298_0;
				float smoothstepResult91 = smoothstep( 0.0 , 0.2 , (1.0 + (temp_output_298_0 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
				float2 temp_cast_0 = (_TimeParameters.x).xx;
				float2 texCoord117 = IN.ase_texcoord1.xy * float2( 1,1 ) + temp_cast_0;
				float simplePerlin2D287 = snoise( texCoord117*0.2 );
				simplePerlin2D287 = simplePerlin2D287*0.5 + 0.5;
				float clampResult107 = clamp( ( ( ( 1.0 - pow( ( 1.0 / 1000.0 ) , temp_output_298_0 ) ) * sin( ( ( temp_output_298_0 * 100.0 ) + ( 4.0 * _TimeParameters.x ) ) ) ) * ( simplePerlin2D287 + 0.7 ) ) , 0.0 , 0.9 );
				float lerpResult143 = lerp( _WaveRiseThershold , 1.0 , _WaveRiseFallback);
				float2 texCoord118 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float cos121 = cos( radians( _Roataion ) );
				float sin121 = sin( radians( _Roataion ) );
				float2 rotator121 = mul( texCoord118 - float2( 0.5,0.5 ) , float2x2( cos121 , -sin121 , sin121 , cos121 )) + float2( 0.5,0.5 );
				float simplePerlin2D126 = snoise( rotator121*0.5 );
				simplePerlin2D126 = simplePerlin2D126*0.5 + 0.5;
				float localgerstner4_g186 = ( 0.0 );
				float3 ase_worldPos = IN.ase_texcoord2.xyz;
				float temp_output_143_0_g185 = _NeighbourDistance;
				float3 appendResult142_g185 = (float3(temp_output_143_0_g185 , 0.0 , 0.0));
				float3 temp_output_23_0_g186 = ( ase_worldPos + appendResult142_g185 );
				float3 position4_g186 = temp_output_23_0_g186;
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_79_0_g185 = rotatedValue387;
				float3 direction4_g186 = temp_output_79_0_g185;
				float temp_output_82_0_g185 = _Phase;
				float temp_output_24_0_g186 = temp_output_82_0_g185;
				float phase4_g186 = temp_output_24_0_g186;
				float temp_output_25_0_g186 = _TimeParameters.x;
				float time4_g186 = temp_output_25_0_g186;
				float temp_output_81_0_g185 = _Gravity;
				float temp_output_26_0_g186 = temp_output_81_0_g185;
				float gravity4_g186 = temp_output_26_0_g186;
				float temp_output_80_0_g185 = _Depth;
				float temp_output_27_0_g186 = temp_output_80_0_g185;
				float depth4_g186 = temp_output_27_0_g186;
				float temp_output_84_0_g185 = ( _Amplitude1 * _Intensity );
				float amplitude4_g186 = temp_output_84_0_g185;
				float3 result4_g186 = float3( 0,0,0 );
				gerstner_float( position4_g186 , direction4_g186 , phase4_g186 , time4_g186 , gravity4_g186 , depth4_g186 , amplitude4_g186 , result4_g186 );
				float localgerstner9_g186 = ( 0.0 );
				float3 position9_g186 = temp_output_23_0_g186;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_78_0_g185 = rotatedValue64;
				float3 direction9_g186 = temp_output_78_0_g185;
				float phase9_g186 = temp_output_24_0_g186;
				float time9_g186 = temp_output_25_0_g186;
				float gravity9_g186 = temp_output_26_0_g186;
				float depth9_g186 = temp_output_27_0_g186;
				float temp_output_73_0_g185 = ( _Intensity * _Amplitude2 );
				float amplitude9_g186 = temp_output_73_0_g185;
				float3 result9_g186 = float3( 0,0,0 );
				gerstner_float( position9_g186 , direction9_g186 , phase9_g186 , time9_g186 , gravity9_g186 , depth9_g186 , amplitude9_g186 , result9_g186 );
				float localgerstner14_g186 = ( 0.0 );
				float3 position14_g186 = temp_output_23_0_g186;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_77_0_g185 = rotatedValue65;
				float3 direction14_g186 = temp_output_77_0_g185;
				float phase14_g186 = temp_output_24_0_g186;
				float time14_g186 = temp_output_25_0_g186;
				float gravity14_g186 = temp_output_26_0_g186;
				float depth14_g186 = temp_output_27_0_g186;
				float temp_output_75_0_g185 = ( _Intensity * _Amplitude3 );
				float amplitude14_g186 = temp_output_75_0_g185;
				float3 result14_g186 = float3( 0,0,0 );
				gerstner_float( position14_g186 , direction14_g186 , phase14_g186 , time14_g186 , gravity14_g186 , depth14_g186 , amplitude14_g186 , result14_g186 );
				float localgerstner15_g186 = ( 0.0 );
				float3 position15_g186 = temp_output_23_0_g186;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), _Roataion );
				float3 temp_output_76_0_g185 = rotatedValue66;
				float3 direction15_g186 = temp_output_76_0_g185;
				float phase15_g186 = temp_output_24_0_g186;
				float time15_g186 = temp_output_25_0_g186;
				float gravity15_g186 = temp_output_26_0_g186;
				float depth15_g186 = temp_output_27_0_g186;
				float temp_output_74_0_g185 = ( _Amplitude4 * _Intensity );
				float amplitude15_g186 = temp_output_74_0_g185;
				float3 result15_g186 = float3( 0,0,0 );
				gerstner_float( position15_g186 , direction15_g186 , phase15_g186 , time15_g186 , gravity15_g186 , depth15_g186 , amplitude15_g186 , result15_g186 );
				float3 worldToObj156_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g186 + result9_g186 ) + ( result14_g186 + result15_g186 ) ) + temp_output_23_0_g186 ), 1 ) ).xyz;
				float localgerstner4_g189 = ( 0.0 );
				float3 appendResult69_g185 = (float3(0.0 , temp_output_143_0_g185 , 0.0));
				float3 temp_output_23_0_g189 = ( ase_worldPos + appendResult69_g185 );
				float3 position4_g189 = temp_output_23_0_g189;
				float3 direction4_g189 = temp_output_79_0_g185;
				float temp_output_24_0_g189 = temp_output_82_0_g185;
				float phase4_g189 = temp_output_24_0_g189;
				float temp_output_25_0_g189 = _TimeParameters.x;
				float time4_g189 = temp_output_25_0_g189;
				float temp_output_26_0_g189 = temp_output_81_0_g185;
				float gravity4_g189 = temp_output_26_0_g189;
				float temp_output_27_0_g189 = temp_output_80_0_g185;
				float depth4_g189 = temp_output_27_0_g189;
				float amplitude4_g189 = temp_output_84_0_g185;
				float3 result4_g189 = float3( 0,0,0 );
				gerstner_float( position4_g189 , direction4_g189 , phase4_g189 , time4_g189 , gravity4_g189 , depth4_g189 , amplitude4_g189 , result4_g189 );
				float localgerstner9_g189 = ( 0.0 );
				float3 position9_g189 = temp_output_23_0_g189;
				float3 direction9_g189 = temp_output_78_0_g185;
				float phase9_g189 = temp_output_24_0_g189;
				float time9_g189 = temp_output_25_0_g189;
				float gravity9_g189 = temp_output_26_0_g189;
				float depth9_g189 = temp_output_27_0_g189;
				float amplitude9_g189 = temp_output_73_0_g185;
				float3 result9_g189 = float3( 0,0,0 );
				gerstner_float( position9_g189 , direction9_g189 , phase9_g189 , time9_g189 , gravity9_g189 , depth9_g189 , amplitude9_g189 , result9_g189 );
				float localgerstner14_g189 = ( 0.0 );
				float3 position14_g189 = temp_output_23_0_g189;
				float3 direction14_g189 = temp_output_77_0_g185;
				float phase14_g189 = temp_output_24_0_g189;
				float time14_g189 = temp_output_25_0_g189;
				float gravity14_g189 = temp_output_26_0_g189;
				float depth14_g189 = temp_output_27_0_g189;
				float amplitude14_g189 = temp_output_75_0_g185;
				float3 result14_g189 = float3( 0,0,0 );
				gerstner_float( position14_g189 , direction14_g189 , phase14_g189 , time14_g189 , gravity14_g189 , depth14_g189 , amplitude14_g189 , result14_g189 );
				float localgerstner15_g189 = ( 0.0 );
				float3 position15_g189 = temp_output_23_0_g189;
				float3 direction15_g189 = temp_output_76_0_g185;
				float phase15_g189 = temp_output_24_0_g189;
				float time15_g189 = temp_output_25_0_g189;
				float gravity15_g189 = temp_output_26_0_g189;
				float depth15_g189 = temp_output_27_0_g189;
				float amplitude15_g189 = temp_output_74_0_g185;
				float3 result15_g189 = float3( 0,0,0 );
				gerstner_float( position15_g189 , direction15_g189 , phase15_g189 , time15_g189 , gravity15_g189 , depth15_g189 , amplitude15_g189 , result15_g189 );
				float3 worldToObj155_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g189 + result9_g189 ) + ( result14_g189 + result15_g189 ) ) + temp_output_23_0_g189 ), 1 ) ).xyz;
				float3 temp_output_3_0_g188 = worldToObj155_g185;
				float3 normalizeResult8_g188 = normalize( ( worldToObj156_g185 - temp_output_3_0_g188 ) );
				float localgerstner4_g187 = ( 0.0 );
				float3 appendResult136_g185 = (float3(0.0 , 0.0 , temp_output_143_0_g185));
				float3 temp_output_23_0_g187 = ( ase_worldPos + appendResult136_g185 );
				float3 position4_g187 = temp_output_23_0_g187;
				float3 direction4_g187 = temp_output_79_0_g185;
				float temp_output_24_0_g187 = temp_output_82_0_g185;
				float phase4_g187 = temp_output_24_0_g187;
				float temp_output_25_0_g187 = _TimeParameters.x;
				float time4_g187 = temp_output_25_0_g187;
				float temp_output_26_0_g187 = temp_output_81_0_g185;
				float gravity4_g187 = temp_output_26_0_g187;
				float temp_output_27_0_g187 = temp_output_80_0_g185;
				float depth4_g187 = temp_output_27_0_g187;
				float amplitude4_g187 = temp_output_84_0_g185;
				float3 result4_g187 = float3( 0,0,0 );
				gerstner_float( position4_g187 , direction4_g187 , phase4_g187 , time4_g187 , gravity4_g187 , depth4_g187 , amplitude4_g187 , result4_g187 );
				float localgerstner9_g187 = ( 0.0 );
				float3 position9_g187 = temp_output_23_0_g187;
				float3 direction9_g187 = temp_output_78_0_g185;
				float phase9_g187 = temp_output_24_0_g187;
				float time9_g187 = temp_output_25_0_g187;
				float gravity9_g187 = temp_output_26_0_g187;
				float depth9_g187 = temp_output_27_0_g187;
				float amplitude9_g187 = temp_output_73_0_g185;
				float3 result9_g187 = float3( 0,0,0 );
				gerstner_float( position9_g187 , direction9_g187 , phase9_g187 , time9_g187 , gravity9_g187 , depth9_g187 , amplitude9_g187 , result9_g187 );
				float localgerstner14_g187 = ( 0.0 );
				float3 position14_g187 = temp_output_23_0_g187;
				float3 direction14_g187 = temp_output_77_0_g185;
				float phase14_g187 = temp_output_24_0_g187;
				float time14_g187 = temp_output_25_0_g187;
				float gravity14_g187 = temp_output_26_0_g187;
				float depth14_g187 = temp_output_27_0_g187;
				float amplitude14_g187 = temp_output_75_0_g185;
				float3 result14_g187 = float3( 0,0,0 );
				gerstner_float( position14_g187 , direction14_g187 , phase14_g187 , time14_g187 , gravity14_g187 , depth14_g187 , amplitude14_g187 , result14_g187 );
				float localgerstner15_g187 = ( 0.0 );
				float3 position15_g187 = temp_output_23_0_g187;
				float3 direction15_g187 = temp_output_76_0_g185;
				float phase15_g187 = temp_output_24_0_g187;
				float time15_g187 = temp_output_25_0_g187;
				float gravity15_g187 = temp_output_26_0_g187;
				float depth15_g187 = temp_output_27_0_g187;
				float amplitude15_g187 = temp_output_74_0_g185;
				float3 result15_g187 = float3( 0,0,0 );
				gerstner_float( position15_g187 , direction15_g187 , phase15_g187 , time15_g187 , gravity15_g187 , depth15_g187 , amplitude15_g187 , result15_g187 );
				float3 worldToObj164_g185 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g187 + result9_g187 ) + ( result14_g187 + result15_g187 ) ) + temp_output_23_0_g187 ), 1 ) ).xyz;
				float3 normalizeResult9_g188 = normalize( ( temp_output_3_0_g188 - worldToObj164_g185 ) );
				float3 normalizeResult11_g188 = normalize( cross( normalizeResult8_g188 , normalizeResult9_g188 ) );
				float3 GerstNorm134 = normalizeResult11_g188;
				float dotResult130 = dot( GerstNorm134 , float3( 0,0,1 ) );
				float2 temp_cast_1 = (_TimeParameters.x).xx;
				float2 texCoord140 = IN.ase_texcoord1.xy * float2( 1,1 ) + temp_cast_1;
				float simplePerlin2D138 = snoise( texCoord140*0.02 );
				simplePerlin2D138 = simplePerlin2D138*0.5 + 0.5;
				float smoothstepResult147 = smoothstep( _WaveRiseThershold , lerpResult143 , ( ( (-0.1 + (simplePerlin2D126 - 0.0) * (0.1 - -0.1) / (1.0 - 0.0)) + (1.0 + (dotResult130 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) + (-0.2 + (simplePerlin2D138 - 0.0) * (0.2 - -0.2) / (1.0 - 0.0)) ));
				float waterRise149 = smoothstepResult147;
				float foam153 = step( 0.4 , ( ( ( 1.0 - smoothstepResult91 ) * clampResult107 ) + waterRise149 ) );
				

				surfaceDescription.Alpha = ( ( ( 1.0 - WaterDepth187 ) * _WaterThickness ) + foam153 );
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
						clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;

				#ifdef SCENESELECTIONPASS
					outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				#elif defined(SCENEPICKINGPASS)
					outColor = _SelectionID;
				#endif

				return outColor;
			}

			ENDHLSL
		}
		
	}
	
	CustomEditor "UnityEditor.ShaderGraphLitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-387.338,4383.654;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-384.5516,4507.337;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-388.4516,4600.938;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-383.2515,4708.837;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;65;-1023.79,4655.204;Inherit;False;True;4;0;FLOAT3;0,1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;66;-1024.897,4821.411;Inherit;False;True;4;0;FLOAT3;0,1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;118;-1434.155,3586.409;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotatorNode;121;-1202.051,3634.284;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RadiansOpNode;128;-1383.502,3738.417;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;125;-729.568,3633.885;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.1;False;4;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;136;-465.1816,3632.467;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;142;376.1527,3623.556;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-1.909436,4075.061;Inherit;False;Property;_WaveRiseFallback;WaveRiseFallback;16;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;211;1120.13,1745.131;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;212;1120.13,1745.131;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;True;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;213;1120.13,1745.131;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;214;1120.13,1745.131;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;5;False;;10;False;;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;215;1120.13,1745.131;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthNormals;0;6;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;216;1120.13,1745.131;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;GBuffer;0;7;GBuffer;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;5;False;;10;False;;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalGBuffer;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;217;1120.13,1745.131;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;SceneSelectionPass;0;8;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;218;1120.13,1745.131;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ScenePickingPass;0;9;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;229;1335.208,1450.711;Inherit;False;Constant;_Float1;Float 1;26;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-777.6666,4406.986;Inherit;False;Property;_Intensity;Intensity;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;43;-1259.004,4342.271;Inherit;False;Property;_Direction1;Direction1;2;0;Create;True;0;0;0;False;0;False;0.5,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;44;-1257.493,4494.389;Inherit;False;Property;_Direction2;Direction2;3;0;Create;True;0;0;0;False;0;False;-0.3,0,0.3;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;45;-1257.201,4641.688;Inherit;False;Property;_Direction3;Direction3;4;0;Create;True;0;0;0;False;0;False;0.1,0,-0.4;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;46;-1255.019,4822.599;Inherit;False;Property;_Direction4;Direction4;5;0;Create;True;0;0;0;False;0;False;0.01,0,0.01;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;47;-600.5735,4392.228;Inherit;False;Property;_Amplitude1;Amplitude1;6;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-603.7048,4517.831;Inherit;False;Property;_Amplitude2;Amplitude2;7;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-598.8052,4607.831;Inherit;False;Property;_Amplitude3;Amplitude3;8;0;Create;True;0;0;0;False;0;False;0.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-601.1052,4705.131;Inherit;False;Property;_Amplitude4;Amplitude4;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-390.0899,4832.997;Inherit;False;Property;_Depth;Depth;10;0;Create;True;0;0;0;False;0;False;50;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-396.8339,4927.403;Inherit;False;Property;_Phase;Phase;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-395.1481,5018.44;Inherit;False;Property;_Gravity;Gravity;12;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-463.7719,5114.636;Inherit;False;Property;_NeighbourDistance;NeighbourDistance;13;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-1668.765,4359.05;Inherit;False;Property;_Roataion;Roataion;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;209;802.098,1093.014;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.DotProductOpNode;130;-857.827,3902.563;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;131;-722.5792,3901.364;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;140;-344.4902,3775.119;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;138;-114.59,3773.893;Inherit;True;Simplex2D;True;True;2;0;FLOAT2;0,0;False;1;FLOAT;0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;141;119.4303,3774.706;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.2;False;4;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;147;566.9213,3620.511;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;143;363.9533,4028.546;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-3.185071,3996.109;Inherit;False;Property;_WaveRiseThershold;WaveRiseThershold;15;0;Create;True;0;0;0;False;0;False;0.63;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;187;-1145.108,2393.515;Inherit;False;WaterDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;72;-1103.475,2725.032;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;149;825.1532,3620.061;Inherit;False;waterRise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;73;-1318.876,2726.632;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;1000;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;-978.5084,2829.19;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;292;56.56934,2515.742;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;71;-1118.679,2530.23;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;153;649.0096,2521.256;Inherit;False;foam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-1871.695,2532.292;Inherit;False;Property;_ColorDepth;ColorDepth;14;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;-404.1041,3006.991;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;295;-828.9561,2817.641;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-1153.437,2827.453;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-657.2165,2726.569;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;298;-1637.938,2535.712;Inherit;False;WaterDepthFadeAlpha;-1;;132;ea87e8fa9c7d21a44be9a41871d57b62;0;1;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;299;-888.9248,2722.519;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;300;-207.7437,2519.582;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-1269.472,2953.675;Inherit;False;2;2;0;FLOAT;4;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;290;295.3892,2518.583;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;107;-213.6615,3003.568;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;91;-482.0674,2527.407;Inherit;False;3;0;FLOAT;0.97;False;1;FLOAT;0;False;2;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;48.0353,2701.946;Inherit;False;149;waterRise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;304;918.811,1473.864;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;189;454.2368,1059.366;Inherit;False;Property;_DeepColor;DeepColor;24;0;Create;True;0;0;0;False;0;False;0,0.08763248,0.6132076,0;0,0.08763248,0.6132076,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;188;453.0369,875.1653;Inherit;False;Property;_ShallowColor;ShallowColor;21;0;Create;True;0;0;0;False;0;False;0.5415094,0.8120804,1,0;0.5415094,0.8120804,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;284;768.9565,979.8453;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;848.8786,1735.984;Inherit;False;187;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;306;1029.932,1732.111;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;305;1177.575,1733.287;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;289;568.4344,1966.912;Inherit;False;153;foam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;307;1347.778,1771.695;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;287;-834.5835,3054.051;Inherit;True;Simplex2D;True;True;2;0;FLOAT2;0,0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;302;-564.0035,3050.795;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;312;1332.112,1282.884;Inherit;False;Constant;_Float2;Float 2;26;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;228;1333.744,1376.492;Inherit;False;Constant;_Float0;Float 0;26;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;220;525.2111,1636.545;Inherit;False;Property;_FoamEmmision;FoamEmmision;20;1;[HDR];Create;True;0;0;0;False;0;False;2,2,2,0.003921569;2,2,2,0.003921569;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;219;533.6332,1444.119;Inherit;False;Property;_Emission;Emission;19;1;[HDR];Create;True;0;0;0;False;0;False;0.06415081,0.4871341,2,0;0.06415081,0.4871341,2,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;226;1247.18,1600.706;Inherit;False;134;GerstNorm;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;227;1226.829,1523.022;Inherit;False;132;GerstPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;281;904.1102,1825.922;Inherit;False;Property;_WaterThickness;WaterThickness;17;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;126;-994.0635,3637.649;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;181;891.537,1313.804;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,1,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;377;462.8987,1312.561;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;139;-542.59,3916.893;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;210;1560.938,1289.053;Float;False;True;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;OceanSurface_Amplify;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;20;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;5;False;;10;False;;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;;0;0;Standard;41;Workflow;0;638300494971966529;Surface;1;638300532170568009;  Refraction Model;0;638300393858801420;  Blend;0;638300532503677378;Two Sided;1;638300530233978272;Fragment Normal Space,InvertActionOnDeselection;0;638300515573946518;Forward Only;1;0;Transmission;0;638300533001720014;  Transmission Shadow;0.5,False,;0;Translucency;0;638300532644099097;  Translucency Strength;1,False,;0;  Normal Distortion;0.5,False,;0;  Scattering;2,False,;0;  Direct;0.9,False,;0;  Ambient;0.1,False,;0;  Shadow;0.5,False,;0;Cast Shadows;0;638300336150030956;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;0;638300336161044116;LOD CrossFade;1;0;Built-in Fog;1;0;_FinalColorxAlpha;0;0;Meta Pass;1;638300533062819400;Override Baked GI;0;0;Extra Pre Pass;0;0;DOTS Instancing;0;638300351025897575;Tessellation;1;638300330473901041;  Phong;0;0;  Strength;0.5,False,;0;  Type;1;638300336253128043;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;1;638300529556680630;  Early Z;0;638300502736683489;Vertex Position,InvertActionOnDeselection;0;638300547132398355;Debug Display;0;638300351079489654;Clear Coat;0;0;0;10;False;True;False;True;True;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.SimpleTimeNode;84;-1487.472,3122.675;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;117;-1164.19,3059.402;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;303;481.3736,2513.962;Inherit;False;2;0;FLOAT;0.4;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;64;-1036.728,4497.36;Inherit;False;True;4;0;FLOAT3;0,1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;387;-1035.028,4334.226;Inherit;False;True;4;0;FLOAT3;0,1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;135;-1067.422,3903.422;Inherit;False;134;GerstNorm;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;361;-26.72515,1249.536;Inherit;True;Property;_NormalTexture1;NormalTexture1;22;1;[Normal];Create;True;0;0;0;False;0;False;-1;769ca6e81a779f845bdd21c6ffddc408;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;394;-350.9309,1113.298;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureTransformNode;393;-686.9309,1141.298;Inherit;False;361;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.TextureCoordinatesNode;390;-365.8002,1646.635;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;362;-30.84008,1538.619;Inherit;True;Property;_NormalTexture2;NormalTexture2;23;1;[Normal];Create;True;0;0;0;False;0;False;-1;1d07290fa3fdc52449c080dbf13c2089;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;134;266.4007,4471.351;Inherit;False;GerstNorm;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;132;268.9829,4566.814;Inherit;False;GerstPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;407;-128.875,4484.13;Inherit;False;GerstnerFinal;-1;;185;c1f434d9d858ad248a81af6b7a1b452f;0;12;80;FLOAT;0;False;82;FLOAT;0;False;81;FLOAT;0;False;79;FLOAT3;0,0,0;False;78;FLOAT3;0,0,0;False;77;FLOAT3;0,0,0;False;76;FLOAT3;0,0,0;False;84;FLOAT;0;False;73;FLOAT;0;False;75;FLOAT;0;False;74;FLOAT;0;False;143;FLOAT;0;False;2;FLOAT3;125;FLOAT3;0
Node;AmplifyShaderEditor.TextureTransformNode;396;-721.8293,1723.901;Inherit;False;362;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleAddOpNode;413;-590.5315,1311.763;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;414;-590.5315,1485.763;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;161;-1634.932,1420.865;Inherit;False;Property;_PanSpeed;PanSpeed;18;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;154;-1658.858,1281.141;Inherit;False;Constant;_Vector0;Vector 0;17;0;Create;True;0;0;0;False;0;False;0.4,1.17;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;-1433.669,1267.278;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;160;-1424.308,1557.474;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;386;-1451.325,1426.109;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;155;-1683.283,1555.878;Inherit;False;Constant;_Vector1;Vector 0;17;0;Create;True;0;0;0;False;0;False;-0.5,0.2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;398;-1209.489,1279.916;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;397;-1215.489,1550.916;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;410;-1241.774,1406.853;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;415;-1058.774,1428.853;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
WireConnection;58;0;47;0
WireConnection;58;1;57;0
WireConnection;59;0;57;0
WireConnection;59;1;48;0
WireConnection;60;0;57;0
WireConnection;60;1;49;0
WireConnection;61;0;50;0
WireConnection;61;1;57;0
WireConnection;65;1;63;0
WireConnection;65;3;45;0
WireConnection;66;1;63;0
WireConnection;66;3;46;0
WireConnection;121;0;118;0
WireConnection;121;2;128;0
WireConnection;128;0;63;0
WireConnection;125;0;126;0
WireConnection;136;0;125;0
WireConnection;136;1;131;0
WireConnection;142;0;136;0
WireConnection;142;1;141;0
WireConnection;130;0;135;0
WireConnection;131;0;130;0
WireConnection;140;1;139;0
WireConnection;138;0;140;0
WireConnection;141;0;138;0
WireConnection;147;0;142;0
WireConnection;147;1;144;0
WireConnection;147;2;143;0
WireConnection;143;0;144;0
WireConnection;143;2;145;0
WireConnection;187;0;298;0
WireConnection;72;0;73;0
WireConnection;72;1;298;0
WireConnection;149;0;147;0
WireConnection;88;0;74;0
WireConnection;88;1;87;0
WireConnection;292;0;300;0
WireConnection;292;1;107;0
WireConnection;71;0;298;0
WireConnection;153;0;303;0
WireConnection;106;0;90;0
WireConnection;106;1;302;0
WireConnection;295;0;88;0
WireConnection;74;0;298;0
WireConnection;90;0;299;0
WireConnection;90;1;295;0
WireConnection;298;8;68;0
WireConnection;299;0;72;0
WireConnection;300;0;91;0
WireConnection;87;1;84;0
WireConnection;290;0;292;0
WireConnection;290;1;151;0
WireConnection;107;0;106;0
WireConnection;91;0;71;0
WireConnection;304;0;219;0
WireConnection;304;1;220;0
WireConnection;304;2;289;0
WireConnection;284;0;188;0
WireConnection;284;1;189;0
WireConnection;284;2;289;0
WireConnection;306;0;186;0
WireConnection;305;0;306;0
WireConnection;305;1;281;0
WireConnection;307;0;305;0
WireConnection;307;1;289;0
WireConnection;287;0;117;0
WireConnection;302;0;287;0
WireConnection;126;0;121;0
WireConnection;181;0;377;0
WireConnection;181;2;289;0
WireConnection;377;0;361;0
WireConnection;377;1;362;0
WireConnection;210;0;284;0
WireConnection;210;1;181;0
WireConnection;210;2;304;0
WireConnection;210;4;228;0
WireConnection;210;5;229;0
WireConnection;210;6;307;0
WireConnection;210;8;227;0
WireConnection;210;10;226;0
WireConnection;117;1;84;0
WireConnection;303;1;290;0
WireConnection;64;1;63;0
WireConnection;64;3;44;0
WireConnection;387;1;63;0
WireConnection;387;3;43;0
WireConnection;361;1;394;0
WireConnection;394;0;393;0
WireConnection;394;1;413;0
WireConnection;390;0;396;0
WireConnection;390;1;414;0
WireConnection;362;1;390;0
WireConnection;134;0;407;125
WireConnection;132;0;407;0
WireConnection;407;80;51;0
WireConnection;407;82;52;0
WireConnection;407;81;53;0
WireConnection;407;79;387;0
WireConnection;407;78;64;0
WireConnection;407;77;65;0
WireConnection;407;76;66;0
WireConnection;407;84;58;0
WireConnection;407;73;59;0
WireConnection;407;75;60;0
WireConnection;407;74;61;0
WireConnection;407;143;54;0
WireConnection;413;0;398;0
WireConnection;413;1;415;0
WireConnection;414;0;415;0
WireConnection;414;1;397;0
WireConnection;162;0;154;0
WireConnection;162;1;161;0
WireConnection;160;0;161;0
WireConnection;160;1;155;0
WireConnection;398;0;162;0
WireConnection;398;1;386;0
WireConnection;397;0;386;0
WireConnection;397;1;160;0
WireConnection;415;0;410;1
WireConnection;415;1;410;2
ASEEND*/
//CHKSM=27ECB9CF7A3C2E01B3B5277D28D0263F38B5273F