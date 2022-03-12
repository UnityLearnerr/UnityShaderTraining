Shader "Unlit/GaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        CGINCLUDE
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv[5] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            

            v2f vertVertical (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv[0] = v.uv;
                o.uv[1] = v.uv + fixed2(_MainTex_TexelSize.y * 1, 0.0);
                o.uv[2] = v.uv + fixed2(_MainTex_TexelSize.y * -1, 0.0);
                o.uv[3] = v.uv + fixed2(_MainTex_TexelSize.y * 2, 0.0);
                o.uv[4] = v.uv = fixed2(_MainTex_TexelSize.y * -2, 0.0);
                return o;
            }

            v2f vertHorizontal(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv[0] = v.uv;
                o.uv[1] = v.uv + fixed2(0.0, _MainTex_TexelSize.y * 1 );
                o.uv[2] = v.uv + fixed2(0.0, _MainTex_TexelSize.y * -1);
                o.uv[3] = v.uv + fixed2(0.0, _MainTex_TexelSize.y * 2);
                o.uv[4] = v.uv = fixed2(0.0, _MainTex_TexelSize.y * -2);
                return o;
            }

            fixed4 fragGaussian (v2f i) : SV_Target
            {
                float weight[3] = {0.4026, 0.2442, 0.0545};
                float3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];
                for (int it = 1; it<3; it++)
                {
                    sum += tex2D(_MainTex, i.uv[it*2 - 1]).rgb * weight[it];
                    sum += tex2D(_MainTex, i.uv[it*2]).rgb * weight[it];
                }
                return fixed4(sum, 1.0);
            }
        ENDCG

        ZTest Always Cull Off ZWrite Off
        Pass
        {   
            CGPROGRAM
            #pragma vertex vertVertical
            #pragma fragment fragGaussian
            ENDCG
        }

        Pass
        {   
            CGPROGRAM
            #pragma vertex vertHorizontal
            #pragma fragment fragGaussian
            ENDCG
        }
    }
}
