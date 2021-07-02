Shader "Custom/LavaNew"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)

        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _TestTex ("Test Texture", 2D) = "white" {}

        [MaterialToggle] _TestToggle("Gebruik test texture", Float) = 0

        [NoScaleOffset] _FlowMap("Flow (RG)", 2D) = "black" {}

        _ScrollXSpeed("X", Range(0,10)) = 2
        _ScrollYSpeed("Y", Range(0,10)) = 3

        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex, _TestTex, _FlowMap, _UseTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_TestTex;
        };
        fixed _TestToggle;

        fixed _ScrollXSpeed;
        fixed _ScrollYSpeed;
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 useUV;
            
            if (_TestToggle == 1) {
                useUV = IN.uv_TestTex;
            }
            else {
                useUV = IN.uv_MainTex;
            }
            
            fixed2 scrolledUV = useUV;
            float2 flowVector = tex2D(_FlowMap, useUV).rg * 2 - 1; //Verandert de range naar -1, 1
            
            scrolledUV *= flowVector;

            fixed xScrollValue = _ScrollXSpeed * _Time;
            fixed yScrollValue = _ScrollYSpeed * _Time;

            scrolledUV += fixed2(xScrollValue, yScrollValue);

            // Albedo comes from a texture tinted by color
            //fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

            half4 c;
            if (_TestToggle == 1) {
                c = tex2D(_TestTex, scrolledUV);
                o.Albedo = tex2D(_TestTex, useUV).rgb;
            }
            else {
                c = tex2D(_MainTex, scrolledUV);
                o.Albedo = tex2D(_MainTex, useUV).rgb;
            }
                        
            o.Albedo += c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
