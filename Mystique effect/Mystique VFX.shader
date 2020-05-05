Shader "kenny_effect/Mystique VFX" {
	Properties{
	  //F Texture
	  [Header(First Texture)]
	  [Space(5)]
	  _Color("Color", Color) = (1,1,1,1)
	  _MainTex("Texture", 2D) = "white" {}
	  _RoughTex("Roughness Texture", 2D) = "white" {}
	  _NormalTex("Normal Texture", 2D) = "bump" {}
	  [Space(10)]
	  //S Texture
	  [Header(Second Texture)]
	  [Space(5)]
	  _Color2("Color2", Color) = (1,1,1,1)
	  _MainTex2("Texrue2", 2D) = "white" {}
	  _RoughTex2("Roughness Texture2", 2D) = "white" {}
	  _NormalTex2("Normal Texture2", 2D) = "bump" {}
	  [Space(10)]
	  //Mat parameter
	  [Header(Material Parameter)]
	  [Space(5)]
	  _Glossiness("Smoothness", Range(0,1)) = 0.5
	  _Metallic("Metallic", Range(0,1)) = 0.0
	  _Normal("Normal", Range(0,2)) = 1
	  [Space(10)]
	  //VFX parameter
	  [Header(Effect Parameter)]
	  [Space(5)]
	  [PowerSlider(3)]_mRange("CoverRange", Range(0,1)) = 0.09
	  _Pow("Displacement-Power", Range(-50,50)) = 10
	  _LerpScale("LerpScale", float) = 80
	 [Space(10)]
	 [Header(Border)]
	  [Space(5)]
	  _BorderPow("Border Power", float) = 38
	  [PowerSlider(3)]_BorderLit("Border Lit",  Range(0,10)) = 10
	  [Space(5)]
	  _BorderColor("BorderColor", Color) = (1,1,1,1)
	  _BorderMask("Border Mask", 2D) = "white" {}

	}
		SubShader{
		  Tags { "RenderType" = "Opaque" }
		  LOD 200
		  Cull off
		  CGPROGRAM
		  // Physically based Standard lighting model, and enable shadows on all light types
		  #pragma surface surf Standard fullforwardshadows vertex:vert
          //----------------target 3.5 !! instead of 3----------------
		  #pragma target 3.5

		  struct Input {
			  //UV setting
			  float2 uv_MainTex;
			  float2 uv_MainTex2;
			  float2 uv_RoughTex;
			  float2 uv_RoughTex2;
			  float2 uv_NormalTex;
			  float2 uv_NormalTex2;
			  float2 uv_BorderMask;

			  float3 worldPos;
		  };

		  //my variable
		  fixed4 _mVector;
		  fixed _mRange, _Pow, _LerpScale, _BorderPow, _BorderLit;
		  half final;

		  void vert(inout appdata_full v, out Input o) {
			  UNITY_INITIALIZE_OUTPUT(Input,o);
			  //----------------transform vertex to world space!!!----------------
			  // 1. v.vertex => get model vertex pos
			  // 2. transform vertex from object space to world space
			  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			  //calculate effect
			  half dis = dot(_mVector.xyz, worldPos) + _mVector.w;
			  half dis2 = (dot(_mVector.xyz, worldPos) + _mVector.w)*-1;
			  half dis_1 = step(dis, _mRange);
			  half dis_2 = step(dis2, _mRange);
			  final = _Pow * saturate(dis_2 * dis_1* dis2*0.1);
			  //expansion along normal vector
			  v.vertex.xyz += v.normal * final;
		  }
		  //my variable
		  sampler2D _MainTex, _MainTex2, _RoughTex, _RoughTex2, _NormalTex, _NormalTex2, _BorderMask;
		  fixed4 _Color, _Color2, _BorderColor;
		  half _Glossiness;
		  half _Metallic;
		  half _Normal;

		  UNITY_INSTANCING_BUFFER_START(Props)
		  // put more per-instance properties here
		  UNITY_INSTANCING_BUFFER_END(Props)

		  //----------------SurfaceOutputStandard instead of SurfaceOutput !!!----------------
		  void surf(Input IN, inout SurfaceOutputStandard o) {
			  half dis = dot(_mVector.xyz, IN.worldPos) + _mVector.w;
			  half dis2 = (dot(_mVector.xyz, IN.worldPos) + _mVector.w)*-1;
			  half dis_1 = step(dis, _mRange);
			  half dis_2 = step(dis2, _mRange);

			  half final = saturate((dis2- _mRange) * _LerpScale);
			  //Diffuse
			  fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			  fixed4 c2 = tex2D(_MainTex2, IN.uv_MainTex2) * _Color2;
			  //Roughness
			  fixed3 r = tex2D(_RoughTex, IN.uv_RoughTex);
			  fixed3 r2 = tex2D(_RoughTex2, IN.uv_RoughTex2);
			  //Normal
			  fixed3 n = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
			  fixed3 n2 = UnpackNormal(tex2D(_NormalTex2, IN.uv_NormalTex2));

			  fixed4 finalCol = lerp(c, c2, final);
			  fixed3 finalRough = lerp(r, r2, final);
			  fixed3 finalNor = lerp(n, n2, final);
			  finalNor.xy *= _Normal;
			  //border 
			  fixed4 b = tex2D(_BorderMask, IN.uv_BorderMask);
			  fixed4 border = saturate(dis_2 * dis_1 * dis2 * _BorderPow)*_BorderLit;
			  border *= _BorderColor * b;

			  o.Albedo = finalCol.rgb + border;
			  o.Metallic = _Metallic;
			  o.Smoothness = _Glossiness * finalRough.rgb;
			  o.Normal = finalNor.rgb;
			  o.Alpha = c.a;
			  //o.Emission = border;
		  }
		  ENDCG
	}
		Fallback "Diffuse"
}