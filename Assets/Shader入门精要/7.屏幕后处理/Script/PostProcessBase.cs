using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostProcessBase : MonoBehaviour
{

    // Start is called before the first frame update
    void Start()
    {
        Check();
    }

    private bool Check()
    {
        if (!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            return false;
        }
        return true;
    }


    protected Material CreateMaterial(Shader shader, Material mat)
    {
        if (shader == null)
        {
            return null;
        }
        if (mat != null)
        {
            if (mat.shader == shader)
            {
                return mat;
            }
            else
            {
                mat.shader = shader;
                return mat;
            }
        }
        else
        {
            mat = new Material(shader);
            return mat;
        }
    }
}
