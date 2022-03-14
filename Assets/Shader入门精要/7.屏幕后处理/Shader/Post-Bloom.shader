Shader "ShaderBook/Post/Post-Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BloomTex("BloomTex", 2D) = "black" {}
        _LuminanceThreshold("Luminance Threshold", Float) = 0.5
        _BlurSize("BlurSize", Float) = 1
    }
    SubShader
    {
        CGINCLUDE

        #include "UnityCG.cginc"
        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        float4 _MainTex_ST;
        sampler2D _BloomTex;
        float _LuminanceThreshold;
        float _BlurSize;
        struct appdata
        {
            float4 vertex : POSITION;
            fixed4 uv : TEXCOORD0;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            half2 uv : TEXCOORD0;
        };

        struct bloom_v2f
        {
            float4 vertex : SV_POSITION;
            half4 uv : TEXCOORD0;
        };
        
        v2f extractBrightVert(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            return o;
        }
        fixed4 extractBrightFrag (v2f i) : SV_Target
        {
            fixed4 col = tex2D(_MainTex, i.uv);
            float value = clamp(col.r*0.2125 + col.g*0.7154 + col.b*0.0721 - _LuminanceThreshold, 0.0, 1.0);
            return fixed4(col.rgb * value,  1);
        }

        bloom_v2f BloomVert(appdata v)
        {
            bloom_v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
            o.uv.zw = TRANSFORM_TEX(v.uv, _MainTex);    
            #if UNITY_UV_STARTS_AT_TOP
                o.uv.w = 1 - o.uv.w;
            #endif
            return o;
        }

        fixed4 BloomFrag(bloom_v2f i) : SV_Target
        {
            fixed4 finalCol = tex2D(_MainTex, i.uv.xy) + tex2D(_BloomTex, i.uv.zw);
            return finalCol;
        }
        ENDCG

        ZTest Always 
        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex extractBrightVert
            #pragma fragment extractBrightFrag
            ENDCG
        }

        UsePass "ShaderBook/Post/GaussianBlur/GAUSSIAN_VERTICAL"

        UsePass "ShaderBook/Post/GaussianBlur/GAUSSIAN_HORIZONTAL"
       
        Pass
        {
            CGPROGRAM
            #pragma vertex BloomVert
            #pragma fragment BloomFrag
            ENDCG
        }
    }
    FallBack Off
}
