using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostProcessBase
{
    [Range(1,8)]
    public int m_DownSample = 1;
    [Range(1, 4)]
    public int m_Iteration = 3;
    [Range(0, 4)]
    public float m_LuminanceThreshold = 0.5f;
    [Range(0, 20)]
    public float m_BlurSize = 1.0f;

    public Shader m_Shader = null;
    private Material m_Mat = null;

    private Material Mat
    {
        get
        {
            if (m_Mat == null)
            {
                m_Mat = CreateMaterial(m_Shader, m_Mat);
            }
            return m_Mat;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        int width = source.width / m_DownSample;
        int height = source.height / m_DownSample;
        RenderTexture buffer0 = RenderTexture.GetTemporary(width, height, 0);
        Mat.SetFloat("_LuminanceThreshold", m_LuminanceThreshold);
        Mat.SetFloat("_BlurSize", m_BlurSize);
        Graphics.Blit(source, buffer0, Mat, 0);
        for (int i = 0, imax = m_Iteration; i < imax; i++) 
        {
            RenderTexture buffer1 = RenderTexture.GetTemporary(width, height, 0);
            Graphics.Blit(buffer0, buffer1, Mat, 1);
            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;

            buffer1 = RenderTexture.GetTemporary(width, height, 0);
            Graphics.Blit(buffer0, buffer1, Mat, 2);
            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;
        }
        Mat.SetTexture("_BloomTex", buffer0);
        Graphics.Blit(source, destination, Mat, 3);
        RenderTexture.ReleaseTemporary(buffer0);
    }
}
