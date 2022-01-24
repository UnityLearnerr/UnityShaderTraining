Shader "ShaderBook/Tranparent/AlphaTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CutOff("CutOff", Range(0, 1)) = 0.5
        _Specular("Specular", Color)  = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8, 255))  = 10
    }
    SubShader
    {
        Tags { "RenderType"="TranparentCutout" "Quene" = "AlphaTest" }
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 lightDir : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _CutOff;
            fixed4 _Specular;
            fixed _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                o.lightDir = WorldSpaceLightDir(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 lightDir = normalize(i.lightDir);
                fixed3 viewDir = normalize(i.viewDir);

                fixed4 col = tex2D(_MainTex, i.uv);
                float3 ambinet = UNITY_LIGHTMODEL_AMBIENT.rgb * col.rgb;
                float3 diffuse = col.rgb * _LightColor0.rgb * saturate(dot(worldNormal, lightDir));
                float3 halfDir = normalize(viewDir + lightDir);
                float3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);
                clip(col.a - _CutOff);
                return fixed4(ambinet + specular + diffuse, 1);
            }
            ENDCG
        }
    }
}
