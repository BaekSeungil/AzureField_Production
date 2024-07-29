Shader "Shader Graphs/MeshDepthBlending"
{
    Properties
    {
        _TestValue ("TestValue", Float) = 0
        _TestValue2 ("TestValue2", Range(0, 1)) = 0
        [NoScaleOffset]_BaseTextureMap ("BaseTextureMap", 2D) = "white" { }
        _Smoothness ("Smoothness", Float) = 0
        [Normal][NoScaleOffset]_NormalMap ("NormalMap", 2D) = "bump" { }
        [HDR]_Emission ("Emission", Color) = (0, 0, 0, 0)
        _Color ("Color", Color) = (0, 0, 0, 0)
        _Offset ("Offset", Range(-10, 1)) = 1
        _Intensity ("Intensity", Float) = 0.5
        _MainTex ("MainTex", 2D) = "white" { }
        _Noise ("Noise", 2D) = "white" { }
        [HideInInspector]_WorkflowMode ("_WorkflowMode", Float) = 0
        [HideInInspector]_CastShadows ("_CastShadows", Float) = 0
        [HideInInspector]_ReceiveShadows ("_ReceiveShadows", Float) = 1
        [HideInInspector]_Surface ("_Surface", Float) = 0
        [HideInInspector]_Blend ("_Blend", Float) = 0
        [HideInInspector]_AlphaClip ("_AlphaClip", Float) = 0
        [HideInInspector]_BlendModePreserveSpecular ("_BlendModePreserveSpecular", Float) = 1
        [HideInInspector]_SrcBlend ("_SrcBlend", Float) = 1
        [HideInInspector]_DstBlend ("_DstBlend", Float) = 0
        [HideInInspector][ToggleUI]_ZWrite ("_ZWrite", Float) = 1
        [HideInInspector]_ZWriteControl ("_ZWriteControl", Float) = 1
        [HideInInspector]_ZTest ("_ZTest", Float) = 4
        [HideInInspector]_Cull ("_Cull", Float) = 2
        [HideInInspector]_AlphaToMask ("_AlphaToMask", Float) = 0
        [HideInInspector]_QueueOffset ("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl ("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" { }
        [HideInInspector][NoScaleOffset]unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" { }
        [HideInInspector][NoScaleOffset]unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" { }
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque"
            "UniversalMaterialType" = "Lit" "Queue" = "Geometry" "DisableBatching" = "False"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "UniversalLitSubTarget" }
        Pass
        {
            Name "Universal Forward"
            Tags { "LightMode" = "UniversalForward" }
            
            // Render State
            Cull [_Cull]
            Blend [_SrcBlend] [_DstBlend]
            ZTest [_ZTest]
            ZWrite [_ZWrite]
            AlphaToMask [_AlphaToMask]
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma instancing_options renderinglayer
            #pragma vertex vert
            #pragma fragment frag
            
            // Keywords
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SHADOWS_SOFT_LOW
            #pragma multi_compile_fragment _ _SHADOWS_SOFT_MEDIUM
            #pragma multi_compile_fragment _ _SHADOWS_SOFT_HIGH
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _FORWARD_PLUS
            #pragma multi_compile _ EVALUATE_SH_VERTEX
            #pragma multi_compile _ EVALUATE_SH_MIXED
            #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _SPECULAR_SETUP
            #pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_SHADOW_COORD
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            #define _FOG_FRAGMENT 1
            #define REQUIRE_DEPTH_TEXTURE
            #define REQUIRE_OPAQUE_TEXTURE
            #define GBUFFER0 0
            

            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            //Gbuffer
            #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Deferred.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                float3 normalWS;
                float4 tangentWS;
                float4 texCoord0;
                #if defined(LIGHTMAP_ON)
                    float2 staticLightmapUV;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                    float2 dynamicLightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                    float3 sh;
                #endif
                float4 fogFactorAndVertexLight;
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    float4 shadowCoord;
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                float3 TangentSpaceNormal;
                float3 WorldSpacePosition;
                float4 ScreenPosition;
                float2 NDCPosition;
                float2 PixelPosition;
                float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if defined(LIGHTMAP_ON)
                    float2 staticLightmapUV : INTERP0;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                    float2 dynamicLightmapUV : INTERP1;
                #endif
                #if !defined(LIGHTMAP_ON)
                    float3 sh : INTERP2;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    float4 shadowCoord : INTERP3;
                #endif
                float4 tangentWS : INTERP4;
                float4 texCoord0 : INTERP5;
                float4 fogFactorAndVertexLight : INTERP6;
                float3 positionWS : INTERP7;
                float3 normalWS : INTERP8;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.staticLightmapUV;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.dynamicLightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                    output.sh = input.sh;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.shadowCoord;
                #endif
                output.tangentWS.xyzw = input.tangentWS;
                output.texCoord0.xyzw = input.texCoord0;
                output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
                output.positionWS.xyz = input.positionWS;
                output.normalWS.xyz = input.normalWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.staticLightmapUV;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.dynamicLightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                    output.sh = input.sh;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.shadowCoord;
                #endif
                output.tangentWS = input.tangentWS.xyzw;
                output.texCoord0 = input.texCoord0.xyzw;
                output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
                output.positionWS = input.positionWS.xyz;
                output.normalWS = input.normalWS.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _Offset;
                float _Intensity;
                float4 _MainTex_TexelSize;
                float4 _MainTex_ST;
                float4 _Noise_TexelSize;
                float4 _Noise_ST;
                float4 _BaseTextureMap_TexelSize;
                float _Smoothness;
                float4 _NormalMap_TexelSize;
                float4 _Emission;
                float _TestValue;
                float _TestValue2;
                float4 _Color;
            CBUFFER_END
            
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_Noise);
            SAMPLER(sampler_Noise);
            TEXTURE2D(_BaseTextureMap);
            SAMPLER(sampler_BaseTextureMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            
            //Gbuffer
                    
            SamplerState my_point_clamp_sampler;
            TEXTURE2D_X_HALF(_GBuffer0);
            TEXTURE2D_X_HALF(_GBuffer1);
            TEXTURE2D_X_HALF(_GBuffer2);
            #if _RENDER_PASS_ENABLED

                #define GBUFFER0 0
                #define GBUFFER1 1
                #define GBUFFER2 2
                #define GBUFFER3 3

                FRAMEBUFFER_INPUT_HALF(GBUFFER0);
                FRAMEBUFFER_INPUT_HALF(GBUFFER1);
                FRAMEBUFFER_INPUT_HALF(GBUFFER2);
                FRAMEBUFFER_INPUT_FLOAT(GBUFFER3);
                #if OUTPUT_SHADOWMASK
                #define GBUFFER4 4
                FRAMEBUFFER_INPUT_HALF(GBUFFER4);
                #endif
            #else
                #ifdef GBUFFER_OPTIONAL_SLOT_1
                TEXTURE2D_X_HALF(_GBuffer4);
                #endif
            #endif
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
                int _ObjectId;
                int _PassValue;
            #endif
            
            // Graph Functions

            
            
            void Unity_SceneColor_float(float4 UV, out float3 Out)
            {
                Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
            }
            
            void Unity_ColorspaceConversion_RGB_Linear_float(float3 In, out float3 Out)
            {
                float3 linearRGBLo = In / 12.92;
                float3 linearRGBHi = pow(max(abs((In + 0.055) / 1.055), 1.192092896e-07), float3(2.4, 2.4, 2.4));
                Out = float3(In <= 0.04045) ? linearRGBLo : linearRGBHi;
            }
            
            void Unity_Blend_Overlay_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
            {
                float3 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                float3 result2 = 2.0 * Base * Blend;
                float3 zeroOrOne = step(Base, 0.5);
                Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                Out = lerp(Base, Out, Opacity);
            }
            
            void Unity_OneMinus_float(float In, out float Out)
            {
                Out = 1 - In;
            }
            
            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }
            
            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
            {
                Out = smoothstep(Edge1, Edge2, In);
            }
            
            void Unity_Saturate_float(float In, out float Out)
            {
                Out = saturate(In);
            }
            
            float Unity_SceneDepth_Eye(float4 UV)
            {
                if (unity_OrthoParams.w == 1.0)
                {
                    return LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                }
                else
                {
                    return LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
            }
            
            struct  Bindings_DepthBlend
            {
                float4 ScreenPosition;
                float2 NDCPosition;

            };
            
            void SG_DepthBlend(float _offsetValue, Bindings_DepthBlend IN, out float Output)
            {
                float OneMinusOffset = 1 - _offsetValue;
                float SceneDepth;


                SceneDepth = Unity_SceneDepth_Eye(float4(IN.NDCPosition.xy, 0, 0));

                float4 ScreenPosition = IN.ScreenPosition;

                float SubtractAOffset = ScreenPosition.a - _offsetValue;
                float SubtractDepthSubtractA = SceneDepth - SubtractAOffset;

                float SmoothstepResult = smoothstep(0, OneMinusOffset, 1 - SubtractDepthSubtractA);
                float SaturateResult = saturate(1 - SmoothstepResult);
                Output = SaturateResult;
            }
            
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }
            
            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Step_float(float Edge, float In, out float Out)
            {
                Out = step(Edge, In);
            }
            
            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }
            
            void Unity_Blend_Exclusion_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
            {
                Out = Blend + Base - (2.0 * Blend * Base);
                Out = lerp(Base, Out, Opacity);
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                {
                    return output;
                }
                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float3 Specular;
                float Smoothness;
                float Occlusion;
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                float4 posHCS = TransformWorldToHClip(IN.WorldSpacePosition);

                
                float3 screenUV = posHCS.xyw;
                #if UNITY_UV_STARTS_AT_TOP
                screenUV.xy = screenUV.xy * float2(0.5, -0.5) + 0.5 * screenUV.z;
                #else
                screenUV.xy = screenUV.xy * 0.5 + 0.5 * screenUV.z;
                #endif


                // float2 screenUV = IN.ScreenPosition * (1 - _ScreenParams.zw);
                float2 screen_uv = screenUV.xy / screenUV.z;
                
                #if defined(SUPPORTS_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
                    float2 undistorted_screen_uv = screen_uv;
                    UNITY_BRANCH if (_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
                    {
                        screen_uv = input.positionCS.xy * _ScreenSize.zw;
                    }
                #endif

                // screenUV.xy = (screenUV.xy * (1,-1)+ (0.5,0.5)) / screenUV.z ;
                //Gbuffer
                #if _RENDER_PASS_ENABLED
                float d        = LOAD_FRAMEBUFFER_INPUT(GBUFFER3, input.positionCS.xy).x;
                half4 gbuffer0 = LOAD_FRAMEBUFFER_INPUT(GBUFFER0, input.positionCS.xy);
                half4 gbuffer1 = LOAD_FRAMEBUFFER_INPUT(GBUFFER1, input.positionCS.xy);
                half4 gbuffer2 = LOAD_FRAMEBUFFER_INPUT(GBUFFER2, input.positionCS.xy);
                #if defined(_DEFERRED_MIXED_LIGHTING)
                shadowMask = LOAD_FRAMEBUFFER_INPUT(GBUFFER4, input.positionCS.xy);
                #endif
                #else
                // Using SAMPLE_TEXTURE2D is faster than using LOAD_TEXTURE2D on iOS platforms (5% faster shader).
                // Possible reason: HLSLcc upcasts Load() operation to float, which doesn't happen for Sample()?
                float d        = SAMPLE_TEXTURE2D_X_LOD(_CameraDepthTexture, my_point_clamp_sampler, screenUV, 0).x; // raw depth value has UNITY_REVERSED_Z applied on most platforms.
                half4 gbuffer0 = SAMPLE_TEXTURE2D_X_LOD(_GBuffer0, my_point_clamp_sampler, screen_uv,0);
                half4 gbuffer1 = SAMPLE_TEXTURE2D_X_LOD(_GBuffer1, my_point_clamp_sampler, screenUV, 0);
                half4 gbuffer2 = SAMPLE_TEXTURE2D_X_LOD(_GBuffer2, my_point_clamp_sampler, screenUV, 0);
                #if defined(_DEFERRED_MIXED_LIGHTING)
                shadowMask = SAMPLE_TEXTURE2D_X_LOD(MERGE_NAME(_, GBUFFER_SHADOWMASK), my_point_clamp_sampler, screenUV, 0);
                #endif
                #endif



                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D _Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseTextureMap);
                float4 _RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Out_0_Texture2D.tex, _Out_0_Texture2D.samplerstate, _Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                float _R_4_Float = _RGBA_0_Vector4.r;
                float _G_5_Float = _RGBA_0_Vector4.g;
                float _B_6_Float = _RGBA_0_Vector4.b;
                float _A_7_Float = _RGBA_0_Vector4.a;
                // float3 _SceneColor_643b485131d643a38ad44c03f18a3ca1_Out_1_Vector3;
                

                // Unity_SceneColor_float(float4(IN.NDCPosition.xy, 0, 0), _SceneColor_643b485131d643a38ad44c03f18a3ca1_Out_1_Vector3);

                UnityTexture2D _Property_86228470646f47f3aec6674f42394cd6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseTextureMap);
                float4 _SampleTexture2D_1e99cbb5eeb34fdc975b366e72d5d7dc_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_86228470646f47f3aec6674f42394cd6_Out_0_Texture2D.tex, _Property_86228470646f47f3aec6674f42394cd6_Out_0_Texture2D.samplerstate, _Property_86228470646f47f3aec6674f42394cd6_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                float _SampleTexture2D_1e99cbb5eeb34fdc975b366e72d5d7dc_R_4_Float = _SampleTexture2D_1e99cbb5eeb34fdc975b366e72d5d7dc_RGBA_0_Vector4.r;
                float _SampleTexture2D_1e99cbb5eeb34fdc975b366e72d5d7dc_G_5_Float = _SampleTexture2D_1e99cbb5eeb34fdc975b366e72d5d7dc_RGBA_0_Vector4.g;
                float _SampleTexture2D_1e99cbb5eeb34fdc975b366e72d5d7dc_B_6_Float = _SampleTexture2D_1e99cbb5eeb34fdc975b366e72d5d7dc_RGBA_0_Vector4.b;
                float _SampleTexture2D_1e99cbb5eeb34fdc975b366e72d5d7dc_A_7_Float = _SampleTexture2D_1e99cbb5eeb34fdc975b366e72d5d7dc_RGBA_0_Vector4.a;
                float3 _SceneColor_643b485131d643a38ad44c03f18a3ca1_Out_1_Vector3;
                Unity_SceneColor_float(float4(IN.NDCPosition.xy, 0, 0), _SceneColor_643b485131d643a38ad44c03f18a3ca1_Out_1_Vector3);
                //injection
                float3 _ColorspaceConversion_01b33c98e8b94ab8b157addcb9345a61_Out_1_Vector3 = gbuffer0;
                // Unity_ColorspaceConversion_RGB_Linear_float(_SceneColor_643b485131d643a38ad44c03f18a3ca1_Out_1_Vector3, _ColorspaceConversion_01b33c98e8b94ab8b157addcb9345a61_Out_1_Vector3);
                float _Property_1eb3360d614f4c6a86cc9e1242feb80c_Out_0_Float = _TestValue;
                float _Property_ef59310ccd8f4df1964180c6a6b7c6a5_Out_0_Float = _Offset;
                Bindings_DepthBlend _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05;
                _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05.ScreenPosition = IN.ScreenPosition;
                _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05.NDCPosition = IN.NDCPosition;
                float _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05_Output_1_Float;
                SG_DepthBlend(_Property_ef59310ccd8f4df1964180c6a6b7c6a5_Out_0_Float, _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05, _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05_Output_1_Float);
                float _Saturate_88748fd1eed14f0399b9048076110dc8_Out_1_Float;
                Unity_Saturate_float(_DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05_Output_1_Float, _Saturate_88748fd1eed14f0399b9048076110dc8_Out_1_Float);
                float _Smoothstep_4b97c8184be64ef6a912b265ad809f32_Out_3_Float;
                Unity_Smoothstep_float(_Property_1eb3360d614f4c6a86cc9e1242feb80c_Out_0_Float, 0, _Saturate_88748fd1eed14f0399b9048076110dc8_Out_1_Float, _Smoothstep_4b97c8184be64ef6a912b265ad809f32_Out_3_Float);
                float _OneMinus_06f434becb3447c58890a540e95652d3_Out_1_Float;
                Unity_OneMinus_float(_Smoothstep_4b97c8184be64ef6a912b265ad809f32_Out_3_Float, _OneMinus_06f434becb3447c58890a540e95652d3_Out_1_Float);
                float _Smoothstep_264d4698a1b94e5cb961d995b7cea4ad_Out_3_Float;
                Unity_Smoothstep_float(1, 0.1, _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05_Output_1_Float, _Smoothstep_264d4698a1b94e5cb961d995b7cea4ad_Out_3_Float);
                float _Multiply_f348f6a56b14463da9d2d0314cfd1819_Out_2_Float;
                Unity_Multiply_float_float(_OneMinus_06f434becb3447c58890a540e95652d3_Out_1_Float, _Smoothstep_264d4698a1b94e5cb961d995b7cea4ad_Out_3_Float, _Multiply_f348f6a56b14463da9d2d0314cfd1819_Out_2_Float);
                float _Saturate_9b8e1c4120d240c6a4fe927bce0df1d2_Out_1_Float;
                Unity_Saturate_float(_Multiply_f348f6a56b14463da9d2d0314cfd1819_Out_2_Float, _Saturate_9b8e1c4120d240c6a4fe927bce0df1d2_Out_1_Float);
                float _Property_f06830109ba246d8a25bfbdad89a0bf7_Out_0_Float = _Intensity;
                UnityTexture2D _Property_c1230ab00a3e49cea999518db8aabf93_Out_0_Texture2D = UnityBuildTexture2DStruct(_Noise);
                float4 _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_c1230ab00a3e49cea999518db8aabf93_Out_0_Texture2D.tex, _Property_c1230ab00a3e49cea999518db8aabf93_Out_0_Texture2D.samplerstate, _Property_c1230ab00a3e49cea999518db8aabf93_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                float _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_R_4_Float = _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_RGBA_0_Vector4.r;
                float _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_G_5_Float = _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_RGBA_0_Vector4.g;
                float _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_B_6_Float = _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_RGBA_0_Vector4.b;
                float _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_A_7_Float = _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_RGBA_0_Vector4.a;
                float _Multiply_61f98b5488a2445fa62699145c81e641_Out_2_Float;
                Unity_Multiply_float_float(_Property_f06830109ba246d8a25bfbdad89a0bf7_Out_0_Float, _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_R_4_Float, _Multiply_61f98b5488a2445fa62699145c81e641_Out_2_Float);
                float _Power_21104c2ff04d4964945d94ceb523f06e_Out_2_Float;
                Unity_Power_float(_Saturate_9b8e1c4120d240c6a4fe927bce0df1d2_Out_1_Float, 2, _Power_21104c2ff04d4964945d94ceb523f06e_Out_2_Float);
                float _Lerp_270982ec8df14eb6accbb390db977565_Out_3_Float;
                Unity_Lerp_float(_Multiply_61f98b5488a2445fa62699145c81e641_Out_2_Float, _Saturate_9b8e1c4120d240c6a4fe927bce0df1d2_Out_1_Float, _Power_21104c2ff04d4964945d94ceb523f06e_Out_2_Float, _Lerp_270982ec8df14eb6accbb390db977565_Out_3_Float);
                float _Saturate_74458cd6941b4cbd9f22328d4d4bcc02_Out_1_Float;
                Unity_Saturate_float(_Lerp_270982ec8df14eb6accbb390db977565_Out_3_Float, _Saturate_74458cd6941b4cbd9f22328d4d4bcc02_Out_1_Float);
                float _Multiply_584a6e0a45664f7d8209e69fbe4ce0e6_Out_2_Float;
                Unity_Multiply_float_float(_Saturate_9b8e1c4120d240c6a4fe927bce0df1d2_Out_1_Float, _Saturate_74458cd6941b4cbd9f22328d4d4bcc02_Out_1_Float, _Multiply_584a6e0a45664f7d8209e69fbe4ce0e6_Out_2_Float);
                float3 _Lerp_2642d68316244ac59a404b46c289a091_Out_3_Vector3;
                Unity_Lerp_float3((_SampleTexture2D_1e99cbb5eeb34fdc975b366e72d5d7dc_RGBA_0_Vector4.xyz), _ColorspaceConversion_01b33c98e8b94ab8b157addcb9345a61_Out_1_Vector3, (_Multiply_584a6e0a45664f7d8209e69fbe4ce0e6_Out_2_Float.xxx), _Lerp_2642d68316244ac59a404b46c289a091_Out_3_Vector3);
                float _Step_bbd46c8e3dbb4e6197c735f87e692d8c_Out_2_Float;
                Unity_Step_float(_Property_1eb3360d614f4c6a86cc9e1242feb80c_Out_0_Float, _Saturate_88748fd1eed14f0399b9048076110dc8_Out_1_Float, _Step_bbd46c8e3dbb4e6197c735f87e692d8c_Out_2_Float);
                float _OneMinus_a52b7be957434d39b73167e2f4139cf6_Out_1_Float;
                Unity_OneMinus_float(_Step_bbd46c8e3dbb4e6197c735f87e692d8c_Out_2_Float, _OneMinus_a52b7be957434d39b73167e2f4139cf6_Out_1_Float);
                float _Saturate_cc229de25ae549b7830dc00bd4b12d24_Out_1_Float;
                Unity_Saturate_float(_OneMinus_a52b7be957434d39b73167e2f4139cf6_Out_1_Float, _Saturate_cc229de25ae549b7830dc00bd4b12d24_Out_1_Float);
                float3 _Multiply_ae8bc5715f344356bad18279603dcb15_Out_2_Vector3;
                Unity_Multiply_float3_float3(_ColorspaceConversion_01b33c98e8b94ab8b157addcb9345a61_Out_1_Vector3, (_Saturate_cc229de25ae549b7830dc00bd4b12d24_Out_1_Float.xxx), _Multiply_ae8bc5715f344356bad18279603dcb15_Out_2_Vector3);
                float _Property_6429c33ce74e4c929f7b30dbc2be25bb_Out_0_Float = _TestValue2;
                float3 _Blend_644a87250ec64c96ae15faf5ea1f9482_Out_2_Vector3;
                Unity_Blend_Exclusion_float3(_Lerp_2642d68316244ac59a404b46c289a091_Out_3_Vector3, _Multiply_ae8bc5715f344356bad18279603dcb15_Out_2_Vector3, _Blend_644a87250ec64c96ae15faf5ea1f9482_Out_2_Vector3, _Property_6429c33ce74e4c929f7b30dbc2be25bb_Out_0_Float);
                UnityTexture2D _Property_fe824f3a7f1f4c9e83250f7401f8561a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
                float4 _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fe824f3a7f1f4c9e83250f7401f8561a_Out_0_Texture2D.tex, _Property_fe824f3a7f1f4c9e83250f7401f8561a_Out_0_Texture2D.samplerstate, _Property_fe824f3a7f1f4c9e83250f7401f8561a_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4);
                float _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_R_4_Float = _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.r;
                float _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_G_5_Float = _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.g;
                float _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_B_6_Float = _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.b;
                float _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_A_7_Float = _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.a;
                float4 _Property_6f3587b64860490cb8175445f98bda28_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Emission) : _Emission;
                surface.BaseColor = _Blend_644a87250ec64c96ae15faf5ea1f9482_Out_2_Vector3;
                surface.NormalTS = (_SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.xyz);
                surface.Emission = (_Property_6f3587b64860490cb8175445f98bda28_Out_0_Vector4.xyz);
                surface.Metallic = 0;
                surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                surface.Smoothness = 0;
                surface.Occlusion = 1;
                surface.Alpha = 1;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
                #define VFX_SRP_ATTRIBUTES Attributes
                #define VFX_SRP_VARYINGS Varyings
                #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;
                
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    #if VFX_USE_GRAPH_VALUES
                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                    #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                    
                #endif
                
                
                
                
                
                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
                
                
                output.WorldSpacePosition = input.positionWS;
                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                
                #if UNITY_UV_STARTS_AT_TOP
                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                #else
                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                #endif
                
                output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
                output.NDCPosition.y = 1.0f - output.NDCPosition.y;
                
                output.uv0 = input.texCoord0;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign = IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags { "LightMode" = "UniversalGBuffer" }
            
            // Render State
            Cull [_Cull]
            Blend [_SrcBlend] [_DstBlend]
            ZTest [_ZTest]
            ZWrite [_ZWrite]
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma instancing_options renderinglayer
            #pragma vertex vert
            #pragma fragment frag
            
            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SHADOWS_SOFT_LOW
            #pragma multi_compile_fragment _ _SHADOWS_SOFT_MEDIUM
            #pragma multi_compile_fragment _ _SHADOWS_SOFT_HIGH
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
            #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _SPECULAR_SETUP
            #pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_SHADOW_COORD
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_GBUFFER
            #define _FOG_FRAGMENT 1
            #define REQUIRE_DEPTH_TEXTURE
            #define REQUIRE_OPAQUE_TEXTURE
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                float3 normalWS;
                float4 tangentWS;
                float4 texCoord0;
                #if defined(LIGHTMAP_ON)
                    float2 staticLightmapUV;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                    float2 dynamicLightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                    float3 sh;
                #endif
                float4 fogFactorAndVertexLight;
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    float4 shadowCoord;
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                float3 TangentSpaceNormal;
                float3 WorldSpacePosition;
                float4 ScreenPosition;
                float2 NDCPosition;
                float2 PixelPosition;
                float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if defined(LIGHTMAP_ON)
                    float2 staticLightmapUV : INTERP0;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                    float2 dynamicLightmapUV : INTERP1;
                #endif
                #if !defined(LIGHTMAP_ON)
                    float3 sh : INTERP2;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    float4 shadowCoord : INTERP3;
                #endif
                float4 tangentWS : INTERP4;
                float4 texCoord0 : INTERP5;
                float4 fogFactorAndVertexLight : INTERP6;
                float3 positionWS : INTERP7;
                float3 normalWS : INTERP8;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.staticLightmapUV;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.dynamicLightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                    output.sh = input.sh;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.shadowCoord;
                #endif
                output.tangentWS.xyzw = input.tangentWS;
                output.texCoord0.xyzw = input.texCoord0;
                output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
                output.positionWS.xyz = input.positionWS;
                output.normalWS.xyz = input.normalWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.staticLightmapUV;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.dynamicLightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                    output.sh = input.sh;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.shadowCoord;
                #endif
                output.tangentWS = input.tangentWS.xyzw;
                output.texCoord0 = input.texCoord0.xyzw;
                output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
                output.positionWS = input.positionWS.xyz;
                output.normalWS = input.normalWS.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _Offset;
                float _Intensity;
                float4 _MainTex_TexelSize;
                float4 _MainTex_ST;
                float4 _Noise_TexelSize;
                float4 _Noise_ST;
                float4 _BaseTextureMap_TexelSize;
                float _Smoothness;
                float4 _NormalMap_TexelSize;
                float4 _Emission;
                float _TestValue;
                float _TestValue2;
                float4 _Color;
            CBUFFER_END
            
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_Noise);
            SAMPLER(sampler_Noise);
            TEXTURE2D(_BaseTextureMap);
            SAMPLER(sampler_BaseTextureMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
                int _ObjectId;
                int _PassValue;
            #endif
            
            // Graph Functions
            
            void Unity_SceneColor_float(float4 UV, out float3 Out)
            {
                Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
            }
            
            void Unity_ColorspaceConversion_RGB_Linear_float(float3 In, out float3 Out)
            {
                float3 linearRGBLo = In / 12.92;
                float3 linearRGBHi = pow(max(abs((In + 0.055) / 1.055), 1.192092896e-07), float3(2.4, 2.4, 2.4));
                Out = float3(In <= 0.04045) ? linearRGBLo : linearRGBHi;
            }
            
            void Unity_Blend_Overlay_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
            {
                float3 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                float3 result2 = 2.0 * Base * Blend;
                float3 zeroOrOne = step(Base, 0.5);
                Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                Out = lerp(Base, Out, Opacity);
            }
            
            void Unity_OneMinus_float(float In, out float Out)
            {
                Out = 1 - In;
            }
            
            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
            {
                if (unity_OrthoParams.w == 1.0)
                {
                    Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                }
                else
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
            }
            
            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }
            
            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
            {
                Out = smoothstep(Edge1, Edge2, In);
            }
            
            void Unity_Saturate_float(float In, out float Out)
            {
                Out = saturate(In);
            }
            
            struct  Bindings_DepthBlend
            {
                float4 ScreenPosition;
                float2 NDCPosition;
            };
            
            void SG_DepthBlend(float _offset,  Bindings_DepthBlend IN, out float Output_1)
            {
                float _Property_f2e380a237aa409793fb4fc0f0a445f8_Out_0_Float = _offset;
                float _OneMinus_058e8d2f21f745c49268e2a91bd592fe_Out_1_Float;
                Unity_OneMinus_float(_Property_f2e380a237aa409793fb4fc0f0a445f8_Out_0_Float, _OneMinus_058e8d2f21f745c49268e2a91bd592fe_Out_1_Float);
                float _SceneDepth_78ab2c87be924f42b7d2c7c02d20403f_Out_1_Float;
                Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_78ab2c87be924f42b7d2c7c02d20403f_Out_1_Float);
                float4 _ScreenPosition_ef2ad6eba0414c8f869dbcc5c43d0fb3_Out_0_Vector4 = IN.ScreenPosition;
                float _Split_aa419de13dcc4ffba953bffe125d8a3c_R_1_Float = _ScreenPosition_ef2ad6eba0414c8f869dbcc5c43d0fb3_Out_0_Vector4[0];
                float _Split_aa419de13dcc4ffba953bffe125d8a3c_G_2_Float = _ScreenPosition_ef2ad6eba0414c8f869dbcc5c43d0fb3_Out_0_Vector4[1];
                float _Split_aa419de13dcc4ffba953bffe125d8a3c_B_3_Float = _ScreenPosition_ef2ad6eba0414c8f869dbcc5c43d0fb3_Out_0_Vector4[2];
                float _Split_aa419de13dcc4ffba953bffe125d8a3c_A_4_Float = _ScreenPosition_ef2ad6eba0414c8f869dbcc5c43d0fb3_Out_0_Vector4[3];
                float _Subtract_d1b8c990f00245248244bdaca0f02ad3_Out_2_Float;
                Unity_Subtract_float(_Split_aa419de13dcc4ffba953bffe125d8a3c_A_4_Float, _Property_f2e380a237aa409793fb4fc0f0a445f8_Out_0_Float, _Subtract_d1b8c990f00245248244bdaca0f02ad3_Out_2_Float);
                float _Subtract_5e31049675124b1da7a6c397290ad84b_Out_2_Float;
                Unity_Subtract_float(_SceneDepth_78ab2c87be924f42b7d2c7c02d20403f_Out_1_Float, _Subtract_d1b8c990f00245248244bdaca0f02ad3_Out_2_Float, _Subtract_5e31049675124b1da7a6c397290ad84b_Out_2_Float);
                float _OneMinus_ebdb0281a554474ea25e8c5b266431fd_Out_1_Float;
                Unity_OneMinus_float(_Subtract_5e31049675124b1da7a6c397290ad84b_Out_2_Float, _OneMinus_ebdb0281a554474ea25e8c5b266431fd_Out_1_Float);
                float _Smoothstep_523d5e98291543828064f74ff0e20c09_Out_3_Float;
                Unity_Smoothstep_float(0, _OneMinus_058e8d2f21f745c49268e2a91bd592fe_Out_1_Float, _OneMinus_ebdb0281a554474ea25e8c5b266431fd_Out_1_Float, _Smoothstep_523d5e98291543828064f74ff0e20c09_Out_3_Float);
                float _OneMinus_895313891d114162ada33aa9d6910214_Out_1_Float;
                Unity_OneMinus_float(_Smoothstep_523d5e98291543828064f74ff0e20c09_Out_3_Float, _OneMinus_895313891d114162ada33aa9d6910214_Out_1_Float);
                float _Saturate_b1dd144454b8449eb73366d594e7c5d0_Out_1_Float;
                Unity_Saturate_float(_OneMinus_895313891d114162ada33aa9d6910214_Out_1_Float, _Saturate_b1dd144454b8449eb73366d594e7c5d0_Out_1_Float);
                Output_1 = _Saturate_b1dd144454b8449eb73366d594e7c5d0_Out_1_Float;
            }
            
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }
            
            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Step_float(float Edge, float In, out float Out)
            {
                Out = step(Edge, In);
            }
            
            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }
            
            void Unity_Blend_Exclusion_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
            {
                Out = Blend + Base - (2.0 * Blend * Base);
                Out = lerp(Base, Out, Opacity);
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                {
                    return output;
                }
                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float3 Specular;
                float Smoothness;
                float Occlusion;
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D _Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseTextureMap);
                float4  _RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Out_0_Texture2D.tex, _Out_0_Texture2D.samplerstate, _Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                float  _R_4_Float =  _RGBA_0_Vector4.r;
                float  _G_5_Float =  _RGBA_0_Vector4.g;
                float  _B_6_Float =  _RGBA_0_Vector4.b;
                float  _A_7_Float =  _RGBA_0_Vector4.a;
                float3 _SceneColor_643b485131d643a38ad44c03f18a3ca1_Out_1_Vector3;
                Unity_SceneColor_float(float4(IN.NDCPosition.xy, 0, 0), _SceneColor_643b485131d643a38ad44c03f18a3ca1_Out_1_Vector3);
                float3 _ColorspaceConversion_01b33c98e8b94ab8b157addcb9345a61_Out_1_Vector3;
                Unity_ColorspaceConversion_RGB_Linear_float(_SceneColor_643b485131d643a38ad44c03f18a3ca1_Out_1_Vector3, _ColorspaceConversion_01b33c98e8b94ab8b157addcb9345a61_Out_1_Vector3);
                float4 _Property_ab7bb2b9294c40f09900ce2ebf5be048_Out_0_Vector4 = _Color;
                float _Split_8ffcbb1bd44b4e9ba5515b87e3e3ac03_R_1_Float = _Property_ab7bb2b9294c40f09900ce2ebf5be048_Out_0_Vector4[0];
                float _Split_8ffcbb1bd44b4e9ba5515b87e3e3ac03_G_2_Float = _Property_ab7bb2b9294c40f09900ce2ebf5be048_Out_0_Vector4[1];
                float _Split_8ffcbb1bd44b4e9ba5515b87e3e3ac03_B_3_Float = _Property_ab7bb2b9294c40f09900ce2ebf5be048_Out_0_Vector4[2];
                float _Split_8ffcbb1bd44b4e9ba5515b87e3e3ac03_A_4_Float = _Property_ab7bb2b9294c40f09900ce2ebf5be048_Out_0_Vector4[3];
                float3 _Blend_b7ec46c3b5a943a0ac4fbc19b6aed7a1_Out_2_Vector3;
                Unity_Blend_Overlay_float3(_ColorspaceConversion_01b33c98e8b94ab8b157addcb9345a61_Out_1_Vector3, (_Property_ab7bb2b9294c40f09900ce2ebf5be048_Out_0_Vector4.xyz), _Blend_b7ec46c3b5a943a0ac4fbc19b6aed7a1_Out_2_Vector3, _Split_8ffcbb1bd44b4e9ba5515b87e3e3ac03_A_4_Float);
                float _Property_1eb3360d614f4c6a86cc9e1242feb80c_Out_0_Float = _TestValue;
                float _Property_ef59310ccd8f4df1964180c6a6b7c6a5_Out_0_Float = _Offset;
                 Bindings_DepthBlend _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05;
                _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05.ScreenPosition = IN.ScreenPosition;
                _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05.NDCPosition = IN.NDCPosition;
                float _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05_Output_1_Float;
                SG_DepthBlend(_Property_ef59310ccd8f4df1964180c6a6b7c6a5_Out_0_Float, _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05, _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05_Output_1_Float);
                float _Saturate_88748fd1eed14f0399b9048076110dc8_Out_1_Float;
                Unity_Saturate_float(_DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05_Output_1_Float, _Saturate_88748fd1eed14f0399b9048076110dc8_Out_1_Float);
                float _Smoothstep_4b97c8184be64ef6a912b265ad809f32_Out_3_Float;
                Unity_Smoothstep_float(_Property_1eb3360d614f4c6a86cc9e1242feb80c_Out_0_Float, 0, _Saturate_88748fd1eed14f0399b9048076110dc8_Out_1_Float, _Smoothstep_4b97c8184be64ef6a912b265ad809f32_Out_3_Float);
                float _OneMinus_06f434becb3447c58890a540e95652d3_Out_1_Float;
                Unity_OneMinus_float(_Smoothstep_4b97c8184be64ef6a912b265ad809f32_Out_3_Float, _OneMinus_06f434becb3447c58890a540e95652d3_Out_1_Float);
                float _Smoothstep_264d4698a1b94e5cb961d995b7cea4ad_Out_3_Float;
                Unity_Smoothstep_float(1, 0.1, _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05_Output_1_Float, _Smoothstep_264d4698a1b94e5cb961d995b7cea4ad_Out_3_Float);
                float _Multiply_f348f6a56b14463da9d2d0314cfd1819_Out_2_Float;
                Unity_Multiply_float_float(_OneMinus_06f434becb3447c58890a540e95652d3_Out_1_Float, _Smoothstep_264d4698a1b94e5cb961d995b7cea4ad_Out_3_Float, _Multiply_f348f6a56b14463da9d2d0314cfd1819_Out_2_Float);
                float _Saturate_9b8e1c4120d240c6a4fe927bce0df1d2_Out_1_Float;
                Unity_Saturate_float(_Multiply_f348f6a56b14463da9d2d0314cfd1819_Out_2_Float, _Saturate_9b8e1c4120d240c6a4fe927bce0df1d2_Out_1_Float);
                float _Property_f06830109ba246d8a25bfbdad89a0bf7_Out_0_Float = _Intensity;
                UnityTexture2D _Property_c1230ab00a3e49cea999518db8aabf93_Out_0_Texture2D = UnityBuildTexture2DStruct(_Noise);
                float4 _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_c1230ab00a3e49cea999518db8aabf93_Out_0_Texture2D.tex, _Property_c1230ab00a3e49cea999518db8aabf93_Out_0_Texture2D.samplerstate, _Property_c1230ab00a3e49cea999518db8aabf93_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                float _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_R_4_Float = _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_RGBA_0_Vector4.r;
                float _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_G_5_Float = _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_RGBA_0_Vector4.g;
                float _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_B_6_Float = _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_RGBA_0_Vector4.b;
                float _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_A_7_Float = _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_RGBA_0_Vector4.a;
                float _Multiply_61f98b5488a2445fa62699145c81e641_Out_2_Float;
                Unity_Multiply_float_float(_Property_f06830109ba246d8a25bfbdad89a0bf7_Out_0_Float, _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_R_4_Float, _Multiply_61f98b5488a2445fa62699145c81e641_Out_2_Float);
                float _Power_21104c2ff04d4964945d94ceb523f06e_Out_2_Float;
                Unity_Power_float(_Saturate_9b8e1c4120d240c6a4fe927bce0df1d2_Out_1_Float, 2, _Power_21104c2ff04d4964945d94ceb523f06e_Out_2_Float);
                float _Lerp_270982ec8df14eb6accbb390db977565_Out_3_Float;
                Unity_Lerp_float(_Multiply_61f98b5488a2445fa62699145c81e641_Out_2_Float, _Saturate_9b8e1c4120d240c6a4fe927bce0df1d2_Out_1_Float, _Power_21104c2ff04d4964945d94ceb523f06e_Out_2_Float, _Lerp_270982ec8df14eb6accbb390db977565_Out_3_Float);
                float _Saturate_74458cd6941b4cbd9f22328d4d4bcc02_Out_1_Float;
                Unity_Saturate_float(_Lerp_270982ec8df14eb6accbb390db977565_Out_3_Float, _Saturate_74458cd6941b4cbd9f22328d4d4bcc02_Out_1_Float);
                float _Multiply_584a6e0a45664f7d8209e69fbe4ce0e6_Out_2_Float;
                Unity_Multiply_float_float(_Saturate_9b8e1c4120d240c6a4fe927bce0df1d2_Out_1_Float, _Saturate_74458cd6941b4cbd9f22328d4d4bcc02_Out_1_Float, _Multiply_584a6e0a45664f7d8209e69fbe4ce0e6_Out_2_Float);
                float3 _Lerp_2642d68316244ac59a404b46c289a091_Out_3_Vector3;
                Unity_Lerp_float3(( _RGBA_0_Vector4.xyz), _Blend_b7ec46c3b5a943a0ac4fbc19b6aed7a1_Out_2_Vector3, (_Multiply_584a6e0a45664f7d8209e69fbe4ce0e6_Out_2_Float.xxx), _Lerp_2642d68316244ac59a404b46c289a091_Out_3_Vector3);
                float _Step_bbd46c8e3dbb4e6197c735f87e692d8c_Out_2_Float;
                Unity_Step_float(_Property_1eb3360d614f4c6a86cc9e1242feb80c_Out_0_Float, _Saturate_88748fd1eed14f0399b9048076110dc8_Out_1_Float, _Step_bbd46c8e3dbb4e6197c735f87e692d8c_Out_2_Float);
                float _OneMinus_a52b7be957434d39b73167e2f4139cf6_Out_1_Float;
                Unity_OneMinus_float(_Step_bbd46c8e3dbb4e6197c735f87e692d8c_Out_2_Float, _OneMinus_a52b7be957434d39b73167e2f4139cf6_Out_1_Float);
                float _Saturate_cc229de25ae549b7830dc00bd4b12d24_Out_1_Float;
                Unity_Saturate_float(_OneMinus_a52b7be957434d39b73167e2f4139cf6_Out_1_Float, _Saturate_cc229de25ae549b7830dc00bd4b12d24_Out_1_Float);
                float3 _Multiply_ae8bc5715f344356bad18279603dcb15_Out_2_Vector3;
                Unity_Multiply_float3_float3(_ColorspaceConversion_01b33c98e8b94ab8b157addcb9345a61_Out_1_Vector3, (_Saturate_cc229de25ae549b7830dc00bd4b12d24_Out_1_Float.xxx), _Multiply_ae8bc5715f344356bad18279603dcb15_Out_2_Vector3);
                float _Property_6429c33ce74e4c929f7b30dbc2be25bb_Out_0_Float = _TestValue2;
                float3 _Blend_644a87250ec64c96ae15faf5ea1f9482_Out_2_Vector3;
                Unity_Blend_Exclusion_float3(_Lerp_2642d68316244ac59a404b46c289a091_Out_3_Vector3, _Multiply_ae8bc5715f344356bad18279603dcb15_Out_2_Vector3, _Blend_644a87250ec64c96ae15faf5ea1f9482_Out_2_Vector3, _Property_6429c33ce74e4c929f7b30dbc2be25bb_Out_0_Float);
                UnityTexture2D _Property_fe824f3a7f1f4c9e83250f7401f8561a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
                float4 _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fe824f3a7f1f4c9e83250f7401f8561a_Out_0_Texture2D.tex, _Property_fe824f3a7f1f4c9e83250f7401f8561a_Out_0_Texture2D.samplerstate, _Property_fe824f3a7f1f4c9e83250f7401f8561a_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4);
                float _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_R_4_Float = _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.r;
                float _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_G_5_Float = _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.g;
                float _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_B_6_Float = _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.b;
                float _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_A_7_Float = _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.a;
                float4 _Property_6f3587b64860490cb8175445f98bda28_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Emission) : _Emission;
                surface.BaseColor = _Blend_644a87250ec64c96ae15faf5ea1f9482_Out_2_Vector3;
                surface.NormalTS = (_SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.xyz);
                surface.Emission = (_Property_6f3587b64860490cb8175445f98bda28_Out_0_Vector4.xyz);
                surface.Metallic = 0;
                surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                surface.Smoothness = 0;
                surface.Occlusion = 1;
                surface.Alpha = 1;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
                #define VFX_SRP_ATTRIBUTES Attributes
                #define VFX_SRP_VARYINGS Varyings
                #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;
                
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    #if VFX_USE_GRAPH_VALUES
                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                    #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                    
                #endif
                
                
                
                
                
                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
                
                
                output.WorldSpacePosition = input.positionWS;
                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                
                #if UNITY_UV_STARTS_AT_TOP
                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                #else
                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                #endif
                
                output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
                output.NDCPosition.y = 1.0f - output.NDCPosition.y;
                
                output.uv0 = input.texCoord0;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign = IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            
            // Render State
            Cull [_Cull]
            ZTest LEqual
            ZWrite On
            ColorMask 0
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
            
            // Keywords
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_NORMAL_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs { };
            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : INTERP0;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.normalWS.xyz = input.normalWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.normalWS = input.normalWS.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _Offset;
                float _Intensity;
                float4 _MainTex_TexelSize;
                float4 _MainTex_ST;
                float4 _Noise_TexelSize;
                float4 _Noise_ST;
                float4 _BaseTextureMap_TexelSize;
                float _Smoothness;
                float4 _NormalMap_TexelSize;
                float4 _Emission;
                float _TestValue;
                float _TestValue2;
                float4 _Color;
            CBUFFER_END
            
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_Noise);
            SAMPLER(sampler_Noise);
            TEXTURE2D(_BaseTextureMap);
            SAMPLER(sampler_BaseTextureMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
                int _ObjectId;
                int _PassValue;
            #endif
            
            // Graph Functions
            // GraphFunctions: <None>
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                {
                    return output;
                }
                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                surface.Alpha = 1;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
                #define VFX_SRP_ATTRIBUTES Attributes
                #define VFX_SRP_VARYINGS Varyings
                #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;
                
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    #if VFX_USE_GRAPH_VALUES
                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                    #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                    
                #endif
                
                
                
                
                
                
                
                
                #if UNITY_UV_STARTS_AT_TOP
                #else
                #endif
                
                
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign = IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }
            
            // Render State
            Cull [_Cull]
            ZTest LEqual
            ZWrite On
            ColorMask R
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
            
            // Keywords
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs { };
            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _Offset;
                float _Intensity;
                float4 _MainTex_TexelSize;
                float4 _MainTex_ST;
                float4 _Noise_TexelSize;
                float4 _Noise_ST;
                float4 _BaseTextureMap_TexelSize;
                float _Smoothness;
                float4 _NormalMap_TexelSize;
                float4 _Emission;
                float _TestValue;
                float _TestValue2;
                float4 _Color;
            CBUFFER_END
            
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_Noise);
            SAMPLER(sampler_Noise);
            TEXTURE2D(_BaseTextureMap);
            SAMPLER(sampler_BaseTextureMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
                int _ObjectId;
                int _PassValue;
            #endif
            
            // Graph Functions
            // GraphFunctions: <None>
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                {
                    return output;
                }
                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                surface.Alpha = 1;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
                #define VFX_SRP_ATTRIBUTES Attributes
                #define VFX_SRP_VARYINGS Varyings
                #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;
                
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    #if VFX_USE_GRAPH_VALUES
                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                    #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                    
                #endif
                
                
                
                
                
                
                
                
                #if UNITY_UV_STARTS_AT_TOP
                #else
                #endif
                
                
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign = IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags { "LightMode" = "DepthNormals" }
            
            // Render State
            Cull [_Cull]
            ZTest LEqual
            ZWrite On
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
            
            // Keywords
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALS
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS;
                float4 tangentWS;
                float4 texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                float3 TangentSpaceNormal;
                float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                float4 tangentWS : INTERP0;
                float4 texCoord0 : INTERP1;
                float3 normalWS : INTERP2;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.tangentWS.xyzw = input.tangentWS;
                output.texCoord0.xyzw = input.texCoord0;
                output.normalWS.xyz = input.normalWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.tangentWS = input.tangentWS.xyzw;
                output.texCoord0 = input.texCoord0.xyzw;
                output.normalWS = input.normalWS.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _Offset;
                float _Intensity;
                float4 _MainTex_TexelSize;
                float4 _MainTex_ST;
                float4 _Noise_TexelSize;
                float4 _Noise_ST;
                float4 _BaseTextureMap_TexelSize;
                float _Smoothness;
                float4 _NormalMap_TexelSize;
                float4 _Emission;
                float _TestValue;
                float _TestValue2;
                float4 _Color;
            CBUFFER_END
            
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_Noise);
            SAMPLER(sampler_Noise);
            TEXTURE2D(_BaseTextureMap);
            SAMPLER(sampler_BaseTextureMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
                int _ObjectId;
                int _PassValue;
            #endif
            
            // Graph Functions
            // GraphFunctions: <None>
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                {
                    return output;
                }
                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float3 NormalTS;
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D _Property_fe824f3a7f1f4c9e83250f7401f8561a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
                float4 _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_fe824f3a7f1f4c9e83250f7401f8561a_Out_0_Texture2D.tex, _Property_fe824f3a7f1f4c9e83250f7401f8561a_Out_0_Texture2D.samplerstate, _Property_fe824f3a7f1f4c9e83250f7401f8561a_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4);
                float _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_R_4_Float = _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.r;
                float _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_G_5_Float = _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.g;
                float _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_B_6_Float = _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.b;
                float _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_A_7_Float = _SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.a;
                surface.NormalTS = (_SampleTexture2D_0115a21315da46d3a4d7b8dd7c5c3d7a_RGBA_0_Vector4.xyz);
                surface.Alpha = 1;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
                #define VFX_SRP_ATTRIBUTES Attributes
                #define VFX_SRP_VARYINGS Varyings
                #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;
                
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    #if VFX_USE_GRAPH_VALUES
                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                    #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                    
                #endif
                
                
                
                
                
                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
                
                
                
                #if UNITY_UV_STARTS_AT_TOP
                #else
                #endif
                
                
                output.uv0 = input.texCoord0;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign = IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags { "LightMode" = "Meta" }
            
            // Render State
            Cull Off
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag
            
            // Keywords
            #pragma shader_feature _ EDITOR_VISUALIZATION
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD1
            #define VARYINGS_NEED_TEXCOORD2
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
            #define _FOG_FRAGMENT 1
            #define REQUIRE_DEPTH_TEXTURE
            #define REQUIRE_OPAQUE_TEXTURE
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                float4 texCoord0;
                float4 texCoord1;
                float4 texCoord2;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                float3 WorldSpacePosition;
                float4 ScreenPosition;
                float2 NDCPosition;
                float2 PixelPosition;
                float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                float4 texCoord0 : INTERP0;
                float4 texCoord1 : INTERP1;
                float4 texCoord2 : INTERP2;
                float3 positionWS : INTERP3;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.texCoord0.xyzw = input.texCoord0;
                output.texCoord1.xyzw = input.texCoord1;
                output.texCoord2.xyzw = input.texCoord2;
                output.positionWS.xyz = input.positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.texCoord0 = input.texCoord0.xyzw;
                output.texCoord1 = input.texCoord1.xyzw;
                output.texCoord2 = input.texCoord2.xyzw;
                output.positionWS = input.positionWS.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _Offset;
                float _Intensity;
                float4 _MainTex_TexelSize;
                float4 _MainTex_ST;
                float4 _Noise_TexelSize;
                float4 _Noise_ST;
                float4 _BaseTextureMap_TexelSize;
                float _Smoothness;
                float4 _NormalMap_TexelSize;
                float4 _Emission;
                float _TestValue;
                float _TestValue2;
                float4 _Color;
            CBUFFER_END
            
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_Noise);
            SAMPLER(sampler_Noise);
            TEXTURE2D(_BaseTextureMap);
            SAMPLER(sampler_BaseTextureMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
                int _ObjectId;
                int _PassValue;
            #endif
            
            // Graph Functions
            
            void Unity_SceneColor_float(float4 UV, out float3 Out)
            {
                Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
            }
            
            void Unity_ColorspaceConversion_RGB_Linear_float(float3 In, out float3 Out)
            {
                float3 linearRGBLo = In / 12.92;
                float3 linearRGBHi = pow(max(abs((In + 0.055) / 1.055), 1.192092896e-07), float3(2.4, 2.4, 2.4));
                Out = float3(In <= 0.04045) ? linearRGBLo : linearRGBHi;
            }
            
            void Unity_Blend_Overlay_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
            {
                float3 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                float3 result2 = 2.0 * Base * Blend;
                float3 zeroOrOne = step(Base, 0.5);
                Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                Out = lerp(Base, Out, Opacity);
            }
            
            void Unity_OneMinus_float(float In, out float Out)
            {
                Out = 1 - In;
            }
            
            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
            {
                if (unity_OrthoParams.w == 1.0)
                {
                    Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
                }
                else
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
            }
            
            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }
            
            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
            {
                Out = smoothstep(Edge1, Edge2, In);
            }
            
            void Unity_Saturate_float(float In, out float Out)
            {
                Out = saturate(In);
            }
            
            struct  Bindings_DepthBlend
            {
                float4 ScreenPosition;
                float2 NDCPosition;
            };
            
            void SG_DepthBlend(float _offset,  Bindings_DepthBlend IN, out float Output_1)
            {
                float _Property_f2e380a237aa409793fb4fc0f0a445f8_Out_0_Float = _offset;
                float _OneMinus_058e8d2f21f745c49268e2a91bd592fe_Out_1_Float;
                Unity_OneMinus_float(_Property_f2e380a237aa409793fb4fc0f0a445f8_Out_0_Float, _OneMinus_058e8d2f21f745c49268e2a91bd592fe_Out_1_Float);
                float _SceneDepth_78ab2c87be924f42b7d2c7c02d20403f_Out_1_Float;
                Unity_SceneDepth_Eye_float(float4(IN.NDCPosition.xy, 0, 0), _SceneDepth_78ab2c87be924f42b7d2c7c02d20403f_Out_1_Float);
                float4 _ScreenPosition_ef2ad6eba0414c8f869dbcc5c43d0fb3_Out_0_Vector4 = IN.ScreenPosition;
                float _Split_aa419de13dcc4ffba953bffe125d8a3c_R_1_Float = _ScreenPosition_ef2ad6eba0414c8f869dbcc5c43d0fb3_Out_0_Vector4[0];
                float _Split_aa419de13dcc4ffba953bffe125d8a3c_G_2_Float = _ScreenPosition_ef2ad6eba0414c8f869dbcc5c43d0fb3_Out_0_Vector4[1];
                float _Split_aa419de13dcc4ffba953bffe125d8a3c_B_3_Float = _ScreenPosition_ef2ad6eba0414c8f869dbcc5c43d0fb3_Out_0_Vector4[2];
                float _Split_aa419de13dcc4ffba953bffe125d8a3c_A_4_Float = _ScreenPosition_ef2ad6eba0414c8f869dbcc5c43d0fb3_Out_0_Vector4[3];
                float _Subtract_d1b8c990f00245248244bdaca0f02ad3_Out_2_Float;
                Unity_Subtract_float(_Split_aa419de13dcc4ffba953bffe125d8a3c_A_4_Float, _Property_f2e380a237aa409793fb4fc0f0a445f8_Out_0_Float, _Subtract_d1b8c990f00245248244bdaca0f02ad3_Out_2_Float);
                float _Subtract_5e31049675124b1da7a6c397290ad84b_Out_2_Float;
                Unity_Subtract_float(_SceneDepth_78ab2c87be924f42b7d2c7c02d20403f_Out_1_Float, _Subtract_d1b8c990f00245248244bdaca0f02ad3_Out_2_Float, _Subtract_5e31049675124b1da7a6c397290ad84b_Out_2_Float);
                float _OneMinus_ebdb0281a554474ea25e8c5b266431fd_Out_1_Float;
                Unity_OneMinus_float(_Subtract_5e31049675124b1da7a6c397290ad84b_Out_2_Float, _OneMinus_ebdb0281a554474ea25e8c5b266431fd_Out_1_Float);
                float _Smoothstep_523d5e98291543828064f74ff0e20c09_Out_3_Float;
                Unity_Smoothstep_float(0, _OneMinus_058e8d2f21f745c49268e2a91bd592fe_Out_1_Float, _OneMinus_ebdb0281a554474ea25e8c5b266431fd_Out_1_Float, _Smoothstep_523d5e98291543828064f74ff0e20c09_Out_3_Float);
                float _OneMinus_895313891d114162ada33aa9d6910214_Out_1_Float;
                Unity_OneMinus_float(_Smoothstep_523d5e98291543828064f74ff0e20c09_Out_3_Float, _OneMinus_895313891d114162ada33aa9d6910214_Out_1_Float);
                float _Saturate_b1dd144454b8449eb73366d594e7c5d0_Out_1_Float;
                Unity_Saturate_float(_OneMinus_895313891d114162ada33aa9d6910214_Out_1_Float, _Saturate_b1dd144454b8449eb73366d594e7c5d0_Out_1_Float);
                Output_1 = _Saturate_b1dd144454b8449eb73366d594e7c5d0_Out_1_Float;
            }
            
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }
            
            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }
            
            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_Step_float(float Edge, float In, out float Out)
            {
                Out = step(Edge, In);
            }
            
            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }
            
            void Unity_Blend_Exclusion_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
            {
                Out = Blend + Base - (2.0 * Blend * Base);
                Out = lerp(Base, Out, Opacity);
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                {
                    return output;
                }
                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 Emission;
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D _Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseTextureMap);
                float4  _RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Out_0_Texture2D.tex, _Out_0_Texture2D.samplerstate, _Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                float  _R_4_Float =  _RGBA_0_Vector4.r;
                float  _G_5_Float =  _RGBA_0_Vector4.g;
                float  _B_6_Float =  _RGBA_0_Vector4.b;
                float  _A_7_Float =  _RGBA_0_Vector4.a;
                float3 _SceneColor_643b485131d643a38ad44c03f18a3ca1_Out_1_Vector3;
                Unity_SceneColor_float(float4(IN.NDCPosition.xy, 0, 0), _SceneColor_643b485131d643a38ad44c03f18a3ca1_Out_1_Vector3);
                float3 _ColorspaceConversion_01b33c98e8b94ab8b157addcb9345a61_Out_1_Vector3;
                Unity_ColorspaceConversion_RGB_Linear_float(_SceneColor_643b485131d643a38ad44c03f18a3ca1_Out_1_Vector3, _ColorspaceConversion_01b33c98e8b94ab8b157addcb9345a61_Out_1_Vector3);
                float4 _Property_ab7bb2b9294c40f09900ce2ebf5be048_Out_0_Vector4 = _Color;
                float _Split_8ffcbb1bd44b4e9ba5515b87e3e3ac03_R_1_Float = _Property_ab7bb2b9294c40f09900ce2ebf5be048_Out_0_Vector4[0];
                float _Split_8ffcbb1bd44b4e9ba5515b87e3e3ac03_G_2_Float = _Property_ab7bb2b9294c40f09900ce2ebf5be048_Out_0_Vector4[1];
                float _Split_8ffcbb1bd44b4e9ba5515b87e3e3ac03_B_3_Float = _Property_ab7bb2b9294c40f09900ce2ebf5be048_Out_0_Vector4[2];
                float _Split_8ffcbb1bd44b4e9ba5515b87e3e3ac03_A_4_Float = _Property_ab7bb2b9294c40f09900ce2ebf5be048_Out_0_Vector4[3];
                float3 _Blend_b7ec46c3b5a943a0ac4fbc19b6aed7a1_Out_2_Vector3;
                Unity_Blend_Overlay_float3(_ColorspaceConversion_01b33c98e8b94ab8b157addcb9345a61_Out_1_Vector3, (_Property_ab7bb2b9294c40f09900ce2ebf5be048_Out_0_Vector4.xyz), _Blend_b7ec46c3b5a943a0ac4fbc19b6aed7a1_Out_2_Vector3, _Split_8ffcbb1bd44b4e9ba5515b87e3e3ac03_A_4_Float);
                float _Property_1eb3360d614f4c6a86cc9e1242feb80c_Out_0_Float = _TestValue;
                float _Property_ef59310ccd8f4df1964180c6a6b7c6a5_Out_0_Float = _Offset;
                 Bindings_DepthBlend _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05;
                _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05.ScreenPosition = IN.ScreenPosition;
                _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05.NDCPosition = IN.NDCPosition;
                float _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05_Output_1_Float;
                SG_DepthBlend(_Property_ef59310ccd8f4df1964180c6a6b7c6a5_Out_0_Float, _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05, _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05_Output_1_Float);
                float _Saturate_88748fd1eed14f0399b9048076110dc8_Out_1_Float;
                Unity_Saturate_float(_DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05_Output_1_Float, _Saturate_88748fd1eed14f0399b9048076110dc8_Out_1_Float);
                float _Smoothstep_4b97c8184be64ef6a912b265ad809f32_Out_3_Float;
                Unity_Smoothstep_float(_Property_1eb3360d614f4c6a86cc9e1242feb80c_Out_0_Float, 0, _Saturate_88748fd1eed14f0399b9048076110dc8_Out_1_Float, _Smoothstep_4b97c8184be64ef6a912b265ad809f32_Out_3_Float);
                float _OneMinus_06f434becb3447c58890a540e95652d3_Out_1_Float;
                Unity_OneMinus_float(_Smoothstep_4b97c8184be64ef6a912b265ad809f32_Out_3_Float, _OneMinus_06f434becb3447c58890a540e95652d3_Out_1_Float);
                float _Smoothstep_264d4698a1b94e5cb961d995b7cea4ad_Out_3_Float;
                Unity_Smoothstep_float(1, 0.1, _DepthBlend_8c32ea8d3e4245c6bb0150e35f8f0f05_Output_1_Float, _Smoothstep_264d4698a1b94e5cb961d995b7cea4ad_Out_3_Float);
                float _Multiply_f348f6a56b14463da9d2d0314cfd1819_Out_2_Float;
                Unity_Multiply_float_float(_OneMinus_06f434becb3447c58890a540e95652d3_Out_1_Float, _Smoothstep_264d4698a1b94e5cb961d995b7cea4ad_Out_3_Float, _Multiply_f348f6a56b14463da9d2d0314cfd1819_Out_2_Float);
                float _Saturate_9b8e1c4120d240c6a4fe927bce0df1d2_Out_1_Float;
                Unity_Saturate_float(_Multiply_f348f6a56b14463da9d2d0314cfd1819_Out_2_Float, _Saturate_9b8e1c4120d240c6a4fe927bce0df1d2_Out_1_Float);
                float _Property_f06830109ba246d8a25bfbdad89a0bf7_Out_0_Float = _Intensity;
                UnityTexture2D _Property_c1230ab00a3e49cea999518db8aabf93_Out_0_Texture2D = UnityBuildTexture2DStruct(_Noise);
                float4 _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_c1230ab00a3e49cea999518db8aabf93_Out_0_Texture2D.tex, _Property_c1230ab00a3e49cea999518db8aabf93_Out_0_Texture2D.samplerstate, _Property_c1230ab00a3e49cea999518db8aabf93_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                float _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_R_4_Float = _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_RGBA_0_Vector4.r;
                float _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_G_5_Float = _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_RGBA_0_Vector4.g;
                float _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_B_6_Float = _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_RGBA_0_Vector4.b;
                float _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_A_7_Float = _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_RGBA_0_Vector4.a;
                float _Multiply_61f98b5488a2445fa62699145c81e641_Out_2_Float;
                Unity_Multiply_float_float(_Property_f06830109ba246d8a25bfbdad89a0bf7_Out_0_Float, _SampleTexture2D_b54f40474cc14bb1996ab7188d098a68_R_4_Float, _Multiply_61f98b5488a2445fa62699145c81e641_Out_2_Float);
                float _Power_21104c2ff04d4964945d94ceb523f06e_Out_2_Float;
                Unity_Power_float(_Saturate_9b8e1c4120d240c6a4fe927bce0df1d2_Out_1_Float, 2, _Power_21104c2ff04d4964945d94ceb523f06e_Out_2_Float);
                float _Lerp_270982ec8df14eb6accbb390db977565_Out_3_Float;
                Unity_Lerp_float(_Multiply_61f98b5488a2445fa62699145c81e641_Out_2_Float, _Saturate_9b8e1c4120d240c6a4fe927bce0df1d2_Out_1_Float, _Power_21104c2ff04d4964945d94ceb523f06e_Out_2_Float, _Lerp_270982ec8df14eb6accbb390db977565_Out_3_Float);
                float _Saturate_74458cd6941b4cbd9f22328d4d4bcc02_Out_1_Float;
                Unity_Saturate_float(_Lerp_270982ec8df14eb6accbb390db977565_Out_3_Float, _Saturate_74458cd6941b4cbd9f22328d4d4bcc02_Out_1_Float);
                float _Multiply_584a6e0a45664f7d8209e69fbe4ce0e6_Out_2_Float;
                Unity_Multiply_float_float(_Saturate_9b8e1c4120d240c6a4fe927bce0df1d2_Out_1_Float, _Saturate_74458cd6941b4cbd9f22328d4d4bcc02_Out_1_Float, _Multiply_584a6e0a45664f7d8209e69fbe4ce0e6_Out_2_Float);
                float3 _Lerp_2642d68316244ac59a404b46c289a091_Out_3_Vector3;
                Unity_Lerp_float3(( _RGBA_0_Vector4.xyz), _Blend_b7ec46c3b5a943a0ac4fbc19b6aed7a1_Out_2_Vector3, (_Multiply_584a6e0a45664f7d8209e69fbe4ce0e6_Out_2_Float.xxx), _Lerp_2642d68316244ac59a404b46c289a091_Out_3_Vector3);
                float _Step_bbd46c8e3dbb4e6197c735f87e692d8c_Out_2_Float;
                Unity_Step_float(_Property_1eb3360d614f4c6a86cc9e1242feb80c_Out_0_Float, _Saturate_88748fd1eed14f0399b9048076110dc8_Out_1_Float, _Step_bbd46c8e3dbb4e6197c735f87e692d8c_Out_2_Float);
                float _OneMinus_a52b7be957434d39b73167e2f4139cf6_Out_1_Float;
                Unity_OneMinus_float(_Step_bbd46c8e3dbb4e6197c735f87e692d8c_Out_2_Float, _OneMinus_a52b7be957434d39b73167e2f4139cf6_Out_1_Float);
                float _Saturate_cc229de25ae549b7830dc00bd4b12d24_Out_1_Float;
                Unity_Saturate_float(_OneMinus_a52b7be957434d39b73167e2f4139cf6_Out_1_Float, _Saturate_cc229de25ae549b7830dc00bd4b12d24_Out_1_Float);
                float3 _Multiply_ae8bc5715f344356bad18279603dcb15_Out_2_Vector3;
                Unity_Multiply_float3_float3(_ColorspaceConversion_01b33c98e8b94ab8b157addcb9345a61_Out_1_Vector3, (_Saturate_cc229de25ae549b7830dc00bd4b12d24_Out_1_Float.xxx), _Multiply_ae8bc5715f344356bad18279603dcb15_Out_2_Vector3);
                float _Property_6429c33ce74e4c929f7b30dbc2be25bb_Out_0_Float = _TestValue2;
                float3 _Blend_644a87250ec64c96ae15faf5ea1f9482_Out_2_Vector3;
                Unity_Blend_Exclusion_float3(_Lerp_2642d68316244ac59a404b46c289a091_Out_3_Vector3, _Multiply_ae8bc5715f344356bad18279603dcb15_Out_2_Vector3, _Blend_644a87250ec64c96ae15faf5ea1f9482_Out_2_Vector3, _Property_6429c33ce74e4c929f7b30dbc2be25bb_Out_0_Float);
                float4 _Property_6f3587b64860490cb8175445f98bda28_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Emission) : _Emission;
                surface.BaseColor = _Blend_644a87250ec64c96ae15faf5ea1f9482_Out_2_Vector3;
                surface.Emission = (_Property_6f3587b64860490cb8175445f98bda28_Out_0_Vector4.xyz);
                surface.Alpha = 1;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
                #define VFX_SRP_ATTRIBUTES Attributes
                #define VFX_SRP_VARYINGS Varyings
                #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;
                
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    #if VFX_USE_GRAPH_VALUES
                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                    #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                    
                #endif
                
                
                
                
                
                
                
                output.WorldSpacePosition = input.positionWS;
                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                
                #if UNITY_UV_STARTS_AT_TOP
                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                #else
                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                #endif
                
                output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
                output.NDCPosition.y = 1.0f - output.NDCPosition.y;
                
                output.uv0 = input.texCoord0;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign = IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags { "LightMode" = "SceneSelectionPass" }
            
            // Render State
            Cull Off
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag
            
            // Keywords
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            #define SCENESELECTIONPASS 1
            #define ALPHA_CLIP_THRESHOLD 1
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs { };
            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _Offset;
                float _Intensity;
                float4 _MainTex_TexelSize;
                float4 _MainTex_ST;
                float4 _Noise_TexelSize;
                float4 _Noise_ST;
                float4 _BaseTextureMap_TexelSize;
                float _Smoothness;
                float4 _NormalMap_TexelSize;
                float4 _Emission;
                float _TestValue;
                float _TestValue2;
                float4 _Color;
            CBUFFER_END
            
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_Noise);
            SAMPLER(sampler_Noise);
            TEXTURE2D(_BaseTextureMap);
            SAMPLER(sampler_BaseTextureMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
                int _ObjectId;
                int _PassValue;
            #endif
            
            // Graph Functions
            // GraphFunctions: <None>
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                {
                    return output;
                }
                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                surface.Alpha = 1;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
                #define VFX_SRP_ATTRIBUTES Attributes
                #define VFX_SRP_VARYINGS Varyings
                #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;
                
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    #if VFX_USE_GRAPH_VALUES
                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                    #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                    
                #endif
                
                
                
                
                
                
                
                
                #if UNITY_UV_STARTS_AT_TOP
                #else
                #endif
                
                
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign = IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags { "LightMode" = "Picking" }
            
            // Render State
            Cull [_Cull]
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag
            
            // Keywords
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            #define SCENEPICKINGPASS 1
            #define ALPHA_CLIP_THRESHOLD 1
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs { };
            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _Offset;
                float _Intensity;
                float4 _MainTex_TexelSize;
                float4 _MainTex_ST;
                float4 _Noise_TexelSize;
                float4 _Noise_ST;
                float4 _BaseTextureMap_TexelSize;
                float _Smoothness;
                float4 _NormalMap_TexelSize;
                float4 _Emission;
                float _TestValue;
                float _TestValue2;
                float4 _Color;
            CBUFFER_END
            
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_Noise);
            SAMPLER(sampler_Noise);
            TEXTURE2D(_BaseTextureMap);
            SAMPLER(sampler_BaseTextureMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
                int _ObjectId;
                int _PassValue;
            #endif
            
            // Graph Functions
            // GraphFunctions: <None>
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                {
                    return output;
                }
                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                surface.Alpha = 1;
                surface.AlphaClipThreshold = 0.5;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
                #define VFX_SRP_ATTRIBUTES Attributes
                #define VFX_SRP_VARYINGS Varyings
                #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;
                
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                    #if VFX_USE_GRAPH_VALUES
                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                    #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                    
                #endif
                
                
                
                
                
                
                
                
                #if UNITY_UV_STARTS_AT_TOP
                #else
                #endif
                
                
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign = IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
        }
    }

    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}