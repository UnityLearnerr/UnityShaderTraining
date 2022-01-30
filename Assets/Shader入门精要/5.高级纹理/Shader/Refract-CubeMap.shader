Shader "ShaderBook/HighTexture/Refract-CubeMap"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _CubeMap("CubeMap", Cube) = "_SkyBox" {} 
        _refractColor("refractColor", Color) = (1, 1, 1, 1)
        _refractAmount("ReflecAmount", Range(0, 1)) = 0.5
        _RefractRatio("RefractRatio", Range(0, 1))  = 0.5
        
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
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed3 normal : TEXCOORD0;
                fixed3 viewDir : TEXCOORD1;
                fixed3 refract : TEXCOORD2;
                fixed3 worldVertex : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            fixed4 _Diffuse;
            samplerCUBE _CubeMap;
            fixed4 refractColor;
            fixed _refractAmount;
            fixed3 _refractColor;
            fixed _RefractRatio;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldVertex = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = UnityWorldSpaceViewDir(o.worldVertex);
                o.refract = refract(-o.viewDir,o.normal, _RefractRatio);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 normal = normalize(i.normal);
                fixed3 viewDir = normalize(i.viewDir);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldVertex));	
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * saturate(dot(normal, lightDir));
                fixed3 refractColor = texCUBE(_CubeMap, i.refract).rgb *  _refractColor.rgb;
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldVertex);
                fixed3 col = lerp(diffuse, refractColor, _refractAmount) * atten + ambient;
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
