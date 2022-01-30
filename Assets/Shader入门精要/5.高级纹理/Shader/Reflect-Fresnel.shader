Shader "ShaderBook/HighTexture/Reflect-Fresnel"
{
    Properties
    {
        _CubeMap ("CubeMap", Cube) = "_SkyBox" {}
        _Diffuse("Diffuse", Color) = (1, 1, 1, 1)
        _ReflectColor("ReflectColor", Color) = (1, 1, 1, 1 ) 
        _FresnelFactory("FresnelFactory", Range(0, 1)) = 0.5
        _Atten("Atten", Range(0, 1)) = 0.5
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
                fixed4 worldVertex : TEXCOORD0;
                fixed3 normal : TEXCOORD1;
                fixed3 lightDir : TEXCOORD2;
                fixed3 viewDir : TEXCOORD3;
                fixed3 reflect : TEXCOORD4;
            };

            samplerCUBE _CubeMap;
            fixed4 _Diffuse;
            fixed4 _ReflectColor;
            fixed _FresnelFactory;
            fixed _Atten;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldVertex = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.lightDir = UnityWorldSpaceLightDir(o.worldVertex);
                o.viewDir = UnityWorldSpaceViewDir(o.worldVertex);
                o.reflect = refract(-o.viewDir, o.normal, 0);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 normal = normalize(i.normal);
                fixed3 lightDir = normalize(i.lightDir);
                fixed3 viewDir = normalize(i.viewDir);
                fixed3 reflect = normalize(i.reflect);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 diffuse = _Diffuse.rgb * saturate(dot(lightDir, normal));
                fixed3 reflectColor = texCUBE(_CubeMap, reflect).rgb * _ReflectColor;
                fixed fresnel = _FresnelFactory + (1 - _FresnelFactory) * pow(saturate(dot(normal, viewDir)), 5);
                fixed3 col = lerp(diffuse, reflectColor, fresnel) * _Atten + ambient;
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}
