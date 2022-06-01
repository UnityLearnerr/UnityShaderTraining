Shader "Unlit/MapCap_Code"
{
    Properties
    {
        _DiffuseTex ("DiffuseTex", 2D) = "white" {}
        _MapCap ("MapCap", 2D) = "white" {}
        _AddMatCap("AddMatCap", 2D) = "white" {}
        _Bump("Bump", 2D) = "bump" {}
        _RampMap("RampMap", 2D) = "white"{}
        _AddIntensity("AddIntensity", Float) = 5
        _Intensity("Intensity", Float) = 1 
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 nDirWS : TEXCOORD1;
                float3 tDirWS : TEXCOORD2;
                float3 bDirWS : TEXCOORD3;
                float3 vertex_world : TEXCOORD4;
            };

            sampler2D _DiffuseTex;
            float4 _DiffuseTex_ST;
            sampler2D _MapCap;
            sampler2D _AddMatCap;
            sampler2D _Bump;
            sampler2D _RampMap;
            float _AddIntensity;
            float _Intensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.nDirWS = normalize(UnityObjectToWorldNormal(v.normal));
                o.tDirWS = normalize(mul( unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
                o.bDirWS =  normalize(cross(o.nDirWS, o.tDirWS) * v.tangent.w);
                o.uv = TRANSFORM_TEX(v.uv, _DiffuseTex);
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 diffuse_col = tex2D(_DiffuseTex, i.uv);

                fixed4 normal_col = tex2D(_Bump, i.uv);
                fixed3 normal = UnpackNormal(normal_col);
                float3x3 TBN = float3x3(i.tDirWS, i.bDirWS, i.nDirWS);
                fixed3 normal_world = normalize(mul(normal, TBN));
                fixed3 viewDir_world = normalize(UnityWorldSpaceViewDir(i.vertex_world));
                float fresnel = 1.0 - saturate(dot(normal_world, viewDir_world));
                fixed4 ramp_color = tex2D(_RampMap, fixed2(fresnel, 0.5));

                fixed3 normal_view = normalize(mul(UNITY_MATRIX_V, float4(normal_world, 0)).xyz);  // 齐次坐标w=0代表是向量(没有平移计算) 齐次坐标w=1代表是坐标
                fixed2 mapcap_uv = (normal_view.xy + 1) * 0.5;
                fixed4 matcap_col = tex2D(_MapCap, mapcap_uv) * _Intensity;
                fixed4 mapcapadd_col = tex2D(_AddMatCap, mapcap_uv) * _AddIntensity;

                fixed4 final_col = (matcap_col * ramp_color * diffuse_col) + mapcapadd_col;

                return final_col;
                //return mapcapadd_col;
                //return fixed4(matcap_col * ramp_color * diffuse_col);
            }
            ENDCG
        }
    }
}
