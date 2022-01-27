Shader "ShaderBook/ComplexLighting/ForwardRendering"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8, 255)) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
                float3 lightDir : TEXCOORD2;
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            fixed _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                fixed3 worldVertex = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = UnityWorldSpaceViewDir(worldVertex);
                o.lightDir = UnityWorldSpaceLightDir(worldVertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 lightDir = normalize(i.lightDir);
                fixed3 viewDir = normalize(i.viewDir);
                fixed3 normal = normalize(i.worldNormal);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * _Diffuse.rgb;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(lightDir,normal));
                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(halfDir, normal)), _Gloss);
                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }

        Pass
        {
            Tags{"LightMode"="ForwardAdd"}
            Blend One One

            CGPROGRAM
            #pragma multi_compile_fwdadd
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldVertex : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            fixed _Gloss;


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                o.worldVertex = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 normal = normalize(i.worldNormal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldVertex));
                fixed3 viewDir = normalize(i.viewDir);

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(lightDir, normal));
                fixed3 halfDir = normalize(viewDir + lightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir,normal)), _Gloss);

                #ifdef USING_DIRECTTINAL_LIGHT
                    fixed atten = 1;
                #else
                    #if defined(POINT)
                        fixed3 lightSpaceVertex = mul(unity_WorldToLight, fixed4(i.worldVertex, 1)).xyz;
                        fixed atten = tex2D(_LightTexture0,dot(lightSpaceVertex, lightSpaceVertex).rr).UNITY_ATTEN_CHANNEL;
                    #elif defined(SPOT)
                        fixed lightSpaceVertex = mul(unity_WorldToLight, fixed4(i.worldVertex, 1)).xyz;
                        fixed atten = (lightSpaceVertex.z > 0) * tex2D(_LightTexture0, fixed(lightSpaceVertex.x, lightSpaceVertex.y) / lightSpaceVertex.w + 0.5)
                            * tex2D(_LightTextureB0, dot(lightSpaceVertex, lightSpaceVertex).rr).UNITY_ATTEN_CHANNEL;
                    #else
                         fixed atten = 1;
                    #endif
                #endif
                return fixed4((diffuse + specular) * atten, 1);
            }
            ENDCG
        }


    }
}
