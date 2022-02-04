using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessAndContract : MonoBehaviour
{
    public Material m_Material = null;

    [Range(0, 3)]
    public float m_Brightness = 1;
    [Range(0, 1)]
    public float m_Saturation = 1;
    [Range(0, 1)]
    public float m_Constrast = 1;

    public void OnRenderImage(RenderTexture src, RenderTexture dest) 
    {
        m_Material.SetFloat("_Brightness", m_Brightness);
        m_Material.SetFloat("_Saturation", m_Saturation);
        m_Material.SetFloat("_Constrast", m_Constrast);
        Debug.Log(m_Material.shader.isSupported);
        Graphics.Blit(src, dest, m_Material);
    }
}
