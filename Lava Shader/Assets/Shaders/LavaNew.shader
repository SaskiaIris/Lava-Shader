Shader "Custom/LavaNew" {
    Properties {
        //_Color("Color", Color) = (1,1,1,1)

        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _Tiling("Tiling", Float) = 1

        _StoneTex("Stone Texture", 2D) = "white" {}

        [NoScaleOffset] _FlowMap("Flow (RG)", 2D) = "black" {}
        [NoScaleOffset] _AlphaLayer("Alpha Layer", 2D) = "white" {}
        //[NoScaleOffset] _NormalMap("Normals", 2D) = "bump" {}

        _ScrollXSpeed("X Speed", Range(0,10)) = 2
        _ScrollYSpeed("Y Speed", Range(0,10)) = 3

        //_Glossiness("Smoothness", Range(0,1)) = 0.5
        //_Metallic("Metallic", Range(0,1)) = 0.0
    }
    SubShader {
        Tags {
            /*"RenderType"="Transparent"
            "Queue"="Transparent"*/
            "RenderType" = "Opaque"
        }
        LOD 200
        
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows
        //#pragma surface surf Standard alpha fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex, _StoneTex, _FlowMap, _AlphaLayer;

        struct Input
        {
            float2 uv_MainTex;
        };

        float _Tiling;

        fixed _ScrollXSpeed;
        fixed _ScrollYSpeed;
        //half _Glossiness;
        //half _Metallic;
        //fixed4 _Color;


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            
            float2 useUV = IN.uv_MainTex;

            fixed4 colorFlow = tex2D(_FlowMap, useUV);
            


            fixed2 scrolledUV = useUV;

            float2 flowVector = colorFlow.rg * 2 - 1; //Verandert de range naar -1, 1
            
            scrolledUV *= flowVector;

            fixed xScrollValue = _ScrollXSpeed * _Time;
            fixed yScrollValue = _ScrollYSpeed * _Time;

            scrolledUV += fixed2(xScrollValue, yScrollValue);
            //Hier ^ gaat iets fout
            //scrolledUV += _Time;
            
            //Uncomment na testen!
            useUV *= _Tiling;
            scrolledUV *= _Tiling;



            fixed4 colorMain = tex2D(_MainTex, useUV);
            fixed4 colorStone = tex2D(_StoneTex, useUV);
            
            fixed4 colorMainScroll = tex2D(_MainTex, scrolledUV);
            fixed4 colorStoneScroll = tex2D(_StoneTex, scrolledUV);
            fixed4 colorFlowScroll = tex2D(_FlowMap, scrolledUV);
            
            

            o.Albedo = lerp(colorMain.rgb, colorStone.rgb, colorStone.a);

            half3 c = lerp(colorMainScroll.rgb, colorStone.rgb*0.5, colorStone.a); //* 0.5 om de kleuren weer goed te krijgen
                        
            o.Albedo += c.rgb;
            // Metallic and smoothness come from slider variables
            /*o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;*/
        }
        ENDCG
    }
    FallBack "Diffuse"
}