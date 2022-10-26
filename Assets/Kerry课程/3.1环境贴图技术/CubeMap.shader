Shader "Unlit/CubeMap"
{
    Properties
    {
        _TexCube("TexCube", Cube) = "white" {}
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 world_pos : TEXCOORD1;
                float3 world_normal : TEXCOORD2;
            };

            samplerCUBE _TexCube;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.world_pos = mul(unity_ObjectToWorld,v.vertex);
                o.world_normal = mul(v.normal, unity_WorldToObject);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 world_normal = normalize(i.world_normal);
                float3 incident = normalize(i.world_pos - _WorldSpaceCameraPos);
                float3 r = reflect(incident, world_normal);
                fixed4 col = texCUBE(_TexCube, r);
                return col;
            }
            ENDCG
        }
    }
}
