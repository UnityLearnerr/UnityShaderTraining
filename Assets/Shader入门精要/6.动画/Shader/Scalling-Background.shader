Shader "ShaderBook/Anim/Scalling-Background"
{
    Properties
    {
        _FrontTex ("FrontTex", 2D) = "white" {}
        _BackTex ("BackGround", 2D) = "white" {}
        _FrontSpeed("FrontSpeed", Range(1, 200)) = 10
        _BackSpeed("BackGround", Range(1, 200)) = 10
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

            sampler2D _FrontTex;
            float4 _FrontTex_ST;
            sampler2D _BackTex;
            float4 _BackTex_ST;
            fixed _FrontSpeed;
            fixed _BackSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _FrontTex) + fixed2(frac(_Time.y / _FrontSpeed ), 0);
                o.uv.zw = TRANSFORM_TEX(v.uv, _BackTex) + fixed2(frac(_Time.y / _BackSpeed ), 0);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 frontCol = tex2D(_FrontTex, i.uv.xy);
                fixed4 backCol = tex2D(_BackTex, i.uv.zw);
                fixed3 col = (1 - frontCol.a) * backCol.rgb + frontCol.rgb * frontCol.a;
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
