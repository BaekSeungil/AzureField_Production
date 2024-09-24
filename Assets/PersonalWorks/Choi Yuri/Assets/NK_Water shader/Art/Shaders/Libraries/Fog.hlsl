//Set this to value to 1 through Shader.SetGlobalFloat to temporarily disable fog for water
float _WaterFogDisabled;

//Authors of third-party fog solutions can reach out to have their method integrated here

//Executed in vertex stage
float CalculateFogFactor(float3 positionCS) {
	return ComputeFogFactor(positionCS.z);
}

//Fragment stage. Note: Screen position passed here is not normalized (divided by w-component)
void ApplyFog(inout float3 color, float fogFactor, float4 screenPos, float3 positionWS, float vFace) 
{
	float3 foggedColor = color;
	
#ifdef UnityFog
	foggedColor = MixFog(color.rgb, fogFactor);
#endif

	#ifndef UnityFog
	//Allow fog to be disabled for water globally by setting the value through script
	foggedColor = lerp(foggedColor, color, _WaterFogDisabled);
	#endif
	
	//Fog only applies to the front faces, otherwise affects underwater rendering
	color.rgb = lerp(color.rgb, foggedColor.rgb, vFace);
}
