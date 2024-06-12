Shader "Custom/GrassShader"
{
    Properties
    {
        [Header(Blade Color)]
        [Space(10)]
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _TipColor ("Tip Color", Color) = (1, 1, 1, 1)
        
        [Header(Blade Shape)]
        [Space(10)]
        _BladeTexture ("Blade Texture", 2D) = "white" { }

        _BladeWidthMin ("Blade Width (Min)", Range(0, 10)) = 0.02
        _BladeWidthMax ("Blade Width (Max)", Range(0, 10)) = 0.05
        _BladeHeightMin ("Blade Height (Min)", Range(0, 3)) = 0.1
        _BladeHeightMax ("Blade Height (Max)", Range(0, 3)) = 0.2

        _BladeBendDistance ("Blade Forward Amount", Float) = 0.38
        _BladeBendCurve ("Blade Curvature Amount", Range(1, 4)) = 2
        
        [Header(Bend)]
        [Space(10)]
        _BendDelta ("Bend Variation", Range(0, 1)) = 0.2

        [Header(Tessellation)]
        [Space(10)]
        _TessellationGrassDistance ("Tessellation Grass step(cascade)", Range(1, 5)) = 1
        _TessellationGrassDistanceFar ("Tessellation Grass Distance (Far)", Range(0.001, 500)) = 0.5

        _TessellationGrassDistanceRate ("Tessellation Grass Distance (Rate)", Range(0.01, 100)) = 0.1

        
        [Header(Grass VIsibility)]
        [Space(10)]
        _GrassMap ("Grass Visibility Map", 2D) = "white" { }
        _GrassThreshold ("Grass Visibility Threshold", Range(-0.1, 1)) = 0.5
        _GrassFalloff ("Grass Visibility Fade-In Falloff", Range(0, 0.5)) = 0.05

        [Header(Wind)]
        [Space(10)]
        _WindMap ("Wind Offset Map", 2D) = "bump" { }
        _WindVelocity ("Wind Velocity", Vector) = (1, 0, 0, 0)
        _WindFrequency ("Wind Pulse Frequency", Range(0, 1)) = 0.01

        [Header(other)]
        [space(10)]
        _Roughness ("Roughness", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "RenderPipeline"="UniversalPipeline" }
        LOD 100
        Cull Off

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        #pragma multi_compile _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _SHADOWS_SOFT

        #pragma multi_compile_fog

        #define UNITY_PI 3.14159265359f
        #define UNITY_TWO_PI 6.28318530718f
        #define BLADE_SEGMENTS 4

        sampler2D _BladeTexture;
        sampler2D _GrassMap;
        sampler2D _WindMap;
        
        CBUFFER_START(UnityPerMaterial)
            float4 _BaseColor;
            float4 _TipColor;

            float _BladeWidthMin;
            float _BladeWidthMax;
            float _BladeHeightMin;
            float _BladeHeightMax;

            float _BladeBendDistance;
            float _BladeBendCurve;

            float _BendDelta;

            float _TessellationGrassDistance;
            float _TessellationGrassDistanceFar;
            float _TessellationGrassDistanceRate;
            
            float4 _GrassMap_ST;
            float _GrassThreshold;
            float _GrassFalloff;

            float4 _WindMap_ST;
            float4 _WindVelocity;
            float _WindFrequency;

            float _Roughness;
        CBUFFER_END

        struct VertexInput
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
            float2 uv : TEXCOORD0;
        };

        struct VertexOutput
        {
            float4 vertex : SV_POSITION;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
            float2 uv : TEXCOORD0;
        };

        struct TessellationFactors
        {
            float edge[3] : SV_TessFactor;
            float inside : SV_InsideTessFactor;
        };

        struct GeomData
        {
            float4 pos : SV_POSITION;
            float3 normal : NORMAL;
            float2 uv : TEXCOORD0;
            float3 worldPos : TEXCOORD1;
            float fogCoord : TEXCOORD2;
        };

        float rand(float3 co)
        {
            return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 53.539))) * 43758.5453);
        }

        float3x3 angleAxis3x3(float angle, float3 axis)
        {
            float c, s;
            sincos(angle, s, c);

            float t = 1 - c;
            float x = axis.x;
            float y = axis.y;
            float z = axis.z;

            return float3x3
            (
                t * x * x + c, t * x * y - s * z, t * x * z + s * y,
                t * x * y + s * z, t * y * y + c, t * y * z - s * x,
                t * x * z - s * y, t * y * z + s * x, t * z * z + c
            );
        }

        // VertexOutput vert(VertexInput v)
        // {
        //     VertexOutput o;
        //     o.vertex = TransformObjectToHClip(v.vertex.xyz);
        //     o.normal = v.normal;
        //     o.tangent = v.tangent;
        //     o.uv = TRANSFORM_TEX(v.uv, _GrassMap);
        //     return o;
        // }

        VertexOutput tessVert(VertexInput v)
        {
            VertexOutput o;
            
            o.vertex = float4(TransformObjectToWorld(v.vertex), 1.0f);
            o.normal = TransformObjectToWorldNormal(v.normal);
            o.tangent = float4(TransformObjectToWorldNormal(v.tangent).xyz, v.tangent.w);
            o.uv = v.uv;
            return o;
        }

        VertexOutput geomVert(VertexInput v)
        {
            VertexOutput o;

            o.vertex = v.vertex;
            o.normal = v.normal;
            o.tangent = v.tangent;
            o.uv = TRANSFORM_TEX(v.uv, _GrassMap);
            return o;
        }

        //_ProjectionParams = {1.0 (or –1.0 if currently rendering with a flipped projection matrix), near plane, far plane , 1/FarPlane}
        float tessellationEdgeFactor(VertexInput vert0, VertexInput vert1)
        {
            float3 vertexPos = TransformObjectToWorld(lerp(vert0.vertex, vert1.vertex, 0.5f));
            float dist = distance(vertexPos.xyz, _WorldSpaceCameraPos);

            //near,far remap=> 0,1 -> 1,0
            float rate = smoothstep(0, _TessellationGrassDistanceFar, dist);
            float inverseLinearizedDistance10 = (1 - rate);
            float steppedFactor = ceil(inverseLinearizedDistance10 * _TessellationGrassDistance) / _TessellationGrassDistance;

            //small is large interval between geom
            return steppedFactor * _TessellationGrassDistanceRate;
        }

        TessellationFactors patchConstantFunc(InputPatch < VertexInput, 3 > patch)
        {
            TessellationFactors f;

            f.edge[0] = tessellationEdgeFactor(patch[1], patch[2]);
            f.edge[1] = tessellationEdgeFactor(patch[2], patch[0]);
            f.edge[2] = tessellationEdgeFactor(patch[0], patch[1]);
            f.inside = (f.edge[0] + f.edge[1] + f.edge[2]) / 3.0f;

            return f;
        }


        [domain("tri")]
        [outputcontrolpoints(3)]
        [outputtopology("triangle_cw")]
        [partitioning("integer")]
        [patchconstantfunc("patchConstantFunc")]
        VertexInput hull(InputPatch < VertexInput, 3 > patch, uint id : SV_OutputControlPointID)
        {
            return patch[id];
        }
        
        [domain("tri")]
        VertexOutput domain(TessellationFactors factors, OutputPatch < VertexInput, 3 > patch, float3 barycentricCoordinates : SV_DomainLocation)
        {
            VertexInput i;

            #define INTERPOLATE(fieldname) i.fieldname = \
                    patch[0].fieldname * barycentricCoordinates.x + \
                    patch[1].fieldname * barycentricCoordinates.y + \
                    patch[2].fieldname * barycentricCoordinates.z;

            INTERPOLATE(vertex)
            INTERPOLATE(normal)
            INTERPOLATE(tangent)
            INTERPOLATE(uv)

            return tessVert(i);
        }


        GeomData TransformGeomToClip(float3 pos, float3 normal, float3 offset, float3x3 transformationMatrix, float2 uv)
        {
            GeomData o;

            o.pos = TransformObjectToHClip(pos + mul(transformationMatrix, offset));
            o.normal = -TransformObjectToWorldNormal(mul(transformationMatrix, normal));
            o.uv = uv;
            o.worldPos = TransformObjectToWorld(pos + mul(transformationMatrix, offset));
            o.fogCoord = ComputeFogFactor(o.pos.z);
            return o;
        }


        [maxvertexcount(BLADE_SEGMENTS * 2 + 1)]
        void geom(point VertexOutput input[1], inout TriangleStream<GeomData> triStream)
        {
            float3 grassMap = tex2Dlod(_GrassMap, float4(input[0].uv, 0, 0)).rgb;
            float grassVisibility = grassMap.r;
            float grassOverrideBend = grassMap.g;
            float grassOverrideHeight = grassMap.b;

            if (grassVisibility >= _GrassThreshold)
            {
                float3 pos = input[0].vertex.xyz;
                float3 mspos = TransformWorldToObject(pos);

                float3 normal = input[0].normal;
                float4 tangent = input[0].tangent;
                float3 bitangent = cross(normal, tangent.xyz) * tangent.w;

                float3x3 tangentToLocal = float3x3
                (
                    tangent.x, bitangent.x, normal.x,
                    tangent.y, bitangent.y, normal.y,
                    tangent.z, bitangent.z, normal.z
                );
                tangentToLocal = mul(unity_WorldToObject, tangentToLocal);

                // Rotate around the y-axis a random amount.
                float3x3 randRotMatrix = angleAxis3x3(rand(pos) * UNITY_TWO_PI, float3(0, 0, 1.0f));

                // Rotate around the bottom of the blade a random amount.
                float bend = max(_BendDelta, (1 - grassOverrideBend) * 4);
                float3x3 randBendMatrix = angleAxis3x3(rand(pos.zzx) * bend * UNITY_PI * 0.5f, float3(-1.0f, 0, 0));

                float2 windUV = pos.xz * _WindMap_ST.xy + _WindMap_ST.zw + normalize(_WindVelocity.xzy) * _WindFrequency * _Time.y;
                float2 windSample = (tex2Dlod(_WindMap, float4(windUV, 0, 0)).xy * 2 - 1) * length(_WindVelocity);

                float3 windAxis = normalize(float3(windSample.x, windSample.y, 0));
                float3x3 windMatrix = angleAxis3x3(UNITY_PI * windSample * grassOverrideBend, windAxis);

                // Transform the grass blades to the correct tangent space.
                float3x3 baseTransformationMatrix = mul(tangentToLocal, randRotMatrix);
                float3x3 tipTransformationMatrix = mul(mul(mul(tangentToLocal, windMatrix), randBendMatrix), randRotMatrix);

                float falloff = smoothstep(_GrassThreshold, _GrassThreshold + _GrassFalloff, grassVisibility);

                float width = lerp(_BladeWidthMin, _BladeWidthMax, rand(pos.xzy) * falloff);
                float height = lerp(_BladeHeightMin, _BladeHeightMax, rand(pos.zyx) * falloff) * grassOverrideHeight;
                float forward = rand(pos.yyz) * _BladeBendDistance;

                float3 tangentNormal = normal;

                // Create blade segments by adding two vertices at once.
                for (int i = 0; i < BLADE_SEGMENTS; ++i)
                {
                    float3x3 transformationMatrix = (i == 0) ? baseTransformationMatrix : tipTransformationMatrix;

                    float t = i / (float)BLADE_SEGMENTS;
                    float temp = t + 1 / (float)BLADE_SEGMENTS;

                    //approx(#1,#2)
                    float xpos = ((temp * 1.247993 - 0.101306) - pow(temp * 1.247993 - 0.401306, 4.0) - 0.1) * 0.2 * width;
                    float3 offset = float3(xpos, pow(t, _BladeBendCurve) * forward, height * t);
                    
                    //normal setup
                    float3 surfaceUp = normalize(cross(offset, float3(1, 0, 0)));
                    tangentNormal = lerp(tangentNormal, surfaceUp, t);

                    //append
                    triStream.Append(TransformGeomToClip(mspos, tangentNormal, float3(offset.x, offset.y, offset.z), transformationMatrix, float2(0, t)));
                    triStream.Append(TransformGeomToClip(mspos, tangentNormal, float3(-offset.x, offset.y, offset.z), transformationMatrix, float2(1, t)));
                }

                // Add the final vertex at the tip of the grass blade.
                triStream.Append(TransformGeomToClip(mspos, tangentNormal, float3(0, forward, height), tipTransformationMatrix, float2(0.5, 1)));

                triStream.RestartStrip();
            }
        }
        ENDHLSL

        Pass
        {
            Name "GrassPass"
            // Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma require geometry
            #pragma require tessellation tessHW

            //#pragma vertex vert
            #pragma vertex geomVert
            #pragma hull hull
            #pragma domain domain
            #pragma geometry geom
            #pragma fragment frag


            void GGX(in GeomData i, out float lambertian, out float specularTerm)
            {
                i.normal = normalize(i.normal);

                //half lambert
                Light light = GetMainLight();
                lambertian = saturate(dot(i.normal, light.direction));
                lambertian = lambertian * 0.5f + 0.5f;

                //BPhong
                float3 view = GetWorldSpaceNormalizeViewDir(i.worldPos);            //ShaderVariablesFunctions.hlsl
                float3 halfDirection = SafeNormalize(view + light.direction);       //common.hlsl
                
                float NoH = saturate(dot(halfDirection, i.normal));
                half LoH = half(saturate(dot(light.direction, halfDirection)));
                
                //GGX
                half LoH2 = LoH * LoH;
                half NoH2 = NoH * NoH;
                float R2 = _Roughness * _Roughness;
                
                float d = NoH2 * (R2 - 1) + 1.00001f;
                half d2 = half(d * d);

                specularTerm = R2 / (d2 * max(half(0.1), LoH2) * (_Roughness * 4.0 + 2.0));
            }

            float4 frag(GeomData i) : SV_Target
            {
                float4 color = tex2D(_BladeTexture, i.uv);

                //shadow
                #if defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE)
                    VertexPositionInputs vertexInput = (VertexPositionInputs)0;
                    vertexInput.positionWS = i.worldPos;
                    
                    float4 shadowCoord = GetShadowCoord(vertexInput);

                    half shadowAttenuation = saturate(MainLightRealtimeShadow(shadowCoord));
                    float4 shadowColor = lerp(unity_ShadowColor, 1, shadowAttenuation);
                    //unity_ShadowColor _SubtractiveShadowColor
                    color *= shadowColor;
                    color *= _MainLightColor;
                #endif

                //apply ggx
                float lambertian, specularTerm;
                GGX(i, lambertian, specularTerm);
                color = color * lambertian + specularTerm;
                
                //ambient
                //PerFrameBuffer, _SubtractiveShadowColor,  _GlossyEnvironmentColor
                color += _GlossyEnvironmentColor;

                //apply fog
                color *= lerp(_BaseColor, _TipColor, i.uv.y);
                float4 fogColor = float4(MixFog(color, i.fogCoord), 1);
                
                //show result
                return fogColor;

                //test : show normal;
                //return float4(normalize(i.normal), 1);
            }

            /*
                in RenderPipeLine, setup color
            
                static void SetupPerFrameShaderConstants()
                {
                    // When glossy reflections are OFF in the shader we set a constant color to use as indirect specular
                    SphericalHarmonicsL2 ambientSH = RenderSettings.ambientProbe;
                    Color linearGlossyEnvColor = new Color(ambientSH[0, 0], ambientSH[1, 0], ambientSH[2, 0]) * RenderSettings.reflectionIntensity;
                    Color glossyEnvColor = CoreUtils.ConvertLinearToActiveColorSpace(linearGlossyEnvColor);
                    Shader.SetGlobalVector(PerFrameBuffer._GlossyEnvironmentColor, glossyEnvColor);

                    // Used when subtractive mode is selected
                    Shader.SetGlobalVector(PerFrameBuffer._SubtractiveShadowColor, CoreUtils.ConvertSRGBToActiveColorSpace(RenderSettings.subtractiveShadowColor));
                }


            */

            ENDHLSL
        }
    }
}

//appendix

//approximation #1
// y = ((x/13.6)-(x/13.6 - 0.3)^4 - 0.1)*5.3 + 1/( ((x/13.6)-(x/13.6 - 0.3)^4 - 0.1)*5.3)
// substitution => x/13.6 = w
// y = (w - (w - 0.3)^4 - 0.1)5.3 ≈ (w - (w^4 - 4w^30.3 + 6w^20.3^2 - 4w*0.3^3 + 0.3^4) - 0.1)*5.3
// y = (((-(x + 17.513 - 18) + 18) * 0.073529) - (((-(x + 17.513 - 18) + 18) * 0.073529) - 0.3)^4 - 0.1) * 5.3
// y = (-(x - 0.487) * 0.073529 - ((-(x - 0.487) * 0.073529) - 0.3)^4 - 0.1) * 5.3
//...
//approximation #2
//((17.0 * (temp - 0.0812)) * 0.073529 - pow((((17.0 * (temp - 0.0812)) * 0.073529) - 0.3), 4.0) - 0.1) * 0.2 * width
//((temp * 1.247993 - 0.101306) - pow(temp * 1.247993 - 0.401306, 4.0) - 0.1) * 0.2 * width