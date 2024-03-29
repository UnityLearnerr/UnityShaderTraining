﻿Shader "ShaderBook/LightingBase/HalfLambert-BlinnPhong-Frag"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color)  = (1, 1, 1, 1)
        _Gloss("Gloss", Range(1, 255))  = 1  
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
                float3 world_normal : TEXCOORD0;
                float3 world_vertex : TEXCOORD1;
            };
            
            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.world_normal = UnityObjectToWorldNormal(v.normal);
                o.world_vertex = UnityObjectToWorldDir(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // ambient
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // diffuce
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 diffuce = _Diffuse.rgb * _LightColor0.rgb * (0.5 + 0.5 * dot(i.world_normal, lightDir));
                // specular
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.world_vertex);
                float3 h = normalize(_WorldSpaceLightPos0.xyz + viewDir);
                float3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(h, i.world_normal)), _Gloss);
                return fixed4( ambient + diffuce + specular, 1);
            }
            ENDCG
        }
    }
}
