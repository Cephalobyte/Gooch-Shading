Shader "Hidden/CameraDepth" {
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
				fixed4 col = tex2D(_MainTex, i.uv);								//combined pass
				float depth = tex2D(_CameraDepthTexture, i.uv);					//depth pass
				float4 normals = tex2D(_CameraDepthNormalsTexture, i.uv);		//normal pass
				float3 normalV = normals.xyz;
				float normalD = normals.w;

				depth *= _Sensitivity;
				float edge = depth;

				// float n = _Sensitivity * (tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(0, 1)).r);
				// float e = _Sensitivity * (tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(1, 0)).r);
				// float s = _Sensitivity * (tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(0, -1)).r);
				// float w = _Sensitivity * (tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(-1, 0)).r);
				// float ne = _Sensitivity * (tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(1, 1)).r);
				// float nw = _Sensitivity * (tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(-1, 1)).r);
				// float se = _Sensitivity * (tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(1, -1)).r);
				// float sw = _Sensitivity * (tex2D(_CameraDepthTexture, i.uv + _CameraDepthTexture_TexelSize * float2(-1, -1)).r);
				float2 n = i.uv + _CameraDepthTexture_TexelSize * float2(0, 1);
				float2 e = i.uv + _CameraDepthTexture_TexelSize * float2(1, 0);
				float2 s = i.uv + _CameraDepthTexture_TexelSize * float2(0, -1);
				float2 w = i.uv + _CameraDepthTexture_TexelSize * float2(-1, 0);
				float2 ne = i.uv + _CameraDepthTexture_TexelSize * float2(1, 1);
				float2 nw = i.uv + _CameraDepthTexture_TexelSize * float2(-1, 1);
				float2 se = i.uv + _CameraDepthTexture_TexelSize * float2(1, -1);
				float2 sw = i.uv + _CameraDepthTexture_TexelSize * float2(-1, -1);

				float Dn = _Sensitivity * (tex2D(_CameraDepthTexture, n).r);
				float De = _Sensitivity * (tex2D(_CameraDepthTexture, e).r);
				float Ds = _Sensitivity * (tex2D(_CameraDepthTexture, s).r);
				float Dw = _Sensitivity * (tex2D(_CameraDepthTexture, w).r);
				float Dne = _Sensitivity * (tex2D(_CameraDepthTexture, ne).r);
				float Dnw = _Sensitivity * (tex2D(_CameraDepthTexture, nw).r);
				float Dse = _Sensitivity * (tex2D(_CameraDepthTexture, se).r);
				float Dsw = _Sensitivity * (tex2D(_CameraDepthTexture, sw).r);

				float3 Nn = (tex2D(_CameraDepthNormalsTexture, n).xyz);
				float3 Ne = (tex2D(_CameraDepthNormalsTexture, e).xyz);
				float3 Ns = (tex2D(_CameraDepthNormalsTexture, s).xyz);
				float3 Nw = (tex2D(_CameraDepthNormalsTexture, w).xyz);
				float3 Nne = (tex2D(_CameraDepthNormalsTexture, ne).xyz);
				float3 Nnw = (tex2D(_CameraDepthNormalsTexture, nw).xyz);
				float3 Nse = (tex2D(_CameraDepthNormalsTexture, se).xyz);
				float3 Nsw = (tex2D(_CameraDepthNormalsTexture, sw).xyz);
				

				// if (n - s > _Thres || w - e > _Thres || e - w > _Thres || s - n > _Thres)
				// if (n - s < _Thres || w - e < _Thres || e - w < _Thres || s - n < _Thres)
				// 	edge = 1.0f;
					// col = 0.0f;
					// col /= 0.5f;
					
				// if (nw - se > _Thres || ne - sw > _Thres || se - nw > _Thres || sw - ne > _Thres)
				// 	edge = 1.0f;
					// col = 0.0f;
					// col /= 0.5f;
					
				float thres = 0.5;

				if (depth - Dne > _Thres || depth - Dnw > _Thres || depth - Dse > _Thres || depth - Dsw > _Thres)
					col /= 0.5f;
					// col = normals;
					// col = 0.0f;
					// edge = 0.5f;
					// edge = 1.0f;

				if (depth - Dn > _Thres || depth - De > _Thres || depth - Ds > _Thres || depth - Dw > _Thres)
					col = 1.0f;
					// col = normals;
					// edge = 1.0f;

				// if (length(normals - Nne) > thres || length(normals - Nnw) > thres || length(normals - Nse) > thres || length(normals - Nsw) > thres )
				// 	col *= 0.5f;
				
				// if (length(normals - Nn) > thres || length(normals - Ne) > thres || length(normals - Ns) > thres || length(normals - Nw) > thres )
				// 	col = 0.0f;

				// float4 img = depth;
				float4 img = col;
				// if (i.uv.x > 0.5)
					// img = float4(normalV, 1.0f);
					// img = float4(normalD,normalD,normalD, 1.0f);
					// img = float4(ndepth,ndepth,ndepth, 1.0f);
					// img = float4(edge, depth, depth, 1.0f);
				// float4 img = float4(edge, depth, depth, 1.0f);
				
				
				return img;
				// return float4(normal * 0.5 + 0.5, depth);
			}
			ENDCG
		}
	}
}
