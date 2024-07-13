using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class volumetricRenderingSpace : MonoBehaviour
{
    [SerializeField]
    private Material VolumetricFogMaterial;

    // Update is called once per frame
    void Update()
    {
        if (VolumetricFogMaterial == null)
            return;

        Vector3 boundsMin = transform.position - transform.localScale / 2;
        Vector3 boundsMax = transform.position + transform.localScale / 2;

        VolumetricFogMaterial.SetVector("_volumeBoundsMin", boundsMin);
        VolumetricFogMaterial.SetVector("_volumeBoundsMax", boundsMax);
    }
}
