Shader "ShaderBook/DiffuseFrag-Lambert"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1 , 1)
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
                float3 normal :NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed3 world_normal : TEXCOORD0;
            };

            fixed4 _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.world_normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 lightWorldDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(lightWorldDir, i.world_normal));
                return fixed4(diffuse + ambient, 1);
            }
            ENDCG
        }
    }
}
