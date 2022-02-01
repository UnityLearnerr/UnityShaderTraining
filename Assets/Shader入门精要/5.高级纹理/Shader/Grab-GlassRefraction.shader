Shader "ShaderBook/HighTexture/Grab-GlassRefraction"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap("NormalMap", 2D) = "white" {}
        _CubeMap("CubeMap", Cube) = "_SkyBox" {}
        _Distortion("Distortion", Range(10, 200)) = 30
        _RefrAmount("RefrAmount", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        LOD 100

        GrabPass{ "_RefractionTex" }

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
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
                fixed4 tTow0 : TEXCOORD1;
                fixed4 tTow1 : TEXCOORD2;
                fixed4 tTow2 : TEXCOORD3;
                fixed4 grabSceen: TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;
            samplerCUBE _CubeMap;
            fixed _Distortion;
            fixed _RefrAmount;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _NormalMap);
                fixed3 normal = UnityObjectToWorldNormal(v.normal);
                fixed3 tangent = UnityObjectToWorldDir(v.tangent);
                fixed3 biNormal = cross(normal, tangent) * v.tangent.w;
                fixed4 worldVertex = mul(unity_ObjectToWorld, v.vertex);
                o.tTow0 = fixed4(tangent.x, biNormal.x, normal.x,  worldVertex.x);
                o.tTow1 = fixed4(tangent.y, biNormal.y, normal.y,  worldVertex.y);
                o.tTow2 = fixed4(tangent.z, biNormal.z, normal.z,  worldVertex.z);
                o.grabSceen = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldVertex = fixed3(i.tTow0.w, i.tTow1.w, i.tTow2.w);
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldVertex));
                fixed3 bump = UnpackNormal(tex2D(_NormalMap, i.uv.zw));
                fixed3 worldNormal = normalize(fixed3(dot(i.tTow0.xyz,bump), dot(i.tTow1.xyz,bump), dot(i.tTow2.xyz,bump)));
                fixed3 reflectDir = reflect(-viewDir, worldNormal);
                fixed2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize;
                i.grabSceen.xy = i.grabSceen.xy + offset * i.grabSceen.z;
                fixed3 refractCol = tex2D(_RefractionTex, i.grabSceen.xy / i.grabSceen.w);
                fixed3 mainColor = tex2D(_MainTex, i.uv.xy).rgb;
                fixed3 reflectCol = texCUBE(_CubeMap, reflectDir).rgb * mainColor;
                fixed3 finalCol = (1 - _RefrAmount) * reflectCol + _RefrAmount * refractCol;
                return fixed4(finalCol, 1);
            }
            ENDCG
        }
    }
}
