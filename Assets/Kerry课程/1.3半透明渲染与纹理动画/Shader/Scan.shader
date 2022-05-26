// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Scan"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_RimPower("RimPower", Float) = 0
		_RimScale("RimScale", Float) = 0
		_RimBias("RimBias", Range( 0 , 1)) = 0.1647059
		_InnerColor("InnerColor", Color) = (0,0,0,0)
		_RimColor("RimColor", Color) = (0,0,0,0)
		_Speed("Speed", Vector) = (0,0,0,0)
		_ScanTex("ScanTex", 2D) = "white" {}
		_ScanIntensity("ScanIntensity", Range( 0 , 1)) = 1
		_TexPower("TexPower", Float) = 0
		_InnerAlpha("InnerAlpha", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha One
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldNormal;
			float3 viewDir;
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float4 _InnerColor;
		uniform float4 _RimColor;
		uniform float _RimPower;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _TexPower;
		uniform sampler2D _ScanTex;
		uniform float2 _Speed;
		uniform float _ScanIntensity;
		uniform float _InnerAlpha;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldNormal = i.worldNormal;
			float dotResult9 = dot( ase_worldNormal , i.viewDir );
			float clampResult14 = clamp( dotResult9 , 0.0 , 1.0 );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float clampResult43 = clamp( ( ( ( pow( ( 1.0 - clampResult14 ) , _RimPower ) + _RimBias ) * _RimScale ) + pow( tex2D( _MainTex, uv_MainTex ).r , _TexPower ) ) , 0.0 , 1.0 );
			float RimAlpha50 = clampResult43;
			float4 lerpResult22 = lerp( _InnerColor , _RimColor , RimAlpha50);
			float4 RimColor54 = lerpResult22;
			float3 ase_worldPos = i.worldPos;
			float4 transform34 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float4 tex2DNode30 = tex2D( _ScanTex, ( ( float4( ase_worldPos , 0.0 ) - transform34 ) + float4( ( _Speed * _Time.y ), 0.0 , 0.0 ) ).xy );
			float4 ScanColor46 = ( tex2DNode30 * _ScanIntensity );
			o.Emission = ( RimColor54 + ScanColor46 ).rgb;
			float ScanAlpha49 = tex2DNode30.a;
			o.Alpha = clamp( ( RimAlpha50 + ScanAlpha49 + _InnerAlpha ) , 0 , 1 );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
222;464;1906;600;-751.852;-294.0023;1;True;True
Node;AmplifyShaderEditor.WorldNormalVector;7;-1180.021,273.918;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;8;-1159.977,507.4316;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;9;-856.17,403.55;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;14;-650.0002,407.3182;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;11;-466.6593,425.0447;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-540.8223,613.1887;Inherit;False;Property;_RimPower;RimPower;2;0;Create;True;0;0;0;False;0;False;0;8.89;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;13;-241.7375,515.3755;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-647.5932,771.5234;Inherit;False;Property;_RimBias;RimBias;4;0;Create;True;0;0;0;False;0;False;0.1647059;0.142;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;143.0573,1182.371;Inherit;False;Property;_TexPower;TexPower;10;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-98.16299,849.3075;Inherit;False;Property;_RimScale;RimScale;3;0;Create;True;0;0;0;False;0;False;0;1.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;20.18391,953.7354;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;-1;None;6b1e70a108f261743b71ce1e630a555e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;18;89.98558,604.811;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;41;371.6791,1051.963;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;268.7353,716.2904;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;34;-623.5522,1592.71;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;40;471.0563,748.0513;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;31;-584.4159,1376.439;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;27;-93.3559,1779.331;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;25;-101.1959,1618.344;Inherit;False;Property;_Speed;Speed;7;0;Create;True;0;0;0;False;0;False;0,0;1.48,0.8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;33;-97.40365,1461.962;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;43;628.6066,750.0111;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;239.1814,1697.622;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;826.4532,763.3424;Inherit;False;RimAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;403.2599,1471.646;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;180.8711,273.5109;Inherit;False;50;RimAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;1002.235,1597.496;Inherit;False;Property;_ScanIntensity;ScanIntensity;9;0;Create;True;0;0;0;False;0;False;1;0.6870329;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;20;-133.1221,-122.0687;Inherit;False;Property;_InnerColor;InnerColor;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0.3490566,0.3274336,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;21;-155.7649,126.8455;Inherit;False;Property;_RimColor;RimColor;6;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.4386792,1,0.5450347,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;30;603.6815,1484.906;Inherit;True;Property;_ScanTex;ScanTex;8;0;Create;True;0;0;0;False;0;False;-1;None;3e1ba32ea4a1a96408ab3fb1fe0c4518;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;1015.053,1757.62;Inherit;False;ScanAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;1326.733,1472.187;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;22;405.6261,64.27752;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;1530.128,1493.351;Inherit;False;ScanColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;632.2278,50.96879;Inherit;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;44;1110.151,679.1817;Inherit;False;Property;_InnerAlpha;InnerAlpha;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;1105.128,472.0037;Inherit;False;50;RimAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;1106.425,561.7073;Inherit;False;49;ScanAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;1315.945,181.597;Inherit;False;54;RimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;1321.527,339.4959;Inherit;False;46;ScanColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;1337.585,501.4298;Inherit;False;3;3;0;OBJECT;0;False;1;OBJECT;0;False;2;FLOAT;0;False;1;OBJECT;0
Node;AmplifyShaderEditor.ClampOpNode;57;1545.243,586.5148;Inherit;False;3;0;OBJECT;0;False;1;OBJECT;0;False;2;OBJECT;1;False;1;OBJECT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;1553.208,232.869;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1786.197,192.3468;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Scan;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;16;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;8;5;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;9;0;7;0
WireConnection;9;1;8;0
WireConnection;14;0;9;0
WireConnection;11;0;14;0
WireConnection;13;0;11;0
WireConnection;13;1;12;0
WireConnection;18;0;13;0
WireConnection;18;1;17;0
WireConnection;41;0;1;1
WireConnection;41;1;42;0
WireConnection;16;0;18;0
WireConnection;16;1;15;0
WireConnection;40;0;16;0
WireConnection;40;1;41;0
WireConnection;33;0;31;0
WireConnection;33;1;34;0
WireConnection;43;0;40;0
WireConnection;28;0;25;0
WireConnection;28;1;27;0
WireConnection;50;0;43;0
WireConnection;24;0;33;0
WireConnection;24;1;28;0
WireConnection;30;1;24;0
WireConnection;49;0;30;4
WireConnection;39;0;30;0
WireConnection;39;1;37;0
WireConnection;22;0;20;0
WireConnection;22;1;21;0
WireConnection;22;2;53;0
WireConnection;46;0;39;0
WireConnection;54;0;22;0
WireConnection;36;0;51;0
WireConnection;36;1;52;0
WireConnection;36;2;44;0
WireConnection;57;0;36;0
WireConnection;32;0;55;0
WireConnection;32;1;47;0
WireConnection;0;2;32;0
WireConnection;0;9;57;0
ASEEND*/
//CHKSM=6D28B8927808D9A389F17015FAD5D9EF902F124A