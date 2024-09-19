#ifndef GET_BUFFER_INCLUDED
#define GET_BUFFER_INCLUDED

// #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Deferred.hlsl"

// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"

// TEXTURE2D_X(_CameraDepthTexture);
TEXTURE2D(_GBuffer0);
// TEXTURE2D_X_HALF(_GBuffer0);
// TEXTURE2D_X_HALF(_GBuffer1);
// TEXTURE2D_X_HALF(_GBuffer2);

// #if _RENDER_PASS_ENABLED

// #define GBUFFER0 0
// #define GBUFFER1 1
// #define GBUFFER2 2
// #define GBUFFER3 3

// FRAMEBUFFER_INPUT_HALF(GBUFFER0);
// FRAMEBUFFER_INPUT_HALF(GBUFFER1);
// FRAMEBUFFER_INPUT_HALF(GBUFFER2);
// FRAMEBUFFER_INPUT_FLOAT(GBUFFER3);
// #if OUTPUT_SHADOWMASK
//     #define GBUFFER4 4
//     FRAMEBUFFER_INPUT_HALF(GBUFFER4);
// #endif
// #else
//     #ifdef GBUFFER_OPTIONAL_SLOT_1
//         TEXTURE2D_X_HALF(_GBuffer4);
//     #endif
// #endif

// #ifndef GBUFFER0
//     #define GBUFFER0 0
// #endif
// FRAMEBUFFER_INPUT_HALF(GBUFFER0);



SamplerState my_point_clamp_sampler;

void GetGBuffer0_half(half3 positionHCS, out half4 buffer0)
{    
    
    half4 gbuffer0 = SAMPLE_TEXTURE2D_LOD(_GBuffer0, my_point_clamp_sampler, positionHCS,0);
    // half4 gbuffer0 = LOAD_FRAMEBUFFER_INPUT(GBUFFER0, positionHCS);

    buffer0 = gbuffer0;
}


#endif // GET_BUFFER_INCLUDED