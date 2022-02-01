Shader "ShaderBook/Anim/ImageSquenceAnim"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _Horizontal("Horizontal", Float) = 8
        _Vertical("Vertical", Float) = 8
        _TimeSpeed("TimeSpeed", Range(0, 100)) = 40
    }
    SubShader
    {
        Tags { "RenderType"="Transparent"  "Queue"="Transparent" }
        Pass
        {
           	ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed _Horizontal;
            fixed _Vertical;
            fixed _TimeSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed time = _Time.y * _TimeSpeed;
                fixed vOffset = floor(time / _Horizontal);
                fixed hOffset = floor(time - vOffset * _Horizontal);
                fixed2 uv = fixed2(i.uv.x / _Horizontal, -i.uv.y / _Vertical);
                fixed2 uvOffset = fixed2(hOffset / _Horizontal, -vOffset / _Vertical);
                uv += uvOffset;
                fixed4 col = tex2D(_MainTex, uv);
                return col;
            }
            ENDCG
        }
    }
}
