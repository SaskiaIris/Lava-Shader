﻿Shader "EigenShaders/WaterLava"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Size("Size", float) = 1
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

                float2 aspect = float2(2,1);
                float2 uv = i.uv * _Size * aspect;
                uv.y += t * 0.25; //Zodat de druppel niet weer omhoog gaat
                float2 gv = frac(uv)-0.5; //-0.5 zodat het een rondje tekent en niet de helft

                float x = 0;
                float y = -sin(t + sin(t + sin(t) * 0.5)) * 0.45; // 0.45 is zodat hij niet buiten de box gaat

                float2 dropPos = (gv-float2(x, y)) / aspect;
                float drop = smoothstep(.05, .03, length(dropPos));

                float2 trailPos = (gv - float2(x, 0)) / aspect;
                trailPos.y = (frac(trailPos.y * 8)- 0.5) / 8; //-0.5 zodat het een rondje tekent en niet de helft
                float trail = smoothstep(.05, .03, length(trailPos));
                trail *= smoothstep(-0.05, 0.05, dropPos.y);

                col += drop;
                col += trail;

                //col.rg = gv;
                if (gv.x > .48 || gv.y > .49) {
                    col = float4(1, 0, 0, 1);
                }

                float2 offset = drop + trail;

                col = tex2D(_MainTex, i.uv + offset + gv);

                return col;
            }
            ENDCG
        }
    }
}
