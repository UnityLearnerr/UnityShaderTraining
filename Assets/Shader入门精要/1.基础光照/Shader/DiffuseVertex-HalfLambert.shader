Shader "ShaderBook/LightingBase/DiffuseVertex-HalfLambert"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            float4 _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 lightWorldDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 diffuse = _Diffuse * _LightColor0.rgb * (0.5 * dot(lightWorldDir, v.normal) + 0.5);
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                o.color = float4(ambient + diffuse , 1);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               return i.color;
            }
            ENDCG
        }
    }
}
