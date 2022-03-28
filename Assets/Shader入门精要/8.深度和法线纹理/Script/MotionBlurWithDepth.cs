using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class MotionBlurWithDepth : PostProcessBase
{
    public Shader m_Shader = null;
    [Range(0, 10)]
    public float m_BlurSize = 0.5f;

    private Material m_Mat = null;
    private Matrix4x4 m_PreWorld2Proj;
    private Camera m_Camera = null;




    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (m_Camera == null)
        {
            m_Camera = GetComponent<Camera>();
            m_Camera.depthTextureMode |= DepthTextureMode.Depth;
        }
        if (m_Mat == null)
        {
            m_Mat = CreateMaterial(m_Shader, m_Mat);
        }
        m_Mat.SetFloat("_BlurSize", m_BlurSize);
        Matrix4x4 curWorld2Proj = m_Camera.projectionMatrix * m_Camera.worldToCameraMatrix;
        Matrix4x4 curProj2World = curWorld2Proj.inverse;
        m_Mat.SetMatrix("_CurProj2World", curProj2World);
        m_Mat.SetMatrix("_PreWorld2Proj", m_PreWorld2Proj);
        Graphics.Blit(source, destination, m_Mat);
        m_PreWorld2Proj = curWorld2Proj;
    }
}
