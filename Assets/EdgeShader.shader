Shader "Custom/EdgeShader"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _DepthNormalsTexture ("DepthNormals", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float depth : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _DepthNormalsTexture, _CameraDepthTexture;
            float4 _CameraDepthTexture_TexelSize;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);
                // o.depth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(o.pos))));
				// o.depth = tex2Dproj(_CameraDepthTexture, o.pos);
				// o.depth = tex2Dproj(_CameraDepthTexture, o.pos.xy / o.pos.w);
				// o.depth = tex2Dproj(_CameraDepthTexture, float4(o.pos.xy / o.pos.w, 0, 1));
				o.depth = ComputeScreenPos(o.pos).z;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // float3 normal = DecodeDepthNormal(tex2D(_DepthNormalsTexture, i.pos.xy));
				float3 normal = DecodeViewNormalStereo(tex2D(_DepthNormalsTexture, i.pos.xy));
				
                // Example: combine normal and depth for visualization
                // float depth = i.depth/50;

				// return float4(normal * depth, 1.0);
				return float4(normal, 1.0f);
                // return depth;
				// return float4(i.normal,	1.0f);
            }
            ENDCG
        }
    }
}