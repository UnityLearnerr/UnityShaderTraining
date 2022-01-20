Shader "ShaderBook/TextureBase/NormalTex-TangentSpace"
{
    Properties
    {
        _MainTexture("MainTexture", 2D) = "White"{}
        _BumpMap("BumpMap", 2D)  = "White"{}
        _BumpScale("BumpScale", Range(0,5)) = 1
        _Gloss("Gloss", Range(1,255)) = 1
        _Specular("Specular", Color) = (1, 1, 1 , 1)
       
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
            //#pragma multi_compile UNITY_NO_DXT5nm
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D  _MainTexture;
            float4 _MainTexture_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            float _Gloss;
            float4 _Specular;
           

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
                float3 tangentViewDir : TEXCOORD1;
                float3 tangentLightDir : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTexture); // (tex.xy * name##_ST.xy + name##_ST.zw)
                o.uv.zw = TRANSFORM_TEX(v.uv, _BumpMap);
                TANGENT_SPACE_ROTATION;
                o.tangentViewDir = mul(rotation,ObjSpaceViewDir(v.vertex));
                o.tangentLightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 unpackedNormal = UnpackNormal(packedNormal);
                unpackedNormal.xy *= _BumpScale;
                unpackedNormal.z = sqrt(1 - dot(unpackedNormal.xy, unpackedNormal.xy));
                fixed4 texColor = tex2D(_MainTexture, i.uv.xy);
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * texColor;
                //fixed3 diffuse = _LightColor0.rgb * texColor.rgb * (0.5 + 0.5 * (dot(i.tangentLightDir, unpackedNormal)));
                fixed3 diffuse = _LightColor0.rgb * texColor.rgb * max(0, dot(unpackedNormal, i.tangentLightDir));
                fixed3 h = normalize(normalize(i.tangentViewDir) + normalize(i.tangentLightDir)); // 这里的i.tangentViewDir和i.tangentLightDir必须归一化，否则计算半角向量不正确
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(unpackedNormal, h)), _Gloss);
                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }
    }
}
