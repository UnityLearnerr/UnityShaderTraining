// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Vice"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Grow("Grow", Range( -2 , 2)) = 0
		_GrowMin("GrowMin", Range( 0 , 1)) = 0
		_GrowMax("GrowMax", Range( 0 , 1.5)) = 0
		_EndMin("EndMin", Range( 0 , 1)) = 0
		_EndMax("EndMax", Range( 0 , 1.5)) = 0
		_Offset("Offset", Float) = 0
		_Scale("Scale", Float) = 0
		_Diffuse("Diffuse", 2D) = "white" {}
		_Bump("Bump", 2D) = "white" {}
		_Roughness("Roughness", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _GrowMin;
		uniform float _GrowMax;
		uniform float _Grow;
		uniform float _EndMin;
		uniform float _EndMax;
		uniform float _Offset;
		uniform float _Scale;
		uniform sampler2D _Bump;
		uniform float4 _Bump_ST;
		uniform sampler2D _Diffuse;
		uniform float4 _Diffuse_ST;
		uniform sampler2D _Roughness;
		uniform float4 _Roughness_ST;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float temp_output_3_0 = ( v.texcoord.xy.y - _Grow );
			float smoothstepResult5 = smoothstep( _GrowMin , _GrowMax , temp_output_3_0);
			float smoothstepResult12 = smoothstep( _EndMin , _EndMax , v.texcoord.xy.y);
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( ( max( smoothstepResult5 , smoothstepResult12 ) * ( ase_vertexNormal * 0.1 * _Offset ) ) + ( ase_vertexNormal * _Scale ) );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Bump = i.uv_texcoord * _Bump_ST.xy + _Bump_ST.zw;
			o.Normal = tex2D( _Bump, uv_Bump ).rgb;
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			o.Albedo = tex2D( _Diffuse, uv_Diffuse ).rgb;
			float2 uv_Roughness = i.uv_texcoord * _Roughness_ST.xy + _Roughness_ST.zw;
			o.Emission = tex2D( _Roughness, uv_Roughness ).rgb;
			o.Alpha = 1;
			float temp_output_3_0 = ( i.uv_texcoord.y - _Grow );
			clip( ( 1.0 - temp_output_3_0 ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
-1977;382;1906;957;1527.214;465.481;1.3;True;True
Node;AmplifyShaderEditor.RangedFloatNode;2;-2249.223,308.3566;Inherit;False;Property;_Grow;Grow;1;0;Create;True;0;0;0;False;0;False;0;2;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-2210.653,123.4477;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;9;-1993.033,690.1088;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;10;-2005.14,841.0465;Inherit;False;Property;_EndMin;EndMin;4;0;Create;True;0;0;0;False;0;False;0;0.697;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;3;-1812.704,190.8021;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-2002.14,939.0465;Inherit;False;Property;_EndMax;EndMax;5;0;Create;True;0;0;0;False;0;False;0;1.5;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1992.033,538.1088;Inherit;False;Property;_GrowMax;GrowMax;3;0;Create;True;0;0;0;False;0;False;0;0.862;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-2007.033,404.1088;Inherit;False;Property;_GrowMin;GrowMin;2;0;Create;True;0;0;0;False;0;False;0;0.285;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1420.539,1039.409;Inherit;False;Property;_Offset;Offset;6;0;Create;True;0;0;0;False;0;False;0;-8.78;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;12;-1663.14,771.0465;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1421.539,929.4088;Inherit;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;5;-1656.033,439.1088;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;14;-1426.969,752.2106;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1143.539,825.4088;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;13;-1407.02,580.1733;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-939.7847,1019.028;Inherit;False;Property;_Scale;Scale;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;23;-950.7847,837.0282;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-1043.969,572.2106;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-677.7847,942.0282;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;27;-1244.625,-219.5706;Inherit;True;Property;_Bump;Bump;9;0;Create;True;0;0;0;False;0;False;-1;None;0f8684324d1c93e4d82c72a2ae5db933;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;28;-1255.625,4.429443;Inherit;True;Property;_Roughness;Roughness;10;0;Create;True;0;0;0;False;0;False;-1;None;14d4981dfd5e40a42b97e126eaec55fc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;4;-1542.033,206.1088;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-546.3634,649.0228;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;26;-1243.487,-423.3465;Inherit;True;Property;_Diffuse;Diffuse;8;0;Create;True;0;0;0;False;0;False;-1;None;7a2fe6ccac2a6ae42980adbb572f6593;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-76.16658,65.53253;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Vice;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;16;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;8;2
WireConnection;3;1;2;0
WireConnection;12;0;9;2
WireConnection;12;1;10;0
WireConnection;12;2;11;0
WireConnection;5;0;3;0
WireConnection;5;1;6;0
WireConnection;5;2;7;0
WireConnection;18;0;14;0
WireConnection;18;1;16;0
WireConnection;18;2;17;0
WireConnection;13;0;5;0
WireConnection;13;1;12;0
WireConnection;15;0;13;0
WireConnection;15;1;18;0
WireConnection;25;0;23;0
WireConnection;25;1;24;0
WireConnection;4;0;3;0
WireConnection;19;0;15;0
WireConnection;19;1;25;0
WireConnection;0;0;26;0
WireConnection;0;1;27;0
WireConnection;0;2;28;0
WireConnection;0;10;4;0
WireConnection;0;11;19;0
ASEEND*/
//CHKSM=AA4002B54A154F2873E30E8E7064E653DC5A1D85