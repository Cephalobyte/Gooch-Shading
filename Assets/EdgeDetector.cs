using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class EdgeDetector : MonoBehaviour {
    public Shader edgeShader;
    [Range(.01f, 1000f)] public float sensitivity;
    [Range(.001f, 1f)] public float threshold;
    
    private Material edgeMat;

    void Start() {
        if (edgeMat == null) {
            edgeMat = new Material(edgeShader);
            edgeMat.hideFlags = HideFlags.HideAndDontSave;
        }
        edgeMat.SetFloat("_Sensitivity", sensitivity);
        edgeMat.SetFloat("_Thres", threshold);

        Camera cam = GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.Depth | DepthTextureMode.DepthNormals;
        // cam.depthTextureMode = DepthTextureMode.DepthNormals;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination) {
        edgeMat.SetFloat("_Sensitivity", sensitivity);
        edgeMat.SetFloat("_Thres", threshold);
        Graphics.Blit(source, destination, edgeMat);
    }
}