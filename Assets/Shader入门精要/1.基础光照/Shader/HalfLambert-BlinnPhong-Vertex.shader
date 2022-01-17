Shader "ShaderBook/HalfLambert-BlinnPhong-Vertex"
{
    Properties
    {
        _Deffuse("Deffuse", Color) = (1, 1, 1, 1)
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
                float4 color : Color;
            };
            
            float4 _Deffuse;
            float4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // diffuse
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Deffuse * (0.5 + 0.5 * dot(lightDir, worldNormal));
                // ambient
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // specular
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - UnityObjectToWorldDir(v.vertex).xyz);
                fixed3 h = normalize(_WorldSpaceLightPos0.xyz + viewDir);
                fixed3 specular =  _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(h, v.normal)), _Gloss);
                o.color = fixed4(diffuse + ambient + specular,  1);
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
