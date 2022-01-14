Shader "ShaderBook/DiffuseFrag-HalfLambert"
{
    Properties
    {
        _Diffuce ("Diffuce", Color) = (1,1,1,1)
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 world_normal : TEXCOORD0;
            };

            float4 _Diffuce;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.world_normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 diffuce = _Diffuce.rgb * _LightColor0.rgb * (0.5 * dot(lightDir, i.world_normal) + 0.5);
                return float4(diffuce + ambient, 1 );
            }
            ENDCG
        }
    }
}
