﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostProcessBase
{
    public Shader m_Shader = null;
    [Range(0f, 0.9f)]
    public float BlurAmount = 0.5f;

    private RenderTexture m_RenderTexture = null;
    private Material m_Mat = null;

    // Start is called before the first frame update
    void Start()
    {



    }

    // Update is called once per frame
    void Update()
    {

    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (m_Mat == null)
        {
            m_Mat = CreateMaterial(m_Shader, m_Mat);
        }
        if (m_RenderTexture != null && (m_RenderTexture.width != source.width || m_RenderTexture.height != source.height))
        {
            Object.DestroyImmediate(m_RenderTexture);
        }
        if (m_RenderTexture == null)
        {
            m_RenderTexture = RenderTexture.GetTemporary(source.width, source.height);
            Graphics.Blit(source, m_RenderTexture);
        }
        m_RenderTexture.MarkRestoreExpected(); // 下帧不销毁上帧RenderTexture的内容
        m_Mat.SetFloat("_BlurAmount", 1 - BlurAmount);
        Graphics.Blit(source, m_RenderTexture, m_Mat); // 上帧m_RenderTexture的内容没被覆盖,Rgb进行透明度混合,a按照原先值进行输出
        Graphics.Blit(m_RenderTexture, destination);
    }

}
