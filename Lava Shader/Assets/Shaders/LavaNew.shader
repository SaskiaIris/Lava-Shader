Shader "Custom/LavaNew" {
    Properties {
        //_Color("Color", Color) = (1,1,1,1)
        //Uitleggen waarom noscaleoffset
        [NoScaleOffset] _MainTex("Albedo (RGB)", 2D) = "white" {}
        [NoScaleOffset] _StoneTex("Stone Texture", 2D) = "white" {}

        [Space(10)]

        [NoScaleOffset] _FlowMap("Flow (RG)", 2D) = "black" {}
        _FlowSpeed("Flowmap play speed", Range(0.0,2.0)) = 1.0

        [NoScaleOffset] _DispMap("Displacement", 2D) = "grey" {} //Displacement
        [NoScaleOffset] _NormalMap("Normals", 2D) = "bump" {} //Colorful, slope information

        [Space(10)]

        _Tiling("Tiling", Float) = 1

        [Space(50)]
        

        _ScrollXSpeed("X Speed", Range(0,10)) = 2
        _ScrollYSpeed("Y Speed", Range(0,10)) = 3

        [Space(50)]

        //Weghalen?
        _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0
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

        sampler2D _MainTex, _StoneTex, _FlowMap, _DispMap, _NormalMap;

        struct Input
        {
            float2 uv_MainTex;
        };

        float _Tiling;
        float _FlowSpeed;

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

        void surf (Input IN, inout SurfaceOutputStandard o) {
            float2 useUV = IN.uv_MainTex;

            fixed2 scrollUV = useUV;
            
            fixed xScrollValue = _ScrollXSpeed * _Time;
            fixed yScrollValue = _ScrollYSpeed * _Time;

            scrollUV += fixed2(xScrollValue, yScrollValue);
            

            fixed4 colorFlow = tex2D(_FlowMap, scrollUV);
            float2 flowVector = colorFlow.rg * 2 - 1; //Verandert de range naar -1, 1, zodat er naar links en naar rechts/boven/onder gegaan kan worden op basis van hoeveelheid kleur en niet in de min nodig is

            fixed2 flowUV = useUV;

            flowUV *= flowVector;
            flowUV += _FlowSpeed * _Time; //Time zorgt ervoor dat per tijd de flowmap doorspeelt
            
            //Uncomment na testen!
            useUV *= _Tiling;
            scrollUV *= _Tiling;
            flowUV *= _Tiling;

            //Height
            float3 normal = UnpackNormal(tex2D(_NormalMap, scrollUV));


            
            fixed4 colorMainScroll = tex2D(_MainTex, scrollUV);
            fixed4 colorStoneScroll = tex2D(_StoneTex, scrollUV);

            fixed4 colorMainFlow = tex2D(_MainTex, flowUV);
            

            o.Albedo = lerp(colorMainScroll.rgb, colorStoneScroll.rgb, colorStoneScroll.a);
            half3 c = lerp(colorMainFlow.rgb, colorStoneScroll.rgb*0.05, colorStoneScroll.a); //* 0.05 om de kleuren weer goed te krijgen
                        
            o.Albedo += c.rgb;
            o.Normal = normal;
            // Metallic and smoothness come from slider variables
            /*o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;*/
        }
        ENDCG
    }
    FallBack "Diffuse"
}