Shader "ShaderBook/Transparent/AlphaBlend-ZTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaScale("AlphaScale", Range(0, 1)) = 0.5
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8, 255)) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Pass
        {
            ZWrite On
            ColorMask 0
        }

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL; 
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir: TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 worldNormal : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AlphaScale;
            fixed3 _Specular;
            fixed _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                fixed3 worldVertex = UnityObjectToWorldDir(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.lightDir = UnityWorldSpaceLightDir(worldVertex);
                o.viewDir = UnityWorldSpaceViewDir(worldVertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 lightDir = normalize(i.lightDir);
                fixed3 viewDir = normalize(i.viewDir);
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed4 col = tex2D(_MainTex, i.uv);
                col.a *= _AlphaScale;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * col.rgb;
                fixed3 diffuce = _LightColor0.rgb *  col.rgb * saturate(dot(i.lightDir, i.worldNormal));
                fixed3 halfDir = normalize(i.lightDir + i.viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);
                return fixed4(diffuce + ambient + specular, col.a);
            }
            ENDCG
        }
    }
}
