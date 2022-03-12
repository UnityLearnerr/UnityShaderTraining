using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostProcessBase
{
    [Range(0, 4)]
    public int m_Itorations = 1;
    [Range(1, 4)]
    public int m_DownSample = 2;
    public Shader m_Shader;
    private Material m_Material = null;
    private Material Mat
    {
        get 
        {
            if (m_Material == null) 
            {
                m_Material = CreateMaterial(m_Shader, m_Material);
            }
            return m_Material;
        }
    }


    // Start is called before the first frame update
    void Start()
    {
       
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        int width = source.width / m_DownSample;
        int height = source.height / m_DownSample;
        RenderTexture buffer0 = RenderTexture.GetTemporary(width, height);
        Graphics.Blit(source, buffer0);
        for (int i = 0, imax = m_Itorations; i < imax; i++) 
        {
            RenderTexture buffer1 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(buffer0, buffer1, Mat, 0);
            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;

            buffer1 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(buffer0, buffer1, Mat, 1);
            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;
        }
        Graphics.Blit(buffer0, destination);
        RenderTexture.ReleaseTemporary(buffer0);
    }
}
