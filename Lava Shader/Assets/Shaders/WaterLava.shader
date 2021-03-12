Shader "EigenShaders/WaterLava"
{
    Properties
    {
        [Header(Textures)]
        [Space] _MainTex("Texture", 2D) = "black" {}
        _Color("Color", Color) = (1,0,0,1)

        [Space(15)] [Header(Sizing)]
        [Space] _Size("Size", float) = 1
        _AspectRatio("Aspect width and height", vector) = (2,1,0,0)

        [Space(15)] [Header(Trail and flow)]
        [Space] _BendAmount("Bend amount of flow", Range(0,10)) = 5
        [IntRange] _TrailAmount("Amount of drops in trail", Range(0,55)) = 8
        _Distortion("Distortion", range(-5, 5)) = 1
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Size;
            float _BendAmount;
            float _TrailAmount;
            float2 _AspectRatio;
            float _Distortion;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float t = _Time.y;
                
                float4 col = 0;

                float2 aspect = _AspectRatio; //Box size aspect ratio
                float2 uv = i.uv * _Size * aspect;
                uv.y += t * 0.25; //Zodat de druppel niet weer omhoog gaat
                float2 gridView = frac(uv)-0.5; //-0.5 zodat het een rondje tekent en niet de helft

                float w = i.uv.y * _BendAmount;
                float x = sin(3*w)*pow(sin(w), 6)*0.45; // 0.45 is zodat hij niet buiten de box gaat
                //float y = -sin(t + sin(t + sin(t) * 0.5)) * 0.45; // 0.45 is zodat hij niet buiten de box gaat
                float y = sin(t) * 0.45;

                float2 dropPos = (gridView-float2(x, y)) / aspect;
                float drop = smoothstep(.05, .03, length(dropPos));

                float2 trailPos = (gridView - float2(x, t * 0.25)) / aspect;
                trailPos.y = (frac(trailPos.y * _TrailAmount)- 0.5) / _TrailAmount; //-0.5 zodat het een rondje tekent en niet de helft
                float trail = smoothstep(0.03, 0.01, length(trailPos));
                float realTrail = smoothstep(-0.05, 0.05, dropPos.y);
                realTrail *= smoothstep(0.5, y, gridView.y);
                trail *= realTrail;
                realTrail *= smoothstep(0.05, 0.04, abs(dropPos.x));

                float2 offset = 0;
                //offset += drop;
                //offset += trail;
                offset += realTrail * 0.5;
                offset += drop*dropPos;
                offset *= _Distortion;
                //offset *= (1,0,0,1);
                
                
                //col += realTrail * 0.5;
                //col += drop;
                //col += trail;

                //Hieronder is de code voor de randen die het veld verdelen
                /*if (gridView.x > .48 || gridView.y > .49) {
                    col = float4(1, 0, 0, 1);
                }*/

                //float2 offset = drop + trail + realTrail;
                

                col = tex2D(_MainTex, i.uv + offset + gridView);

                return col;
            }
            ENDCG
        }
    }
}
