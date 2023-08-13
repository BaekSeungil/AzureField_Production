using DG.Tweening;
using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SailboatBehavior : MonoBehaviour
{
    [Title("BottomPlane")]
    [SerializeField] private Transform floatingPoint1;
    [SerializeField] private Transform floatingPoint2;
    [SerializeField] private Transform floatingPoint3;

    private Plane surfacePlane;
    public Plane SurfacePlane { get { return surfacePlane; } }
    [SerializeField,ReadOnly] private float submergeRate = 0.0f;
    public float SubmergeRate { get { return submergeRate; } }

    private void Start()
    {
        if (GlobalOceanManager.Instance == null)
        {
            Debug.Log("SailboatBehavior를 사용하려면 Global Ocean Manager를 생성하세요!");
        }

        surfacePlane = new Plane(Vector3.up, 0f);
    }

    private void FixedUpdate()
    {
        float[] surface = new float[3];

        surface[0] = GlobalOceanManager.Instance.GetWaveHeight(floatingPoint1.position);
        surface[1] = GlobalOceanManager.Instance.GetWaveHeight(floatingPoint2.position);
        surface[2] = GlobalOceanManager.Instance.GetWaveHeight(floatingPoint3.position);

        submergeRate = (floatingPoint1.position.y - surface[0] + floatingPoint2.position.y - surface[1] + floatingPoint3.position.y - surface[2]) / 3f;

        surfacePlane = new Plane(
            new Vector3(floatingPoint1.position.x, surface[0], floatingPoint1.position.z),
            new Vector3(floatingPoint2.position.x, surface[1], floatingPoint2.position.z),
            new Vector3(floatingPoint3.position.x, surface[2], floatingPoint3.position.z));

    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.magenta;
        Gizmos.DrawRay(transform.position, surfacePlane.normal);
    }
}
