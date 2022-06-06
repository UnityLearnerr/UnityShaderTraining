Shader "Unlit/Vice_Code"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Grow("Grow", Float) = 0.0
        _GrowMin("GrowMin", Range(0, 1)) = 0.0
        _GrowMax("GrowMax", Range(0, 1.5)) = 0.0
        _EndMin("EndMin", Range(0, 1)) = 0.0
        _EndMax("EndMax", Range(0, 1.5)) = 0.0
        _Offset("Offset", Float) = -5
        _Scale("Scale", Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="AlphaTest" }
        LOD 100
        Cull Off

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
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Grow = 0.0;
            float _GrowMin = 0.0;
            float _GrowMax = 0.0;
            float _EndMin = 0.0;
            float _EndMax = 0.0;
            float _Offset = 2.0;
            float _Scale = 0.0;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float weight_expand = smoothstep(_GrowMin, _GrowMax, v.uv.y - _Grow);
                float weight_end = smoothstep(_EndMin, _EndMax, v.uv.y);
                float weight = max(weight_expand, weight_end);
                float4 normal = normalize(v.normal);
                float4 expand = _Offset * weight * normal * 0.1;
                float4 scale = weight * _Scale * normal;
                float4 offset = expand + scale;
                v.vertex += offset;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                clip(1.0 - (i.uv.y - _Grow));
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
