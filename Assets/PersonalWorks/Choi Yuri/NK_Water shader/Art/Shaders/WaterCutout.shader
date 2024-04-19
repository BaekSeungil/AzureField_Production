Shader "Universal Render Pipeline/NKStudioFX/Water/Cutout"
{
	SubShader
	{
		Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent-1" }
		ColorMask 0
		ZWrite On
		
		Pass 
		{
			Name "Depth mask"
			
			HLSLPROGRAM
			#pragma multi_compile_instancing

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			
			struct Attributes
            {
                float4 positionOS       : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
			
			#pragma vertex vert
            #pragma fragment frag

			Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
				
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
				
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);

                return output;
            }
			
			half4 frag() : SV_Target {
				return 0;
			}
			
			ENDHLSL
		}
	}
}