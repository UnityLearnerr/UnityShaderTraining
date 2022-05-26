using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class MotionBlurWithDepthTexture : PostProcessBase
{
    public Shader m_Shader = null;
    private Material m_Material = null;
    private Matrix4x4 m_PreWorld2ProjMatrix;

    private Camera mm_Camera = null;
    private Camera m_Camera
    {
        get
        {
            if (mm_Camera == null)
            {
                mm_Camera = GetComponent<Camera>();
            }
            return mm_Camera;
        }
    }



    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (m_Shader == null)
        {
            Graphics.Blit(source, destination);
            return;
        }
        if (m_Material == null)
        {
            m_Material = CreateMaterial(m_Shader, m_Material);
            Matrix4x4 curWorld2ProjMatrix = m_Camera.projectionMatrix * m_Camera.worldToCameraMatrix;
            Matrix4x4 curProj2WorldMatrix = curWorld2ProjMatrix.inverse;
            m_Material.SetMatrix("_CurProj2WorldMatrix", curProj2WorldMatrix);
            Matrix4x4 preWorld2ProjMatrix = m_PreWorld2ProjMatrix;
            m_Material.SetMatrix("_PreWorld2ProjMatrix", preWorld2ProjMatrix);
            m_PreWorld2ProjMatrix = curWorld2ProjMatrix;
        }
    }







}
