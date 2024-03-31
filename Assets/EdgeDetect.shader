Shader "Hidden/EdgeDetect" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Sensitivity ("Depth Sensitivity", Float) = 1
        _Thres ("Depth Threshold", Float) = 0.1
    }

    SubShader {

        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            #include "UnityCG.cginc"

            struct VertexData {
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vp(VertexData v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex, _CameraDepthTexture, _CameraDepthNormalsTexture;
            float4 _CameraDepthTexture_TexelSize;
            float _Sensitivity, _Thres;

            fixed4 fp(v2f i) : SV_Target {
                int x, y;
                fixed4 col = tex2D(_MainTex, i.uv);
                float depth = tex2D(_CameraDepthTexture, i.uv);
                float3 norms = tex2D(_CameraDepthNormalsTexture, i.uv);
                // depth = Linear01Depth(depth);
                // LinearEyeDepth
                depth *= _Sensitivity;
                float edge = depth;

                // float n = Linear01Depth(tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(0, 1)).r);
                // float e = Linear01Depth(tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(1, 0)).r);
                // float s = Linear01Depth(tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(0, -1)).r);
                // float w = Linear01Depth(tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(-1, 0)).r);
                // float ne = Linear01Depth(tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(1, 1)).r);
                // float nw = Linear01Depth(tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(-1, 1)).r);
                // float se = Linear01Depth(tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(1, -1)).r);
                // float sw = Linear01Depth(tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(-1, -1)).r);
                float n = _Sensitivity * (tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(0, 1)).r);
                float e = _Sensitivity * (tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(1, 0)).r);
                float s = _Sensitivity * (tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(0, -1)).r);
                float w = _Sensitivity * (tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(-1, 0)).r);
                float ne = _Sensitivity * (tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(1, 1)).r);
                float nw = _Sensitivity * (tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(-1, 1)).r);
                float se = _Sensitivity * (tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(1, -1)).r);
                float sw = _Sensitivity * (tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(-1, -1)).r);

                if (n - s > _Thres || w - e > _Thres || e - w > _Thres || s - n > _Thres)
                    col = 0.0f;
                    edge = 1.0f;
                
                if (nw - se > _Thres || ne - sw > _Thres || se - nw > _Thres || sw - ne > _Thres)
                    col = 0.0f;
                    edge = 1.0f;

                float4 img = col;
                if (i.uv.x > 0.5)
                    img = float4(edge, depth, depth, 1.0f);
                
                // return img;
                // return col;
                // return depth;
                return float4(norms,1.0f);
            }
            ENDCG
        }
    }
}
