#ifndef PI
#define PI 3.14159
#endif
#ifndef DEG2RAD
#define DEG2RAD 0.01745328
#endif
#ifndef TWO_PI
#define TWO_PI 6.28318
#endif

void GetImpostorUV_float(float2 uv_MainTex, float3 viewDir, out float2 gridUv, out float2 gridUvLB, out float2 gridUvRB, out float2 gridUvLT, out float2 gridUvRT, out float alpha, out float beta)
{
    float gridSide = round(sqrt(_GridSize));
    float gridStep = 1.0 / gridSide;
    float trYawOffset = -atan2(unity_ObjectToWorld._31, unity_ObjectToWorld._11);
    float yaw = atan2(viewDir.z, viewDir.x) + TWO_PI + _YawOffset + trYawOffset;
    float elevation = asin(viewDir.y) + _ElevationOffset;
    float elevationId = (max(min(round(elevation / (_LatitudeStep * DEG2RAD)) - _LatitudeOffset, _LatitudeSamples), -_LatitudeSamples));
    float elevationFrac = frac(elevation / (_LatitudeStep * DEG2RAD));
    float offset = 0;

    float currentLongitudeSamples;
    float lastLongitudeSamples;
    if (_SmartSphere > 0.5) {
        for (int l = -_LatitudeSamples; l < elevationId; ++l) {
            if (l == elevationId - 1) {
                lastLongitudeSamples = round(cos(l * PI / (2.0 * (_LatitudeSamples + 1.0))) * _LongitudeSamples);
                offset += lastLongitudeSamples;
            }
            else
                offset += round(cos(l * PI / (2.0 * (_LatitudeSamples + 1.0))) * _LongitudeSamples);
        }
        currentLongitudeSamples = round(cos(elevationId * _LatitudeStep * DEG2RAD) * _LongitudeSamples);
    }
    else
        currentLongitudeSamples = _LongitudeSamples;
    float yawId = (round((yaw / TWO_PI) * currentLongitudeSamples) % currentLongitudeSamples);
    if (_Smooth > 0.5) {

        float yawFrac = frac((yaw / TWO_PI) * currentLongitudeSamples);
        float subdLB;
        float subdRB;
        float subdLT;
        float subdRT;
        alpha = 1.0 - yawFrac;
        beta = 1.0 - elevationFrac;
        if (_SmartSphere < 0.5) {
            if (elevationFrac < 0.5) {
                if (yawFrac < 0.5) {
                    subdLB = yawId + (elevationId + _LatitudeSamples) * currentLongitudeSamples;
                    subdRB = (yawId + 1) % currentLongitudeSamples + (elevationId + _LatitudeSamples) * currentLongitudeSamples;
                    subdLT = (yawId + (elevationId + (elevationId == _LatitudeSamples ? 0 : 1) + _LatitudeSamples) * currentLongitudeSamples); ///
                    subdRT = ((yawId + 1) % currentLongitudeSamples + (elevationId + (elevationId == _LatitudeSamples ? 0 : 1) + _LatitudeSamples) * currentLongitudeSamples);
                }
                else {
                    subdLB = (yawId - 1) % currentLongitudeSamples + (elevationId + _LatitudeSamples) * currentLongitudeSamples;
                    subdRB = yawId + (elevationId + _LatitudeSamples) * currentLongitudeSamples;
                    subdLT = ((yawId - 1) % currentLongitudeSamples + (elevationId + (elevationId == _LatitudeSamples ? 0 : 1) + _LatitudeSamples) * currentLongitudeSamples);
                    subdRT = (yawId + (elevationId + (elevationId == _LatitudeSamples ? 0 : 1) + _LatitudeSamples) * currentLongitudeSamples); ///
                }
            }
            else {
                if (yawFrac < 0.5) {
                    subdLB = yawId + (elevationId - (elevationId == -_LatitudeSamples ? 0 : 1) + _LatitudeSamples) * currentLongitudeSamples; ///
                    subdRB = (yawId + 1) % currentLongitudeSamples + (elevationId + _LatitudeSamples - (elevationId == -_LatitudeSamples ? 0 : 1)) * currentLongitudeSamples;
                    subdLT = yawId + (elevationId + _LatitudeSamples) * currentLongitudeSamples;
                    subdRT = ((yawId + 1) % currentLongitudeSamples + (elevationId + _LatitudeSamples) * currentLongitudeSamples);
                }
                else {
                    subdLB = (yawId - 1) % currentLongitudeSamples + (elevationId + _LatitudeSamples - (elevationId == -_LatitudeSamples ? 0 : 1)) * currentLongitudeSamples;
                    subdRB = yawId + (elevationId + _LatitudeSamples - (elevationId == -_LatitudeSamples ? 0 : 1)) * currentLongitudeSamples; ///
                    subdLT = ((yawId - 1) % currentLongitudeSamples) + (elevationId + _LatitudeSamples) * currentLongitudeSamples;
                    subdRT = yawId + (elevationId + _LatitudeSamples) * currentLongitudeSamples;
                }
            }
        }
        else {
            if (elevationFrac < 0.5) {
                if (yawFrac < 0.5) {
                    subdLB = yawId + offset;
                    subdRB = (yawId + 1) % currentLongitudeSamples + offset;
                    subdLT = subdLB;
                    subdRT = subdRB;
                }
                else {
                    subdLB = (yawId - 1) % currentLongitudeSamples + offset;
                    subdRB = yawId + offset;
                    subdLT = subdLB;
                    subdRT = subdRB;
                }
            }
            else {
                if (yawFrac < 0.5) {
                    subdLT = yawId + offset;
                    subdRT = ((yawId + 1) % currentLongitudeSamples + offset);
                    subdLB = subdLT;
                    subdRB = subdRT;
                }
                else {
                    subdLT = ((yawId - 1) % currentLongitudeSamples) + offset;
                    subdRT = yawId + offset;
                    subdLB = subdLT;
                    subdRB = subdRT;
                }
            }
        }
        gridUvLB = uv_MainTex / gridSide + float2((subdLB % gridSide), floor(subdLB / gridSide)) * gridStep;
        gridUvRB = uv_MainTex / gridSide + float2((subdRB % gridSide), floor(subdRB / gridSide)) * gridStep;
        gridUvRT = uv_MainTex / gridSide + float2((subdRT % gridSide), floor(subdRT / gridSide)) * gridStep;
        gridUvLT = uv_MainTex / gridSide + float2((subdLT % gridSide), floor(subdLT / gridSide)) * gridStep;
    }
    else {
        float subd = (_SmartSphere < 0.5 ? yawId + (elevationId + _LatitudeSamples) * currentLongitudeSamples : yawId + offset);
        gridUv = uv_MainTex / gridSide + float2((subd % gridSide), floor(subd / gridSide)) * gridStep;
    }
}