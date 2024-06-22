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

float4 hash4(in float2 input)
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
    return frac(p.xzxz * p.yyww * invSomeLargeFixed);
}

void textureTiling1_float(in Texture2D tex, in SamplerState ss, in float2 uv, out float3 color)
{
    float2 p = float2(floor(uv));
    float2 f = frac(uv);

    // generate per-tile transform
    float4 ofa = hash4(p + float2(0, 0));
    float4 ofb = hash4(p + float2(1, 0));
    float4 ofc = hash4(p + float2(0, 1));
    float4 ofd = hash4(p + float2(1, 1));
    
    float2 _ddx = ddx(uv);
    float2 _ddy = ddy(uv);

    // transform per-tile uvs
    ofa.zw = sign(ofa.zw - 0.5);
    ofb.zw = sign(ofb.zw - 0.5);
    ofc.zw = sign(ofc.zw - 0.5);
    ofd.zw = sign(ofd.zw - 0.5);
    
    // uv's, and derivatives (for correct mipmapping)
    float2 uva = uv * ofa.zw + ofa.xy;
    float2 ddxa = _ddx * ofa.zw;
    float2 ddya = _ddy * ofa.zw;

    float2 uvb = uv * ofb.zw + ofb.xy;
    float2 ddxb = _ddx * ofb.zw;
    float2 ddyb = _ddy * ofb.zw;

    float2 uvc = uv * ofc.zw + ofc.xy;
    float2 ddxc = _ddx * ofc.zw;
    float2 ddyc = _ddy * ofc.zw;

    float2 uvd = uv * ofd.zw + ofd.xy;
    float2 ddxd = _ddx * ofd.zw;
    float2 ddyd = _ddy * ofd.zw;
    
    // fetch and blend
    float2 b = smoothstep(0.25, 0.75, f);
    
    color = lerp(
        lerp(tex.SampleGrad(ss,uva, ddxa, ddya), tex.SampleGrad(ss,uvb, ddxb, ddyb), b.x),
        lerp(tex.SampleGrad(ss,uvc, ddxc, ddyc), tex.SampleGrad(ss,uvd, ddxd, ddyd), b.x),
        b.y).rgb;
}
        


void textureTiling2(in sampler2D samp, in float2 uv, out float3 color)
{
    float2 p = floor(uv);
    float2 f = frac(uv);

    //for correct mip-mapping, derivatives
    float2 _ddx = ddx(uv);
    float2 _ddy = ddy(uv);

    float4 va = float4(0, 0, 0, 0);
    float wt = 0.0;
    for (int j = -1; j <= 1; ++j)
    {
        for (int i = -1; i <= 1; ++i)
        {
            float2 g = float2(i, j);
            float4 o = hash4(p + g);
            float2 r = g - f + o.xy;
            float d = dot(r, r);
            float w = exp(-5.0 * d);
            float4 c = tex2Dgrad(samp, uv + o.zw, _ddx, _ddy);
            va += w * c;
            wt += w;
        }
    }

    color = (va / wt).rgb;
}

float sum(in float3 v)
{
    return v.x + v.y + v.z;

}

void textureTiling3_float(in sampler2D samp, in sampler2D noise, in float2 uv, out float3 color)
{
    // sample variation pattern
    float k = tex2D(noise, uv * 0.005).r; // cheap (cache friendly) lookup
    
    // compute index
    float index = k * 8.0;
    float i = floor(index);
    float f = frac(index);

    // offsets for the different virtual patterns
    float2 offa = sin(float2(3.0, 7.0) * (i + 0.0)); // can replace with any other hash
    float2 offb = sin(float2(3.0, 7.0) * (i + 1.0)); // can replace with any other hash

    // compute derivatives for mip-mapping
    float2 dx = ddx(uv);
    float2 dy = ddy(uv);
    
    // sample the two closest virtual patterns
    float3 cola = tex2Dgrad(samp, uv + offa, dx, dy).rgb;
    float3 colb = tex2Dgrad(samp, uv + offb, dx, dy).rgb;

    // return colb;
    
    // interpolate between the two virtual patterns
    color = lerp(cola, colb, smoothstep(0.2, 0.8, f - 0.1 * sum(cola - colb)));
}