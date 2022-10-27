Shader "Unlit/CubeMap"
{
    Properties
    {
        _TexCube("TexCube", Cube) = "white" {}
        _NormalMap("NormalMap", 2D) = "bump"{}
        _AoMap ("AOMap", 2D) = "white"{}
        _Color("Color", Color) = (1, 1, 1, 1)
        _Expose("Expose", Float) = 1
        _NormalIntensity("NormalIntensity", Float) = 1
        _Angle("Angle", Range(0, 360)) = 0
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
                float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 world_pos : TEXCOORD1;
                float3 world_normal : TEXCOORD2;
                float3 world_tangent : TEXCOORD3;
                float3 world_binormal : TEXCOORD4;
                float2 uv : TEXCOORD5;

            };

            samplerCUBE _TexCube;
            float4 _TexCube_HDR;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            sampler2D _AoMap;
            float4 _Color;
            float _Expose;
            float _NormalIntensity;
            float _Angle;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.world_pos = mul(unity_ObjectToWorld, v.vertex);
                o.world_normal = normalize(mul(float4(v.normal, 0), unity_WorldToObject));
                o.world_tangent = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0)).xyz);
                o.world_binormal = normalize(cross(o.world_normal, o.world_tangent))* v.tangent.w;
                o.uv = v.texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed ao = tex2D(_AoMap, i.uv).r;
                fixed3 normal_data = UnpackNormal(tex2D(_NormalMap, i.uv));
                normal_data.xy *= _NormalIntensity;
                fixed3 world_normal = normalize(i.world_normal);
                fixed3 world_tangent = normalize(i.world_tangent);
                fixed3 world_binormal = normalize(i.world_binormal);
                fixed3 normal = normalize(normal_data.x * world_tangent + normal_data.y * world_binormal  + normal_data.z * world_normal);
                fixed3 view_dir = normalize(i.world_pos - _WorldSpaceCameraPos.xyz);
                fixed rad = _Angle * UNITY_PI / 180;
                float2x2 rotate_matrix = float2x2(cos(rad), -sin(rad),
                                                  sin(rad), cos(rad));
               
                float3 ref_dir = reflect(view_dir, normal);
                fixed2 rotate_dir = mul(rotate_matrix,  ref_dir.xz);
                ref_dir = fixed3(rotate_dir.x, ref_dir.y, rotate_dir.y);
                fixed4 ambient_col = texCUBE(_TexCube, ref_dir);
                fixed3 ambient_hdr = DecodeHDR(ambient_col, _TexCube_HDR);
                fixed4 final_color = fixed4(ambient_hdr * ao, ambient_col.a) * ao * _Color * _Expose;
                return final_color;
            }
            ENDCG
        }
    }
}
