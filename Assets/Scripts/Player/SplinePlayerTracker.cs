using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Splines;

public class SplinePlayerTracker : MonoBehaviour
{ 
    // 오브젝트의 Transform이 스플라인(베지어 커브) 위에서 플레이어와 가장 가까운 거리를 따라다닙니다.

    [SerializeField] private SplineContainer track;                 // 스플라인
    [SerializeField] private float maxTrackDistance = 100f;         // 인식 최대거리
    Transform playerTF;

    /// <summary>
    /// Spine의 내부에 있는지 확인하는 함수입니다. *반드시 스플라인이 "시계방향"으로 진행해야 합니다!!
    /// </summary>
    /// <param name="point">지점</param>
    /// <param name="splineContainer">스플라인 영역</param>
    /// <param name="nearestPointInSpline">(out)플레이어에서 가장 가까운 Spline경계면 위치</param>
    /// <returns></returns>
    public static bool IsInsideSpline(float3 point, SplineContainer splineContainer, out Vector3 nearestPointInSpline)
    {
        Vector3 pointPositionLocalToSpline = splineContainer.transform.InverseTransformPoint(point);
        Bounds splineBounds = splineContainer.Spline.GetBounds();

        SplineUtility.GetNearestPoint(splineContainer.Spline, pointPositionLocalToSpline, out var splinePoint, out var t);
        splinePoint.y = pointPositionLocalToSpline.y;
        

        if (Vector3.Distance(point, splineContainer.transform.TransformPoint( splineBounds.center)) < Vector3.Distance(splinePoint, splineBounds.center))
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

    private void OnEnable()
    {
        var player = PlayerCore.Instance;
        if (player != null)
            playerTF = player.transform;
    }

    private void FixedUpdate()
    {
        if (playerTF != null)
        {
            if (Vector3.Distance(playerTF.position, transform.position) < maxTrackDistance)
            {

                float3 playerPoint = new float3(playerTF.position.x, playerTF.position.y, playerTF.position.z); ;
                float3 nearPoint;
                float t;

                SplineUtility.GetNearestPoint(track.Spline, playerPoint, out nearPoint, out t);
                transform.position = new Vector3(nearPoint.x, nearPoint.y, nearPoint.z);
            }
        }



    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, maxTrackDistance);
    }
}


