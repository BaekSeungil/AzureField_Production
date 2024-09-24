#ifndef WATER_COMMON_INCLUDED
#define WATER_COMMON_INCLUDED

float _CustomTime;
#define TIME_FRAG_INPUT _CustomTime > 0 ? _CustomTime : input.uv.z
#define TIME_VERTEX_OUTPUT _CustomTime > 0 ? _CustomTime : output.uv.z

#define TIME ((TIME_FRAG_INPUT * _Speed) * -_Direction.xy)
#define TIME_VERTEX ((TIME_VERTEX_OUTPUT * _Speed) * -_Direction.xy)

#define HORIZONTAL_DISPLACEMENT_SCALAR 0.01
#define UP_VECTOR float3(0,1,0)

struct WaterSurface
{
	uint vFace;
	float3 positionWS;
	float3 viewDelta; //Un-normalized view direction, 
	float3 viewDir;

	//Normal from the base geometry, in world-space
	float3 vertexNormal;
	//Normal of geometry + waves
	float3 waveNormal;	
	half3x3 tangentToWorldMatrix;
	//Tangent-space normal
	float3 tangentNormal;
	//World-space normal, include geometry+waves+normal map
	float3 tangentWorldNormal;
	//The normal used for diffuse lighting.
	float3 diffuseNormal;
	//Per-pixel offset vector
	float4 refractionOffset;
	
	float3 albedo;
	float3 reflections;
	float3 caustics;
	float3 specular;
	half reflectionMask;
	half reflectionLighting;
	
	float3 offset;
	float slope;
	
	float fog;
	float intersection;
	float foam;

	float alpha;
	float edgeFade;
	float shadowMask;
};

float2 GetSourceUV(float2 uv, float2 wPos, float state) 
{
	float2 output =  lerp(uv, wPos, state);
	
	return output;
}

float4 GetVertexColor(float4 inputColor, float4 mask)
{
	return inputColor * mask;
}

float DepthDistance(float3 wPos, float3 viewPos, float3 normal)
{
	return length((wPos - viewPos) * normal);
}

float4 PackedUV(float2 sourceUV, float2 time, float speed, float subTiling, float subSpeed)
{
	float2 uv1 = sourceUV.xy + (time.xy * speed);
	
	float2 uv2 = (sourceUV.xy * subTiling) + ((time.xy) * speed * subSpeed);
	
	return float4(uv1.xy, uv2.xy);
}

struct SurfaceNormalData
{
	float3 geometryNormalWS;
	float3 pixelNormalWS;
	float lightingStrength;
	float mask;
};

float GetSlope(float3 normalWS, float threshold)
{
	return 1-smoothstep(1.0 - threshold, 1.0, saturate(dot(UP_VECTOR, normalWS)));
}

struct SceneDepth
{
	float raw;
	float linear01;
	float eye;
};

#define FAR_CLIP _ProjectionParams.z
#define NEAR_CLIP _ProjectionParams.y
// 직교 투영을 위해 선형 값을 클리핑 평면으로 조정합니다(unity_OrthoParams.w = 1 = 직교).
#define DEPTH_SCALAR lerp(1.0, FAR_CLIP - NEAR_CLIP, unity_OrthoParams.w)

//Linear depth difference between scene and current (transparent) geometry pixel
float SurfaceDepth(SceneDepth depth, float4 positionCS)
{
	const float sceneDepth = (unity_OrthoParams.w == 0) ? depth.eye : LinearDepthToEyeDepth(depth.raw);
	const float clipSpaceDepth = (unity_OrthoParams.w == 0) ? LinearEyeDepth(positionCS.z, _ZBufferParams) : LinearDepthToEyeDepth(positionCS.z / positionCS.w);

	return sceneDepth - clipSpaceDepth;
}

// 사용된 기술(버퍼, 정점 색상, 베이크 텍스처)을 기반으로 한 반환 깊이
SceneDepth SampleDepth(float4 screenPos)
{
	SceneDepth depth = (SceneDepth)0;
	
#ifndef _DISABLE_DEPTH_TEX
	screenPos.xyz /= screenPos.w;

	depth.raw = SampleSceneDepth(screenPos.xy);
	depth.eye = LinearEyeDepth(depth.raw, _ZBufferParams);
	depth.linear01 = Linear01Depth(depth.raw, _ZBufferParams) * DEPTH_SCALAR;
#else
	depth.raw = 1.0;
	depth.eye = 1.0;
	depth.linear01 = 1.0;
#endif

	return depth;
}

#define ORTHOGRAPHIC_SUPPORT

#if defined(USING_STEREO_MATRICES)
// VR에서는 절대 사용되지 않으며 조각별 행렬 곱셈을 저장합니다.
#undef ORTHOGRAPHIC_SUPPORT
#endif

//Reconstruct world-space position from depth.
float3 ReconstructWorldPosition(float4 screenPos, float3 viewDir, SceneDepth sceneDepth)
{
	#if UNITY_REVERSED_Z
	real rawDepth = sceneDepth.raw;
	#else
	// OpenGL용 NDC와 일치하도록 z 조정
	real rawDepth = lerp(UNITY_NEAR_CLIP_VALUE, 1, sceneDepth.raw);
	#endif
	
	#if defined(ORTHOGRAPHIC_SUPPORT)
	// 월드 위치 보기
	float4 viewPos = float4((screenPos.xy/screenPos.w) * 2.0 - 1.0, rawDepth, 1.0);
	float4x4 viewToWorld = UNITY_MATRIX_I_VP;
	#if UNITY_REVERSED_Z 
	viewToWorld._12_22_32_42 = -viewToWorld._12_22_32_42;              
	#endif
	float4 viewWorld = mul(viewToWorld, viewPos);
	float3 viewWorldPos = viewWorld.xyz / viewWorld.w;
	#endif

	//Projection to world position
	float3 camPos = GetCurrentViewPosition().xyz;
	float3 worldPos = sceneDepth.eye * (viewDir/screenPos.w) - camPos;
	float3 perspWorldPos = -worldPos;

	#if defined(ORTHOGRAPHIC_SUPPORT)
	return lerp(perspWorldPos, viewWorldPos, unity_OrthoParams.w);
	#else
	return perspWorldPos;
	#endif

}
#endif