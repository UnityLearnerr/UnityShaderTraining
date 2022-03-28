Shader "ShaderBook/DepthNormalTex/MotionBlurWithDepth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZTest Off
            Cull Off
            ZTest Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_Texel;
            sampler2D _CameraDepthTexture;
            float4x4  _CurProj2World;
            float4x4 _PreWorld2Proj;
            float _BlurSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv;
                o.uv.zw = v.uv;
                #if UNITY_UV_START_AT_TOP
                    if (_MainTex_Texel.y < 0)
                    {
                         o.uv.z = 1- uv.z;
                    }
                #endif
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv.zw);
                float4 curClipPos = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
                float4 curWorldPosNoNormalize = mul(_CurProj2World, curClipPos);
                float4 curWorldPos = curWorldPosNoNormalize / curWorldPosNoNormalize.w;

                float4 preClipPosNoNoralize = mul(_PreWorld2Proj, curWorldPos);
                float4 preClipPos = preClipPosNoNoralize / preClipPosNoNoralize.w;
                
                float2 velocity = (curClipPos - preClipPos).xy / 2;
                float4 col = tex2D(_MainTex, i.uv.xy);
                float2 uv = i.uv.xy + velocity * _BlurSize;

                for (int it = 1;it < 3; it++, uv += velocity * _BlurSize)
                {
                    col += tex2D(_MainTex, uv);
                }
                col /= 3;
                return fixed4(col.rgb, 1);
            }
            ENDCG
        }
    }
}
