Shader "Unlit/ScanCode"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScanTex("ScanTex", 2D) = "white" {}
        _InnerColor("InnerColor", Color) = (0,0,0,0)
        _RimColor("RimColor", Color) = (1,1,1,1)
        _RimInstensity("RimInstensity", float) = 1 
        _RimPower("RimPower", float) = 1
        _RimBias("RimBias", Range(0, 1)) = 1
        _RimScale("RimScale", Range(0, 1)) = 1
        _ScanSpeed("ScanSpeed", Vector) = (0,0,0,0)
        _TexPow("TexPow", Range(0, 10)) = 5

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "RenderQueue"="Transparent" }
        LOD 100

        Pass
        {
            ColorMask 0
            ZWrite On
        }

        Pass
        {
            Blend SrcAlpha One
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float3 worldViewDir:TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
                float2 mainTexUV:TEXCOORD3;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _ScanTex;
            float4 _ScanTex_ST;
            fixed4 _InnerColor;
            fixed4 _RimColor;
            float _RimInstensity;
            float _RimPower;
            float _RamBias;
            float _RimScale;
            float _RimBias;
            float4 _ScanSpeed;
            float _TexPow;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float3 rootPos = mul(unity_ObjectToWorld, float4(0, 0, 0, 1));
                o.worldPos = worldPos - rootPos;
                o.worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.mainTexUV = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float CalFresnel(v2f i)
            {
                float dotresult = clamp(dot(normalize(i.worldNormal), normalize(i.worldViewDir)), 0, 1);
                float rimresult = (pow((1 - dotresult), _RimPower) + _RimBias) * _RimScale;
                return rimresult;   
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float detailAlpha = pow(tex2D(_MainTex, i.mainTexUV).r, _TexPow);
                float rimAlpha = clamp(CalFresnel(i) + detailAlpha, 0, 1);
                fixed4 rimColor = lerp(_InnerColor, _RimColor * _RimInstensity, rimAlpha);
                float3 pos = i.worldPos + _ScanSpeed * _Time.y;
                float4 uv = float4(pos.x, pos.y, 0, 0);
                fixed4 scanColor = tex2D(_ScanTex, uv);
                fixed3 finalColor = rimColor.rgb + scanColor.rgb;
                fixed finalAlpha = clamp(rimAlpha + scanColor.a, 0, 1);
                return fixed4(finalColor, finalAlpha);
            }
            ENDCG
        }
    }
}
