// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "OceanSurface_Amplify"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Header(WaveGeneration)]_Intensity("Intensity", Float) = 1
		_Roataion("Roataion", Float) = 0
		_Direction1("Direction1", Vector) = (0.5,0,0,0)
		_Direction2("Direction2", Vector) = (-0.3,0,0.3,0)
		_Direction3("Direction3", Vector) = (0.1,0,-0.4,0)
		_Direction4("Direction4", Vector) = (0.01,0,0.01,0)
		_Amplitude1("Amplitude1", Float) = 1.5
		_Amplitude2("Amplitude2", Float) = 0.2
		_Amplitude3("Amplitude3", Float) = 0.3
		_Amplitude4("Amplitude4", Float) = 0
		_WaveDepth("WaveDepth", Float) = 50
		_Phase("Phase", Float) = 0
		_Gravity("Gravity", Float) = 0.2
		_NeighbourDistance("NeighbourDistance", Float) = 0.1
		[Header(Depth Settings)]_DepthDistance("DepthDistance", Float) = 5
		[Header(RiseTide)]_RiseThreshold("RiseThreshold", Range( 0 , 1)) = 0.63
		[Header(RiseTide)]_RiseFadeout("RiseFadeout", Range( 0 , 1)) = 0
		_NormalPanSpeed("NormalPanSpeed", Float) = 1
		_NormalTexture1("NormalTexture1", 2D) = "bump" {}
		_NormalTexture2("NormalTexture2", 2D) = "bump" {}
		_NormalStrength("NormalStrength", Float) = 1
		_ShallowColor("ShallowColor", Color) = (0.2268067,0.2911928,0.4339623,0)
		_DeepColor("DeepColor", Color) = (0.1320755,0.1320755,0.1320755,0)
		[HDR]_FoamColor("FoamColor", Color) = (2,2,2,0)
		[HDR]_Emmision("Emmision", Color) = (0,0.4158199,1,0)
		_WaterThickness("WaterThickness", Float) = 3


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
			Tags { "LightMode"="UniversalForward" }

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
			#define _NORMAL_DROPOFF_TS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_DISTANCE_TESSELLATION
			#define ASE_DEPTH_WRITE_ON
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1
			#define ASE_USING_SAMPLING_MACROS 1


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
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_POSITION


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
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FoamColor;
			float4 _NormalTexture2_ST;
			float4 _NormalTexture1_ST;
			float4 _Emmision;
			float4 _DeepColor;
			float4 _ShallowColor;
			float3 _Direction4;
			float3 _Direction1;
			float3 _Direction2;
			float3 _Direction3;
			float _RiseFadeout;
			float _RiseThreshold;
			float _NormalStrength;
			float _NormalPanSpeed;
			float _DepthDistance;
			float _NeighbourDistance;
			float _Amplitude3;
			float _Amplitude2;
			float _Intensity;
			float _Amplitude1;
			float _WaveDepth;
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
			TEXTURE2D(_NormalTexture1);
			SAMPLER(sampler_NormalTexture1);
			TEXTURE2D(_NormalTexture2);
			SAMPLER(sampler_NormalTexture2);


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
			
			inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }
			inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }
			inline float valueNoise (float2 uv)
			{
				float2 i = floor(uv);
				float2 f = frac( uv );
				f = f* f * (3.0 - 2.0 * f);
				uv = abs( frac(uv) - 0.5);
				float2 c0 = i + float2( 0.0, 0.0 );
				float2 c1 = i + float2( 1.0, 0.0 );
				float2 c2 = i + float2( 0.0, 1.0 );
				float2 c3 = i + float2( 1.0, 1.0 );
				float r0 = noise_randomValue( c0 );
				float r1 = noise_randomValue( c1 );
				float r2 = noise_randomValue( c2 );
				float r3 = noise_randomValue( c3 );
				float bottomOfGrid = noise_interpolate( r0, r1, f.x );
				float topOfGrid = noise_interpolate( r2, r3, f.x );
				float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
				return t;
			}
			
			float SimpleNoise(float2 UV)
			{
				float t = 0.0;
				float freq = pow( 2.0, float( 0 ) );
				float amp = pow( 0.5, float( 3 - 0 ) );
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(1));
				amp = pow(0.5, float(3-1));
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(2));
				amp = pow(0.5, float(3-2));
				t += valueNoise( UV/freq )*amp;
				return t;
			}
			
			float2 UnityGradientNoiseDir( float2 p )
			{
				p = fmod(p , 289);
				float x = fmod((34 * p.x + 1) * p.x , 289) + p.y;
				x = fmod( (34 * x + 1) * x , 289);
				x = frac( x / 41 ) * 2 - 1;
				return normalize( float2(x - floor(x + 0.5 ), abs( x ) - 0.5 ) );
			}
			
			float UnityGradientNoise( float2 UV, float Scale )
			{
				float2 p = UV * Scale;
				float2 ip = floor( p );
				float2 fp = frac( p );
				float d00 = dot( UnityGradientNoiseDir( ip ), fp );
				float d01 = dot( UnityGradientNoiseDir( ip + float2( 0, 1 ) ), fp - float2( 0, 1 ) );
				float d10 = dot( UnityGradientNoiseDir( ip + float2( 1, 0 ) ), fp - float2( 1, 0 ) );
				float d11 = dot( UnityGradientNoiseDir( ip + float2( 1, 1 ) ), fp - float2( 1, 1 ) );
				fp = fp * fp * fp * ( fp * ( fp * 6 - 15 ) + 10 );
				return lerp( lerp( d00, d01, fp.y ), lerp( d10, d11, fp.y ), fp.x ) + 0.5;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float localgerstner4_g24 = ( 0.0 );
				float3 objToWorld179_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float temp_output_143_0_g1 = _NeighbourDistance;
				float3 appendResult142_g1 = (float3(temp_output_143_0_g1 , 0.0 , 0.0));
				float3 temp_output_23_0_g24 = ( objToWorld179_g1 + appendResult142_g1 );
				float3 position4_g24 = temp_output_23_0_g24;
				float temp_output_615_0 = radians( _Roataion );
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_79_0_g1 = rotatedValue387;
				float3 direction4_g24 = temp_output_79_0_g1;
				float temp_output_82_0_g1 = _Phase;
				float temp_output_24_0_g24 = temp_output_82_0_g1;
				float phase4_g24 = temp_output_24_0_g24;
				float temp_output_25_0_g24 = _TimeParameters.x;
				float time4_g24 = temp_output_25_0_g24;
				float temp_output_81_0_g1 = _Gravity;
				float temp_output_26_0_g24 = temp_output_81_0_g1;
				float gravity4_g24 = temp_output_26_0_g24;
				float temp_output_80_0_g1 = _WaveDepth;
				float temp_output_27_0_g24 = temp_output_80_0_g1;
				float depth4_g24 = temp_output_27_0_g24;
				float temp_output_84_0_g1 = ( _Amplitude1 * _Intensity );
				float amplitude4_g24 = temp_output_84_0_g1;
				float3 result4_g24 = float3( 0,0,0 );
				gerstner_float( position4_g24 , direction4_g24 , phase4_g24 , time4_g24 , gravity4_g24 , depth4_g24 , amplitude4_g24 , result4_g24 );
				float localgerstner9_g24 = ( 0.0 );
				float3 position9_g24 = temp_output_23_0_g24;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_78_0_g1 = rotatedValue64;
				float3 direction9_g24 = temp_output_78_0_g1;
				float phase9_g24 = temp_output_24_0_g24;
				float time9_g24 = temp_output_25_0_g24;
				float gravity9_g24 = temp_output_26_0_g24;
				float depth9_g24 = temp_output_27_0_g24;
				float temp_output_73_0_g1 = ( _Intensity * _Amplitude2 );
				float amplitude9_g24 = temp_output_73_0_g1;
				float3 result9_g24 = float3( 0,0,0 );
				gerstner_float( position9_g24 , direction9_g24 , phase9_g24 , time9_g24 , gravity9_g24 , depth9_g24 , amplitude9_g24 , result9_g24 );
				float localgerstner14_g24 = ( 0.0 );
				float3 position14_g24 = temp_output_23_0_g24;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_77_0_g1 = rotatedValue65;
				float3 direction14_g24 = temp_output_77_0_g1;
				float phase14_g24 = temp_output_24_0_g24;
				float time14_g24 = temp_output_25_0_g24;
				float gravity14_g24 = temp_output_26_0_g24;
				float depth14_g24 = temp_output_27_0_g24;
				float temp_output_75_0_g1 = ( _Intensity * _Amplitude3 );
				float amplitude14_g24 = temp_output_75_0_g1;
				float3 result14_g24 = float3( 0,0,0 );
				gerstner_float( position14_g24 , direction14_g24 , phase14_g24 , time14_g24 , gravity14_g24 , depth14_g24 , amplitude14_g24 , result14_g24 );
				float localgerstner15_g24 = ( 0.0 );
				float3 position15_g24 = temp_output_23_0_g24;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_76_0_g1 = rotatedValue66;
				float3 direction15_g24 = temp_output_76_0_g1;
				float phase15_g24 = temp_output_24_0_g24;
				float time15_g24 = temp_output_25_0_g24;
				float gravity15_g24 = temp_output_26_0_g24;
				float depth15_g24 = temp_output_27_0_g24;
				float temp_output_74_0_g1 = ( _Amplitude4 * _Intensity );
				float amplitude15_g24 = temp_output_74_0_g1;
				float3 result15_g24 = float3( 0,0,0 );
				gerstner_float( position15_g24 , direction15_g24 , phase15_g24 , time15_g24 , gravity15_g24 , depth15_g24 , amplitude15_g24 , result15_g24 );
				float3 worldToObj156_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g24 + result9_g24 ) + ( result14_g24 + result15_g24 ) ) + temp_output_23_0_g24 ), 1 ) ).xyz;
				float3 GerstPos132 = worldToObj156_g1;
				
				float localgerstner4_g28 = ( 0.0 );
				float3 objToWorld182_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 appendResult174_g1 = (float3(0.0 , temp_output_143_0_g1 , 0.0));
				float3 temp_output_23_0_g28 = ( objToWorld182_g1 + appendResult174_g1 );
				float3 position4_g28 = temp_output_23_0_g28;
				float3 direction4_g28 = temp_output_79_0_g1;
				float temp_output_24_0_g28 = temp_output_82_0_g1;
				float phase4_g28 = temp_output_24_0_g28;
				float temp_output_25_0_g28 = _TimeParameters.x;
				float time4_g28 = temp_output_25_0_g28;
				float temp_output_26_0_g28 = temp_output_81_0_g1;
				float gravity4_g28 = temp_output_26_0_g28;
				float temp_output_27_0_g28 = temp_output_80_0_g1;
				float depth4_g28 = temp_output_27_0_g28;
				float amplitude4_g28 = temp_output_84_0_g1;
				float3 result4_g28 = float3( 0,0,0 );
				gerstner_float( position4_g28 , direction4_g28 , phase4_g28 , time4_g28 , gravity4_g28 , depth4_g28 , amplitude4_g28 , result4_g28 );
				float localgerstner9_g28 = ( 0.0 );
				float3 position9_g28 = temp_output_23_0_g28;
				float3 direction9_g28 = temp_output_78_0_g1;
				float phase9_g28 = temp_output_24_0_g28;
				float time9_g28 = temp_output_25_0_g28;
				float gravity9_g28 = temp_output_26_0_g28;
				float depth9_g28 = temp_output_27_0_g28;
				float amplitude9_g28 = temp_output_73_0_g1;
				float3 result9_g28 = float3( 0,0,0 );
				gerstner_float( position9_g28 , direction9_g28 , phase9_g28 , time9_g28 , gravity9_g28 , depth9_g28 , amplitude9_g28 , result9_g28 );
				float localgerstner14_g28 = ( 0.0 );
				float3 position14_g28 = temp_output_23_0_g28;
				float3 direction14_g28 = temp_output_77_0_g1;
				float phase14_g28 = temp_output_24_0_g28;
				float time14_g28 = temp_output_25_0_g28;
				float gravity14_g28 = temp_output_26_0_g28;
				float depth14_g28 = temp_output_27_0_g28;
				float amplitude14_g28 = temp_output_75_0_g1;
				float3 result14_g28 = float3( 0,0,0 );
				gerstner_float( position14_g28 , direction14_g28 , phase14_g28 , time14_g28 , gravity14_g28 , depth14_g28 , amplitude14_g28 , result14_g28 );
				float localgerstner15_g28 = ( 0.0 );
				float3 position15_g28 = temp_output_23_0_g28;
				float3 direction15_g28 = temp_output_76_0_g1;
				float phase15_g28 = temp_output_24_0_g28;
				float time15_g28 = temp_output_25_0_g28;
				float gravity15_g28 = temp_output_26_0_g28;
				float depth15_g28 = temp_output_27_0_g28;
				float amplitude15_g28 = temp_output_74_0_g1;
				float3 result15_g28 = float3( 0,0,0 );
				gerstner_float( position15_g28 , direction15_g28 , phase15_g28 , time15_g28 , gravity15_g28 , depth15_g28 , amplitude15_g28 , result15_g28 );
				float3 worldToObj155_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g28 + result9_g28 ) + ( result14_g28 + result15_g28 ) ) + temp_output_23_0_g28 ), 1 ) ).xyz;
				float3 temp_output_3_0_g29 = worldToObj155_g1;
				float3 normalizeResult8_g29 = normalize( ( worldToObj156_g1 - temp_output_3_0_g29 ) );
				float localgerstner4_g26 = ( 0.0 );
				float3 objToWorld184_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 appendResult136_g1 = (float3(0.0 , 0.0 , temp_output_143_0_g1));
				float3 temp_output_23_0_g26 = ( objToWorld184_g1 + appendResult136_g1 );
				float3 position4_g26 = temp_output_23_0_g26;
				float3 direction4_g26 = temp_output_79_0_g1;
				float temp_output_24_0_g26 = temp_output_82_0_g1;
				float phase4_g26 = temp_output_24_0_g26;
				float temp_output_25_0_g26 = _TimeParameters.x;
				float time4_g26 = temp_output_25_0_g26;
				float temp_output_26_0_g26 = temp_output_81_0_g1;
				float gravity4_g26 = temp_output_26_0_g26;
				float temp_output_27_0_g26 = temp_output_80_0_g1;
				float depth4_g26 = temp_output_27_0_g26;
				float amplitude4_g26 = temp_output_84_0_g1;
				float3 result4_g26 = float3( 0,0,0 );
				gerstner_float( position4_g26 , direction4_g26 , phase4_g26 , time4_g26 , gravity4_g26 , depth4_g26 , amplitude4_g26 , result4_g26 );
				float localgerstner9_g26 = ( 0.0 );
				float3 position9_g26 = temp_output_23_0_g26;
				float3 direction9_g26 = temp_output_78_0_g1;
				float phase9_g26 = temp_output_24_0_g26;
				float time9_g26 = temp_output_25_0_g26;
				float gravity9_g26 = temp_output_26_0_g26;
				float depth9_g26 = temp_output_27_0_g26;
				float amplitude9_g26 = temp_output_73_0_g1;
				float3 result9_g26 = float3( 0,0,0 );
				gerstner_float( position9_g26 , direction9_g26 , phase9_g26 , time9_g26 , gravity9_g26 , depth9_g26 , amplitude9_g26 , result9_g26 );
				float localgerstner14_g26 = ( 0.0 );
				float3 position14_g26 = temp_output_23_0_g26;
				float3 direction14_g26 = temp_output_77_0_g1;
				float phase14_g26 = temp_output_24_0_g26;
				float time14_g26 = temp_output_25_0_g26;
				float gravity14_g26 = temp_output_26_0_g26;
				float depth14_g26 = temp_output_27_0_g26;
				float amplitude14_g26 = temp_output_75_0_g1;
				float3 result14_g26 = float3( 0,0,0 );
				gerstner_float( position14_g26 , direction14_g26 , phase14_g26 , time14_g26 , gravity14_g26 , depth14_g26 , amplitude14_g26 , result14_g26 );
				float localgerstner15_g26 = ( 0.0 );
				float3 position15_g26 = temp_output_23_0_g26;
				float3 direction15_g26 = temp_output_76_0_g1;
				float phase15_g26 = temp_output_24_0_g26;
				float time15_g26 = temp_output_25_0_g26;
				float gravity15_g26 = temp_output_26_0_g26;
				float depth15_g26 = temp_output_27_0_g26;
				float amplitude15_g26 = temp_output_74_0_g1;
				float3 result15_g26 = float3( 0,0,0 );
				gerstner_float( position15_g26 , direction15_g26 , phase15_g26 , time15_g26 , gravity15_g26 , depth15_g26 , amplitude15_g26 , result15_g26 );
				float3 worldToObj164_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g26 + result9_g26 ) + ( result14_g26 + result15_g26 ) ) + temp_output_23_0_g26 ), 1 ) ).xyz;
				float3 normalizeResult9_g29 = normalize( ( temp_output_3_0_g29 - worldToObj164_g1 ) );
				float3 normalizeResult11_g29 = normalize( cross( normalizeResult8_g29 , normalizeResult9_g29 ) );
				float3 GerstNorm134 = normalizeResult11_g29;
				
				o.ase_texcoord8.xy = v.texcoord.xy;
				o.ase_texcoord9 = v.vertex;
				
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
				float screenDepth498 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth498 = saturate( ( screenDepth498 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthDistance ) );
				float Depth500 = distanceDepth498;
				float4 lerpResult590 = lerp( _ShallowColor , _DeepColor , Depth500);
				
				float mulTime568 = _TimeParameters.x * _NormalPanSpeed;
				float2 appendResult574 = (float2(WorldPosition.x , WorldPosition.z));
				float2 texCoord577 = IN.ase_texcoord8.xy * _NormalTexture1_ST.xy + ( ( float2( 0.4,0.17 ) * mulTime568 ) + appendResult574 );
				float3 unpack580 = UnpackNormalScale( SAMPLE_TEXTURE2D( _NormalTexture1, sampler_NormalTexture1, texCoord577 ), _NormalStrength );
				unpack580.z = lerp( 1, unpack580.z, saturate(_NormalStrength) );
				float2 texCoord582 = IN.ase_texcoord8.xy * _NormalTexture2_ST.xy + ( appendResult574 + ( mulTime568 * float2( -0.5,0.2 ) ) );
				float3 unpack584 = UnpackNormalScale( SAMPLE_TEXTURE2D( _NormalTexture2, sampler_NormalTexture2, texCoord582 ), _NormalStrength );
				unpack584.z = lerp( 1, unpack584.z, saturate(_NormalStrength) );
				float lerpResult558 = lerp( _RiseThreshold , 1.0 , _RiseFadeout);
				float localgerstner4_g24 = ( 0.0 );
				float3 objToWorld179_g1 = mul( GetObjectToWorldMatrix(), float4( IN.ase_texcoord9.xyz, 1 ) ).xyz;
				float temp_output_143_0_g1 = _NeighbourDistance;
				float3 appendResult142_g1 = (float3(temp_output_143_0_g1 , 0.0 , 0.0));
				float3 temp_output_23_0_g24 = ( objToWorld179_g1 + appendResult142_g1 );
				float3 position4_g24 = temp_output_23_0_g24;
				float temp_output_615_0 = radians( _Roataion );
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_79_0_g1 = rotatedValue387;
				float3 direction4_g24 = temp_output_79_0_g1;
				float temp_output_82_0_g1 = _Phase;
				float temp_output_24_0_g24 = temp_output_82_0_g1;
				float phase4_g24 = temp_output_24_0_g24;
				float temp_output_25_0_g24 = _TimeParameters.x;
				float time4_g24 = temp_output_25_0_g24;
				float temp_output_81_0_g1 = _Gravity;
				float temp_output_26_0_g24 = temp_output_81_0_g1;
				float gravity4_g24 = temp_output_26_0_g24;
				float temp_output_80_0_g1 = _WaveDepth;
				float temp_output_27_0_g24 = temp_output_80_0_g1;
				float depth4_g24 = temp_output_27_0_g24;
				float temp_output_84_0_g1 = ( _Amplitude1 * _Intensity );
				float amplitude4_g24 = temp_output_84_0_g1;
				float3 result4_g24 = float3( 0,0,0 );
				gerstner_float( position4_g24 , direction4_g24 , phase4_g24 , time4_g24 , gravity4_g24 , depth4_g24 , amplitude4_g24 , result4_g24 );
				float localgerstner9_g24 = ( 0.0 );
				float3 position9_g24 = temp_output_23_0_g24;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_78_0_g1 = rotatedValue64;
				float3 direction9_g24 = temp_output_78_0_g1;
				float phase9_g24 = temp_output_24_0_g24;
				float time9_g24 = temp_output_25_0_g24;
				float gravity9_g24 = temp_output_26_0_g24;
				float depth9_g24 = temp_output_27_0_g24;
				float temp_output_73_0_g1 = ( _Intensity * _Amplitude2 );
				float amplitude9_g24 = temp_output_73_0_g1;
				float3 result9_g24 = float3( 0,0,0 );
				gerstner_float( position9_g24 , direction9_g24 , phase9_g24 , time9_g24 , gravity9_g24 , depth9_g24 , amplitude9_g24 , result9_g24 );
				float localgerstner14_g24 = ( 0.0 );
				float3 position14_g24 = temp_output_23_0_g24;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_77_0_g1 = rotatedValue65;
				float3 direction14_g24 = temp_output_77_0_g1;
				float phase14_g24 = temp_output_24_0_g24;
				float time14_g24 = temp_output_25_0_g24;
				float gravity14_g24 = temp_output_26_0_g24;
				float depth14_g24 = temp_output_27_0_g24;
				float temp_output_75_0_g1 = ( _Intensity * _Amplitude3 );
				float amplitude14_g24 = temp_output_75_0_g1;
				float3 result14_g24 = float3( 0,0,0 );
				gerstner_float( position14_g24 , direction14_g24 , phase14_g24 , time14_g24 , gravity14_g24 , depth14_g24 , amplitude14_g24 , result14_g24 );
				float localgerstner15_g24 = ( 0.0 );
				float3 position15_g24 = temp_output_23_0_g24;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_76_0_g1 = rotatedValue66;
				float3 direction15_g24 = temp_output_76_0_g1;
				float phase15_g24 = temp_output_24_0_g24;
				float time15_g24 = temp_output_25_0_g24;
				float gravity15_g24 = temp_output_26_0_g24;
				float depth15_g24 = temp_output_27_0_g24;
				float temp_output_74_0_g1 = ( _Amplitude4 * _Intensity );
				float amplitude15_g24 = temp_output_74_0_g1;
				float3 result15_g24 = float3( 0,0,0 );
				gerstner_float( position15_g24 , direction15_g24 , phase15_g24 , time15_g24 , gravity15_g24 , depth15_g24 , amplitude15_g24 , result15_g24 );
				float3 worldToObj156_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g24 + result9_g24 ) + ( result14_g24 + result15_g24 ) ) + temp_output_23_0_g24 ), 1 ) ).xyz;
				float localgerstner4_g28 = ( 0.0 );
				float3 objToWorld182_g1 = mul( GetObjectToWorldMatrix(), float4( IN.ase_texcoord9.xyz, 1 ) ).xyz;
				float3 appendResult174_g1 = (float3(0.0 , temp_output_143_0_g1 , 0.0));
				float3 temp_output_23_0_g28 = ( objToWorld182_g1 + appendResult174_g1 );
				float3 position4_g28 = temp_output_23_0_g28;
				float3 direction4_g28 = temp_output_79_0_g1;
				float temp_output_24_0_g28 = temp_output_82_0_g1;
				float phase4_g28 = temp_output_24_0_g28;
				float temp_output_25_0_g28 = _TimeParameters.x;
				float time4_g28 = temp_output_25_0_g28;
				float temp_output_26_0_g28 = temp_output_81_0_g1;
				float gravity4_g28 = temp_output_26_0_g28;
				float temp_output_27_0_g28 = temp_output_80_0_g1;
				float depth4_g28 = temp_output_27_0_g28;
				float amplitude4_g28 = temp_output_84_0_g1;
				float3 result4_g28 = float3( 0,0,0 );
				gerstner_float( position4_g28 , direction4_g28 , phase4_g28 , time4_g28 , gravity4_g28 , depth4_g28 , amplitude4_g28 , result4_g28 );
				float localgerstner9_g28 = ( 0.0 );
				float3 position9_g28 = temp_output_23_0_g28;
				float3 direction9_g28 = temp_output_78_0_g1;
				float phase9_g28 = temp_output_24_0_g28;
				float time9_g28 = temp_output_25_0_g28;
				float gravity9_g28 = temp_output_26_0_g28;
				float depth9_g28 = temp_output_27_0_g28;
				float amplitude9_g28 = temp_output_73_0_g1;
				float3 result9_g28 = float3( 0,0,0 );
				gerstner_float( position9_g28 , direction9_g28 , phase9_g28 , time9_g28 , gravity9_g28 , depth9_g28 , amplitude9_g28 , result9_g28 );
				float localgerstner14_g28 = ( 0.0 );
				float3 position14_g28 = temp_output_23_0_g28;
				float3 direction14_g28 = temp_output_77_0_g1;
				float phase14_g28 = temp_output_24_0_g28;
				float time14_g28 = temp_output_25_0_g28;
				float gravity14_g28 = temp_output_26_0_g28;
				float depth14_g28 = temp_output_27_0_g28;
				float amplitude14_g28 = temp_output_75_0_g1;
				float3 result14_g28 = float3( 0,0,0 );
				gerstner_float( position14_g28 , direction14_g28 , phase14_g28 , time14_g28 , gravity14_g28 , depth14_g28 , amplitude14_g28 , result14_g28 );
				float localgerstner15_g28 = ( 0.0 );
				float3 position15_g28 = temp_output_23_0_g28;
				float3 direction15_g28 = temp_output_76_0_g1;
				float phase15_g28 = temp_output_24_0_g28;
				float time15_g28 = temp_output_25_0_g28;
				float gravity15_g28 = temp_output_26_0_g28;
				float depth15_g28 = temp_output_27_0_g28;
				float amplitude15_g28 = temp_output_74_0_g1;
				float3 result15_g28 = float3( 0,0,0 );
				gerstner_float( position15_g28 , direction15_g28 , phase15_g28 , time15_g28 , gravity15_g28 , depth15_g28 , amplitude15_g28 , result15_g28 );
				float3 worldToObj155_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g28 + result9_g28 ) + ( result14_g28 + result15_g28 ) ) + temp_output_23_0_g28 ), 1 ) ).xyz;
				float3 temp_output_3_0_g29 = worldToObj155_g1;
				float3 normalizeResult8_g29 = normalize( ( worldToObj156_g1 - temp_output_3_0_g29 ) );
				float localgerstner4_g26 = ( 0.0 );
				float3 objToWorld184_g1 = mul( GetObjectToWorldMatrix(), float4( IN.ase_texcoord9.xyz, 1 ) ).xyz;
				float3 appendResult136_g1 = (float3(0.0 , 0.0 , temp_output_143_0_g1));
				float3 temp_output_23_0_g26 = ( objToWorld184_g1 + appendResult136_g1 );
				float3 position4_g26 = temp_output_23_0_g26;
				float3 direction4_g26 = temp_output_79_0_g1;
				float temp_output_24_0_g26 = temp_output_82_0_g1;
				float phase4_g26 = temp_output_24_0_g26;
				float temp_output_25_0_g26 = _TimeParameters.x;
				float time4_g26 = temp_output_25_0_g26;
				float temp_output_26_0_g26 = temp_output_81_0_g1;
				float gravity4_g26 = temp_output_26_0_g26;
				float temp_output_27_0_g26 = temp_output_80_0_g1;
				float depth4_g26 = temp_output_27_0_g26;
				float amplitude4_g26 = temp_output_84_0_g1;
				float3 result4_g26 = float3( 0,0,0 );
				gerstner_float( position4_g26 , direction4_g26 , phase4_g26 , time4_g26 , gravity4_g26 , depth4_g26 , amplitude4_g26 , result4_g26 );
				float localgerstner9_g26 = ( 0.0 );
				float3 position9_g26 = temp_output_23_0_g26;
				float3 direction9_g26 = temp_output_78_0_g1;
				float phase9_g26 = temp_output_24_0_g26;
				float time9_g26 = temp_output_25_0_g26;
				float gravity9_g26 = temp_output_26_0_g26;
				float depth9_g26 = temp_output_27_0_g26;
				float amplitude9_g26 = temp_output_73_0_g1;
				float3 result9_g26 = float3( 0,0,0 );
				gerstner_float( position9_g26 , direction9_g26 , phase9_g26 , time9_g26 , gravity9_g26 , depth9_g26 , amplitude9_g26 , result9_g26 );
				float localgerstner14_g26 = ( 0.0 );
				float3 position14_g26 = temp_output_23_0_g26;
				float3 direction14_g26 = temp_output_77_0_g1;
				float phase14_g26 = temp_output_24_0_g26;
				float time14_g26 = temp_output_25_0_g26;
				float gravity14_g26 = temp_output_26_0_g26;
				float depth14_g26 = temp_output_27_0_g26;
				float amplitude14_g26 = temp_output_75_0_g1;
				float3 result14_g26 = float3( 0,0,0 );
				gerstner_float( position14_g26 , direction14_g26 , phase14_g26 , time14_g26 , gravity14_g26 , depth14_g26 , amplitude14_g26 , result14_g26 );
				float localgerstner15_g26 = ( 0.0 );
				float3 position15_g26 = temp_output_23_0_g26;
				float3 direction15_g26 = temp_output_76_0_g1;
				float phase15_g26 = temp_output_24_0_g26;
				float time15_g26 = temp_output_25_0_g26;
				float gravity15_g26 = temp_output_26_0_g26;
				float depth15_g26 = temp_output_27_0_g26;
				float amplitude15_g26 = temp_output_74_0_g1;
				float3 result15_g26 = float3( 0,0,0 );
				gerstner_float( position15_g26 , direction15_g26 , phase15_g26 , time15_g26 , gravity15_g26 , depth15_g26 , amplitude15_g26 , result15_g26 );
				float3 worldToObj164_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g26 + result9_g26 ) + ( result14_g26 + result15_g26 ) ) + temp_output_23_0_g26 ), 1 ) ).xyz;
				float3 normalizeResult9_g29 = normalize( ( temp_output_3_0_g29 - worldToObj164_g1 ) );
				float3 normalizeResult11_g29 = normalize( cross( normalizeResult8_g29 , normalizeResult9_g29 ) );
				float3 GerstNorm134 = normalizeResult11_g29;
				float4 temp_output_6_0_g30 = float4( 0,1,0,0 );
				float dotResult1_g30 = dot( float4( GerstNorm134 , 0.0 ) , temp_output_6_0_g30 );
				float dotResult2_g30 = dot( temp_output_6_0_g30 , temp_output_6_0_g30 );
				float2 appendResult536 = (float2(WorldPosition.x , WorldPosition.z));
				float2 texCoord537 = IN.ase_texcoord8.xy * float2( 1,1 ) + appendResult536;
				float rotation543 = temp_output_615_0;
				float cos539 = cos( rotation543 );
				float sin539 = sin( rotation543 );
				float2 rotator539 = mul( texCoord537 - float2( 0.5,0.5 ) , float2x2( cos539 , -sin539 , sin539 , cos539 )) + float2( 0.5,0.5 );
				float simpleNoise545 = SimpleNoise( rotator539*5.0 );
				float2 texCoord553 = IN.ase_texcoord8.xy * float2( 1,1 ) + ( appendResult536 + _TimeParameters.x );
				float gradientNoise554 = UnityGradientNoise(texCoord553,0.02);
				gradientNoise554 = gradientNoise554*0.5 + 0.5;
				float smoothstepResult559 = smoothstep( _RiseThreshold , lerpResult558 , ( (1.0 + (length( ( ( dotResult1_g30 / dotResult2_g30 ) * temp_output_6_0_g30 ) ) - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) + (-0.1 + (simpleNoise545 - 0.0) * (0.1 - -0.1) / (1.0 - 0.0)) + (-0.3 + (gradientNoise554 - 0.0) * (0.3 - -0.3) / (1.0 - 0.0)) ));
				float RiseTide560 = smoothstepResult559;
				float smoothstepResult523 = smoothstep( 0.97 , 1.0 , (1.0 + (distanceDepth498 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
				float2 appendResult510 = (float2(WorldPosition.x , WorldPosition.z));
				float2 texCoord517 = IN.ase_texcoord8.xy * float2( 1,1 ) + ( ( _TimeParameters.x * 0.5 ) + appendResult510 );
				float gradientNoise516 = UnityGradientNoise(texCoord517,2.15);
				gradientNoise516 = gradientNoise516*0.5 + 0.5;
				float clampResult526 = clamp( ( ( pow( ( 1.0 / 1000.0 ) , distanceDepth498 ) * cos( ( ( distanceDepth498 * 100.0 ) + ( 4.0 * _TimeParameters.x ) ) ) ) * ( 0.5 + gradientNoise516 ) ) , -0.1 , 1.0 );
				float Foam564 = step( ( RiseTide560 + smoothstepResult523 + clampResult526 ) , 0.5 );
				float3 lerpResult587 = lerp( float3( 0.5,0.5,1 ) , BlendNormal( unpack580 , unpack584 ) , Foam564);
				
				float4 lerpResult607 = lerp( _FoamColor , _Emmision , Foam564);
				

				float3 BaseColor = lerpResult590.rgb;
				float3 Normal = lerpResult587;
				float3 Emission = lerpResult607.rgb;
				float3 Specular = 0.5;
				float Metallic = 0.5;
				float Smoothness = 1.0;
				float Occlusion = 0.0;
				float Alpha = ( Depth500 * _WaterThickness );
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
			#define _NORMAL_DROPOFF_TS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_DISTANCE_TESSELLATION
			#define ASE_DEPTH_WRITE_ON
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1
			#define ASE_USING_SAMPLING_MACROS 1


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
			#define ASE_NEEDS_VERT_POSITION
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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FoamColor;
			float4 _NormalTexture2_ST;
			float4 _NormalTexture1_ST;
			float4 _Emmision;
			float4 _DeepColor;
			float4 _ShallowColor;
			float3 _Direction4;
			float3 _Direction1;
			float3 _Direction2;
			float3 _Direction3;
			float _RiseFadeout;
			float _RiseThreshold;
			float _NormalStrength;
			float _NormalPanSpeed;
			float _DepthDistance;
			float _NeighbourDistance;
			float _Amplitude3;
			float _Amplitude2;
			float _Intensity;
			float _Amplitude1;
			float _WaveDepth;
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
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float localgerstner4_g24 = ( 0.0 );
				float3 objToWorld179_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float temp_output_143_0_g1 = _NeighbourDistance;
				float3 appendResult142_g1 = (float3(temp_output_143_0_g1 , 0.0 , 0.0));
				float3 temp_output_23_0_g24 = ( objToWorld179_g1 + appendResult142_g1 );
				float3 position4_g24 = temp_output_23_0_g24;
				float temp_output_615_0 = radians( _Roataion );
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_79_0_g1 = rotatedValue387;
				float3 direction4_g24 = temp_output_79_0_g1;
				float temp_output_82_0_g1 = _Phase;
				float temp_output_24_0_g24 = temp_output_82_0_g1;
				float phase4_g24 = temp_output_24_0_g24;
				float temp_output_25_0_g24 = _TimeParameters.x;
				float time4_g24 = temp_output_25_0_g24;
				float temp_output_81_0_g1 = _Gravity;
				float temp_output_26_0_g24 = temp_output_81_0_g1;
				float gravity4_g24 = temp_output_26_0_g24;
				float temp_output_80_0_g1 = _WaveDepth;
				float temp_output_27_0_g24 = temp_output_80_0_g1;
				float depth4_g24 = temp_output_27_0_g24;
				float temp_output_84_0_g1 = ( _Amplitude1 * _Intensity );
				float amplitude4_g24 = temp_output_84_0_g1;
				float3 result4_g24 = float3( 0,0,0 );
				gerstner_float( position4_g24 , direction4_g24 , phase4_g24 , time4_g24 , gravity4_g24 , depth4_g24 , amplitude4_g24 , result4_g24 );
				float localgerstner9_g24 = ( 0.0 );
				float3 position9_g24 = temp_output_23_0_g24;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_78_0_g1 = rotatedValue64;
				float3 direction9_g24 = temp_output_78_0_g1;
				float phase9_g24 = temp_output_24_0_g24;
				float time9_g24 = temp_output_25_0_g24;
				float gravity9_g24 = temp_output_26_0_g24;
				float depth9_g24 = temp_output_27_0_g24;
				float temp_output_73_0_g1 = ( _Intensity * _Amplitude2 );
				float amplitude9_g24 = temp_output_73_0_g1;
				float3 result9_g24 = float3( 0,0,0 );
				gerstner_float( position9_g24 , direction9_g24 , phase9_g24 , time9_g24 , gravity9_g24 , depth9_g24 , amplitude9_g24 , result9_g24 );
				float localgerstner14_g24 = ( 0.0 );
				float3 position14_g24 = temp_output_23_0_g24;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_77_0_g1 = rotatedValue65;
				float3 direction14_g24 = temp_output_77_0_g1;
				float phase14_g24 = temp_output_24_0_g24;
				float time14_g24 = temp_output_25_0_g24;
				float gravity14_g24 = temp_output_26_0_g24;
				float depth14_g24 = temp_output_27_0_g24;
				float temp_output_75_0_g1 = ( _Intensity * _Amplitude3 );
				float amplitude14_g24 = temp_output_75_0_g1;
				float3 result14_g24 = float3( 0,0,0 );
				gerstner_float( position14_g24 , direction14_g24 , phase14_g24 , time14_g24 , gravity14_g24 , depth14_g24 , amplitude14_g24 , result14_g24 );
				float localgerstner15_g24 = ( 0.0 );
				float3 position15_g24 = temp_output_23_0_g24;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_76_0_g1 = rotatedValue66;
				float3 direction15_g24 = temp_output_76_0_g1;
				float phase15_g24 = temp_output_24_0_g24;
				float time15_g24 = temp_output_25_0_g24;
				float gravity15_g24 = temp_output_26_0_g24;
				float depth15_g24 = temp_output_27_0_g24;
				float temp_output_74_0_g1 = ( _Amplitude4 * _Intensity );
				float amplitude15_g24 = temp_output_74_0_g1;
				float3 result15_g24 = float3( 0,0,0 );
				gerstner_float( position15_g24 , direction15_g24 , phase15_g24 , time15_g24 , gravity15_g24 , depth15_g24 , amplitude15_g24 , result15_g24 );
				float3 worldToObj156_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g24 + result9_g24 ) + ( result14_g24 + result15_g24 ) ) + temp_output_23_0_g24 ), 1 ) ).xyz;
				float3 GerstPos132 = worldToObj156_g1;
				
				float localgerstner4_g28 = ( 0.0 );
				float3 objToWorld182_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 appendResult174_g1 = (float3(0.0 , temp_output_143_0_g1 , 0.0));
				float3 temp_output_23_0_g28 = ( objToWorld182_g1 + appendResult174_g1 );
				float3 position4_g28 = temp_output_23_0_g28;
				float3 direction4_g28 = temp_output_79_0_g1;
				float temp_output_24_0_g28 = temp_output_82_0_g1;
				float phase4_g28 = temp_output_24_0_g28;
				float temp_output_25_0_g28 = _TimeParameters.x;
				float time4_g28 = temp_output_25_0_g28;
				float temp_output_26_0_g28 = temp_output_81_0_g1;
				float gravity4_g28 = temp_output_26_0_g28;
				float temp_output_27_0_g28 = temp_output_80_0_g1;
				float depth4_g28 = temp_output_27_0_g28;
				float amplitude4_g28 = temp_output_84_0_g1;
				float3 result4_g28 = float3( 0,0,0 );
				gerstner_float( position4_g28 , direction4_g28 , phase4_g28 , time4_g28 , gravity4_g28 , depth4_g28 , amplitude4_g28 , result4_g28 );
				float localgerstner9_g28 = ( 0.0 );
				float3 position9_g28 = temp_output_23_0_g28;
				float3 direction9_g28 = temp_output_78_0_g1;
				float phase9_g28 = temp_output_24_0_g28;
				float time9_g28 = temp_output_25_0_g28;
				float gravity9_g28 = temp_output_26_0_g28;
				float depth9_g28 = temp_output_27_0_g28;
				float amplitude9_g28 = temp_output_73_0_g1;
				float3 result9_g28 = float3( 0,0,0 );
				gerstner_float( position9_g28 , direction9_g28 , phase9_g28 , time9_g28 , gravity9_g28 , depth9_g28 , amplitude9_g28 , result9_g28 );
				float localgerstner14_g28 = ( 0.0 );
				float3 position14_g28 = temp_output_23_0_g28;
				float3 direction14_g28 = temp_output_77_0_g1;
				float phase14_g28 = temp_output_24_0_g28;
				float time14_g28 = temp_output_25_0_g28;
				float gravity14_g28 = temp_output_26_0_g28;
				float depth14_g28 = temp_output_27_0_g28;
				float amplitude14_g28 = temp_output_75_0_g1;
				float3 result14_g28 = float3( 0,0,0 );
				gerstner_float( position14_g28 , direction14_g28 , phase14_g28 , time14_g28 , gravity14_g28 , depth14_g28 , amplitude14_g28 , result14_g28 );
				float localgerstner15_g28 = ( 0.0 );
				float3 position15_g28 = temp_output_23_0_g28;
				float3 direction15_g28 = temp_output_76_0_g1;
				float phase15_g28 = temp_output_24_0_g28;
				float time15_g28 = temp_output_25_0_g28;
				float gravity15_g28 = temp_output_26_0_g28;
				float depth15_g28 = temp_output_27_0_g28;
				float amplitude15_g28 = temp_output_74_0_g1;
				float3 result15_g28 = float3( 0,0,0 );
				gerstner_float( position15_g28 , direction15_g28 , phase15_g28 , time15_g28 , gravity15_g28 , depth15_g28 , amplitude15_g28 , result15_g28 );
				float3 worldToObj155_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g28 + result9_g28 ) + ( result14_g28 + result15_g28 ) ) + temp_output_23_0_g28 ), 1 ) ).xyz;
				float3 temp_output_3_0_g29 = worldToObj155_g1;
				float3 normalizeResult8_g29 = normalize( ( worldToObj156_g1 - temp_output_3_0_g29 ) );
				float localgerstner4_g26 = ( 0.0 );
				float3 objToWorld184_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 appendResult136_g1 = (float3(0.0 , 0.0 , temp_output_143_0_g1));
				float3 temp_output_23_0_g26 = ( objToWorld184_g1 + appendResult136_g1 );
				float3 position4_g26 = temp_output_23_0_g26;
				float3 direction4_g26 = temp_output_79_0_g1;
				float temp_output_24_0_g26 = temp_output_82_0_g1;
				float phase4_g26 = temp_output_24_0_g26;
				float temp_output_25_0_g26 = _TimeParameters.x;
				float time4_g26 = temp_output_25_0_g26;
				float temp_output_26_0_g26 = temp_output_81_0_g1;
				float gravity4_g26 = temp_output_26_0_g26;
				float temp_output_27_0_g26 = temp_output_80_0_g1;
				float depth4_g26 = temp_output_27_0_g26;
				float amplitude4_g26 = temp_output_84_0_g1;
				float3 result4_g26 = float3( 0,0,0 );
				gerstner_float( position4_g26 , direction4_g26 , phase4_g26 , time4_g26 , gravity4_g26 , depth4_g26 , amplitude4_g26 , result4_g26 );
				float localgerstner9_g26 = ( 0.0 );
				float3 position9_g26 = temp_output_23_0_g26;
				float3 direction9_g26 = temp_output_78_0_g1;
				float phase9_g26 = temp_output_24_0_g26;
				float time9_g26 = temp_output_25_0_g26;
				float gravity9_g26 = temp_output_26_0_g26;
				float depth9_g26 = temp_output_27_0_g26;
				float amplitude9_g26 = temp_output_73_0_g1;
				float3 result9_g26 = float3( 0,0,0 );
				gerstner_float( position9_g26 , direction9_g26 , phase9_g26 , time9_g26 , gravity9_g26 , depth9_g26 , amplitude9_g26 , result9_g26 );
				float localgerstner14_g26 = ( 0.0 );
				float3 position14_g26 = temp_output_23_0_g26;
				float3 direction14_g26 = temp_output_77_0_g1;
				float phase14_g26 = temp_output_24_0_g26;
				float time14_g26 = temp_output_25_0_g26;
				float gravity14_g26 = temp_output_26_0_g26;
				float depth14_g26 = temp_output_27_0_g26;
				float amplitude14_g26 = temp_output_75_0_g1;
				float3 result14_g26 = float3( 0,0,0 );
				gerstner_float( position14_g26 , direction14_g26 , phase14_g26 , time14_g26 , gravity14_g26 , depth14_g26 , amplitude14_g26 , result14_g26 );
				float localgerstner15_g26 = ( 0.0 );
				float3 position15_g26 = temp_output_23_0_g26;
				float3 direction15_g26 = temp_output_76_0_g1;
				float phase15_g26 = temp_output_24_0_g26;
				float time15_g26 = temp_output_25_0_g26;
				float gravity15_g26 = temp_output_26_0_g26;
				float depth15_g26 = temp_output_27_0_g26;
				float amplitude15_g26 = temp_output_74_0_g1;
				float3 result15_g26 = float3( 0,0,0 );
				gerstner_float( position15_g26 , direction15_g26 , phase15_g26 , time15_g26 , gravity15_g26 , depth15_g26 , amplitude15_g26 , result15_g26 );
				float3 worldToObj164_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g26 + result9_g26 ) + ( result14_g26 + result15_g26 ) ) + temp_output_23_0_g26 ), 1 ) ).xyz;
				float3 normalizeResult9_g29 = normalize( ( temp_output_3_0_g29 - worldToObj164_g1 ) );
				float3 normalizeResult11_g29 = normalize( cross( normalizeResult8_g29 , normalizeResult9_g29 ) );
				float3 GerstNorm134 = normalizeResult11_g29;
				

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
				float screenDepth498 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth498 = saturate( ( screenDepth498 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthDistance ) );
				float Depth500 = distanceDepth498;
				

				float Alpha = ( Depth500 * _WaterThickness );
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
			#define _NORMAL_DROPOFF_TS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_DISTANCE_TESSELLATION
			#define ASE_DEPTH_WRITE_ON
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1
			#define ASE_USING_SAMPLING_MACROS 1


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
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_POSITION
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
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FoamColor;
			float4 _NormalTexture2_ST;
			float4 _NormalTexture1_ST;
			float4 _Emmision;
			float4 _DeepColor;
			float4 _ShallowColor;
			float3 _Direction4;
			float3 _Direction1;
			float3 _Direction2;
			float3 _Direction3;
			float _RiseFadeout;
			float _RiseThreshold;
			float _NormalStrength;
			float _NormalPanSpeed;
			float _DepthDistance;
			float _NeighbourDistance;
			float _Amplitude3;
			float _Amplitude2;
			float _Intensity;
			float _Amplitude1;
			float _WaveDepth;
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
			
			inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }
			inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }
			inline float valueNoise (float2 uv)
			{
				float2 i = floor(uv);
				float2 f = frac( uv );
				f = f* f * (3.0 - 2.0 * f);
				uv = abs( frac(uv) - 0.5);
				float2 c0 = i + float2( 0.0, 0.0 );
				float2 c1 = i + float2( 1.0, 0.0 );
				float2 c2 = i + float2( 0.0, 1.0 );
				float2 c3 = i + float2( 1.0, 1.0 );
				float r0 = noise_randomValue( c0 );
				float r1 = noise_randomValue( c1 );
				float r2 = noise_randomValue( c2 );
				float r3 = noise_randomValue( c3 );
				float bottomOfGrid = noise_interpolate( r0, r1, f.x );
				float topOfGrid = noise_interpolate( r2, r3, f.x );
				float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
				return t;
			}
			
			float SimpleNoise(float2 UV)
			{
				float t = 0.0;
				float freq = pow( 2.0, float( 0 ) );
				float amp = pow( 0.5, float( 3 - 0 ) );
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(1));
				amp = pow(0.5, float(3-1));
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(2));
				amp = pow(0.5, float(3-2));
				t += valueNoise( UV/freq )*amp;
				return t;
			}
			
			float2 UnityGradientNoiseDir( float2 p )
			{
				p = fmod(p , 289);
				float x = fmod((34 * p.x + 1) * p.x , 289) + p.y;
				x = fmod( (34 * x + 1) * x , 289);
				x = frac( x / 41 ) * 2 - 1;
				return normalize( float2(x - floor(x + 0.5 ), abs( x ) - 0.5 ) );
			}
			
			float UnityGradientNoise( float2 UV, float Scale )
			{
				float2 p = UV * Scale;
				float2 ip = floor( p );
				float2 fp = frac( p );
				float d00 = dot( UnityGradientNoiseDir( ip ), fp );
				float d01 = dot( UnityGradientNoiseDir( ip + float2( 0, 1 ) ), fp - float2( 0, 1 ) );
				float d10 = dot( UnityGradientNoiseDir( ip + float2( 1, 0 ) ), fp - float2( 1, 0 ) );
				float d11 = dot( UnityGradientNoiseDir( ip + float2( 1, 1 ) ), fp - float2( 1, 1 ) );
				fp = fp * fp * fp * ( fp * ( fp * 6 - 15 ) + 10 );
				return lerp( lerp( d00, d01, fp.y ), lerp( d10, d11, fp.y ), fp.x ) + 0.5;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float localgerstner4_g24 = ( 0.0 );
				float3 objToWorld179_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float temp_output_143_0_g1 = _NeighbourDistance;
				float3 appendResult142_g1 = (float3(temp_output_143_0_g1 , 0.0 , 0.0));
				float3 temp_output_23_0_g24 = ( objToWorld179_g1 + appendResult142_g1 );
				float3 position4_g24 = temp_output_23_0_g24;
				float temp_output_615_0 = radians( _Roataion );
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_79_0_g1 = rotatedValue387;
				float3 direction4_g24 = temp_output_79_0_g1;
				float temp_output_82_0_g1 = _Phase;
				float temp_output_24_0_g24 = temp_output_82_0_g1;
				float phase4_g24 = temp_output_24_0_g24;
				float temp_output_25_0_g24 = _TimeParameters.x;
				float time4_g24 = temp_output_25_0_g24;
				float temp_output_81_0_g1 = _Gravity;
				float temp_output_26_0_g24 = temp_output_81_0_g1;
				float gravity4_g24 = temp_output_26_0_g24;
				float temp_output_80_0_g1 = _WaveDepth;
				float temp_output_27_0_g24 = temp_output_80_0_g1;
				float depth4_g24 = temp_output_27_0_g24;
				float temp_output_84_0_g1 = ( _Amplitude1 * _Intensity );
				float amplitude4_g24 = temp_output_84_0_g1;
				float3 result4_g24 = float3( 0,0,0 );
				gerstner_float( position4_g24 , direction4_g24 , phase4_g24 , time4_g24 , gravity4_g24 , depth4_g24 , amplitude4_g24 , result4_g24 );
				float localgerstner9_g24 = ( 0.0 );
				float3 position9_g24 = temp_output_23_0_g24;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_78_0_g1 = rotatedValue64;
				float3 direction9_g24 = temp_output_78_0_g1;
				float phase9_g24 = temp_output_24_0_g24;
				float time9_g24 = temp_output_25_0_g24;
				float gravity9_g24 = temp_output_26_0_g24;
				float depth9_g24 = temp_output_27_0_g24;
				float temp_output_73_0_g1 = ( _Intensity * _Amplitude2 );
				float amplitude9_g24 = temp_output_73_0_g1;
				float3 result9_g24 = float3( 0,0,0 );
				gerstner_float( position9_g24 , direction9_g24 , phase9_g24 , time9_g24 , gravity9_g24 , depth9_g24 , amplitude9_g24 , result9_g24 );
				float localgerstner14_g24 = ( 0.0 );
				float3 position14_g24 = temp_output_23_0_g24;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_77_0_g1 = rotatedValue65;
				float3 direction14_g24 = temp_output_77_0_g1;
				float phase14_g24 = temp_output_24_0_g24;
				float time14_g24 = temp_output_25_0_g24;
				float gravity14_g24 = temp_output_26_0_g24;
				float depth14_g24 = temp_output_27_0_g24;
				float temp_output_75_0_g1 = ( _Intensity * _Amplitude3 );
				float amplitude14_g24 = temp_output_75_0_g1;
				float3 result14_g24 = float3( 0,0,0 );
				gerstner_float( position14_g24 , direction14_g24 , phase14_g24 , time14_g24 , gravity14_g24 , depth14_g24 , amplitude14_g24 , result14_g24 );
				float localgerstner15_g24 = ( 0.0 );
				float3 position15_g24 = temp_output_23_0_g24;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_76_0_g1 = rotatedValue66;
				float3 direction15_g24 = temp_output_76_0_g1;
				float phase15_g24 = temp_output_24_0_g24;
				float time15_g24 = temp_output_25_0_g24;
				float gravity15_g24 = temp_output_26_0_g24;
				float depth15_g24 = temp_output_27_0_g24;
				float temp_output_74_0_g1 = ( _Amplitude4 * _Intensity );
				float amplitude15_g24 = temp_output_74_0_g1;
				float3 result15_g24 = float3( 0,0,0 );
				gerstner_float( position15_g24 , direction15_g24 , phase15_g24 , time15_g24 , gravity15_g24 , depth15_g24 , amplitude15_g24 , result15_g24 );
				float3 worldToObj156_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g24 + result9_g24 ) + ( result14_g24 + result15_g24 ) ) + temp_output_23_0_g24 ), 1 ) ).xyz;
				float3 GerstPos132 = worldToObj156_g1;
				
				float localgerstner4_g28 = ( 0.0 );
				float3 objToWorld182_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 appendResult174_g1 = (float3(0.0 , temp_output_143_0_g1 , 0.0));
				float3 temp_output_23_0_g28 = ( objToWorld182_g1 + appendResult174_g1 );
				float3 position4_g28 = temp_output_23_0_g28;
				float3 direction4_g28 = temp_output_79_0_g1;
				float temp_output_24_0_g28 = temp_output_82_0_g1;
				float phase4_g28 = temp_output_24_0_g28;
				float temp_output_25_0_g28 = _TimeParameters.x;
				float time4_g28 = temp_output_25_0_g28;
				float temp_output_26_0_g28 = temp_output_81_0_g1;
				float gravity4_g28 = temp_output_26_0_g28;
				float temp_output_27_0_g28 = temp_output_80_0_g1;
				float depth4_g28 = temp_output_27_0_g28;
				float amplitude4_g28 = temp_output_84_0_g1;
				float3 result4_g28 = float3( 0,0,0 );
				gerstner_float( position4_g28 , direction4_g28 , phase4_g28 , time4_g28 , gravity4_g28 , depth4_g28 , amplitude4_g28 , result4_g28 );
				float localgerstner9_g28 = ( 0.0 );
				float3 position9_g28 = temp_output_23_0_g28;
				float3 direction9_g28 = temp_output_78_0_g1;
				float phase9_g28 = temp_output_24_0_g28;
				float time9_g28 = temp_output_25_0_g28;
				float gravity9_g28 = temp_output_26_0_g28;
				float depth9_g28 = temp_output_27_0_g28;
				float amplitude9_g28 = temp_output_73_0_g1;
				float3 result9_g28 = float3( 0,0,0 );
				gerstner_float( position9_g28 , direction9_g28 , phase9_g28 , time9_g28 , gravity9_g28 , depth9_g28 , amplitude9_g28 , result9_g28 );
				float localgerstner14_g28 = ( 0.0 );
				float3 position14_g28 = temp_output_23_0_g28;
				float3 direction14_g28 = temp_output_77_0_g1;
				float phase14_g28 = temp_output_24_0_g28;
				float time14_g28 = temp_output_25_0_g28;
				float gravity14_g28 = temp_output_26_0_g28;
				float depth14_g28 = temp_output_27_0_g28;
				float amplitude14_g28 = temp_output_75_0_g1;
				float3 result14_g28 = float3( 0,0,0 );
				gerstner_float( position14_g28 , direction14_g28 , phase14_g28 , time14_g28 , gravity14_g28 , depth14_g28 , amplitude14_g28 , result14_g28 );
				float localgerstner15_g28 = ( 0.0 );
				float3 position15_g28 = temp_output_23_0_g28;
				float3 direction15_g28 = temp_output_76_0_g1;
				float phase15_g28 = temp_output_24_0_g28;
				float time15_g28 = temp_output_25_0_g28;
				float gravity15_g28 = temp_output_26_0_g28;
				float depth15_g28 = temp_output_27_0_g28;
				float amplitude15_g28 = temp_output_74_0_g1;
				float3 result15_g28 = float3( 0,0,0 );
				gerstner_float( position15_g28 , direction15_g28 , phase15_g28 , time15_g28 , gravity15_g28 , depth15_g28 , amplitude15_g28 , result15_g28 );
				float3 worldToObj155_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g28 + result9_g28 ) + ( result14_g28 + result15_g28 ) ) + temp_output_23_0_g28 ), 1 ) ).xyz;
				float3 temp_output_3_0_g29 = worldToObj155_g1;
				float3 normalizeResult8_g29 = normalize( ( worldToObj156_g1 - temp_output_3_0_g29 ) );
				float localgerstner4_g26 = ( 0.0 );
				float3 objToWorld184_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 appendResult136_g1 = (float3(0.0 , 0.0 , temp_output_143_0_g1));
				float3 temp_output_23_0_g26 = ( objToWorld184_g1 + appendResult136_g1 );
				float3 position4_g26 = temp_output_23_0_g26;
				float3 direction4_g26 = temp_output_79_0_g1;
				float temp_output_24_0_g26 = temp_output_82_0_g1;
				float phase4_g26 = temp_output_24_0_g26;
				float temp_output_25_0_g26 = _TimeParameters.x;
				float time4_g26 = temp_output_25_0_g26;
				float temp_output_26_0_g26 = temp_output_81_0_g1;
				float gravity4_g26 = temp_output_26_0_g26;
				float temp_output_27_0_g26 = temp_output_80_0_g1;
				float depth4_g26 = temp_output_27_0_g26;
				float amplitude4_g26 = temp_output_84_0_g1;
				float3 result4_g26 = float3( 0,0,0 );
				gerstner_float( position4_g26 , direction4_g26 , phase4_g26 , time4_g26 , gravity4_g26 , depth4_g26 , amplitude4_g26 , result4_g26 );
				float localgerstner9_g26 = ( 0.0 );
				float3 position9_g26 = temp_output_23_0_g26;
				float3 direction9_g26 = temp_output_78_0_g1;
				float phase9_g26 = temp_output_24_0_g26;
				float time9_g26 = temp_output_25_0_g26;
				float gravity9_g26 = temp_output_26_0_g26;
				float depth9_g26 = temp_output_27_0_g26;
				float amplitude9_g26 = temp_output_73_0_g1;
				float3 result9_g26 = float3( 0,0,0 );
				gerstner_float( position9_g26 , direction9_g26 , phase9_g26 , time9_g26 , gravity9_g26 , depth9_g26 , amplitude9_g26 , result9_g26 );
				float localgerstner14_g26 = ( 0.0 );
				float3 position14_g26 = temp_output_23_0_g26;
				float3 direction14_g26 = temp_output_77_0_g1;
				float phase14_g26 = temp_output_24_0_g26;
				float time14_g26 = temp_output_25_0_g26;
				float gravity14_g26 = temp_output_26_0_g26;
				float depth14_g26 = temp_output_27_0_g26;
				float amplitude14_g26 = temp_output_75_0_g1;
				float3 result14_g26 = float3( 0,0,0 );
				gerstner_float( position14_g26 , direction14_g26 , phase14_g26 , time14_g26 , gravity14_g26 , depth14_g26 , amplitude14_g26 , result14_g26 );
				float localgerstner15_g26 = ( 0.0 );
				float3 position15_g26 = temp_output_23_0_g26;
				float3 direction15_g26 = temp_output_76_0_g1;
				float phase15_g26 = temp_output_24_0_g26;
				float time15_g26 = temp_output_25_0_g26;
				float gravity15_g26 = temp_output_26_0_g26;
				float depth15_g26 = temp_output_27_0_g26;
				float amplitude15_g26 = temp_output_74_0_g1;
				float3 result15_g26 = float3( 0,0,0 );
				gerstner_float( position15_g26 , direction15_g26 , phase15_g26 , time15_g26 , gravity15_g26 , depth15_g26 , amplitude15_g26 , result15_g26 );
				float3 worldToObj164_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g26 + result9_g26 ) + ( result14_g26 + result15_g26 ) ) + temp_output_23_0_g26 ), 1 ) ).xyz;
				float3 normalizeResult9_g29 = normalize( ( temp_output_3_0_g29 - worldToObj164_g1 ) );
				float3 normalizeResult11_g29 = normalize( cross( normalizeResult8_g29 , normalizeResult9_g29 ) );
				float3 GerstNorm134 = normalizeResult11_g29;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.ase_texcoord5 = v.vertex;
				o.ase_texcoord6.xy = v.texcoord0.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord6.zw = 0;

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
				float screenDepth498 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth498 = saturate( ( screenDepth498 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthDistance ) );
				float Depth500 = distanceDepth498;
				float4 lerpResult590 = lerp( _ShallowColor , _DeepColor , Depth500);
				
				float lerpResult558 = lerp( _RiseThreshold , 1.0 , _RiseFadeout);
				float localgerstner4_g24 = ( 0.0 );
				float3 objToWorld179_g1 = mul( GetObjectToWorldMatrix(), float4( IN.ase_texcoord5.xyz, 1 ) ).xyz;
				float temp_output_143_0_g1 = _NeighbourDistance;
				float3 appendResult142_g1 = (float3(temp_output_143_0_g1 , 0.0 , 0.0));
				float3 temp_output_23_0_g24 = ( objToWorld179_g1 + appendResult142_g1 );
				float3 position4_g24 = temp_output_23_0_g24;
				float temp_output_615_0 = radians( _Roataion );
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_79_0_g1 = rotatedValue387;
				float3 direction4_g24 = temp_output_79_0_g1;
				float temp_output_82_0_g1 = _Phase;
				float temp_output_24_0_g24 = temp_output_82_0_g1;
				float phase4_g24 = temp_output_24_0_g24;
				float temp_output_25_0_g24 = _TimeParameters.x;
				float time4_g24 = temp_output_25_0_g24;
				float temp_output_81_0_g1 = _Gravity;
				float temp_output_26_0_g24 = temp_output_81_0_g1;
				float gravity4_g24 = temp_output_26_0_g24;
				float temp_output_80_0_g1 = _WaveDepth;
				float temp_output_27_0_g24 = temp_output_80_0_g1;
				float depth4_g24 = temp_output_27_0_g24;
				float temp_output_84_0_g1 = ( _Amplitude1 * _Intensity );
				float amplitude4_g24 = temp_output_84_0_g1;
				float3 result4_g24 = float3( 0,0,0 );
				gerstner_float( position4_g24 , direction4_g24 , phase4_g24 , time4_g24 , gravity4_g24 , depth4_g24 , amplitude4_g24 , result4_g24 );
				float localgerstner9_g24 = ( 0.0 );
				float3 position9_g24 = temp_output_23_0_g24;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_78_0_g1 = rotatedValue64;
				float3 direction9_g24 = temp_output_78_0_g1;
				float phase9_g24 = temp_output_24_0_g24;
				float time9_g24 = temp_output_25_0_g24;
				float gravity9_g24 = temp_output_26_0_g24;
				float depth9_g24 = temp_output_27_0_g24;
				float temp_output_73_0_g1 = ( _Intensity * _Amplitude2 );
				float amplitude9_g24 = temp_output_73_0_g1;
				float3 result9_g24 = float3( 0,0,0 );
				gerstner_float( position9_g24 , direction9_g24 , phase9_g24 , time9_g24 , gravity9_g24 , depth9_g24 , amplitude9_g24 , result9_g24 );
				float localgerstner14_g24 = ( 0.0 );
				float3 position14_g24 = temp_output_23_0_g24;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_77_0_g1 = rotatedValue65;
				float3 direction14_g24 = temp_output_77_0_g1;
				float phase14_g24 = temp_output_24_0_g24;
				float time14_g24 = temp_output_25_0_g24;
				float gravity14_g24 = temp_output_26_0_g24;
				float depth14_g24 = temp_output_27_0_g24;
				float temp_output_75_0_g1 = ( _Intensity * _Amplitude3 );
				float amplitude14_g24 = temp_output_75_0_g1;
				float3 result14_g24 = float3( 0,0,0 );
				gerstner_float( position14_g24 , direction14_g24 , phase14_g24 , time14_g24 , gravity14_g24 , depth14_g24 , amplitude14_g24 , result14_g24 );
				float localgerstner15_g24 = ( 0.0 );
				float3 position15_g24 = temp_output_23_0_g24;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_76_0_g1 = rotatedValue66;
				float3 direction15_g24 = temp_output_76_0_g1;
				float phase15_g24 = temp_output_24_0_g24;
				float time15_g24 = temp_output_25_0_g24;
				float gravity15_g24 = temp_output_26_0_g24;
				float depth15_g24 = temp_output_27_0_g24;
				float temp_output_74_0_g1 = ( _Amplitude4 * _Intensity );
				float amplitude15_g24 = temp_output_74_0_g1;
				float3 result15_g24 = float3( 0,0,0 );
				gerstner_float( position15_g24 , direction15_g24 , phase15_g24 , time15_g24 , gravity15_g24 , depth15_g24 , amplitude15_g24 , result15_g24 );
				float3 worldToObj156_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g24 + result9_g24 ) + ( result14_g24 + result15_g24 ) ) + temp_output_23_0_g24 ), 1 ) ).xyz;
				float localgerstner4_g28 = ( 0.0 );
				float3 objToWorld182_g1 = mul( GetObjectToWorldMatrix(), float4( IN.ase_texcoord5.xyz, 1 ) ).xyz;
				float3 appendResult174_g1 = (float3(0.0 , temp_output_143_0_g1 , 0.0));
				float3 temp_output_23_0_g28 = ( objToWorld182_g1 + appendResult174_g1 );
				float3 position4_g28 = temp_output_23_0_g28;
				float3 direction4_g28 = temp_output_79_0_g1;
				float temp_output_24_0_g28 = temp_output_82_0_g1;
				float phase4_g28 = temp_output_24_0_g28;
				float temp_output_25_0_g28 = _TimeParameters.x;
				float time4_g28 = temp_output_25_0_g28;
				float temp_output_26_0_g28 = temp_output_81_0_g1;
				float gravity4_g28 = temp_output_26_0_g28;
				float temp_output_27_0_g28 = temp_output_80_0_g1;
				float depth4_g28 = temp_output_27_0_g28;
				float amplitude4_g28 = temp_output_84_0_g1;
				float3 result4_g28 = float3( 0,0,0 );
				gerstner_float( position4_g28 , direction4_g28 , phase4_g28 , time4_g28 , gravity4_g28 , depth4_g28 , amplitude4_g28 , result4_g28 );
				float localgerstner9_g28 = ( 0.0 );
				float3 position9_g28 = temp_output_23_0_g28;
				float3 direction9_g28 = temp_output_78_0_g1;
				float phase9_g28 = temp_output_24_0_g28;
				float time9_g28 = temp_output_25_0_g28;
				float gravity9_g28 = temp_output_26_0_g28;
				float depth9_g28 = temp_output_27_0_g28;
				float amplitude9_g28 = temp_output_73_0_g1;
				float3 result9_g28 = float3( 0,0,0 );
				gerstner_float( position9_g28 , direction9_g28 , phase9_g28 , time9_g28 , gravity9_g28 , depth9_g28 , amplitude9_g28 , result9_g28 );
				float localgerstner14_g28 = ( 0.0 );
				float3 position14_g28 = temp_output_23_0_g28;
				float3 direction14_g28 = temp_output_77_0_g1;
				float phase14_g28 = temp_output_24_0_g28;
				float time14_g28 = temp_output_25_0_g28;
				float gravity14_g28 = temp_output_26_0_g28;
				float depth14_g28 = temp_output_27_0_g28;
				float amplitude14_g28 = temp_output_75_0_g1;
				float3 result14_g28 = float3( 0,0,0 );
				gerstner_float( position14_g28 , direction14_g28 , phase14_g28 , time14_g28 , gravity14_g28 , depth14_g28 , amplitude14_g28 , result14_g28 );
				float localgerstner15_g28 = ( 0.0 );
				float3 position15_g28 = temp_output_23_0_g28;
				float3 direction15_g28 = temp_output_76_0_g1;
				float phase15_g28 = temp_output_24_0_g28;
				float time15_g28 = temp_output_25_0_g28;
				float gravity15_g28 = temp_output_26_0_g28;
				float depth15_g28 = temp_output_27_0_g28;
				float amplitude15_g28 = temp_output_74_0_g1;
				float3 result15_g28 = float3( 0,0,0 );
				gerstner_float( position15_g28 , direction15_g28 , phase15_g28 , time15_g28 , gravity15_g28 , depth15_g28 , amplitude15_g28 , result15_g28 );
				float3 worldToObj155_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g28 + result9_g28 ) + ( result14_g28 + result15_g28 ) ) + temp_output_23_0_g28 ), 1 ) ).xyz;
				float3 temp_output_3_0_g29 = worldToObj155_g1;
				float3 normalizeResult8_g29 = normalize( ( worldToObj156_g1 - temp_output_3_0_g29 ) );
				float localgerstner4_g26 = ( 0.0 );
				float3 objToWorld184_g1 = mul( GetObjectToWorldMatrix(), float4( IN.ase_texcoord5.xyz, 1 ) ).xyz;
				float3 appendResult136_g1 = (float3(0.0 , 0.0 , temp_output_143_0_g1));
				float3 temp_output_23_0_g26 = ( objToWorld184_g1 + appendResult136_g1 );
				float3 position4_g26 = temp_output_23_0_g26;
				float3 direction4_g26 = temp_output_79_0_g1;
				float temp_output_24_0_g26 = temp_output_82_0_g1;
				float phase4_g26 = temp_output_24_0_g26;
				float temp_output_25_0_g26 = _TimeParameters.x;
				float time4_g26 = temp_output_25_0_g26;
				float temp_output_26_0_g26 = temp_output_81_0_g1;
				float gravity4_g26 = temp_output_26_0_g26;
				float temp_output_27_0_g26 = temp_output_80_0_g1;
				float depth4_g26 = temp_output_27_0_g26;
				float amplitude4_g26 = temp_output_84_0_g1;
				float3 result4_g26 = float3( 0,0,0 );
				gerstner_float( position4_g26 , direction4_g26 , phase4_g26 , time4_g26 , gravity4_g26 , depth4_g26 , amplitude4_g26 , result4_g26 );
				float localgerstner9_g26 = ( 0.0 );
				float3 position9_g26 = temp_output_23_0_g26;
				float3 direction9_g26 = temp_output_78_0_g1;
				float phase9_g26 = temp_output_24_0_g26;
				float time9_g26 = temp_output_25_0_g26;
				float gravity9_g26 = temp_output_26_0_g26;
				float depth9_g26 = temp_output_27_0_g26;
				float amplitude9_g26 = temp_output_73_0_g1;
				float3 result9_g26 = float3( 0,0,0 );
				gerstner_float( position9_g26 , direction9_g26 , phase9_g26 , time9_g26 , gravity9_g26 , depth9_g26 , amplitude9_g26 , result9_g26 );
				float localgerstner14_g26 = ( 0.0 );
				float3 position14_g26 = temp_output_23_0_g26;
				float3 direction14_g26 = temp_output_77_0_g1;
				float phase14_g26 = temp_output_24_0_g26;
				float time14_g26 = temp_output_25_0_g26;
				float gravity14_g26 = temp_output_26_0_g26;
				float depth14_g26 = temp_output_27_0_g26;
				float amplitude14_g26 = temp_output_75_0_g1;
				float3 result14_g26 = float3( 0,0,0 );
				gerstner_float( position14_g26 , direction14_g26 , phase14_g26 , time14_g26 , gravity14_g26 , depth14_g26 , amplitude14_g26 , result14_g26 );
				float localgerstner15_g26 = ( 0.0 );
				float3 position15_g26 = temp_output_23_0_g26;
				float3 direction15_g26 = temp_output_76_0_g1;
				float phase15_g26 = temp_output_24_0_g26;
				float time15_g26 = temp_output_25_0_g26;
				float gravity15_g26 = temp_output_26_0_g26;
				float depth15_g26 = temp_output_27_0_g26;
				float amplitude15_g26 = temp_output_74_0_g1;
				float3 result15_g26 = float3( 0,0,0 );
				gerstner_float( position15_g26 , direction15_g26 , phase15_g26 , time15_g26 , gravity15_g26 , depth15_g26 , amplitude15_g26 , result15_g26 );
				float3 worldToObj164_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g26 + result9_g26 ) + ( result14_g26 + result15_g26 ) ) + temp_output_23_0_g26 ), 1 ) ).xyz;
				float3 normalizeResult9_g29 = normalize( ( temp_output_3_0_g29 - worldToObj164_g1 ) );
				float3 normalizeResult11_g29 = normalize( cross( normalizeResult8_g29 , normalizeResult9_g29 ) );
				float3 GerstNorm134 = normalizeResult11_g29;
				float4 temp_output_6_0_g30 = float4( 0,1,0,0 );
				float dotResult1_g30 = dot( float4( GerstNorm134 , 0.0 ) , temp_output_6_0_g30 );
				float dotResult2_g30 = dot( temp_output_6_0_g30 , temp_output_6_0_g30 );
				float2 appendResult536 = (float2(WorldPosition.x , WorldPosition.z));
				float2 texCoord537 = IN.ase_texcoord6.xy * float2( 1,1 ) + appendResult536;
				float rotation543 = temp_output_615_0;
				float cos539 = cos( rotation543 );
				float sin539 = sin( rotation543 );
				float2 rotator539 = mul( texCoord537 - float2( 0.5,0.5 ) , float2x2( cos539 , -sin539 , sin539 , cos539 )) + float2( 0.5,0.5 );
				float simpleNoise545 = SimpleNoise( rotator539*5.0 );
				float2 texCoord553 = IN.ase_texcoord6.xy * float2( 1,1 ) + ( appendResult536 + _TimeParameters.x );
				float gradientNoise554 = UnityGradientNoise(texCoord553,0.02);
				gradientNoise554 = gradientNoise554*0.5 + 0.5;
				float smoothstepResult559 = smoothstep( _RiseThreshold , lerpResult558 , ( (1.0 + (length( ( ( dotResult1_g30 / dotResult2_g30 ) * temp_output_6_0_g30 ) ) - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) + (-0.1 + (simpleNoise545 - 0.0) * (0.1 - -0.1) / (1.0 - 0.0)) + (-0.3 + (gradientNoise554 - 0.0) * (0.3 - -0.3) / (1.0 - 0.0)) ));
				float RiseTide560 = smoothstepResult559;
				float smoothstepResult523 = smoothstep( 0.97 , 1.0 , (1.0 + (distanceDepth498 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
				float2 appendResult510 = (float2(WorldPosition.x , WorldPosition.z));
				float2 texCoord517 = IN.ase_texcoord6.xy * float2( 1,1 ) + ( ( _TimeParameters.x * 0.5 ) + appendResult510 );
				float gradientNoise516 = UnityGradientNoise(texCoord517,2.15);
				gradientNoise516 = gradientNoise516*0.5 + 0.5;
				float clampResult526 = clamp( ( ( pow( ( 1.0 / 1000.0 ) , distanceDepth498 ) * cos( ( ( distanceDepth498 * 100.0 ) + ( 4.0 * _TimeParameters.x ) ) ) ) * ( 0.5 + gradientNoise516 ) ) , -0.1 , 1.0 );
				float Foam564 = step( ( RiseTide560 + smoothstepResult523 + clampResult526 ) , 0.5 );
				float4 lerpResult607 = lerp( _FoamColor , _Emmision , Foam564);
				

				float3 BaseColor = lerpResult590.rgb;
				float3 Emission = lerpResult607.rgb;
				float Alpha = ( Depth500 * _WaterThickness );
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
			#define _NORMAL_DROPOFF_TS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_DISTANCE_TESSELLATION
			#define ASE_DEPTH_WRITE_ON
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1
			#define ASE_USING_SAMPLING_MACROS 1


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
			#define ASE_NEEDS_VERT_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FoamColor;
			float4 _NormalTexture2_ST;
			float4 _NormalTexture1_ST;
			float4 _Emmision;
			float4 _DeepColor;
			float4 _ShallowColor;
			float3 _Direction4;
			float3 _Direction1;
			float3 _Direction2;
			float3 _Direction3;
			float _RiseFadeout;
			float _RiseThreshold;
			float _NormalStrength;
			float _NormalPanSpeed;
			float _DepthDistance;
			float _NeighbourDistance;
			float _Amplitude3;
			float _Amplitude2;
			float _Intensity;
			float _Amplitude1;
			float _WaveDepth;
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
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float localgerstner4_g24 = ( 0.0 );
				float3 objToWorld179_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float temp_output_143_0_g1 = _NeighbourDistance;
				float3 appendResult142_g1 = (float3(temp_output_143_0_g1 , 0.0 , 0.0));
				float3 temp_output_23_0_g24 = ( objToWorld179_g1 + appendResult142_g1 );
				float3 position4_g24 = temp_output_23_0_g24;
				float temp_output_615_0 = radians( _Roataion );
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_79_0_g1 = rotatedValue387;
				float3 direction4_g24 = temp_output_79_0_g1;
				float temp_output_82_0_g1 = _Phase;
				float temp_output_24_0_g24 = temp_output_82_0_g1;
				float phase4_g24 = temp_output_24_0_g24;
				float temp_output_25_0_g24 = _TimeParameters.x;
				float time4_g24 = temp_output_25_0_g24;
				float temp_output_81_0_g1 = _Gravity;
				float temp_output_26_0_g24 = temp_output_81_0_g1;
				float gravity4_g24 = temp_output_26_0_g24;
				float temp_output_80_0_g1 = _WaveDepth;
				float temp_output_27_0_g24 = temp_output_80_0_g1;
				float depth4_g24 = temp_output_27_0_g24;
				float temp_output_84_0_g1 = ( _Amplitude1 * _Intensity );
				float amplitude4_g24 = temp_output_84_0_g1;
				float3 result4_g24 = float3( 0,0,0 );
				gerstner_float( position4_g24 , direction4_g24 , phase4_g24 , time4_g24 , gravity4_g24 , depth4_g24 , amplitude4_g24 , result4_g24 );
				float localgerstner9_g24 = ( 0.0 );
				float3 position9_g24 = temp_output_23_0_g24;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_78_0_g1 = rotatedValue64;
				float3 direction9_g24 = temp_output_78_0_g1;
				float phase9_g24 = temp_output_24_0_g24;
				float time9_g24 = temp_output_25_0_g24;
				float gravity9_g24 = temp_output_26_0_g24;
				float depth9_g24 = temp_output_27_0_g24;
				float temp_output_73_0_g1 = ( _Intensity * _Amplitude2 );
				float amplitude9_g24 = temp_output_73_0_g1;
				float3 result9_g24 = float3( 0,0,0 );
				gerstner_float( position9_g24 , direction9_g24 , phase9_g24 , time9_g24 , gravity9_g24 , depth9_g24 , amplitude9_g24 , result9_g24 );
				float localgerstner14_g24 = ( 0.0 );
				float3 position14_g24 = temp_output_23_0_g24;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_77_0_g1 = rotatedValue65;
				float3 direction14_g24 = temp_output_77_0_g1;
				float phase14_g24 = temp_output_24_0_g24;
				float time14_g24 = temp_output_25_0_g24;
				float gravity14_g24 = temp_output_26_0_g24;
				float depth14_g24 = temp_output_27_0_g24;
				float temp_output_75_0_g1 = ( _Intensity * _Amplitude3 );
				float amplitude14_g24 = temp_output_75_0_g1;
				float3 result14_g24 = float3( 0,0,0 );
				gerstner_float( position14_g24 , direction14_g24 , phase14_g24 , time14_g24 , gravity14_g24 , depth14_g24 , amplitude14_g24 , result14_g24 );
				float localgerstner15_g24 = ( 0.0 );
				float3 position15_g24 = temp_output_23_0_g24;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_76_0_g1 = rotatedValue66;
				float3 direction15_g24 = temp_output_76_0_g1;
				float phase15_g24 = temp_output_24_0_g24;
				float time15_g24 = temp_output_25_0_g24;
				float gravity15_g24 = temp_output_26_0_g24;
				float depth15_g24 = temp_output_27_0_g24;
				float temp_output_74_0_g1 = ( _Amplitude4 * _Intensity );
				float amplitude15_g24 = temp_output_74_0_g1;
				float3 result15_g24 = float3( 0,0,0 );
				gerstner_float( position15_g24 , direction15_g24 , phase15_g24 , time15_g24 , gravity15_g24 , depth15_g24 , amplitude15_g24 , result15_g24 );
				float3 worldToObj156_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g24 + result9_g24 ) + ( result14_g24 + result15_g24 ) ) + temp_output_23_0_g24 ), 1 ) ).xyz;
				float3 GerstPos132 = worldToObj156_g1;
				
				float localgerstner4_g28 = ( 0.0 );
				float3 objToWorld182_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 appendResult174_g1 = (float3(0.0 , temp_output_143_0_g1 , 0.0));
				float3 temp_output_23_0_g28 = ( objToWorld182_g1 + appendResult174_g1 );
				float3 position4_g28 = temp_output_23_0_g28;
				float3 direction4_g28 = temp_output_79_0_g1;
				float temp_output_24_0_g28 = temp_output_82_0_g1;
				float phase4_g28 = temp_output_24_0_g28;
				float temp_output_25_0_g28 = _TimeParameters.x;
				float time4_g28 = temp_output_25_0_g28;
				float temp_output_26_0_g28 = temp_output_81_0_g1;
				float gravity4_g28 = temp_output_26_0_g28;
				float temp_output_27_0_g28 = temp_output_80_0_g1;
				float depth4_g28 = temp_output_27_0_g28;
				float amplitude4_g28 = temp_output_84_0_g1;
				float3 result4_g28 = float3( 0,0,0 );
				gerstner_float( position4_g28 , direction4_g28 , phase4_g28 , time4_g28 , gravity4_g28 , depth4_g28 , amplitude4_g28 , result4_g28 );
				float localgerstner9_g28 = ( 0.0 );
				float3 position9_g28 = temp_output_23_0_g28;
				float3 direction9_g28 = temp_output_78_0_g1;
				float phase9_g28 = temp_output_24_0_g28;
				float time9_g28 = temp_output_25_0_g28;
				float gravity9_g28 = temp_output_26_0_g28;
				float depth9_g28 = temp_output_27_0_g28;
				float amplitude9_g28 = temp_output_73_0_g1;
				float3 result9_g28 = float3( 0,0,0 );
				gerstner_float( position9_g28 , direction9_g28 , phase9_g28 , time9_g28 , gravity9_g28 , depth9_g28 , amplitude9_g28 , result9_g28 );
				float localgerstner14_g28 = ( 0.0 );
				float3 position14_g28 = temp_output_23_0_g28;
				float3 direction14_g28 = temp_output_77_0_g1;
				float phase14_g28 = temp_output_24_0_g28;
				float time14_g28 = temp_output_25_0_g28;
				float gravity14_g28 = temp_output_26_0_g28;
				float depth14_g28 = temp_output_27_0_g28;
				float amplitude14_g28 = temp_output_75_0_g1;
				float3 result14_g28 = float3( 0,0,0 );
				gerstner_float( position14_g28 , direction14_g28 , phase14_g28 , time14_g28 , gravity14_g28 , depth14_g28 , amplitude14_g28 , result14_g28 );
				float localgerstner15_g28 = ( 0.0 );
				float3 position15_g28 = temp_output_23_0_g28;
				float3 direction15_g28 = temp_output_76_0_g1;
				float phase15_g28 = temp_output_24_0_g28;
				float time15_g28 = temp_output_25_0_g28;
				float gravity15_g28 = temp_output_26_0_g28;
				float depth15_g28 = temp_output_27_0_g28;
				float amplitude15_g28 = temp_output_74_0_g1;
				float3 result15_g28 = float3( 0,0,0 );
				gerstner_float( position15_g28 , direction15_g28 , phase15_g28 , time15_g28 , gravity15_g28 , depth15_g28 , amplitude15_g28 , result15_g28 );
				float3 worldToObj155_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g28 + result9_g28 ) + ( result14_g28 + result15_g28 ) ) + temp_output_23_0_g28 ), 1 ) ).xyz;
				float3 temp_output_3_0_g29 = worldToObj155_g1;
				float3 normalizeResult8_g29 = normalize( ( worldToObj156_g1 - temp_output_3_0_g29 ) );
				float localgerstner4_g26 = ( 0.0 );
				float3 objToWorld184_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 appendResult136_g1 = (float3(0.0 , 0.0 , temp_output_143_0_g1));
				float3 temp_output_23_0_g26 = ( objToWorld184_g1 + appendResult136_g1 );
				float3 position4_g26 = temp_output_23_0_g26;
				float3 direction4_g26 = temp_output_79_0_g1;
				float temp_output_24_0_g26 = temp_output_82_0_g1;
				float phase4_g26 = temp_output_24_0_g26;
				float temp_output_25_0_g26 = _TimeParameters.x;
				float time4_g26 = temp_output_25_0_g26;
				float temp_output_26_0_g26 = temp_output_81_0_g1;
				float gravity4_g26 = temp_output_26_0_g26;
				float temp_output_27_0_g26 = temp_output_80_0_g1;
				float depth4_g26 = temp_output_27_0_g26;
				float amplitude4_g26 = temp_output_84_0_g1;
				float3 result4_g26 = float3( 0,0,0 );
				gerstner_float( position4_g26 , direction4_g26 , phase4_g26 , time4_g26 , gravity4_g26 , depth4_g26 , amplitude4_g26 , result4_g26 );
				float localgerstner9_g26 = ( 0.0 );
				float3 position9_g26 = temp_output_23_0_g26;
				float3 direction9_g26 = temp_output_78_0_g1;
				float phase9_g26 = temp_output_24_0_g26;
				float time9_g26 = temp_output_25_0_g26;
				float gravity9_g26 = temp_output_26_0_g26;
				float depth9_g26 = temp_output_27_0_g26;
				float amplitude9_g26 = temp_output_73_0_g1;
				float3 result9_g26 = float3( 0,0,0 );
				gerstner_float( position9_g26 , direction9_g26 , phase9_g26 , time9_g26 , gravity9_g26 , depth9_g26 , amplitude9_g26 , result9_g26 );
				float localgerstner14_g26 = ( 0.0 );
				float3 position14_g26 = temp_output_23_0_g26;
				float3 direction14_g26 = temp_output_77_0_g1;
				float phase14_g26 = temp_output_24_0_g26;
				float time14_g26 = temp_output_25_0_g26;
				float gravity14_g26 = temp_output_26_0_g26;
				float depth14_g26 = temp_output_27_0_g26;
				float amplitude14_g26 = temp_output_75_0_g1;
				float3 result14_g26 = float3( 0,0,0 );
				gerstner_float( position14_g26 , direction14_g26 , phase14_g26 , time14_g26 , gravity14_g26 , depth14_g26 , amplitude14_g26 , result14_g26 );
				float localgerstner15_g26 = ( 0.0 );
				float3 position15_g26 = temp_output_23_0_g26;
				float3 direction15_g26 = temp_output_76_0_g1;
				float phase15_g26 = temp_output_24_0_g26;
				float time15_g26 = temp_output_25_0_g26;
				float gravity15_g26 = temp_output_26_0_g26;
				float depth15_g26 = temp_output_27_0_g26;
				float amplitude15_g26 = temp_output_74_0_g1;
				float3 result15_g26 = float3( 0,0,0 );
				gerstner_float( position15_g26 , direction15_g26 , phase15_g26 , time15_g26 , gravity15_g26 , depth15_g26 , amplitude15_g26 , result15_g26 );
				float3 worldToObj164_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g26 + result9_g26 ) + ( result14_g26 + result15_g26 ) ) + temp_output_23_0_g26 ), 1 ) ).xyz;
				float3 normalizeResult9_g29 = normalize( ( temp_output_3_0_g29 - worldToObj164_g1 ) );
				float3 normalizeResult11_g29 = normalize( cross( normalizeResult8_g29 , normalizeResult9_g29 ) );
				float3 GerstNorm134 = normalizeResult11_g29;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				

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
				float screenDepth498 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth498 = saturate( ( screenDepth498 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthDistance ) );
				float Depth500 = distanceDepth498;
				float4 lerpResult590 = lerp( _ShallowColor , _DeepColor , Depth500);
				

				float3 BaseColor = lerpResult590.rgb;
				float Alpha = ( Depth500 * _WaterThickness );
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
			Tags { "LightMode"="DepthNormals" }

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
			#define _NORMAL_DROPOFF_TS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_DISTANCE_TESSELLATION
			#define ASE_DEPTH_WRITE_ON
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1
			#define ASE_USING_SAMPLING_MACROS 1


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
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_POSITION
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
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FoamColor;
			float4 _NormalTexture2_ST;
			float4 _NormalTexture1_ST;
			float4 _Emmision;
			float4 _DeepColor;
			float4 _ShallowColor;
			float3 _Direction4;
			float3 _Direction1;
			float3 _Direction2;
			float3 _Direction3;
			float _RiseFadeout;
			float _RiseThreshold;
			float _NormalStrength;
			float _NormalPanSpeed;
			float _DepthDistance;
			float _NeighbourDistance;
			float _Amplitude3;
			float _Amplitude2;
			float _Intensity;
			float _Amplitude1;
			float _WaveDepth;
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

			TEXTURE2D(_NormalTexture1);
			SAMPLER(sampler_NormalTexture1);
			TEXTURE2D(_NormalTexture2);
			SAMPLER(sampler_NormalTexture2);
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
			
			inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }
			inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }
			inline float valueNoise (float2 uv)
			{
				float2 i = floor(uv);
				float2 f = frac( uv );
				f = f* f * (3.0 - 2.0 * f);
				uv = abs( frac(uv) - 0.5);
				float2 c0 = i + float2( 0.0, 0.0 );
				float2 c1 = i + float2( 1.0, 0.0 );
				float2 c2 = i + float2( 0.0, 1.0 );
				float2 c3 = i + float2( 1.0, 1.0 );
				float r0 = noise_randomValue( c0 );
				float r1 = noise_randomValue( c1 );
				float r2 = noise_randomValue( c2 );
				float r3 = noise_randomValue( c3 );
				float bottomOfGrid = noise_interpolate( r0, r1, f.x );
				float topOfGrid = noise_interpolate( r2, r3, f.x );
				float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
				return t;
			}
			
			float SimpleNoise(float2 UV)
			{
				float t = 0.0;
				float freq = pow( 2.0, float( 0 ) );
				float amp = pow( 0.5, float( 3 - 0 ) );
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(1));
				amp = pow(0.5, float(3-1));
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(2));
				amp = pow(0.5, float(3-2));
				t += valueNoise( UV/freq )*amp;
				return t;
			}
			
			float2 UnityGradientNoiseDir( float2 p )
			{
				p = fmod(p , 289);
				float x = fmod((34 * p.x + 1) * p.x , 289) + p.y;
				x = fmod( (34 * x + 1) * x , 289);
				x = frac( x / 41 ) * 2 - 1;
				return normalize( float2(x - floor(x + 0.5 ), abs( x ) - 0.5 ) );
			}
			
			float UnityGradientNoise( float2 UV, float Scale )
			{
				float2 p = UV * Scale;
				float2 ip = floor( p );
				float2 fp = frac( p );
				float d00 = dot( UnityGradientNoiseDir( ip ), fp );
				float d01 = dot( UnityGradientNoiseDir( ip + float2( 0, 1 ) ), fp - float2( 0, 1 ) );
				float d10 = dot( UnityGradientNoiseDir( ip + float2( 1, 0 ) ), fp - float2( 1, 0 ) );
				float d11 = dot( UnityGradientNoiseDir( ip + float2( 1, 1 ) ), fp - float2( 1, 1 ) );
				fp = fp * fp * fp * ( fp * ( fp * 6 - 15 ) + 10 );
				return lerp( lerp( d00, d01, fp.y ), lerp( d10, d11, fp.y ), fp.x ) + 0.5;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float localgerstner4_g24 = ( 0.0 );
				float3 objToWorld179_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float temp_output_143_0_g1 = _NeighbourDistance;
				float3 appendResult142_g1 = (float3(temp_output_143_0_g1 , 0.0 , 0.0));
				float3 temp_output_23_0_g24 = ( objToWorld179_g1 + appendResult142_g1 );
				float3 position4_g24 = temp_output_23_0_g24;
				float temp_output_615_0 = radians( _Roataion );
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_79_0_g1 = rotatedValue387;
				float3 direction4_g24 = temp_output_79_0_g1;
				float temp_output_82_0_g1 = _Phase;
				float temp_output_24_0_g24 = temp_output_82_0_g1;
				float phase4_g24 = temp_output_24_0_g24;
				float temp_output_25_0_g24 = _TimeParameters.x;
				float time4_g24 = temp_output_25_0_g24;
				float temp_output_81_0_g1 = _Gravity;
				float temp_output_26_0_g24 = temp_output_81_0_g1;
				float gravity4_g24 = temp_output_26_0_g24;
				float temp_output_80_0_g1 = _WaveDepth;
				float temp_output_27_0_g24 = temp_output_80_0_g1;
				float depth4_g24 = temp_output_27_0_g24;
				float temp_output_84_0_g1 = ( _Amplitude1 * _Intensity );
				float amplitude4_g24 = temp_output_84_0_g1;
				float3 result4_g24 = float3( 0,0,0 );
				gerstner_float( position4_g24 , direction4_g24 , phase4_g24 , time4_g24 , gravity4_g24 , depth4_g24 , amplitude4_g24 , result4_g24 );
				float localgerstner9_g24 = ( 0.0 );
				float3 position9_g24 = temp_output_23_0_g24;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_78_0_g1 = rotatedValue64;
				float3 direction9_g24 = temp_output_78_0_g1;
				float phase9_g24 = temp_output_24_0_g24;
				float time9_g24 = temp_output_25_0_g24;
				float gravity9_g24 = temp_output_26_0_g24;
				float depth9_g24 = temp_output_27_0_g24;
				float temp_output_73_0_g1 = ( _Intensity * _Amplitude2 );
				float amplitude9_g24 = temp_output_73_0_g1;
				float3 result9_g24 = float3( 0,0,0 );
				gerstner_float( position9_g24 , direction9_g24 , phase9_g24 , time9_g24 , gravity9_g24 , depth9_g24 , amplitude9_g24 , result9_g24 );
				float localgerstner14_g24 = ( 0.0 );
				float3 position14_g24 = temp_output_23_0_g24;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_77_0_g1 = rotatedValue65;
				float3 direction14_g24 = temp_output_77_0_g1;
				float phase14_g24 = temp_output_24_0_g24;
				float time14_g24 = temp_output_25_0_g24;
				float gravity14_g24 = temp_output_26_0_g24;
				float depth14_g24 = temp_output_27_0_g24;
				float temp_output_75_0_g1 = ( _Intensity * _Amplitude3 );
				float amplitude14_g24 = temp_output_75_0_g1;
				float3 result14_g24 = float3( 0,0,0 );
				gerstner_float( position14_g24 , direction14_g24 , phase14_g24 , time14_g24 , gravity14_g24 , depth14_g24 , amplitude14_g24 , result14_g24 );
				float localgerstner15_g24 = ( 0.0 );
				float3 position15_g24 = temp_output_23_0_g24;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_76_0_g1 = rotatedValue66;
				float3 direction15_g24 = temp_output_76_0_g1;
				float phase15_g24 = temp_output_24_0_g24;
				float time15_g24 = temp_output_25_0_g24;
				float gravity15_g24 = temp_output_26_0_g24;
				float depth15_g24 = temp_output_27_0_g24;
				float temp_output_74_0_g1 = ( _Amplitude4 * _Intensity );
				float amplitude15_g24 = temp_output_74_0_g1;
				float3 result15_g24 = float3( 0,0,0 );
				gerstner_float( position15_g24 , direction15_g24 , phase15_g24 , time15_g24 , gravity15_g24 , depth15_g24 , amplitude15_g24 , result15_g24 );
				float3 worldToObj156_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g24 + result9_g24 ) + ( result14_g24 + result15_g24 ) ) + temp_output_23_0_g24 ), 1 ) ).xyz;
				float3 GerstPos132 = worldToObj156_g1;
				
				float localgerstner4_g28 = ( 0.0 );
				float3 objToWorld182_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 appendResult174_g1 = (float3(0.0 , temp_output_143_0_g1 , 0.0));
				float3 temp_output_23_0_g28 = ( objToWorld182_g1 + appendResult174_g1 );
				float3 position4_g28 = temp_output_23_0_g28;
				float3 direction4_g28 = temp_output_79_0_g1;
				float temp_output_24_0_g28 = temp_output_82_0_g1;
				float phase4_g28 = temp_output_24_0_g28;
				float temp_output_25_0_g28 = _TimeParameters.x;
				float time4_g28 = temp_output_25_0_g28;
				float temp_output_26_0_g28 = temp_output_81_0_g1;
				float gravity4_g28 = temp_output_26_0_g28;
				float temp_output_27_0_g28 = temp_output_80_0_g1;
				float depth4_g28 = temp_output_27_0_g28;
				float amplitude4_g28 = temp_output_84_0_g1;
				float3 result4_g28 = float3( 0,0,0 );
				gerstner_float( position4_g28 , direction4_g28 , phase4_g28 , time4_g28 , gravity4_g28 , depth4_g28 , amplitude4_g28 , result4_g28 );
				float localgerstner9_g28 = ( 0.0 );
				float3 position9_g28 = temp_output_23_0_g28;
				float3 direction9_g28 = temp_output_78_0_g1;
				float phase9_g28 = temp_output_24_0_g28;
				float time9_g28 = temp_output_25_0_g28;
				float gravity9_g28 = temp_output_26_0_g28;
				float depth9_g28 = temp_output_27_0_g28;
				float amplitude9_g28 = temp_output_73_0_g1;
				float3 result9_g28 = float3( 0,0,0 );
				gerstner_float( position9_g28 , direction9_g28 , phase9_g28 , time9_g28 , gravity9_g28 , depth9_g28 , amplitude9_g28 , result9_g28 );
				float localgerstner14_g28 = ( 0.0 );
				float3 position14_g28 = temp_output_23_0_g28;
				float3 direction14_g28 = temp_output_77_0_g1;
				float phase14_g28 = temp_output_24_0_g28;
				float time14_g28 = temp_output_25_0_g28;
				float gravity14_g28 = temp_output_26_0_g28;
				float depth14_g28 = temp_output_27_0_g28;
				float amplitude14_g28 = temp_output_75_0_g1;
				float3 result14_g28 = float3( 0,0,0 );
				gerstner_float( position14_g28 , direction14_g28 , phase14_g28 , time14_g28 , gravity14_g28 , depth14_g28 , amplitude14_g28 , result14_g28 );
				float localgerstner15_g28 = ( 0.0 );
				float3 position15_g28 = temp_output_23_0_g28;
				float3 direction15_g28 = temp_output_76_0_g1;
				float phase15_g28 = temp_output_24_0_g28;
				float time15_g28 = temp_output_25_0_g28;
				float gravity15_g28 = temp_output_26_0_g28;
				float depth15_g28 = temp_output_27_0_g28;
				float amplitude15_g28 = temp_output_74_0_g1;
				float3 result15_g28 = float3( 0,0,0 );
				gerstner_float( position15_g28 , direction15_g28 , phase15_g28 , time15_g28 , gravity15_g28 , depth15_g28 , amplitude15_g28 , result15_g28 );
				float3 worldToObj155_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g28 + result9_g28 ) + ( result14_g28 + result15_g28 ) ) + temp_output_23_0_g28 ), 1 ) ).xyz;
				float3 temp_output_3_0_g29 = worldToObj155_g1;
				float3 normalizeResult8_g29 = normalize( ( worldToObj156_g1 - temp_output_3_0_g29 ) );
				float localgerstner4_g26 = ( 0.0 );
				float3 objToWorld184_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 appendResult136_g1 = (float3(0.0 , 0.0 , temp_output_143_0_g1));
				float3 temp_output_23_0_g26 = ( objToWorld184_g1 + appendResult136_g1 );
				float3 position4_g26 = temp_output_23_0_g26;
				float3 direction4_g26 = temp_output_79_0_g1;
				float temp_output_24_0_g26 = temp_output_82_0_g1;
				float phase4_g26 = temp_output_24_0_g26;
				float temp_output_25_0_g26 = _TimeParameters.x;
				float time4_g26 = temp_output_25_0_g26;
				float temp_output_26_0_g26 = temp_output_81_0_g1;
				float gravity4_g26 = temp_output_26_0_g26;
				float temp_output_27_0_g26 = temp_output_80_0_g1;
				float depth4_g26 = temp_output_27_0_g26;
				float amplitude4_g26 = temp_output_84_0_g1;
				float3 result4_g26 = float3( 0,0,0 );
				gerstner_float( position4_g26 , direction4_g26 , phase4_g26 , time4_g26 , gravity4_g26 , depth4_g26 , amplitude4_g26 , result4_g26 );
				float localgerstner9_g26 = ( 0.0 );
				float3 position9_g26 = temp_output_23_0_g26;
				float3 direction9_g26 = temp_output_78_0_g1;
				float phase9_g26 = temp_output_24_0_g26;
				float time9_g26 = temp_output_25_0_g26;
				float gravity9_g26 = temp_output_26_0_g26;
				float depth9_g26 = temp_output_27_0_g26;
				float amplitude9_g26 = temp_output_73_0_g1;
				float3 result9_g26 = float3( 0,0,0 );
				gerstner_float( position9_g26 , direction9_g26 , phase9_g26 , time9_g26 , gravity9_g26 , depth9_g26 , amplitude9_g26 , result9_g26 );
				float localgerstner14_g26 = ( 0.0 );
				float3 position14_g26 = temp_output_23_0_g26;
				float3 direction14_g26 = temp_output_77_0_g1;
				float phase14_g26 = temp_output_24_0_g26;
				float time14_g26 = temp_output_25_0_g26;
				float gravity14_g26 = temp_output_26_0_g26;
				float depth14_g26 = temp_output_27_0_g26;
				float amplitude14_g26 = temp_output_75_0_g1;
				float3 result14_g26 = float3( 0,0,0 );
				gerstner_float( position14_g26 , direction14_g26 , phase14_g26 , time14_g26 , gravity14_g26 , depth14_g26 , amplitude14_g26 , result14_g26 );
				float localgerstner15_g26 = ( 0.0 );
				float3 position15_g26 = temp_output_23_0_g26;
				float3 direction15_g26 = temp_output_76_0_g1;
				float phase15_g26 = temp_output_24_0_g26;
				float time15_g26 = temp_output_25_0_g26;
				float gravity15_g26 = temp_output_26_0_g26;
				float depth15_g26 = temp_output_27_0_g26;
				float amplitude15_g26 = temp_output_74_0_g1;
				float3 result15_g26 = float3( 0,0,0 );
				gerstner_float( position15_g26 , direction15_g26 , phase15_g26 , time15_g26 , gravity15_g26 , depth15_g26 , amplitude15_g26 , result15_g26 );
				float3 worldToObj164_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g26 + result9_g26 ) + ( result14_g26 + result15_g26 ) ) + temp_output_23_0_g26 ), 1 ) ).xyz;
				float3 normalizeResult9_g29 = normalize( ( temp_output_3_0_g29 - worldToObj164_g1 ) );
				float3 normalizeResult11_g29 = normalize( cross( normalizeResult8_g29 , normalizeResult9_g29 ) );
				float3 GerstNorm134 = normalizeResult11_g29;
				
				o.ase_texcoord5.xy = v.ase_texcoord.xy;
				o.ase_texcoord6 = v.vertex;
				
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

				float mulTime568 = _TimeParameters.x * _NormalPanSpeed;
				float2 appendResult574 = (float2(WorldPosition.x , WorldPosition.z));
				float2 texCoord577 = IN.ase_texcoord5.xy * _NormalTexture1_ST.xy + ( ( float2( 0.4,0.17 ) * mulTime568 ) + appendResult574 );
				float3 unpack580 = UnpackNormalScale( SAMPLE_TEXTURE2D( _NormalTexture1, sampler_NormalTexture1, texCoord577 ), _NormalStrength );
				unpack580.z = lerp( 1, unpack580.z, saturate(_NormalStrength) );
				float2 texCoord582 = IN.ase_texcoord5.xy * _NormalTexture2_ST.xy + ( appendResult574 + ( mulTime568 * float2( -0.5,0.2 ) ) );
				float3 unpack584 = UnpackNormalScale( SAMPLE_TEXTURE2D( _NormalTexture2, sampler_NormalTexture2, texCoord582 ), _NormalStrength );
				unpack584.z = lerp( 1, unpack584.z, saturate(_NormalStrength) );
				float lerpResult558 = lerp( _RiseThreshold , 1.0 , _RiseFadeout);
				float localgerstner4_g24 = ( 0.0 );
				float3 objToWorld179_g1 = mul( GetObjectToWorldMatrix(), float4( IN.ase_texcoord6.xyz, 1 ) ).xyz;
				float temp_output_143_0_g1 = _NeighbourDistance;
				float3 appendResult142_g1 = (float3(temp_output_143_0_g1 , 0.0 , 0.0));
				float3 temp_output_23_0_g24 = ( objToWorld179_g1 + appendResult142_g1 );
				float3 position4_g24 = temp_output_23_0_g24;
				float temp_output_615_0 = radians( _Roataion );
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_79_0_g1 = rotatedValue387;
				float3 direction4_g24 = temp_output_79_0_g1;
				float temp_output_82_0_g1 = _Phase;
				float temp_output_24_0_g24 = temp_output_82_0_g1;
				float phase4_g24 = temp_output_24_0_g24;
				float temp_output_25_0_g24 = _TimeParameters.x;
				float time4_g24 = temp_output_25_0_g24;
				float temp_output_81_0_g1 = _Gravity;
				float temp_output_26_0_g24 = temp_output_81_0_g1;
				float gravity4_g24 = temp_output_26_0_g24;
				float temp_output_80_0_g1 = _WaveDepth;
				float temp_output_27_0_g24 = temp_output_80_0_g1;
				float depth4_g24 = temp_output_27_0_g24;
				float temp_output_84_0_g1 = ( _Amplitude1 * _Intensity );
				float amplitude4_g24 = temp_output_84_0_g1;
				float3 result4_g24 = float3( 0,0,0 );
				gerstner_float( position4_g24 , direction4_g24 , phase4_g24 , time4_g24 , gravity4_g24 , depth4_g24 , amplitude4_g24 , result4_g24 );
				float localgerstner9_g24 = ( 0.0 );
				float3 position9_g24 = temp_output_23_0_g24;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_78_0_g1 = rotatedValue64;
				float3 direction9_g24 = temp_output_78_0_g1;
				float phase9_g24 = temp_output_24_0_g24;
				float time9_g24 = temp_output_25_0_g24;
				float gravity9_g24 = temp_output_26_0_g24;
				float depth9_g24 = temp_output_27_0_g24;
				float temp_output_73_0_g1 = ( _Intensity * _Amplitude2 );
				float amplitude9_g24 = temp_output_73_0_g1;
				float3 result9_g24 = float3( 0,0,0 );
				gerstner_float( position9_g24 , direction9_g24 , phase9_g24 , time9_g24 , gravity9_g24 , depth9_g24 , amplitude9_g24 , result9_g24 );
				float localgerstner14_g24 = ( 0.0 );
				float3 position14_g24 = temp_output_23_0_g24;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_77_0_g1 = rotatedValue65;
				float3 direction14_g24 = temp_output_77_0_g1;
				float phase14_g24 = temp_output_24_0_g24;
				float time14_g24 = temp_output_25_0_g24;
				float gravity14_g24 = temp_output_26_0_g24;
				float depth14_g24 = temp_output_27_0_g24;
				float temp_output_75_0_g1 = ( _Intensity * _Amplitude3 );
				float amplitude14_g24 = temp_output_75_0_g1;
				float3 result14_g24 = float3( 0,0,0 );
				gerstner_float( position14_g24 , direction14_g24 , phase14_g24 , time14_g24 , gravity14_g24 , depth14_g24 , amplitude14_g24 , result14_g24 );
				float localgerstner15_g24 = ( 0.0 );
				float3 position15_g24 = temp_output_23_0_g24;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_76_0_g1 = rotatedValue66;
				float3 direction15_g24 = temp_output_76_0_g1;
				float phase15_g24 = temp_output_24_0_g24;
				float time15_g24 = temp_output_25_0_g24;
				float gravity15_g24 = temp_output_26_0_g24;
				float depth15_g24 = temp_output_27_0_g24;
				float temp_output_74_0_g1 = ( _Amplitude4 * _Intensity );
				float amplitude15_g24 = temp_output_74_0_g1;
				float3 result15_g24 = float3( 0,0,0 );
				gerstner_float( position15_g24 , direction15_g24 , phase15_g24 , time15_g24 , gravity15_g24 , depth15_g24 , amplitude15_g24 , result15_g24 );
				float3 worldToObj156_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g24 + result9_g24 ) + ( result14_g24 + result15_g24 ) ) + temp_output_23_0_g24 ), 1 ) ).xyz;
				float localgerstner4_g28 = ( 0.0 );
				float3 objToWorld182_g1 = mul( GetObjectToWorldMatrix(), float4( IN.ase_texcoord6.xyz, 1 ) ).xyz;
				float3 appendResult174_g1 = (float3(0.0 , temp_output_143_0_g1 , 0.0));
				float3 temp_output_23_0_g28 = ( objToWorld182_g1 + appendResult174_g1 );
				float3 position4_g28 = temp_output_23_0_g28;
				float3 direction4_g28 = temp_output_79_0_g1;
				float temp_output_24_0_g28 = temp_output_82_0_g1;
				float phase4_g28 = temp_output_24_0_g28;
				float temp_output_25_0_g28 = _TimeParameters.x;
				float time4_g28 = temp_output_25_0_g28;
				float temp_output_26_0_g28 = temp_output_81_0_g1;
				float gravity4_g28 = temp_output_26_0_g28;
				float temp_output_27_0_g28 = temp_output_80_0_g1;
				float depth4_g28 = temp_output_27_0_g28;
				float amplitude4_g28 = temp_output_84_0_g1;
				float3 result4_g28 = float3( 0,0,0 );
				gerstner_float( position4_g28 , direction4_g28 , phase4_g28 , time4_g28 , gravity4_g28 , depth4_g28 , amplitude4_g28 , result4_g28 );
				float localgerstner9_g28 = ( 0.0 );
				float3 position9_g28 = temp_output_23_0_g28;
				float3 direction9_g28 = temp_output_78_0_g1;
				float phase9_g28 = temp_output_24_0_g28;
				float time9_g28 = temp_output_25_0_g28;
				float gravity9_g28 = temp_output_26_0_g28;
				float depth9_g28 = temp_output_27_0_g28;
				float amplitude9_g28 = temp_output_73_0_g1;
				float3 result9_g28 = float3( 0,0,0 );
				gerstner_float( position9_g28 , direction9_g28 , phase9_g28 , time9_g28 , gravity9_g28 , depth9_g28 , amplitude9_g28 , result9_g28 );
				float localgerstner14_g28 = ( 0.0 );
				float3 position14_g28 = temp_output_23_0_g28;
				float3 direction14_g28 = temp_output_77_0_g1;
				float phase14_g28 = temp_output_24_0_g28;
				float time14_g28 = temp_output_25_0_g28;
				float gravity14_g28 = temp_output_26_0_g28;
				float depth14_g28 = temp_output_27_0_g28;
				float amplitude14_g28 = temp_output_75_0_g1;
				float3 result14_g28 = float3( 0,0,0 );
				gerstner_float( position14_g28 , direction14_g28 , phase14_g28 , time14_g28 , gravity14_g28 , depth14_g28 , amplitude14_g28 , result14_g28 );
				float localgerstner15_g28 = ( 0.0 );
				float3 position15_g28 = temp_output_23_0_g28;
				float3 direction15_g28 = temp_output_76_0_g1;
				float phase15_g28 = temp_output_24_0_g28;
				float time15_g28 = temp_output_25_0_g28;
				float gravity15_g28 = temp_output_26_0_g28;
				float depth15_g28 = temp_output_27_0_g28;
				float amplitude15_g28 = temp_output_74_0_g1;
				float3 result15_g28 = float3( 0,0,0 );
				gerstner_float( position15_g28 , direction15_g28 , phase15_g28 , time15_g28 , gravity15_g28 , depth15_g28 , amplitude15_g28 , result15_g28 );
				float3 worldToObj155_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g28 + result9_g28 ) + ( result14_g28 + result15_g28 ) ) + temp_output_23_0_g28 ), 1 ) ).xyz;
				float3 temp_output_3_0_g29 = worldToObj155_g1;
				float3 normalizeResult8_g29 = normalize( ( worldToObj156_g1 - temp_output_3_0_g29 ) );
				float localgerstner4_g26 = ( 0.0 );
				float3 objToWorld184_g1 = mul( GetObjectToWorldMatrix(), float4( IN.ase_texcoord6.xyz, 1 ) ).xyz;
				float3 appendResult136_g1 = (float3(0.0 , 0.0 , temp_output_143_0_g1));
				float3 temp_output_23_0_g26 = ( objToWorld184_g1 + appendResult136_g1 );
				float3 position4_g26 = temp_output_23_0_g26;
				float3 direction4_g26 = temp_output_79_0_g1;
				float temp_output_24_0_g26 = temp_output_82_0_g1;
				float phase4_g26 = temp_output_24_0_g26;
				float temp_output_25_0_g26 = _TimeParameters.x;
				float time4_g26 = temp_output_25_0_g26;
				float temp_output_26_0_g26 = temp_output_81_0_g1;
				float gravity4_g26 = temp_output_26_0_g26;
				float temp_output_27_0_g26 = temp_output_80_0_g1;
				float depth4_g26 = temp_output_27_0_g26;
				float amplitude4_g26 = temp_output_84_0_g1;
				float3 result4_g26 = float3( 0,0,0 );
				gerstner_float( position4_g26 , direction4_g26 , phase4_g26 , time4_g26 , gravity4_g26 , depth4_g26 , amplitude4_g26 , result4_g26 );
				float localgerstner9_g26 = ( 0.0 );
				float3 position9_g26 = temp_output_23_0_g26;
				float3 direction9_g26 = temp_output_78_0_g1;
				float phase9_g26 = temp_output_24_0_g26;
				float time9_g26 = temp_output_25_0_g26;
				float gravity9_g26 = temp_output_26_0_g26;
				float depth9_g26 = temp_output_27_0_g26;
				float amplitude9_g26 = temp_output_73_0_g1;
				float3 result9_g26 = float3( 0,0,0 );
				gerstner_float( position9_g26 , direction9_g26 , phase9_g26 , time9_g26 , gravity9_g26 , depth9_g26 , amplitude9_g26 , result9_g26 );
				float localgerstner14_g26 = ( 0.0 );
				float3 position14_g26 = temp_output_23_0_g26;
				float3 direction14_g26 = temp_output_77_0_g1;
				float phase14_g26 = temp_output_24_0_g26;
				float time14_g26 = temp_output_25_0_g26;
				float gravity14_g26 = temp_output_26_0_g26;
				float depth14_g26 = temp_output_27_0_g26;
				float amplitude14_g26 = temp_output_75_0_g1;
				float3 result14_g26 = float3( 0,0,0 );
				gerstner_float( position14_g26 , direction14_g26 , phase14_g26 , time14_g26 , gravity14_g26 , depth14_g26 , amplitude14_g26 , result14_g26 );
				float localgerstner15_g26 = ( 0.0 );
				float3 position15_g26 = temp_output_23_0_g26;
				float3 direction15_g26 = temp_output_76_0_g1;
				float phase15_g26 = temp_output_24_0_g26;
				float time15_g26 = temp_output_25_0_g26;
				float gravity15_g26 = temp_output_26_0_g26;
				float depth15_g26 = temp_output_27_0_g26;
				float amplitude15_g26 = temp_output_74_0_g1;
				float3 result15_g26 = float3( 0,0,0 );
				gerstner_float( position15_g26 , direction15_g26 , phase15_g26 , time15_g26 , gravity15_g26 , depth15_g26 , amplitude15_g26 , result15_g26 );
				float3 worldToObj164_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g26 + result9_g26 ) + ( result14_g26 + result15_g26 ) ) + temp_output_23_0_g26 ), 1 ) ).xyz;
				float3 normalizeResult9_g29 = normalize( ( temp_output_3_0_g29 - worldToObj164_g1 ) );
				float3 normalizeResult11_g29 = normalize( cross( normalizeResult8_g29 , normalizeResult9_g29 ) );
				float3 GerstNorm134 = normalizeResult11_g29;
				float4 temp_output_6_0_g30 = float4( 0,1,0,0 );
				float dotResult1_g30 = dot( float4( GerstNorm134 , 0.0 ) , temp_output_6_0_g30 );
				float dotResult2_g30 = dot( temp_output_6_0_g30 , temp_output_6_0_g30 );
				float2 appendResult536 = (float2(WorldPosition.x , WorldPosition.z));
				float2 texCoord537 = IN.ase_texcoord5.xy * float2( 1,1 ) + appendResult536;
				float rotation543 = temp_output_615_0;
				float cos539 = cos( rotation543 );
				float sin539 = sin( rotation543 );
				float2 rotator539 = mul( texCoord537 - float2( 0.5,0.5 ) , float2x2( cos539 , -sin539 , sin539 , cos539 )) + float2( 0.5,0.5 );
				float simpleNoise545 = SimpleNoise( rotator539*5.0 );
				float2 texCoord553 = IN.ase_texcoord5.xy * float2( 1,1 ) + ( appendResult536 + _TimeParameters.x );
				float gradientNoise554 = UnityGradientNoise(texCoord553,0.02);
				gradientNoise554 = gradientNoise554*0.5 + 0.5;
				float smoothstepResult559 = smoothstep( _RiseThreshold , lerpResult558 , ( (1.0 + (length( ( ( dotResult1_g30 / dotResult2_g30 ) * temp_output_6_0_g30 ) ) - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) + (-0.1 + (simpleNoise545 - 0.0) * (0.1 - -0.1) / (1.0 - 0.0)) + (-0.3 + (gradientNoise554 - 0.0) * (0.3 - -0.3) / (1.0 - 0.0)) ));
				float RiseTide560 = smoothstepResult559;
				float4 ase_screenPosNorm = ScreenPos / ScreenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth498 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth498 = saturate( ( screenDepth498 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthDistance ) );
				float smoothstepResult523 = smoothstep( 0.97 , 1.0 , (1.0 + (distanceDepth498 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
				float2 appendResult510 = (float2(WorldPosition.x , WorldPosition.z));
				float2 texCoord517 = IN.ase_texcoord5.xy * float2( 1,1 ) + ( ( _TimeParameters.x * 0.5 ) + appendResult510 );
				float gradientNoise516 = UnityGradientNoise(texCoord517,2.15);
				gradientNoise516 = gradientNoise516*0.5 + 0.5;
				float clampResult526 = clamp( ( ( pow( ( 1.0 / 1000.0 ) , distanceDepth498 ) * cos( ( ( distanceDepth498 * 100.0 ) + ( 4.0 * _TimeParameters.x ) ) ) ) * ( 0.5 + gradientNoise516 ) ) , -0.1 , 1.0 );
				float Foam564 = step( ( RiseTide560 + smoothstepResult523 + clampResult526 ) , 0.5 );
				float3 lerpResult587 = lerp( float3( 0.5,0.5,1 ) , BlendNormal( unpack580 , unpack584 ) , Foam564);
				
				float Depth500 = distanceDepth498;
				

				float3 Normal = lerpResult587;
				float Alpha = ( Depth500 * _WaterThickness );
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
			#define _NORMAL_DROPOFF_TS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_DISTANCE_TESSELLATION
			#define ASE_DEPTH_WRITE_ON
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1
			#define ASE_USING_SAMPLING_MACROS 1


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
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_POSITION


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
				float4 ase_texcoord9 : TEXCOORD9;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FoamColor;
			float4 _NormalTexture2_ST;
			float4 _NormalTexture1_ST;
			float4 _Emmision;
			float4 _DeepColor;
			float4 _ShallowColor;
			float3 _Direction4;
			float3 _Direction1;
			float3 _Direction2;
			float3 _Direction3;
			float _RiseFadeout;
			float _RiseThreshold;
			float _NormalStrength;
			float _NormalPanSpeed;
			float _DepthDistance;
			float _NeighbourDistance;
			float _Amplitude3;
			float _Amplitude2;
			float _Intensity;
			float _Amplitude1;
			float _WaveDepth;
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
			TEXTURE2D(_NormalTexture1);
			SAMPLER(sampler_NormalTexture1);
			TEXTURE2D(_NormalTexture2);
			SAMPLER(sampler_NormalTexture2);


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
			
			inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }
			inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }
			inline float valueNoise (float2 uv)
			{
				float2 i = floor(uv);
				float2 f = frac( uv );
				f = f* f * (3.0 - 2.0 * f);
				uv = abs( frac(uv) - 0.5);
				float2 c0 = i + float2( 0.0, 0.0 );
				float2 c1 = i + float2( 1.0, 0.0 );
				float2 c2 = i + float2( 0.0, 1.0 );
				float2 c3 = i + float2( 1.0, 1.0 );
				float r0 = noise_randomValue( c0 );
				float r1 = noise_randomValue( c1 );
				float r2 = noise_randomValue( c2 );
				float r3 = noise_randomValue( c3 );
				float bottomOfGrid = noise_interpolate( r0, r1, f.x );
				float topOfGrid = noise_interpolate( r2, r3, f.x );
				float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
				return t;
			}
			
			float SimpleNoise(float2 UV)
			{
				float t = 0.0;
				float freq = pow( 2.0, float( 0 ) );
				float amp = pow( 0.5, float( 3 - 0 ) );
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(1));
				amp = pow(0.5, float(3-1));
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(2));
				amp = pow(0.5, float(3-2));
				t += valueNoise( UV/freq )*amp;
				return t;
			}
			
			float2 UnityGradientNoiseDir( float2 p )
			{
				p = fmod(p , 289);
				float x = fmod((34 * p.x + 1) * p.x , 289) + p.y;
				x = fmod( (34 * x + 1) * x , 289);
				x = frac( x / 41 ) * 2 - 1;
				return normalize( float2(x - floor(x + 0.5 ), abs( x ) - 0.5 ) );
			}
			
			float UnityGradientNoise( float2 UV, float Scale )
			{
				float2 p = UV * Scale;
				float2 ip = floor( p );
				float2 fp = frac( p );
				float d00 = dot( UnityGradientNoiseDir( ip ), fp );
				float d01 = dot( UnityGradientNoiseDir( ip + float2( 0, 1 ) ), fp - float2( 0, 1 ) );
				float d10 = dot( UnityGradientNoiseDir( ip + float2( 1, 0 ) ), fp - float2( 1, 0 ) );
				float d11 = dot( UnityGradientNoiseDir( ip + float2( 1, 1 ) ), fp - float2( 1, 1 ) );
				fp = fp * fp * fp * ( fp * ( fp * 6 - 15 ) + 10 );
				return lerp( lerp( d00, d01, fp.y ), lerp( d10, d11, fp.y ), fp.x ) + 0.5;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float localgerstner4_g24 = ( 0.0 );
				float3 objToWorld179_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float temp_output_143_0_g1 = _NeighbourDistance;
				float3 appendResult142_g1 = (float3(temp_output_143_0_g1 , 0.0 , 0.0));
				float3 temp_output_23_0_g24 = ( objToWorld179_g1 + appendResult142_g1 );
				float3 position4_g24 = temp_output_23_0_g24;
				float temp_output_615_0 = radians( _Roataion );
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_79_0_g1 = rotatedValue387;
				float3 direction4_g24 = temp_output_79_0_g1;
				float temp_output_82_0_g1 = _Phase;
				float temp_output_24_0_g24 = temp_output_82_0_g1;
				float phase4_g24 = temp_output_24_0_g24;
				float temp_output_25_0_g24 = _TimeParameters.x;
				float time4_g24 = temp_output_25_0_g24;
				float temp_output_81_0_g1 = _Gravity;
				float temp_output_26_0_g24 = temp_output_81_0_g1;
				float gravity4_g24 = temp_output_26_0_g24;
				float temp_output_80_0_g1 = _WaveDepth;
				float temp_output_27_0_g24 = temp_output_80_0_g1;
				float depth4_g24 = temp_output_27_0_g24;
				float temp_output_84_0_g1 = ( _Amplitude1 * _Intensity );
				float amplitude4_g24 = temp_output_84_0_g1;
				float3 result4_g24 = float3( 0,0,0 );
				gerstner_float( position4_g24 , direction4_g24 , phase4_g24 , time4_g24 , gravity4_g24 , depth4_g24 , amplitude4_g24 , result4_g24 );
				float localgerstner9_g24 = ( 0.0 );
				float3 position9_g24 = temp_output_23_0_g24;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_78_0_g1 = rotatedValue64;
				float3 direction9_g24 = temp_output_78_0_g1;
				float phase9_g24 = temp_output_24_0_g24;
				float time9_g24 = temp_output_25_0_g24;
				float gravity9_g24 = temp_output_26_0_g24;
				float depth9_g24 = temp_output_27_0_g24;
				float temp_output_73_0_g1 = ( _Intensity * _Amplitude2 );
				float amplitude9_g24 = temp_output_73_0_g1;
				float3 result9_g24 = float3( 0,0,0 );
				gerstner_float( position9_g24 , direction9_g24 , phase9_g24 , time9_g24 , gravity9_g24 , depth9_g24 , amplitude9_g24 , result9_g24 );
				float localgerstner14_g24 = ( 0.0 );
				float3 position14_g24 = temp_output_23_0_g24;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_77_0_g1 = rotatedValue65;
				float3 direction14_g24 = temp_output_77_0_g1;
				float phase14_g24 = temp_output_24_0_g24;
				float time14_g24 = temp_output_25_0_g24;
				float gravity14_g24 = temp_output_26_0_g24;
				float depth14_g24 = temp_output_27_0_g24;
				float temp_output_75_0_g1 = ( _Intensity * _Amplitude3 );
				float amplitude14_g24 = temp_output_75_0_g1;
				float3 result14_g24 = float3( 0,0,0 );
				gerstner_float( position14_g24 , direction14_g24 , phase14_g24 , time14_g24 , gravity14_g24 , depth14_g24 , amplitude14_g24 , result14_g24 );
				float localgerstner15_g24 = ( 0.0 );
				float3 position15_g24 = temp_output_23_0_g24;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_76_0_g1 = rotatedValue66;
				float3 direction15_g24 = temp_output_76_0_g1;
				float phase15_g24 = temp_output_24_0_g24;
				float time15_g24 = temp_output_25_0_g24;
				float gravity15_g24 = temp_output_26_0_g24;
				float depth15_g24 = temp_output_27_0_g24;
				float temp_output_74_0_g1 = ( _Amplitude4 * _Intensity );
				float amplitude15_g24 = temp_output_74_0_g1;
				float3 result15_g24 = float3( 0,0,0 );
				gerstner_float( position15_g24 , direction15_g24 , phase15_g24 , time15_g24 , gravity15_g24 , depth15_g24 , amplitude15_g24 , result15_g24 );
				float3 worldToObj156_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g24 + result9_g24 ) + ( result14_g24 + result15_g24 ) ) + temp_output_23_0_g24 ), 1 ) ).xyz;
				float3 GerstPos132 = worldToObj156_g1;
				
				float localgerstner4_g28 = ( 0.0 );
				float3 objToWorld182_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 appendResult174_g1 = (float3(0.0 , temp_output_143_0_g1 , 0.0));
				float3 temp_output_23_0_g28 = ( objToWorld182_g1 + appendResult174_g1 );
				float3 position4_g28 = temp_output_23_0_g28;
				float3 direction4_g28 = temp_output_79_0_g1;
				float temp_output_24_0_g28 = temp_output_82_0_g1;
				float phase4_g28 = temp_output_24_0_g28;
				float temp_output_25_0_g28 = _TimeParameters.x;
				float time4_g28 = temp_output_25_0_g28;
				float temp_output_26_0_g28 = temp_output_81_0_g1;
				float gravity4_g28 = temp_output_26_0_g28;
				float temp_output_27_0_g28 = temp_output_80_0_g1;
				float depth4_g28 = temp_output_27_0_g28;
				float amplitude4_g28 = temp_output_84_0_g1;
				float3 result4_g28 = float3( 0,0,0 );
				gerstner_float( position4_g28 , direction4_g28 , phase4_g28 , time4_g28 , gravity4_g28 , depth4_g28 , amplitude4_g28 , result4_g28 );
				float localgerstner9_g28 = ( 0.0 );
				float3 position9_g28 = temp_output_23_0_g28;
				float3 direction9_g28 = temp_output_78_0_g1;
				float phase9_g28 = temp_output_24_0_g28;
				float time9_g28 = temp_output_25_0_g28;
				float gravity9_g28 = temp_output_26_0_g28;
				float depth9_g28 = temp_output_27_0_g28;
				float amplitude9_g28 = temp_output_73_0_g1;
				float3 result9_g28 = float3( 0,0,0 );
				gerstner_float( position9_g28 , direction9_g28 , phase9_g28 , time9_g28 , gravity9_g28 , depth9_g28 , amplitude9_g28 , result9_g28 );
				float localgerstner14_g28 = ( 0.0 );
				float3 position14_g28 = temp_output_23_0_g28;
				float3 direction14_g28 = temp_output_77_0_g1;
				float phase14_g28 = temp_output_24_0_g28;
				float time14_g28 = temp_output_25_0_g28;
				float gravity14_g28 = temp_output_26_0_g28;
				float depth14_g28 = temp_output_27_0_g28;
				float amplitude14_g28 = temp_output_75_0_g1;
				float3 result14_g28 = float3( 0,0,0 );
				gerstner_float( position14_g28 , direction14_g28 , phase14_g28 , time14_g28 , gravity14_g28 , depth14_g28 , amplitude14_g28 , result14_g28 );
				float localgerstner15_g28 = ( 0.0 );
				float3 position15_g28 = temp_output_23_0_g28;
				float3 direction15_g28 = temp_output_76_0_g1;
				float phase15_g28 = temp_output_24_0_g28;
				float time15_g28 = temp_output_25_0_g28;
				float gravity15_g28 = temp_output_26_0_g28;
				float depth15_g28 = temp_output_27_0_g28;
				float amplitude15_g28 = temp_output_74_0_g1;
				float3 result15_g28 = float3( 0,0,0 );
				gerstner_float( position15_g28 , direction15_g28 , phase15_g28 , time15_g28 , gravity15_g28 , depth15_g28 , amplitude15_g28 , result15_g28 );
				float3 worldToObj155_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g28 + result9_g28 ) + ( result14_g28 + result15_g28 ) ) + temp_output_23_0_g28 ), 1 ) ).xyz;
				float3 temp_output_3_0_g29 = worldToObj155_g1;
				float3 normalizeResult8_g29 = normalize( ( worldToObj156_g1 - temp_output_3_0_g29 ) );
				float localgerstner4_g26 = ( 0.0 );
				float3 objToWorld184_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 appendResult136_g1 = (float3(0.0 , 0.0 , temp_output_143_0_g1));
				float3 temp_output_23_0_g26 = ( objToWorld184_g1 + appendResult136_g1 );
				float3 position4_g26 = temp_output_23_0_g26;
				float3 direction4_g26 = temp_output_79_0_g1;
				float temp_output_24_0_g26 = temp_output_82_0_g1;
				float phase4_g26 = temp_output_24_0_g26;
				float temp_output_25_0_g26 = _TimeParameters.x;
				float time4_g26 = temp_output_25_0_g26;
				float temp_output_26_0_g26 = temp_output_81_0_g1;
				float gravity4_g26 = temp_output_26_0_g26;
				float temp_output_27_0_g26 = temp_output_80_0_g1;
				float depth4_g26 = temp_output_27_0_g26;
				float amplitude4_g26 = temp_output_84_0_g1;
				float3 result4_g26 = float3( 0,0,0 );
				gerstner_float( position4_g26 , direction4_g26 , phase4_g26 , time4_g26 , gravity4_g26 , depth4_g26 , amplitude4_g26 , result4_g26 );
				float localgerstner9_g26 = ( 0.0 );
				float3 position9_g26 = temp_output_23_0_g26;
				float3 direction9_g26 = temp_output_78_0_g1;
				float phase9_g26 = temp_output_24_0_g26;
				float time9_g26 = temp_output_25_0_g26;
				float gravity9_g26 = temp_output_26_0_g26;
				float depth9_g26 = temp_output_27_0_g26;
				float amplitude9_g26 = temp_output_73_0_g1;
				float3 result9_g26 = float3( 0,0,0 );
				gerstner_float( position9_g26 , direction9_g26 , phase9_g26 , time9_g26 , gravity9_g26 , depth9_g26 , amplitude9_g26 , result9_g26 );
				float localgerstner14_g26 = ( 0.0 );
				float3 position14_g26 = temp_output_23_0_g26;
				float3 direction14_g26 = temp_output_77_0_g1;
				float phase14_g26 = temp_output_24_0_g26;
				float time14_g26 = temp_output_25_0_g26;
				float gravity14_g26 = temp_output_26_0_g26;
				float depth14_g26 = temp_output_27_0_g26;
				float amplitude14_g26 = temp_output_75_0_g1;
				float3 result14_g26 = float3( 0,0,0 );
				gerstner_float( position14_g26 , direction14_g26 , phase14_g26 , time14_g26 , gravity14_g26 , depth14_g26 , amplitude14_g26 , result14_g26 );
				float localgerstner15_g26 = ( 0.0 );
				float3 position15_g26 = temp_output_23_0_g26;
				float3 direction15_g26 = temp_output_76_0_g1;
				float phase15_g26 = temp_output_24_0_g26;
				float time15_g26 = temp_output_25_0_g26;
				float gravity15_g26 = temp_output_26_0_g26;
				float depth15_g26 = temp_output_27_0_g26;
				float amplitude15_g26 = temp_output_74_0_g1;
				float3 result15_g26 = float3( 0,0,0 );
				gerstner_float( position15_g26 , direction15_g26 , phase15_g26 , time15_g26 , gravity15_g26 , depth15_g26 , amplitude15_g26 , result15_g26 );
				float3 worldToObj164_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g26 + result9_g26 ) + ( result14_g26 + result15_g26 ) ) + temp_output_23_0_g26 ), 1 ) ).xyz;
				float3 normalizeResult9_g29 = normalize( ( temp_output_3_0_g29 - worldToObj164_g1 ) );
				float3 normalizeResult11_g29 = normalize( cross( normalizeResult8_g29 , normalizeResult9_g29 ) );
				float3 GerstNorm134 = normalizeResult11_g29;
				
				o.ase_texcoord8.xy = v.texcoord.xy;
				o.ase_texcoord9 = v.vertex;
				
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
				float screenDepth498 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth498 = saturate( ( screenDepth498 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthDistance ) );
				float Depth500 = distanceDepth498;
				float4 lerpResult590 = lerp( _ShallowColor , _DeepColor , Depth500);
				
				float mulTime568 = _TimeParameters.x * _NormalPanSpeed;
				float2 appendResult574 = (float2(WorldPosition.x , WorldPosition.z));
				float2 texCoord577 = IN.ase_texcoord8.xy * _NormalTexture1_ST.xy + ( ( float2( 0.4,0.17 ) * mulTime568 ) + appendResult574 );
				float3 unpack580 = UnpackNormalScale( SAMPLE_TEXTURE2D( _NormalTexture1, sampler_NormalTexture1, texCoord577 ), _NormalStrength );
				unpack580.z = lerp( 1, unpack580.z, saturate(_NormalStrength) );
				float2 texCoord582 = IN.ase_texcoord8.xy * _NormalTexture2_ST.xy + ( appendResult574 + ( mulTime568 * float2( -0.5,0.2 ) ) );
				float3 unpack584 = UnpackNormalScale( SAMPLE_TEXTURE2D( _NormalTexture2, sampler_NormalTexture2, texCoord582 ), _NormalStrength );
				unpack584.z = lerp( 1, unpack584.z, saturate(_NormalStrength) );
				float lerpResult558 = lerp( _RiseThreshold , 1.0 , _RiseFadeout);
				float localgerstner4_g24 = ( 0.0 );
				float3 objToWorld179_g1 = mul( GetObjectToWorldMatrix(), float4( IN.ase_texcoord9.xyz, 1 ) ).xyz;
				float temp_output_143_0_g1 = _NeighbourDistance;
				float3 appendResult142_g1 = (float3(temp_output_143_0_g1 , 0.0 , 0.0));
				float3 temp_output_23_0_g24 = ( objToWorld179_g1 + appendResult142_g1 );
				float3 position4_g24 = temp_output_23_0_g24;
				float temp_output_615_0 = radians( _Roataion );
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_79_0_g1 = rotatedValue387;
				float3 direction4_g24 = temp_output_79_0_g1;
				float temp_output_82_0_g1 = _Phase;
				float temp_output_24_0_g24 = temp_output_82_0_g1;
				float phase4_g24 = temp_output_24_0_g24;
				float temp_output_25_0_g24 = _TimeParameters.x;
				float time4_g24 = temp_output_25_0_g24;
				float temp_output_81_0_g1 = _Gravity;
				float temp_output_26_0_g24 = temp_output_81_0_g1;
				float gravity4_g24 = temp_output_26_0_g24;
				float temp_output_80_0_g1 = _WaveDepth;
				float temp_output_27_0_g24 = temp_output_80_0_g1;
				float depth4_g24 = temp_output_27_0_g24;
				float temp_output_84_0_g1 = ( _Amplitude1 * _Intensity );
				float amplitude4_g24 = temp_output_84_0_g1;
				float3 result4_g24 = float3( 0,0,0 );
				gerstner_float( position4_g24 , direction4_g24 , phase4_g24 , time4_g24 , gravity4_g24 , depth4_g24 , amplitude4_g24 , result4_g24 );
				float localgerstner9_g24 = ( 0.0 );
				float3 position9_g24 = temp_output_23_0_g24;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_78_0_g1 = rotatedValue64;
				float3 direction9_g24 = temp_output_78_0_g1;
				float phase9_g24 = temp_output_24_0_g24;
				float time9_g24 = temp_output_25_0_g24;
				float gravity9_g24 = temp_output_26_0_g24;
				float depth9_g24 = temp_output_27_0_g24;
				float temp_output_73_0_g1 = ( _Intensity * _Amplitude2 );
				float amplitude9_g24 = temp_output_73_0_g1;
				float3 result9_g24 = float3( 0,0,0 );
				gerstner_float( position9_g24 , direction9_g24 , phase9_g24 , time9_g24 , gravity9_g24 , depth9_g24 , amplitude9_g24 , result9_g24 );
				float localgerstner14_g24 = ( 0.0 );
				float3 position14_g24 = temp_output_23_0_g24;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_77_0_g1 = rotatedValue65;
				float3 direction14_g24 = temp_output_77_0_g1;
				float phase14_g24 = temp_output_24_0_g24;
				float time14_g24 = temp_output_25_0_g24;
				float gravity14_g24 = temp_output_26_0_g24;
				float depth14_g24 = temp_output_27_0_g24;
				float temp_output_75_0_g1 = ( _Intensity * _Amplitude3 );
				float amplitude14_g24 = temp_output_75_0_g1;
				float3 result14_g24 = float3( 0,0,0 );
				gerstner_float( position14_g24 , direction14_g24 , phase14_g24 , time14_g24 , gravity14_g24 , depth14_g24 , amplitude14_g24 , result14_g24 );
				float localgerstner15_g24 = ( 0.0 );
				float3 position15_g24 = temp_output_23_0_g24;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_76_0_g1 = rotatedValue66;
				float3 direction15_g24 = temp_output_76_0_g1;
				float phase15_g24 = temp_output_24_0_g24;
				float time15_g24 = temp_output_25_0_g24;
				float gravity15_g24 = temp_output_26_0_g24;
				float depth15_g24 = temp_output_27_0_g24;
				float temp_output_74_0_g1 = ( _Amplitude4 * _Intensity );
				float amplitude15_g24 = temp_output_74_0_g1;
				float3 result15_g24 = float3( 0,0,0 );
				gerstner_float( position15_g24 , direction15_g24 , phase15_g24 , time15_g24 , gravity15_g24 , depth15_g24 , amplitude15_g24 , result15_g24 );
				float3 worldToObj156_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g24 + result9_g24 ) + ( result14_g24 + result15_g24 ) ) + temp_output_23_0_g24 ), 1 ) ).xyz;
				float localgerstner4_g28 = ( 0.0 );
				float3 objToWorld182_g1 = mul( GetObjectToWorldMatrix(), float4( IN.ase_texcoord9.xyz, 1 ) ).xyz;
				float3 appendResult174_g1 = (float3(0.0 , temp_output_143_0_g1 , 0.0));
				float3 temp_output_23_0_g28 = ( objToWorld182_g1 + appendResult174_g1 );
				float3 position4_g28 = temp_output_23_0_g28;
				float3 direction4_g28 = temp_output_79_0_g1;
				float temp_output_24_0_g28 = temp_output_82_0_g1;
				float phase4_g28 = temp_output_24_0_g28;
				float temp_output_25_0_g28 = _TimeParameters.x;
				float time4_g28 = temp_output_25_0_g28;
				float temp_output_26_0_g28 = temp_output_81_0_g1;
				float gravity4_g28 = temp_output_26_0_g28;
				float temp_output_27_0_g28 = temp_output_80_0_g1;
				float depth4_g28 = temp_output_27_0_g28;
				float amplitude4_g28 = temp_output_84_0_g1;
				float3 result4_g28 = float3( 0,0,0 );
				gerstner_float( position4_g28 , direction4_g28 , phase4_g28 , time4_g28 , gravity4_g28 , depth4_g28 , amplitude4_g28 , result4_g28 );
				float localgerstner9_g28 = ( 0.0 );
				float3 position9_g28 = temp_output_23_0_g28;
				float3 direction9_g28 = temp_output_78_0_g1;
				float phase9_g28 = temp_output_24_0_g28;
				float time9_g28 = temp_output_25_0_g28;
				float gravity9_g28 = temp_output_26_0_g28;
				float depth9_g28 = temp_output_27_0_g28;
				float amplitude9_g28 = temp_output_73_0_g1;
				float3 result9_g28 = float3( 0,0,0 );
				gerstner_float( position9_g28 , direction9_g28 , phase9_g28 , time9_g28 , gravity9_g28 , depth9_g28 , amplitude9_g28 , result9_g28 );
				float localgerstner14_g28 = ( 0.0 );
				float3 position14_g28 = temp_output_23_0_g28;
				float3 direction14_g28 = temp_output_77_0_g1;
				float phase14_g28 = temp_output_24_0_g28;
				float time14_g28 = temp_output_25_0_g28;
				float gravity14_g28 = temp_output_26_0_g28;
				float depth14_g28 = temp_output_27_0_g28;
				float amplitude14_g28 = temp_output_75_0_g1;
				float3 result14_g28 = float3( 0,0,0 );
				gerstner_float( position14_g28 , direction14_g28 , phase14_g28 , time14_g28 , gravity14_g28 , depth14_g28 , amplitude14_g28 , result14_g28 );
				float localgerstner15_g28 = ( 0.0 );
				float3 position15_g28 = temp_output_23_0_g28;
				float3 direction15_g28 = temp_output_76_0_g1;
				float phase15_g28 = temp_output_24_0_g28;
				float time15_g28 = temp_output_25_0_g28;
				float gravity15_g28 = temp_output_26_0_g28;
				float depth15_g28 = temp_output_27_0_g28;
				float amplitude15_g28 = temp_output_74_0_g1;
				float3 result15_g28 = float3( 0,0,0 );
				gerstner_float( position15_g28 , direction15_g28 , phase15_g28 , time15_g28 , gravity15_g28 , depth15_g28 , amplitude15_g28 , result15_g28 );
				float3 worldToObj155_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g28 + result9_g28 ) + ( result14_g28 + result15_g28 ) ) + temp_output_23_0_g28 ), 1 ) ).xyz;
				float3 temp_output_3_0_g29 = worldToObj155_g1;
				float3 normalizeResult8_g29 = normalize( ( worldToObj156_g1 - temp_output_3_0_g29 ) );
				float localgerstner4_g26 = ( 0.0 );
				float3 objToWorld184_g1 = mul( GetObjectToWorldMatrix(), float4( IN.ase_texcoord9.xyz, 1 ) ).xyz;
				float3 appendResult136_g1 = (float3(0.0 , 0.0 , temp_output_143_0_g1));
				float3 temp_output_23_0_g26 = ( objToWorld184_g1 + appendResult136_g1 );
				float3 position4_g26 = temp_output_23_0_g26;
				float3 direction4_g26 = temp_output_79_0_g1;
				float temp_output_24_0_g26 = temp_output_82_0_g1;
				float phase4_g26 = temp_output_24_0_g26;
				float temp_output_25_0_g26 = _TimeParameters.x;
				float time4_g26 = temp_output_25_0_g26;
				float temp_output_26_0_g26 = temp_output_81_0_g1;
				float gravity4_g26 = temp_output_26_0_g26;
				float temp_output_27_0_g26 = temp_output_80_0_g1;
				float depth4_g26 = temp_output_27_0_g26;
				float amplitude4_g26 = temp_output_84_0_g1;
				float3 result4_g26 = float3( 0,0,0 );
				gerstner_float( position4_g26 , direction4_g26 , phase4_g26 , time4_g26 , gravity4_g26 , depth4_g26 , amplitude4_g26 , result4_g26 );
				float localgerstner9_g26 = ( 0.0 );
				float3 position9_g26 = temp_output_23_0_g26;
				float3 direction9_g26 = temp_output_78_0_g1;
				float phase9_g26 = temp_output_24_0_g26;
				float time9_g26 = temp_output_25_0_g26;
				float gravity9_g26 = temp_output_26_0_g26;
				float depth9_g26 = temp_output_27_0_g26;
				float amplitude9_g26 = temp_output_73_0_g1;
				float3 result9_g26 = float3( 0,0,0 );
				gerstner_float( position9_g26 , direction9_g26 , phase9_g26 , time9_g26 , gravity9_g26 , depth9_g26 , amplitude9_g26 , result9_g26 );
				float localgerstner14_g26 = ( 0.0 );
				float3 position14_g26 = temp_output_23_0_g26;
				float3 direction14_g26 = temp_output_77_0_g1;
				float phase14_g26 = temp_output_24_0_g26;
				float time14_g26 = temp_output_25_0_g26;
				float gravity14_g26 = temp_output_26_0_g26;
				float depth14_g26 = temp_output_27_0_g26;
				float amplitude14_g26 = temp_output_75_0_g1;
				float3 result14_g26 = float3( 0,0,0 );
				gerstner_float( position14_g26 , direction14_g26 , phase14_g26 , time14_g26 , gravity14_g26 , depth14_g26 , amplitude14_g26 , result14_g26 );
				float localgerstner15_g26 = ( 0.0 );
				float3 position15_g26 = temp_output_23_0_g26;
				float3 direction15_g26 = temp_output_76_0_g1;
				float phase15_g26 = temp_output_24_0_g26;
				float time15_g26 = temp_output_25_0_g26;
				float gravity15_g26 = temp_output_26_0_g26;
				float depth15_g26 = temp_output_27_0_g26;
				float amplitude15_g26 = temp_output_74_0_g1;
				float3 result15_g26 = float3( 0,0,0 );
				gerstner_float( position15_g26 , direction15_g26 , phase15_g26 , time15_g26 , gravity15_g26 , depth15_g26 , amplitude15_g26 , result15_g26 );
				float3 worldToObj164_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g26 + result9_g26 ) + ( result14_g26 + result15_g26 ) ) + temp_output_23_0_g26 ), 1 ) ).xyz;
				float3 normalizeResult9_g29 = normalize( ( temp_output_3_0_g29 - worldToObj164_g1 ) );
				float3 normalizeResult11_g29 = normalize( cross( normalizeResult8_g29 , normalizeResult9_g29 ) );
				float3 GerstNorm134 = normalizeResult11_g29;
				float4 temp_output_6_0_g30 = float4( 0,1,0,0 );
				float dotResult1_g30 = dot( float4( GerstNorm134 , 0.0 ) , temp_output_6_0_g30 );
				float dotResult2_g30 = dot( temp_output_6_0_g30 , temp_output_6_0_g30 );
				float2 appendResult536 = (float2(WorldPosition.x , WorldPosition.z));
				float2 texCoord537 = IN.ase_texcoord8.xy * float2( 1,1 ) + appendResult536;
				float rotation543 = temp_output_615_0;
				float cos539 = cos( rotation543 );
				float sin539 = sin( rotation543 );
				float2 rotator539 = mul( texCoord537 - float2( 0.5,0.5 ) , float2x2( cos539 , -sin539 , sin539 , cos539 )) + float2( 0.5,0.5 );
				float simpleNoise545 = SimpleNoise( rotator539*5.0 );
				float2 texCoord553 = IN.ase_texcoord8.xy * float2( 1,1 ) + ( appendResult536 + _TimeParameters.x );
				float gradientNoise554 = UnityGradientNoise(texCoord553,0.02);
				gradientNoise554 = gradientNoise554*0.5 + 0.5;
				float smoothstepResult559 = smoothstep( _RiseThreshold , lerpResult558 , ( (1.0 + (length( ( ( dotResult1_g30 / dotResult2_g30 ) * temp_output_6_0_g30 ) ) - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) + (-0.1 + (simpleNoise545 - 0.0) * (0.1 - -0.1) / (1.0 - 0.0)) + (-0.3 + (gradientNoise554 - 0.0) * (0.3 - -0.3) / (1.0 - 0.0)) ));
				float RiseTide560 = smoothstepResult559;
				float smoothstepResult523 = smoothstep( 0.97 , 1.0 , (1.0 + (distanceDepth498 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
				float2 appendResult510 = (float2(WorldPosition.x , WorldPosition.z));
				float2 texCoord517 = IN.ase_texcoord8.xy * float2( 1,1 ) + ( ( _TimeParameters.x * 0.5 ) + appendResult510 );
				float gradientNoise516 = UnityGradientNoise(texCoord517,2.15);
				gradientNoise516 = gradientNoise516*0.5 + 0.5;
				float clampResult526 = clamp( ( ( pow( ( 1.0 / 1000.0 ) , distanceDepth498 ) * cos( ( ( distanceDepth498 * 100.0 ) + ( 4.0 * _TimeParameters.x ) ) ) ) * ( 0.5 + gradientNoise516 ) ) , -0.1 , 1.0 );
				float Foam564 = step( ( RiseTide560 + smoothstepResult523 + clampResult526 ) , 0.5 );
				float3 lerpResult587 = lerp( float3( 0.5,0.5,1 ) , BlendNormal( unpack580 , unpack584 ) , Foam564);
				
				float4 lerpResult607 = lerp( _FoamColor , _Emmision , Foam564);
				

				float3 BaseColor = lerpResult590.rgb;
				float3 Normal = lerpResult587;
				float3 Emission = lerpResult607.rgb;
				float3 Specular = 0.5;
				float Metallic = 0.5;
				float Smoothness = 1.0;
				float Occlusion = 0.0;
				float Alpha = ( Depth500 * _WaterThickness );
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
			#define _NORMAL_DROPOFF_TS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_DISTANCE_TESSELLATION
			#define ASE_DEPTH_WRITE_ON
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1
			#define ASE_USING_SAMPLING_MACROS 1


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
			#define ASE_NEEDS_VERT_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FoamColor;
			float4 _NormalTexture2_ST;
			float4 _NormalTexture1_ST;
			float4 _Emmision;
			float4 _DeepColor;
			float4 _ShallowColor;
			float3 _Direction4;
			float3 _Direction1;
			float3 _Direction2;
			float3 _Direction3;
			float _RiseFadeout;
			float _RiseThreshold;
			float _NormalStrength;
			float _NormalPanSpeed;
			float _DepthDistance;
			float _NeighbourDistance;
			float _Amplitude3;
			float _Amplitude2;
			float _Intensity;
			float _Amplitude1;
			float _WaveDepth;
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

				float localgerstner4_g24 = ( 0.0 );
				float3 objToWorld179_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float temp_output_143_0_g1 = _NeighbourDistance;
				float3 appendResult142_g1 = (float3(temp_output_143_0_g1 , 0.0 , 0.0));
				float3 temp_output_23_0_g24 = ( objToWorld179_g1 + appendResult142_g1 );
				float3 position4_g24 = temp_output_23_0_g24;
				float temp_output_615_0 = radians( _Roataion );
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_79_0_g1 = rotatedValue387;
				float3 direction4_g24 = temp_output_79_0_g1;
				float temp_output_82_0_g1 = _Phase;
				float temp_output_24_0_g24 = temp_output_82_0_g1;
				float phase4_g24 = temp_output_24_0_g24;
				float temp_output_25_0_g24 = _TimeParameters.x;
				float time4_g24 = temp_output_25_0_g24;
				float temp_output_81_0_g1 = _Gravity;
				float temp_output_26_0_g24 = temp_output_81_0_g1;
				float gravity4_g24 = temp_output_26_0_g24;
				float temp_output_80_0_g1 = _WaveDepth;
				float temp_output_27_0_g24 = temp_output_80_0_g1;
				float depth4_g24 = temp_output_27_0_g24;
				float temp_output_84_0_g1 = ( _Amplitude1 * _Intensity );
				float amplitude4_g24 = temp_output_84_0_g1;
				float3 result4_g24 = float3( 0,0,0 );
				gerstner_float( position4_g24 , direction4_g24 , phase4_g24 , time4_g24 , gravity4_g24 , depth4_g24 , amplitude4_g24 , result4_g24 );
				float localgerstner9_g24 = ( 0.0 );
				float3 position9_g24 = temp_output_23_0_g24;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_78_0_g1 = rotatedValue64;
				float3 direction9_g24 = temp_output_78_0_g1;
				float phase9_g24 = temp_output_24_0_g24;
				float time9_g24 = temp_output_25_0_g24;
				float gravity9_g24 = temp_output_26_0_g24;
				float depth9_g24 = temp_output_27_0_g24;
				float temp_output_73_0_g1 = ( _Intensity * _Amplitude2 );
				float amplitude9_g24 = temp_output_73_0_g1;
				float3 result9_g24 = float3( 0,0,0 );
				gerstner_float( position9_g24 , direction9_g24 , phase9_g24 , time9_g24 , gravity9_g24 , depth9_g24 , amplitude9_g24 , result9_g24 );
				float localgerstner14_g24 = ( 0.0 );
				float3 position14_g24 = temp_output_23_0_g24;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_77_0_g1 = rotatedValue65;
				float3 direction14_g24 = temp_output_77_0_g1;
				float phase14_g24 = temp_output_24_0_g24;
				float time14_g24 = temp_output_25_0_g24;
				float gravity14_g24 = temp_output_26_0_g24;
				float depth14_g24 = temp_output_27_0_g24;
				float temp_output_75_0_g1 = ( _Intensity * _Amplitude3 );
				float amplitude14_g24 = temp_output_75_0_g1;
				float3 result14_g24 = float3( 0,0,0 );
				gerstner_float( position14_g24 , direction14_g24 , phase14_g24 , time14_g24 , gravity14_g24 , depth14_g24 , amplitude14_g24 , result14_g24 );
				float localgerstner15_g24 = ( 0.0 );
				float3 position15_g24 = temp_output_23_0_g24;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_76_0_g1 = rotatedValue66;
				float3 direction15_g24 = temp_output_76_0_g1;
				float phase15_g24 = temp_output_24_0_g24;
				float time15_g24 = temp_output_25_0_g24;
				float gravity15_g24 = temp_output_26_0_g24;
				float depth15_g24 = temp_output_27_0_g24;
				float temp_output_74_0_g1 = ( _Amplitude4 * _Intensity );
				float amplitude15_g24 = temp_output_74_0_g1;
				float3 result15_g24 = float3( 0,0,0 );
				gerstner_float( position15_g24 , direction15_g24 , phase15_g24 , time15_g24 , gravity15_g24 , depth15_g24 , amplitude15_g24 , result15_g24 );
				float3 worldToObj156_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g24 + result9_g24 ) + ( result14_g24 + result15_g24 ) ) + temp_output_23_0_g24 ), 1 ) ).xyz;
				float3 GerstPos132 = worldToObj156_g1;
				
				float localgerstner4_g28 = ( 0.0 );
				float3 objToWorld182_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 appendResult174_g1 = (float3(0.0 , temp_output_143_0_g1 , 0.0));
				float3 temp_output_23_0_g28 = ( objToWorld182_g1 + appendResult174_g1 );
				float3 position4_g28 = temp_output_23_0_g28;
				float3 direction4_g28 = temp_output_79_0_g1;
				float temp_output_24_0_g28 = temp_output_82_0_g1;
				float phase4_g28 = temp_output_24_0_g28;
				float temp_output_25_0_g28 = _TimeParameters.x;
				float time4_g28 = temp_output_25_0_g28;
				float temp_output_26_0_g28 = temp_output_81_0_g1;
				float gravity4_g28 = temp_output_26_0_g28;
				float temp_output_27_0_g28 = temp_output_80_0_g1;
				float depth4_g28 = temp_output_27_0_g28;
				float amplitude4_g28 = temp_output_84_0_g1;
				float3 result4_g28 = float3( 0,0,0 );
				gerstner_float( position4_g28 , direction4_g28 , phase4_g28 , time4_g28 , gravity4_g28 , depth4_g28 , amplitude4_g28 , result4_g28 );
				float localgerstner9_g28 = ( 0.0 );
				float3 position9_g28 = temp_output_23_0_g28;
				float3 direction9_g28 = temp_output_78_0_g1;
				float phase9_g28 = temp_output_24_0_g28;
				float time9_g28 = temp_output_25_0_g28;
				float gravity9_g28 = temp_output_26_0_g28;
				float depth9_g28 = temp_output_27_0_g28;
				float amplitude9_g28 = temp_output_73_0_g1;
				float3 result9_g28 = float3( 0,0,0 );
				gerstner_float( position9_g28 , direction9_g28 , phase9_g28 , time9_g28 , gravity9_g28 , depth9_g28 , amplitude9_g28 , result9_g28 );
				float localgerstner14_g28 = ( 0.0 );
				float3 position14_g28 = temp_output_23_0_g28;
				float3 direction14_g28 = temp_output_77_0_g1;
				float phase14_g28 = temp_output_24_0_g28;
				float time14_g28 = temp_output_25_0_g28;
				float gravity14_g28 = temp_output_26_0_g28;
				float depth14_g28 = temp_output_27_0_g28;
				float amplitude14_g28 = temp_output_75_0_g1;
				float3 result14_g28 = float3( 0,0,0 );
				gerstner_float( position14_g28 , direction14_g28 , phase14_g28 , time14_g28 , gravity14_g28 , depth14_g28 , amplitude14_g28 , result14_g28 );
				float localgerstner15_g28 = ( 0.0 );
				float3 position15_g28 = temp_output_23_0_g28;
				float3 direction15_g28 = temp_output_76_0_g1;
				float phase15_g28 = temp_output_24_0_g28;
				float time15_g28 = temp_output_25_0_g28;
				float gravity15_g28 = temp_output_26_0_g28;
				float depth15_g28 = temp_output_27_0_g28;
				float amplitude15_g28 = temp_output_74_0_g1;
				float3 result15_g28 = float3( 0,0,0 );
				gerstner_float( position15_g28 , direction15_g28 , phase15_g28 , time15_g28 , gravity15_g28 , depth15_g28 , amplitude15_g28 , result15_g28 );
				float3 worldToObj155_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g28 + result9_g28 ) + ( result14_g28 + result15_g28 ) ) + temp_output_23_0_g28 ), 1 ) ).xyz;
				float3 temp_output_3_0_g29 = worldToObj155_g1;
				float3 normalizeResult8_g29 = normalize( ( worldToObj156_g1 - temp_output_3_0_g29 ) );
				float localgerstner4_g26 = ( 0.0 );
				float3 objToWorld184_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 appendResult136_g1 = (float3(0.0 , 0.0 , temp_output_143_0_g1));
				float3 temp_output_23_0_g26 = ( objToWorld184_g1 + appendResult136_g1 );
				float3 position4_g26 = temp_output_23_0_g26;
				float3 direction4_g26 = temp_output_79_0_g1;
				float temp_output_24_0_g26 = temp_output_82_0_g1;
				float phase4_g26 = temp_output_24_0_g26;
				float temp_output_25_0_g26 = _TimeParameters.x;
				float time4_g26 = temp_output_25_0_g26;
				float temp_output_26_0_g26 = temp_output_81_0_g1;
				float gravity4_g26 = temp_output_26_0_g26;
				float temp_output_27_0_g26 = temp_output_80_0_g1;
				float depth4_g26 = temp_output_27_0_g26;
				float amplitude4_g26 = temp_output_84_0_g1;
				float3 result4_g26 = float3( 0,0,0 );
				gerstner_float( position4_g26 , direction4_g26 , phase4_g26 , time4_g26 , gravity4_g26 , depth4_g26 , amplitude4_g26 , result4_g26 );
				float localgerstner9_g26 = ( 0.0 );
				float3 position9_g26 = temp_output_23_0_g26;
				float3 direction9_g26 = temp_output_78_0_g1;
				float phase9_g26 = temp_output_24_0_g26;
				float time9_g26 = temp_output_25_0_g26;
				float gravity9_g26 = temp_output_26_0_g26;
				float depth9_g26 = temp_output_27_0_g26;
				float amplitude9_g26 = temp_output_73_0_g1;
				float3 result9_g26 = float3( 0,0,0 );
				gerstner_float( position9_g26 , direction9_g26 , phase9_g26 , time9_g26 , gravity9_g26 , depth9_g26 , amplitude9_g26 , result9_g26 );
				float localgerstner14_g26 = ( 0.0 );
				float3 position14_g26 = temp_output_23_0_g26;
				float3 direction14_g26 = temp_output_77_0_g1;
				float phase14_g26 = temp_output_24_0_g26;
				float time14_g26 = temp_output_25_0_g26;
				float gravity14_g26 = temp_output_26_0_g26;
				float depth14_g26 = temp_output_27_0_g26;
				float amplitude14_g26 = temp_output_75_0_g1;
				float3 result14_g26 = float3( 0,0,0 );
				gerstner_float( position14_g26 , direction14_g26 , phase14_g26 , time14_g26 , gravity14_g26 , depth14_g26 , amplitude14_g26 , result14_g26 );
				float localgerstner15_g26 = ( 0.0 );
				float3 position15_g26 = temp_output_23_0_g26;
				float3 direction15_g26 = temp_output_76_0_g1;
				float phase15_g26 = temp_output_24_0_g26;
				float time15_g26 = temp_output_25_0_g26;
				float gravity15_g26 = temp_output_26_0_g26;
				float depth15_g26 = temp_output_27_0_g26;
				float amplitude15_g26 = temp_output_74_0_g1;
				float3 result15_g26 = float3( 0,0,0 );
				gerstner_float( position15_g26 , direction15_g26 , phase15_g26 , time15_g26 , gravity15_g26 , depth15_g26 , amplitude15_g26 , result15_g26 );
				float3 worldToObj164_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g26 + result9_g26 ) + ( result14_g26 + result15_g26 ) ) + temp_output_23_0_g26 ), 1 ) ).xyz;
				float3 normalizeResult9_g29 = normalize( ( temp_output_3_0_g29 - worldToObj164_g1 ) );
				float3 normalizeResult11_g29 = normalize( cross( normalizeResult8_g29 , normalizeResult9_g29 ) );
				float3 GerstNorm134 = normalizeResult11_g29;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord = screenPos;
				

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
				float screenDepth498 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth498 = saturate( ( screenDepth498 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthDistance ) );
				float Depth500 = distanceDepth498;
				

				surfaceDescription.Alpha = ( Depth500 * _WaterThickness );
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
			#define _NORMAL_DROPOFF_TS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define ASE_DISTANCE_TESSELLATION
			#define ASE_DEPTH_WRITE_ON
			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1
			#define ASE_USING_SAMPLING_MACROS 1


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
			#define ASE_NEEDS_VERT_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FoamColor;
			float4 _NormalTexture2_ST;
			float4 _NormalTexture1_ST;
			float4 _Emmision;
			float4 _DeepColor;
			float4 _ShallowColor;
			float3 _Direction4;
			float3 _Direction1;
			float3 _Direction2;
			float3 _Direction3;
			float _RiseFadeout;
			float _RiseThreshold;
			float _NormalStrength;
			float _NormalPanSpeed;
			float _DepthDistance;
			float _NeighbourDistance;
			float _Amplitude3;
			float _Amplitude2;
			float _Intensity;
			float _Amplitude1;
			float _WaveDepth;
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

				float localgerstner4_g24 = ( 0.0 );
				float3 objToWorld179_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float temp_output_143_0_g1 = _NeighbourDistance;
				float3 appendResult142_g1 = (float3(temp_output_143_0_g1 , 0.0 , 0.0));
				float3 temp_output_23_0_g24 = ( objToWorld179_g1 + appendResult142_g1 );
				float3 position4_g24 = temp_output_23_0_g24;
				float temp_output_615_0 = radians( _Roataion );
				float3 rotatedValue387 = RotateAroundAxis( float3( 0,0,0 ), _Direction1, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_79_0_g1 = rotatedValue387;
				float3 direction4_g24 = temp_output_79_0_g1;
				float temp_output_82_0_g1 = _Phase;
				float temp_output_24_0_g24 = temp_output_82_0_g1;
				float phase4_g24 = temp_output_24_0_g24;
				float temp_output_25_0_g24 = _TimeParameters.x;
				float time4_g24 = temp_output_25_0_g24;
				float temp_output_81_0_g1 = _Gravity;
				float temp_output_26_0_g24 = temp_output_81_0_g1;
				float gravity4_g24 = temp_output_26_0_g24;
				float temp_output_80_0_g1 = _WaveDepth;
				float temp_output_27_0_g24 = temp_output_80_0_g1;
				float depth4_g24 = temp_output_27_0_g24;
				float temp_output_84_0_g1 = ( _Amplitude1 * _Intensity );
				float amplitude4_g24 = temp_output_84_0_g1;
				float3 result4_g24 = float3( 0,0,0 );
				gerstner_float( position4_g24 , direction4_g24 , phase4_g24 , time4_g24 , gravity4_g24 , depth4_g24 , amplitude4_g24 , result4_g24 );
				float localgerstner9_g24 = ( 0.0 );
				float3 position9_g24 = temp_output_23_0_g24;
				float3 rotatedValue64 = RotateAroundAxis( float3( 0,0,0 ), _Direction2, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_78_0_g1 = rotatedValue64;
				float3 direction9_g24 = temp_output_78_0_g1;
				float phase9_g24 = temp_output_24_0_g24;
				float time9_g24 = temp_output_25_0_g24;
				float gravity9_g24 = temp_output_26_0_g24;
				float depth9_g24 = temp_output_27_0_g24;
				float temp_output_73_0_g1 = ( _Intensity * _Amplitude2 );
				float amplitude9_g24 = temp_output_73_0_g1;
				float3 result9_g24 = float3( 0,0,0 );
				gerstner_float( position9_g24 , direction9_g24 , phase9_g24 , time9_g24 , gravity9_g24 , depth9_g24 , amplitude9_g24 , result9_g24 );
				float localgerstner14_g24 = ( 0.0 );
				float3 position14_g24 = temp_output_23_0_g24;
				float3 rotatedValue65 = RotateAroundAxis( float3( 0,0,0 ), _Direction3, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_77_0_g1 = rotatedValue65;
				float3 direction14_g24 = temp_output_77_0_g1;
				float phase14_g24 = temp_output_24_0_g24;
				float time14_g24 = temp_output_25_0_g24;
				float gravity14_g24 = temp_output_26_0_g24;
				float depth14_g24 = temp_output_27_0_g24;
				float temp_output_75_0_g1 = ( _Intensity * _Amplitude3 );
				float amplitude14_g24 = temp_output_75_0_g1;
				float3 result14_g24 = float3( 0,0,0 );
				gerstner_float( position14_g24 , direction14_g24 , phase14_g24 , time14_g24 , gravity14_g24 , depth14_g24 , amplitude14_g24 , result14_g24 );
				float localgerstner15_g24 = ( 0.0 );
				float3 position15_g24 = temp_output_23_0_g24;
				float3 rotatedValue66 = RotateAroundAxis( float3( 0,0,0 ), _Direction4, normalize( float3( 0,1,0 ) ), temp_output_615_0 );
				float3 temp_output_76_0_g1 = rotatedValue66;
				float3 direction15_g24 = temp_output_76_0_g1;
				float phase15_g24 = temp_output_24_0_g24;
				float time15_g24 = temp_output_25_0_g24;
				float gravity15_g24 = temp_output_26_0_g24;
				float depth15_g24 = temp_output_27_0_g24;
				float temp_output_74_0_g1 = ( _Amplitude4 * _Intensity );
				float amplitude15_g24 = temp_output_74_0_g1;
				float3 result15_g24 = float3( 0,0,0 );
				gerstner_float( position15_g24 , direction15_g24 , phase15_g24 , time15_g24 , gravity15_g24 , depth15_g24 , amplitude15_g24 , result15_g24 );
				float3 worldToObj156_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g24 + result9_g24 ) + ( result14_g24 + result15_g24 ) ) + temp_output_23_0_g24 ), 1 ) ).xyz;
				float3 GerstPos132 = worldToObj156_g1;
				
				float localgerstner4_g28 = ( 0.0 );
				float3 objToWorld182_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 appendResult174_g1 = (float3(0.0 , temp_output_143_0_g1 , 0.0));
				float3 temp_output_23_0_g28 = ( objToWorld182_g1 + appendResult174_g1 );
				float3 position4_g28 = temp_output_23_0_g28;
				float3 direction4_g28 = temp_output_79_0_g1;
				float temp_output_24_0_g28 = temp_output_82_0_g1;
				float phase4_g28 = temp_output_24_0_g28;
				float temp_output_25_0_g28 = _TimeParameters.x;
				float time4_g28 = temp_output_25_0_g28;
				float temp_output_26_0_g28 = temp_output_81_0_g1;
				float gravity4_g28 = temp_output_26_0_g28;
				float temp_output_27_0_g28 = temp_output_80_0_g1;
				float depth4_g28 = temp_output_27_0_g28;
				float amplitude4_g28 = temp_output_84_0_g1;
				float3 result4_g28 = float3( 0,0,0 );
				gerstner_float( position4_g28 , direction4_g28 , phase4_g28 , time4_g28 , gravity4_g28 , depth4_g28 , amplitude4_g28 , result4_g28 );
				float localgerstner9_g28 = ( 0.0 );
				float3 position9_g28 = temp_output_23_0_g28;
				float3 direction9_g28 = temp_output_78_0_g1;
				float phase9_g28 = temp_output_24_0_g28;
				float time9_g28 = temp_output_25_0_g28;
				float gravity9_g28 = temp_output_26_0_g28;
				float depth9_g28 = temp_output_27_0_g28;
				float amplitude9_g28 = temp_output_73_0_g1;
				float3 result9_g28 = float3( 0,0,0 );
				gerstner_float( position9_g28 , direction9_g28 , phase9_g28 , time9_g28 , gravity9_g28 , depth9_g28 , amplitude9_g28 , result9_g28 );
				float localgerstner14_g28 = ( 0.0 );
				float3 position14_g28 = temp_output_23_0_g28;
				float3 direction14_g28 = temp_output_77_0_g1;
				float phase14_g28 = temp_output_24_0_g28;
				float time14_g28 = temp_output_25_0_g28;
				float gravity14_g28 = temp_output_26_0_g28;
				float depth14_g28 = temp_output_27_0_g28;
				float amplitude14_g28 = temp_output_75_0_g1;
				float3 result14_g28 = float3( 0,0,0 );
				gerstner_float( position14_g28 , direction14_g28 , phase14_g28 , time14_g28 , gravity14_g28 , depth14_g28 , amplitude14_g28 , result14_g28 );
				float localgerstner15_g28 = ( 0.0 );
				float3 position15_g28 = temp_output_23_0_g28;
				float3 direction15_g28 = temp_output_76_0_g1;
				float phase15_g28 = temp_output_24_0_g28;
				float time15_g28 = temp_output_25_0_g28;
				float gravity15_g28 = temp_output_26_0_g28;
				float depth15_g28 = temp_output_27_0_g28;
				float amplitude15_g28 = temp_output_74_0_g1;
				float3 result15_g28 = float3( 0,0,0 );
				gerstner_float( position15_g28 , direction15_g28 , phase15_g28 , time15_g28 , gravity15_g28 , depth15_g28 , amplitude15_g28 , result15_g28 );
				float3 worldToObj155_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g28 + result9_g28 ) + ( result14_g28 + result15_g28 ) ) + temp_output_23_0_g28 ), 1 ) ).xyz;
				float3 temp_output_3_0_g29 = worldToObj155_g1;
				float3 normalizeResult8_g29 = normalize( ( worldToObj156_g1 - temp_output_3_0_g29 ) );
				float localgerstner4_g26 = ( 0.0 );
				float3 objToWorld184_g1 = mul( GetObjectToWorldMatrix(), float4( v.vertex.xyz, 1 ) ).xyz;
				float3 appendResult136_g1 = (float3(0.0 , 0.0 , temp_output_143_0_g1));
				float3 temp_output_23_0_g26 = ( objToWorld184_g1 + appendResult136_g1 );
				float3 position4_g26 = temp_output_23_0_g26;
				float3 direction4_g26 = temp_output_79_0_g1;
				float temp_output_24_0_g26 = temp_output_82_0_g1;
				float phase4_g26 = temp_output_24_0_g26;
				float temp_output_25_0_g26 = _TimeParameters.x;
				float time4_g26 = temp_output_25_0_g26;
				float temp_output_26_0_g26 = temp_output_81_0_g1;
				float gravity4_g26 = temp_output_26_0_g26;
				float temp_output_27_0_g26 = temp_output_80_0_g1;
				float depth4_g26 = temp_output_27_0_g26;
				float amplitude4_g26 = temp_output_84_0_g1;
				float3 result4_g26 = float3( 0,0,0 );
				gerstner_float( position4_g26 , direction4_g26 , phase4_g26 , time4_g26 , gravity4_g26 , depth4_g26 , amplitude4_g26 , result4_g26 );
				float localgerstner9_g26 = ( 0.0 );
				float3 position9_g26 = temp_output_23_0_g26;
				float3 direction9_g26 = temp_output_78_0_g1;
				float phase9_g26 = temp_output_24_0_g26;
				float time9_g26 = temp_output_25_0_g26;
				float gravity9_g26 = temp_output_26_0_g26;
				float depth9_g26 = temp_output_27_0_g26;
				float amplitude9_g26 = temp_output_73_0_g1;
				float3 result9_g26 = float3( 0,0,0 );
				gerstner_float( position9_g26 , direction9_g26 , phase9_g26 , time9_g26 , gravity9_g26 , depth9_g26 , amplitude9_g26 , result9_g26 );
				float localgerstner14_g26 = ( 0.0 );
				float3 position14_g26 = temp_output_23_0_g26;
				float3 direction14_g26 = temp_output_77_0_g1;
				float phase14_g26 = temp_output_24_0_g26;
				float time14_g26 = temp_output_25_0_g26;
				float gravity14_g26 = temp_output_26_0_g26;
				float depth14_g26 = temp_output_27_0_g26;
				float amplitude14_g26 = temp_output_75_0_g1;
				float3 result14_g26 = float3( 0,0,0 );
				gerstner_float( position14_g26 , direction14_g26 , phase14_g26 , time14_g26 , gravity14_g26 , depth14_g26 , amplitude14_g26 , result14_g26 );
				float localgerstner15_g26 = ( 0.0 );
				float3 position15_g26 = temp_output_23_0_g26;
				float3 direction15_g26 = temp_output_76_0_g1;
				float phase15_g26 = temp_output_24_0_g26;
				float time15_g26 = temp_output_25_0_g26;
				float gravity15_g26 = temp_output_26_0_g26;
				float depth15_g26 = temp_output_27_0_g26;
				float amplitude15_g26 = temp_output_74_0_g1;
				float3 result15_g26 = float3( 0,0,0 );
				gerstner_float( position15_g26 , direction15_g26 , phase15_g26 , time15_g26 , gravity15_g26 , depth15_g26 , amplitude15_g26 , result15_g26 );
				float3 worldToObj164_g1 = mul( GetWorldToObjectMatrix(), float4( ( ( ( result4_g26 + result9_g26 ) + ( result14_g26 + result15_g26 ) ) + temp_output_23_0_g26 ), 1 ) ).xyz;
				float3 normalizeResult9_g29 = normalize( ( temp_output_3_0_g29 - worldToObj164_g1 ) );
				float3 normalizeResult11_g29 = normalize( cross( normalizeResult8_g29 , normalizeResult9_g29 ) );
				float3 GerstNorm134 = normalizeResult11_g29;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord = screenPos;
				

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
				float screenDepth498 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth498 = saturate( ( screenDepth498 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _DepthDistance ) );
				float Depth500 = distanceDepth498;
				

				surfaceDescription.Alpha = ( Depth500 * _WaterThickness );
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
Node;AmplifyShaderEditor.CommentaryNode;565;1709.683,1707.994;Inherit;False;2503.378;734.5054;;18;571;584;580;586;585;582;583;577;575;578;576;574;570;569;568;567;566;634;NormalMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;533;812.8723,2708.312;Inherit;False;2693.161;763.9817;;22;536;541;612;613;547;549;555;554;557;556;560;559;558;550;553;552;551;537;545;539;546;635;RiseTide;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;502;963.7496,3869.6;Inherit;False;2412.672;1101.149;;23;510;562;519;523;507;525;564;561;528;526;524;522;521;520;506;518;516;517;511;514;513;505;636;Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;493;-1837.498,2459.587;Inherit;False;2392.958;1082.213;;26;63;615;65;51;57;132;134;54;53;52;50;49;48;47;61;60;59;58;543;45;46;43;387;64;44;66;GerstnerGenerate;1,1,1,1;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;211;1120.13,1745.131;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;212;1120.13,1745.131;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;True;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;213;1120.13,1745.131;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;214;1120.13,1745.131;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;5;False;;10;False;;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;215;1120.13,1745.131;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthNormals;0;6;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormals;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;216;1120.13,1745.131;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;GBuffer;0;7;GBuffer;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;5;False;;10;False;;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalGBuffer;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;217;1120.13,1745.131;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;SceneSelectionPass;0;8;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;218;1120.13,1745.131;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ScenePickingPass;0;9;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;209;647.6163,729.0755;Float;False;False;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;66;-930.2685,3112.79;Inherit;False;True;4;0;FLOAT3;0,1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;44;-1162.865,2785.769;Inherit;False;Property;_Direction2;Direction2;3;0;Create;True;0;0;0;False;0;False;-0.3,0,0.3;-0.3,0,0.3;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RotateAboutAxisNode;64;-942.0992,2788.739;Inherit;False;True;4;0;FLOAT3;0,1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;387;-940.3992,2625.605;Inherit;False;True;4;0;FLOAT3;0,1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;43;-1164.375,2633.65;Inherit;False;Property;_Direction1;Direction1;2;0;Create;True;0;0;0;False;0;False;0.5,0,0;0.5,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;46;-1160.39,3113.978;Inherit;False;Property;_Direction4;Direction4;5;0;Create;True;0;0;0;False;0;False;0.01,0,0.01;0.01,0,0.01;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;45;-1162.573,2933.067;Inherit;False;Property;_Direction3;Direction3;4;0;Create;True;0;0;0;False;0;False;0.1,0,-0.4;0.1,0,-0.4;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;543;-1371.129,3102.213;Inherit;False;rotation;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;546;2188.355,2948.317;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.1;False;4;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-292.7112,2675.033;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-289.9247,2798.716;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-293.8247,2892.317;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-288.6246,3000.216;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-505.947,2683.607;Inherit;False;Property;_Amplitude1;Amplitude1;6;0;Create;True;0;0;0;False;0;False;1.5;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-509.0782,2809.21;Inherit;False;Property;_Amplitude2;Amplitude2;7;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-504.1786,2899.21;Inherit;False;Property;_Amplitude3;Amplitude3;8;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-506.4787,2996.51;Inherit;False;Property;_Amplitude4;Amplitude4;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-302.207,3218.782;Inherit;False;Property;_Phase;Phase;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-300.5212,3309.819;Inherit;False;Property;_Gravity;Gravity;12;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-369.1451,3406.015;Inherit;False;Property;_NeighbourDistance;NeighbourDistance;13;0;Create;True;0;0;0;False;0;False;0.1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;134;303.4348,2693.114;Inherit;False;GerstNorm;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;132;304.8331,2792.68;Inherit;False;GerstPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotatorNode;539;1733.505,2948.729;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;545;1937.689,2947.81;Inherit;True;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;537;1475.505,2953.829;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;551;1489.326,3222.096;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;552;1245.326,3300.096;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;553;1666.326,3213.096;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;550;2454.323,2938.367;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;558;2777.137,3173.696;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;559;2968.945,2936.545;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;560;3181.538,2935.038;Inherit;False;RiseTide;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;505;1385.671,4044.718;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;513;1156.241,4601.067;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;514;1342.241,4638.067;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;511;1502.333,4663.7;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;517;1628.286,4573.776;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;516;1838.286,4573.776;Inherit;True;Gradient;True;True;2;0;FLOAT2;0,0;False;1;FLOAT;2.15;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;518;1356.286,4516.776;Inherit;False;2;2;0;FLOAT;4;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;506;1404.46,4232.724;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;520;1607.506,4375.161;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;521;1735.506,4375.161;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;522;1883.506,4240.161;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;524;2127.71,4523.313;Inherit;False;2;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;526;2515.112,4238.615;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-0.1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;528;2741.825,4018.401;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;561;2529.949,3950.404;Inherit;False;560;RiseTide;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;576;2897.372,2136.831;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureTransformNode;578;3049.073,1770.932;Inherit;False;580;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleAddOpNode;575;2905.139,1826.023;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;577;3302.873,1776.534;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;582;3300.226,2090.999;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;585;3265.74,1955.667;Inherit;False;Property;_NormalStrength;NormalStrength;20;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;586;3857.668,1933.734;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;588;4086.855,2045.838;Inherit;False;564;Foam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;590;4154.394,2640.354;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;591;3877.393,2547.354;Inherit;False;Property;_ShallowColor;ShallowColor;21;0;Create;True;0;0;0;False;0;False;0.2268067,0.2911928,0.4339623,0;0,0.3100035,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;592;3886.044,2723.82;Inherit;False;Property;_DeepColor;DeepColor;22;0;Create;True;0;0;0;False;0;False;0.1320755,0.1320755,0.1320755,0;0,0.3100035,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;589;3902.17,2907.215;Inherit;False;500;Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;500;1068.422,3728.328;Inherit;False;Depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;602;4614.414,3062.686;Inherit;False;132;GerstPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;603;4644.414,3158.686;Inherit;False;134;GerstNorm;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-661.0399,2707.365;Inherit;False;Property;_Intensity;Intensity;0;1;[Header];Create;True;1;WaveGeneration;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-332.463,3126.376;Inherit;False;Property;_WaveDepth;WaveDepth;10;0;Create;True;0;0;0;False;0;False;50;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;556;2464.475,3144.964;Inherit;False;Property;_RiseThreshold;RiseThreshold;15;1;[Header];Create;True;1;RiseTide;0;0;False;0;False;0.63;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;557;2464.05,3236.845;Inherit;False;Property;_RiseFadeout;RiseFadeout;16;1;[Header];Create;True;1;RiseTide;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;580;3522.308,1761.508;Inherit;True;Property;_NormalTexture1;NormalTexture1;18;0;Create;True;0;0;0;False;0;False;-1;769ca6e81a779f845bdd21c6ffddc408;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;599;3880.588,3688.009;Inherit;False;Property;_WaterThickness;WaterThickness;25;0;Create;True;0;0;0;False;0;False;3;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;587;4303.686,1909.053;Inherit;False;3;0;FLOAT3;0.5,0.5,1;False;1;FLOAT3;0.5,0.5,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;605;4664.252,2818.863;Inherit;False;Constant;_Float1;Float 0;26;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;604;4663.252,2744.863;Inherit;False;Constant;_Float0;Float 0;26;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;564;3175.891,4017.852;Inherit;False;Foam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;593;3886.536,3216.293;Inherit;False;Property;_FoamColor;FoamColor;23;1;[HDR];Create;True;0;0;0;False;0;False;2,2,2,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;600;4156.588,3591.009;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;525;2316.211,4239.013;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;606;4666.252,2895.863;Inherit;False;Constant;_Float2;Float 0;26;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;598;3913.077,3594.006;Inherit;False;500;Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;596;3907.314,3120.212;Inherit;False;564;Foam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;507;1201.45,4239.472;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;1000;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;594;3887.292,3399.664;Inherit;False;Property;_Emmision;Emmision;24;1;[HDR];Create;True;0;0;0;False;0;False;0,0.4158199,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;607;4402.274,2935.732;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;523;1865.188,4045.231;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.97;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;519;1398.286,4374.776;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;562;2928.556,4018.885;Inherit;False;2;0;FLOAT;0.4;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;554;1929.326,3215.096;Inherit;True;Gradient;True;True;2;0;FLOAT2;0,0;False;1;FLOAT;0.02;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;555;2182.326,3215.096;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.3;False;4;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;549;2189.323,2766.367;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;210;4877.916,2651.775;Float;False;True;-1;2;UnityEditor.ShaderGraphLitGUI;0;12;OceanSurface_Amplify;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;20;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;4;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Lit;True;5;True;12;all;0;False;True;1;5;False;;10;False;;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;;0;0;Standard;41;Workflow;1;638304480516057885;Surface;1;638300532170568009;  Refraction Model;0;638304480755138240;  Blend;0;638300532503677378;Two Sided;1;638300530233978272;Fragment Normal Space,InvertActionOnDeselection;0;638300515573946518;Forward Only;0;638304493892474346;Transmission;0;638304493882192066;  Transmission Shadow;0.5,False,;0;Translucency;0;638304493887678754;  Translucency Strength;1,False,;0;  Normal Distortion;0.5,False,;0;  Scattering;2,False,;0;  Direct;0.9,False,;0;  Ambient;0.1,False,;0;  Shadow;0.5,False,;0;Cast Shadows;0;638300336150030956;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;0;638300336161044116;LOD CrossFade;1;0;Built-in Fog;1;0;_FinalColorxAlpha;0;0;Meta Pass;1;638302145110543716;Override Baked GI;0;0;Extra Pre Pass;0;0;DOTS Instancing;0;638300351025897575;Tessellation;1;638300330473901041;  Phong;0;0;  Strength;0.5,False,;0;  Type;1;638302106946930346;  Tess;32,False,_Float1;638302108524865803;  Min;5,False,;638302108654740862;  Max;50,False,;638302108723997465;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;1;638304683130604165;  Early Z;0;638302145002705540;Vertex Position,InvertActionOnDeselection;0;638304707961944244;Debug Display;0;638300351079489654;Clear Coat;0;0;0;10;False;True;False;True;True;True;True;True;True;True;False;;True;0
Node;AmplifyShaderEditor.GetLocalVarNode;547;1569.948,2764.97;Inherit;False;134;GerstNorm;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;613;2006.018,2761.116;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;612;1830.018,2766.116;Inherit;False;Projection;-1;;30;3249e2c8638c9ef4bbd1902a2d38a67c;0;2;5;FLOAT3;0,0,0;False;6;FLOAT4;0,1,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;65;-929.1613,2946.583;Inherit;False;True;4;0;FLOAT3;0,1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-1736.886,2912.546;Inherit;False;Property;_Roataion;Roataion;1;0;Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RadiansOpNode;615;-1556.789,2914.256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;541;1482.655,2872.56;Inherit;False;543;rotation;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;616;-31.21512,2691.199;Inherit;False;GerstnerFinal;-1;;1;c1f434d9d858ad248a81af6b7a1b452f;0;12;80;FLOAT;0;False;82;FLOAT;0;False;81;FLOAT;0;False;79;FLOAT3;0,0,0;False;78;FLOAT3;0,0,0;False;77;FLOAT3;0,0,0;False;76;FLOAT3;0,0,0;False;84;FLOAT;0;False;73;FLOAT;0;False;75;FLOAT;0;False;74;FLOAT;0;False;143;FLOAT;0;False;2;FLOAT3;125;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;499;506.8818,3884.611;Inherit;False;Property;_DepthDistance;DepthDistance;14;1;[Header];Create;True;1;Depth Settings;0;0;False;0;False;5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;498;701.1948,3860.666;Inherit;False;True;True;False;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;510;1266.332,4749.7;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;536;1242.759,3098.837;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;566;2175.323,1807.845;Inherit;False;Constant;_Vector;Vector;18;0;Create;True;0;0;0;False;0;False;0.4,0.17;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;567;2174.916,2225.917;Inherit;False;Constant;_Vector0;Vector 0;18;0;Create;True;0;0;0;False;0;False;-0.5,0.2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;568;2169.685,2031.351;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;569;2430.154,1825.279;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;570;2421.784,2187.212;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;574;2686.77,1968.334;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;571;1943.565,2031.978;Inherit;False;Property;_NormalPanSpeed;NormalPanSpeed;17;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;634;2444.875,1952.313;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;635;1019.064,3066.555;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;636;1023.606,4729.098;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureTransformNode;583;3029.228,2056.998;Inherit;False;584;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SamplerNode;584;3523.883,2119.091;Inherit;True;Property;_NormalTexture2;NormalTexture2;19;0;Create;True;0;0;0;False;0;False;-1;1d07290fa3fdc52449c080dbf13c2089;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;66;1;615;0
WireConnection;66;3;46;0
WireConnection;64;1;615;0
WireConnection;64;3;44;0
WireConnection;387;1;615;0
WireConnection;387;3;43;0
WireConnection;543;0;615;0
WireConnection;546;0;545;0
WireConnection;58;0;47;0
WireConnection;58;1;57;0
WireConnection;59;0;57;0
WireConnection;59;1;48;0
WireConnection;60;0;57;0
WireConnection;60;1;49;0
WireConnection;61;0;50;0
WireConnection;61;1;57;0
WireConnection;134;0;616;125
WireConnection;132;0;616;0
WireConnection;539;0;537;0
WireConnection;539;2;541;0
WireConnection;545;0;539;0
WireConnection;537;1;536;0
WireConnection;551;0;536;0
WireConnection;551;1;552;0
WireConnection;553;1;551;0
WireConnection;550;0;549;0
WireConnection;550;1;546;0
WireConnection;550;2;555;0
WireConnection;558;0;556;0
WireConnection;558;2;557;0
WireConnection;559;0;550;0
WireConnection;559;1;556;0
WireConnection;559;2;558;0
WireConnection;560;0;559;0
WireConnection;505;0;498;0
WireConnection;514;0;513;0
WireConnection;511;0;514;0
WireConnection;511;1;510;0
WireConnection;517;1;511;0
WireConnection;516;0;517;0
WireConnection;518;1;513;0
WireConnection;506;0;507;0
WireConnection;506;1;498;0
WireConnection;520;0;519;0
WireConnection;520;1;518;0
WireConnection;521;0;520;0
WireConnection;522;0;506;0
WireConnection;522;1;521;0
WireConnection;524;1;516;0
WireConnection;526;0;525;0
WireConnection;528;0;561;0
WireConnection;528;1;523;0
WireConnection;528;2;526;0
WireConnection;576;0;574;0
WireConnection;576;1;570;0
WireConnection;575;0;569;0
WireConnection;575;1;574;0
WireConnection;577;0;578;0
WireConnection;577;1;575;0
WireConnection;582;0;583;0
WireConnection;582;1;576;0
WireConnection;586;0;580;0
WireConnection;586;1;584;0
WireConnection;590;0;591;0
WireConnection;590;1;592;0
WireConnection;590;2;589;0
WireConnection;500;0;498;0
WireConnection;580;1;577;0
WireConnection;580;5;585;0
WireConnection;587;1;586;0
WireConnection;587;2;588;0
WireConnection;564;0;562;0
WireConnection;600;0;598;0
WireConnection;600;1;599;0
WireConnection;525;0;522;0
WireConnection;525;1;524;0
WireConnection;607;0;593;0
WireConnection;607;1;594;0
WireConnection;607;2;596;0
WireConnection;523;0;505;0
WireConnection;519;0;498;0
WireConnection;562;0;528;0
WireConnection;554;0;553;0
WireConnection;555;0;554;0
WireConnection;549;0;613;0
WireConnection;210;0;590;0
WireConnection;210;1;587;0
WireConnection;210;2;607;0
WireConnection;210;3;604;0
WireConnection;210;4;605;0
WireConnection;210;5;606;0
WireConnection;210;6;600;0
WireConnection;210;8;602;0
WireConnection;210;10;603;0
WireConnection;613;0;612;0
WireConnection;612;5;547;0
WireConnection;65;1;615;0
WireConnection;65;3;45;0
WireConnection;615;0;63;0
WireConnection;616;80;51;0
WireConnection;616;82;52;0
WireConnection;616;81;53;0
WireConnection;616;79;387;0
WireConnection;616;78;64;0
WireConnection;616;77;65;0
WireConnection;616;76;66;0
WireConnection;616;84;58;0
WireConnection;616;73;59;0
WireConnection;616;75;60;0
WireConnection;616;74;61;0
WireConnection;616;143;54;0
WireConnection;498;0;499;0
WireConnection;510;0;636;1
WireConnection;510;1;636;3
WireConnection;536;0;635;1
WireConnection;536;1;635;3
WireConnection;568;0;571;0
WireConnection;569;0;566;0
WireConnection;569;1;568;0
WireConnection;570;0;568;0
WireConnection;570;1;567;0
WireConnection;574;0;634;1
WireConnection;574;1;634;3
WireConnection;584;1;582;0
WireConnection;584;5;585;0
ASEEND*/
//CHKSM=D12E0CCBA315C0966517507C1A1A2337AA2CBF2B