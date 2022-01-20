Shader "ShaderBook/TextureBase/NormalTex-WorldSpace"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpTex("BumpTex", 2D) = "bump" {}
        _BumpScale("BumpScale", Range(0, 50)) = 1
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Closs", Range(0, 255)) = 1
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
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 tangentToWorld1 : TEXCOORD1;
                float4 tangentToWorld2 : TEXCOORD2;
                float4 tangentToWorld3 : TEXCOORD3;
            };

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            sampler2D _BumpTex;
            fixed4 _BumpTex_ST;
            float _BumpScale;
            fixed4 _Specular;
            fixed _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _BumpTex);
                fixed3 worldVertex = UnityObjectToWorldDir(v.vertex);
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                o.tangentToWorld1 = fixed4(worldTangent.x, worldBinormal.x, worldNormal.x, worldVertex.x);
                o.tangentToWorld2 = fixed4(worldTangent.y, worldBinormal.y, worldNormal.y, worldVertex.y);
                o.tangentToWorld3 = fixed4(worldTangent.z, worldBinormal.z, worldNormal.z, worldVertex.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, i.uv.xy);
                fixed4 packedNormal = tex2D(_BumpTex, i.uv.zw);
                fixed3 unpackedNormal = UnpackNormal(packedNormal);
                unpackedNormal.xy *= _BumpScale;
                unpackedNormal.z = sqrt(1 - dot(unpackedNormal.xy, unpackedNormal.xy));
                fixed3 worldNormal = normalize(fixed3(dot(i.tangentToWorld1.xyz, unpackedNormal),dot(i.tangentToWorld2.xyz, unpackedNormal),dot(i.tangentToWorld3.xyz, unpackedNormal)));
                fixed3 worldVertex = fixed3(i.tangentToWorld1.z, i.tangentToWorld2.z, i.tangentToWorld3.z); 
                fixed3 viewWorldDir = normalize(UnityWorldSpaceViewDir(worldVertex));
                fixed3 lightWorldDir = normalize(UnityWorldSpaceLightDir(worldVertex));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * texColor.rgb;
                fixed3 diffuse = texColor.rgb * _LightColor0.rgb * saturate(dot(lightWorldDir, worldNormal));
                fixed3 h = normalize(viewWorldDir + lightWorldDir);
                fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(h, worldNormal)), _Gloss);
                return fixed4(diffuse + specular + ambient, 1);
            }
            ENDCG
        }
    }
}
