Shader "ShaderBook/Transparent/AlphaBlendOption-SoftAdditive"
{
    Properties
    {
        _MainColor ("MainColor", Color) = (1, 1, 1, 1)
        _AlphaScale("AlphaScale", Range(0, 1)) = 0.5 
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100

        Pass
        {
            ZWrite Off
            Blend OneMinusDstColor One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            fixed4 _MainColor;
            fixed _AlphaScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _MainColor;
                col.a = _AlphaScale;
                return col;
            }
            ENDCG
        }
    }
}
