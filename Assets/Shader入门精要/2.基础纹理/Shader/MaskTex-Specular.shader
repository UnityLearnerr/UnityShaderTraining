Shader "ShaderBook/TextureBase/MaskTex-Specular"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpTex ("BumpTex", 2D)  = "white" {}
        _SpecularMask("SpecularMask", 2D) = "white" {}
        _BumpScale("Bump Scale", Float) = 1.0
        _SpecularScale("SpecularScale", Range(0, 20)) = 1
        _SpecularColor("SpecularColor", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8, 255)) = 8
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
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {  
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
                float2 maskUV : TEXCOORD1;
                float3 tangentViewDir : TEXCOORD2;
                float3 tangentLightDir : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpTex;
            float4 _BumpTex_ST;
            sampler2D _SpecularMask;
            float4 _SpecularMask_ST;
            fixed _Gloss;
            fixed _SpecularScale;
            float3 _SpecularColor;
            fixed _BumpScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _BumpTex);
                o.maskUV = TRANSFORM_TEX(v.uv, _SpecularMask);
                TANGENT_SPACE_ROTATION;
                o.tangentLightDir =normalize( mul(rotation, ObjSpaceLightDir(v.vertex)).xyz);
                o.tangentViewDir =normalize( mul(rotation, ObjSpaceViewDir(v.vertex)).xyz);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 unpackNormal = UnpackNormal(tex2D(_BumpTex, i.uv.xy));
                unpackNormal.xy *= _BumpScale;
                unpackNormal.z = sqrt(1 - saturate(dot(unpackNormal.xy, unpackNormal.xy)));
              
                fixed4 mainTexColor = tex2D(_MainTex, i.uv.xy);
                // ambient
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * mainTexColor;
                // diffuse
                fixed3 diffuse = _LightColor0.rgb * mainTexColor.rgb * max(0, dot(unpackNormal, i.tangentLightDir));
                // specular
                fixed4 specularMask = tex2D(_SpecularMask, i.maskUV);
                fixed3 h = normalize(i.tangentViewDir + i.tangentLightDir);
                fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(saturate(dot(h, unpackNormal)) , _Gloss) * specularMask.r;
                return fixed4(diffuse + specular + ambient, 1);
            }
            ENDCG
        }
    }
     FallBack "Specular"
}
