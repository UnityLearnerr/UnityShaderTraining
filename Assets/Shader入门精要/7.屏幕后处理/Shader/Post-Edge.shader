Shader "ShaderBook/PostProcess/Post-Edge"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BackGroundColor("BackGroundColor", Color) = (1, 1, 1, 1)
        _EdgeColor("EdgeColor", Color) = (1, 1, 1, 1)
        _EdgeOnly("EdgeOnly", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Cull Off
        ZTest Always
        ZWrite Off

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
                float2 uv[9] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            float4 _EdgeColor;
            fixed4 _BackGroundColor;
            fixed _EdgeOnly;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                fixed2 uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv[0] = uv + _MainTex_TexelSize * half2(-1, -1);
                o.uv[1] = uv + _MainTex_TexelSize * half2(0, -1);
                o.uv[2] = uv + _MainTex_TexelSize * half2(1, -1);
                o.uv[3] = uv + _MainTex_TexelSize * half2(-1, 0);
                o.uv[4] = uv + _MainTex_TexelSize * half2(0, 0);
                o.uv[5] = uv + _MainTex_TexelSize * half2(1, 0);
                o.uv[6] = uv + _MainTex_TexelSize * half2(-1, 1);
                o.uv[7] = uv + _MainTex_TexelSize * half2(0, 1);
                o.uv[8] = uv + _MainTex_TexelSize * half2(1, 1);
                return o;
            }

            
            fixed luminance(fixed3 color)
            {
               return 0.2125 * color.r +  0.7154 + color.g + 0.0721 * color.b;
            }

            fixed convolution(v2f v)
            {
                const fixed Gx[9] = {1, 2, 1,
                                  0, 0, 0,
                                  -1,-2,-1};
                const fixed Gy[9] = {1, 0, -1,
                                  2, 0, -2,
                                  1, 0, -1};
                
                fixed result_x = 0;
                fixed result_y = 0;
                for(int i = 0; i < 9; i++)
                {
                    fixed l = luminance(tex2D(_MainTex, v.uv[i]));
                    result_x += l * Gx[i];
                    result_y += l * Gy[i];
                }
                return (1 - result_x - result_y);
            }


            fixed4 frag (v2f i) : SV_Target
            {
                fixed edge = convolution(i);
                fixed3 col1 = lerp(_EdgeColor.rgb, tex2D(_MainTex, i.uv[4]).rgb, edge);
                fixed3 col2 = lerp(_EdgeColor.rgb, _BackGroundColor.rgb, edge);
                fixed3 col = lerp(col1, col2, _EdgeOnly);              
                return fixed4(col2, 1);
            }
            ENDCG
        }
    }
}
