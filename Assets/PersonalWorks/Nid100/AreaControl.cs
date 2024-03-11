using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Splines;

public class AreaControl : MonoBehaviour
{
    public Transform playerPoint;
    public SplineContainer splineContainer;
    public Bounds splineBounds;

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 nearestPointInSpline;
        bool isInside = IsInsideSpline(ToVector3(playerPoint), splineContainer, splineBounds, out nearestPointInSpline);

        if (isInside)
        {
            Debug.Log("스플라인 안에 있습니다.");
        }
        else
        {
            Debug.Log("스플라인 밖으로 벗어났습니다.");
        }
    }

    public static Vector3 ToVector3(Transform transform)
    {
        return transform.position;
    }

    public static bool IsInsideSpline(Vector3 point, SplineContainer splineContainer, Bounds splineBounds, out Vector3 nearestPointInSpline)
    {
        Vector3 pointPositionLocalToSpline = splineContainer.transform.InverseTransformPoint(point);

        SplineUtility.GetNearestPoint(splineContainer.Spline, pointPositionLocalToSpline, out var splinePoint, out var t);
        splinePoint.y = pointPositionLocalToSpline.y;

        if (Vector3.Distance(point, splineContainer.transform.TransformPoint(splineBounds.center)) < Vector3.Distance(splinePoint, splineBounds.center))
        {
            // If point is inside of the spline...
            nearestPointInSpline = point;
            return true;
        }
        else
        {
            nearestPointInSpline = splineContainer.transform.TransformPoint(splinePoint);
            return false;
        }
    }
}
