void calculateLinearFog_float(float depth, out float density)
{
    density = 1.0f - saturate(depth * unity_FogParams.z + unity_FogParams.w);
}