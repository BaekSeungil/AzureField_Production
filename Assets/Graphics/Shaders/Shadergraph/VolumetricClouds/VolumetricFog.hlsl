#include "noiseSimplex.cginc"

float sdRoundBox(float3 p, float b, float r)
{
    float3 q = abs(p) - float3(b, b, b);
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

void FogMagic_float(float3 viewPosition, float3 viewDirection, float fogSize, float fogRoundedness, out float minDist)
{
    float march = 0;
    minDist = 100000;

    while (march < 1000)
    {
        float3 p = viewPosition + viewDirection * march;
        float dist = sdRoundBox(p, (1 - fogRoundedness) * fogSize, fogRoundedness * fogSize);
        minDist = min(max(dist, 0), minDist);
        march += dist;
        if (dist < 0.0001)
            break;
    }
}

void FractalNoise_float(float3 position, float scale, out float noise)
{
    noise = 0;

    float p = 1.0 / 2;
    for (int i = 0; i < 6; i++)
    {
        noise += snoise(position * scale / p) * p;
        p /= 2;
    }
}