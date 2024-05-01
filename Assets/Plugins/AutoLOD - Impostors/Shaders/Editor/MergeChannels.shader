// Copyright (c) 2021-2022 Léo Chaumartin

Shader "AutoLOD/MergeChannels"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
        _DepthTex("Base (RGB)", 2D) = "white" {}
    }
        SubShader
        {
            Pass
            {
                CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                uniform sampler2D _MainTex;
                uniform sampler2D _DepthTex;
                uniform half4 _MainTex_TexelSize;

                struct input
                {
                    float4 pos : POSITION;
                    half2 uv : TEXCOORD0;
                };

                struct output
                {
                    float4 pos : SV_POSITION;
                    half2 uv : TEXCOORD0;
                };


                output vert(input i)
                {
                    output o;
                    o.pos = UnityObjectToClipPos(i.pos);
                    o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, i.uv);
                    // why do we need this? cause sometimes the image I get is flipped. see: http://docs.unity3d.com/Manual/SL-PlatformDifferences.html
                    #if UNITY_UV_STARTS_AT_TOP
                    if (_MainTex_TexelSize.y < 0)
                            o.uv.y = 1 - o.uv.y;
                    #endif

                    return o;
                }

                fixed4 frag(output o) : COLOR
                {
                    float4 color = tex2D(_MainTex, o.uv);
                    float depth = 1.0 - tex2D(_DepthTex, o.uv).r;
                    return float4(color.xyz, depth);
                }

                ENDCG
            }
        }
}