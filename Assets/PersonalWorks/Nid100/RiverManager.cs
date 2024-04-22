using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Splines;

public class RiverManager : MonoBehaviour
{
    [SerializeField] private PlayerCore player;
    [SerializeField] private Transform playerPoint;             //플레이어 좌표
    [SerializeField] private Transform flowPoint;            //강의 흐름 방향
    [SerializeField] private float flowPower;

    public bool isInside;                                   //플레이어의 통제구역 내부/외부를 확인
    public SplineContainer[] splineContainer;               //스플라인으로 만든 통제구역범위
    public Bounds splineBounds;                             //Bounds입니다. 건들지마시오.   


    private void Awake()
    {
        player = PlayerCore.Instance;
        playerPoint = PlayerCore.Instance.transform;
    }

    private void Start()
    {
        
    }

    private void Update()
    {
        Flow();
    }
    private void Flow() 
    {
        if (player.movementStateRefernce == "Swimming" || player.movementStateRefernce == "Sailboat")
            playerPoint.position = Vector3.MoveTowards(playerPoint.position, flowPoint.position, flowPower);
    }

    void PlayerAreaCheck()
    {
        Vector3 nearestPointInSpline;
        isInside = IsInsideSpline(ToVector3(playerPoint), splineContainer[0], splineBounds, out nearestPointInSpline);
    }

    /// <summary>
    /// 플레이어의 좌표를 Vector3로 변환해주는 함수
    /// </summary>
    /// <param name="transform"></param>
    /// <returns></returns>
    public static Vector3 ToVector3(Transform transform)
    {
        return transform.position;
    }

    /// <summary>
    /// 특정 점의 위치가 스플라인 영역의 내부/외부에 있는지 체크하는 함수
    /// </summary>
    /// <param name="point"></param>
    /// <param name="splineContainer"></param>
    /// <param name="splineBounds"></param>
    /// <param name="nearestPointInSpline"></param>
    /// <returns></returns>
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
