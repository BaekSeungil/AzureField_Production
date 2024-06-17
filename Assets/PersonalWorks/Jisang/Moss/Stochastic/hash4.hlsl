void hash4_float(in float2 input, out float4 output)
{
    const float2 offset = float2(26.0, 161.0);
    const float domain = 71.0;
    const float invDomain = 1 / domain;
    const float someLargeFixed = 951.135664;
    const float invSomeLargeFixed = (1 / someLargeFixed);

    float4 p = float4(input.xy, input.xy + 1);
    p = frac(p * invDomain) * domain;
    p += offset.xyxy;
    p *= p;
    output = frac(p.xzxz * p.yyww * invSomeLargeFixed);
}