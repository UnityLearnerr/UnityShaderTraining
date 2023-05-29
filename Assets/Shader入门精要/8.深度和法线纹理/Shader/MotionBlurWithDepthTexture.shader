Shader "Unlit/MotionBlurWithDepthTexture"
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
            half4 _MainTex_Texel_Size;
            float4 _MainTex_ST;
            sampler2D _CameraDepthTexture;
            float4x4 _CurProj2WorldMatrix; 
            float4x4 _PreWorld2ProjMatrix;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv;
                o.uv.zw = v.uv;
                #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_Texel_Size.y < 0)
                {
                    o.uv.z = 1 - o.uv.z;
                }
                #endif
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
