Shader "ShaderBook/Anim/BillBoard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _VerticalBillboarding ("Vertical Restraints", Range(0, 1)) = 1 
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "DisableBatching"="True"}
        LOD 100

        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _VerticalBillboarding;

            v2f vert (appdata v)
            {
                v2f o;

                fixed3 cameraObjSpacePos = mul(unity_WorldToObject, fixed4(_WorldSpaceCameraPos, 0));
                fixed3 normalDir = cameraObjSpacePos - v.vertex;
                normalDir.y *= _VerticalBillboarding;
                normalDir = normalize(normalDir);

                fixed3 upDir = normalDir.y > 0.999 ? fixed3(0, 0, 1) : fixed3(0, 1, 0);
                fixed3 rightDir = normalize(cross(normalDir, upDir));
                upDir = normalize(cross(rightDir, normalDir));
                v.vertex.xyz = v.vertex.x * rightDir + v.vertex.y * upDir + v.vertex.z * normalDir;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
