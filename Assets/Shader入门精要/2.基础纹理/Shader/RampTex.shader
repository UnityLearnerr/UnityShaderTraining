Shader "ShaderBook/TextureBase/RampTex"
{
    Properties
    {
        _RampTex ("RampTex", 2D) = "white" {}
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(1, 255)) = 8
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
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {  
                float4 vertex : SV_POSITION;
                //float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldVertex : TEXCOORD2;
                float3 worldViewDir : TEXCOORD3;
                float3 worldLightDir: TEXCOORD4;
            };

            sampler2D _RampTex;
            fixed4 _RampTex_ST;
            fixed4 _Specular;
            fixed _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _RampTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldVertex = UnityObjectToWorldDir(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldVertex));
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldVertex ));
                fixed halfLambert = 0.5 + 0.5 * dot(worldLightDir, i.worldNormal);
                fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed4 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert));
                fixed3 diffuse = diffuseColor * _LightColor0.rgb;
                fixed3 h = normalize(worldViewDir + worldLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb *  pow(saturate(dot(h, worldNormal)), _Gloss);
                return fixed4(ambientColor + diffuse + specular, 1);
            }
            ENDCG
        }
    }
}
