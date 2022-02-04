using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Edge : MonoBehaviour
{

    [Range(0, 1)]
    public float m_OnlyEdge = 0;
    public Color m_EdgeColor = Color.white;
    public Color m_BackGround = Color.white;
    public Material m_Matarial = null;

    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {

        m_Matarial.SetColor("_EdgeColor", m_EdgeColor);
        m_Matarial.SetColor("_BackGroundColor", m_BackGround);
        m_Matarial.SetFloat("_EdgeOnly", m_OnlyEdge);
        Graphics.Blit(source, destination, m_Matarial);
    }
}
