// Made with Amplify Shader Editor v1.9.3.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AmplifySurface"
{
	Properties
	{
		_TessValue( "Max Tessellation", Range( 1, 32 ) ) = 15
		_TessMin( "Tess Min Distance", Float ) = 10
		_TessMax( "Tess Max Distance", Float ) = 25
		_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_TextureTiling("TextureTiling", Vector) = (1,1,0,0)
		_TextureOffset("TextureOffset", Vector) = (1,1,0,0)
		_NormalStrength("NormalStrength", Float) = 0.5
		_Emmision("Emmision", 2D) = "black" {}
		_AmbientOcclusion("AmbientOcclusion", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Normal;
		uniform float2 _TextureTiling;
		uniform float2 _TextureOffset;
		float4 _Normal_TexelSize;
		uniform float _NormalStrength;
		uniform sampler2D _Albedo;
		uniform sampler2D _Emmision;
		uniform sampler2D _AmbientOcclusion;
		uniform float _TessValue;
		uniform float _TessMin;
		uniform float _TessMax;


		float3 CombineSamplesSharp128_g3( float S0, float S1, float S2, float Strength )
		{
			{
			    float3 va = float3( 0.13, 0, ( S1 - S0 ) * Strength );
			    float3 vb = float3( 0, 0.13, ( S2 - S0 ) * Strength );
			    return normalize( cross( va, vb ) );
			}
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, _TessMin, _TessMax, _TessValue );
		}

		void vertexDataFunc( inout appdata_full v )
		{
		}

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float localCalculateUVsSharp110_g3 = ( 0.0 );
			float2 uv_TexCoord20 = i.uv_texcoord * _TextureTiling + _TextureOffset;
			float2 temp_output_85_0_g3 = uv_TexCoord20;
			float2 UV110_g3 = temp_output_85_0_g3;
			float4 TexelSize110_g3 = _Normal_TexelSize;
			float2 UV0110_g3 = float2( 0,0 );
			float2 UV1110_g3 = float2( 0,0 );
			float2 UV2110_g3 = float2( 0,0 );
			{
			{
			    UV110_g3.y -= TexelSize110_g3.y * 0.5;
			    UV0110_g3 = UV110_g3;
			    UV1110_g3 = UV110_g3 + float2( TexelSize110_g3.x, 0 );
			    UV2110_g3 = UV110_g3 + float2( 0, TexelSize110_g3.y );
			}
			}
			float4 break134_g3 = tex2D( _Normal, UV0110_g3 );
			float S0128_g3 = break134_g3.r;
			float4 break136_g3 = tex2D( _Normal, UV1110_g3 );
			float S1128_g3 = break136_g3.r;
			float4 break138_g3 = tex2D( _Normal, UV2110_g3 );
			float S2128_g3 = break138_g3.r;
			float temp_output_91_0_g3 = _NormalStrength;
			float Strength128_g3 = temp_output_91_0_g3;
			float3 localCombineSamplesSharp128_g3 = CombineSamplesSharp128_g3( S0128_g3 , S1128_g3 , S2128_g3 , Strength128_g3 );
			o.Normal = localCombineSamplesSharp128_g3;
			o.Albedo = tex2D( _Albedo, uv_TexCoord20 ).rgb;
			o.Emission = tex2D( _Emmision, uv_TexCoord20 ).rgb;
			o.Occlusion = tex2D( _AmbientOcclusion, uv_TexCoord20 ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19302
Node;AmplifyShaderEditor.Vector2Node;21;-1132.185,-170.4812;Inherit;False;Property;_TextureTiling;TextureTiling;7;0;Create;True;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;23;-1124.985,-30.4811;Inherit;False;Property;_TextureOffset;TextureOffset;8;0;Create;True;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;20;-905.0385,-99.19435;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;-940.1252,279.1399;Inherit;False;Property;_NormalStrength;NormalStrength;9;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;17;-971.6547,92.97593;Inherit;True;Property;_Normal;Normal;6;0;Create;True;0;0;0;False;0;False;None;None;False;bump;LockedToTexture2D;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;26;-629.4866,91.21985;Inherit;False;Normal From Texture;-1;;3;9728ee98a55193249b513caf9a0f1676;13,149,0,147,0,143,0,141,0,139,0,151,0,137,0,153,0,159,0,157,0,155,0,135,0,108,0;4;87;SAMPLER2D;0;False;85;FLOAT2;0,0;False;74;SAMPLERSTATE;0;False;91;FLOAT;1.5;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;12;-636.7729,-105.948;Inherit;True;Property;_Albedo;Albedo;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;30;-632.4902,247.5276;Inherit;True;Property;_Emmision;Emmision;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;LockedToTexture2D;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;33;-634.4664,441.5591;Inherit;True;Property;_AmbientOcclusion;AmbientOcclusion;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;34;-632.3865,654.7589;Inherit;True;Property;_Height;Height;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;11;4.159936,3.119952;Float;False;True;-1;6;ASEMaterialInspector;0;0;StandardSpecular;AmplifySurface;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;0;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;0;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;20;0;21;0
WireConnection;20;1;23;0
WireConnection;26;87;17;0
WireConnection;26;85;20;0
WireConnection;26;91;27;0
WireConnection;12;1;20;0
WireConnection;30;1;20;0
WireConnection;33;1;20;0
WireConnection;34;1;20;0
WireConnection;11;0;12;0
WireConnection;11;1;26;40
WireConnection;11;2;30;0
WireConnection;11;5;33;1
ASEEND*/
//CHKSM=6112CA4F85E4C71D6A828EA234227BB1ADF3F76C