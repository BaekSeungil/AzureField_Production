using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class IslandArea : MonoBehaviour
{
    [SerializeField] private string islandID;
    [SerializeField] private float areaFadeStart = 50f;
    [SerializeField] private float fullArea = 100f;

    public float GetAreaInterpolation(Vector3 t_postion)
    {
        if (Vector3.Distance(transform.position, t_postion) > fullArea) return 0;
        else if(Vector3.Distance(transform.position, t_postion) < areaFadeStart) return 1;
        else
        {
            return Mathf.InverseLerp(fullArea, areaFadeStart, Vector3.Distance(transform.position, t_postion));
        }
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = new Color(0f, 1f, 0f, 1.0f);
        Gizmos.DrawWireSphere(transform.position, areaFadeStart);
        Gizmos.color = new Color(1f, 1f, 0f, 1.0f);
        Gizmos.DrawWireSphere(transform.position, fullArea);
    }
}
