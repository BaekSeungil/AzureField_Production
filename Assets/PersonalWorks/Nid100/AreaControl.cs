using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Splines;


/// <summary>
/// 맵의 통제구역을 관리하는 스크립트입니다.  
/// </summary>
public class AreaControl : StaticSerializedMonoBehaviour<AreaControl>
{
    #region Properties
    [SerializeField] private float countDownTimer = 30f;       //플레이어가 영역밖으로 나가면 카운트다운으로 사용될 변수입니다.
    [SerializeField] private float countDownOverTimer = 6f;     //countDownTimer의 타이머가 끝나고 플레이어 익사 애니메이션이 나오는 시간입니다.
    [SerializeField] private static string recentLand;                //최근 방문한 섬
    [SerializeField] private static Vector3 respawnTransgorm;
    [SerializeField] private GameObject player;
    [SerializeField] private Transform playerPoint;             //플레이어 좌표
    [SerializeField] private GameObject fade;
    #endregion
                    
    public bool isInside;                                   //플레이어의 통제구역 내부/외부를 확인
    public SplineContainer[] splineContainer;               //스플라인으로 만든 통제구역범위
    public Bounds splineBounds;                             //Bounds입니다. 건들지마시오.                   

    

    protected override void Awake()
    {
        base.Awake();
        player = GameObject.Find("MainCharacter");
        playerPoint = GameObject.Find("MainCharacter").GetComponent<Transform>();
        fade = GameObject.Find("Fade");
    }

        void Update()
    {
        PlayerAreaCheck();
        InOutArea();
    }

    /// <summary>
    /// 플레이어가 영역 내부/외부에 있는지 확인하는 함수입니다.
    /// </summary>
    void PlayerAreaCheck() 
    {
        Vector3 nearestPointInSpline;
        isInside = IsInsideSpline(ToVector3(playerPoint), splineContainer[0], splineBounds, out nearestPointInSpline);
    }

    public static void RecentLandRecord(string landName,Vector3 spawnTransform)
    {
        recentLand = landName;
        respawnTransgorm = spawnTransform;
        Debug.Log(recentLand);
    }

    /// <summary>
    /// 플레이어가 통제구역 내부/외부에 있을 경우 호출하는 함수
    /// </summary>
    void InOutArea() 
    {
        if (isInside)
        {
            //Debug.Log("스플라인 안에 있습니다.");
            countDownTimer = 30.0f;
        }
        else
        {
            //Debug.Log("스플라인 밖으로 벗어났습니다.");
            countDown();
        }
    }

    /// <summary>
    /// 플레이어가 영역밖으로 나가면 카운트다운이 시작되는 함수입니다. 카운트가 0이 됬을 경우의 처리도 여기서 합니다.
    /// </summary>
    void countDown() 
    {
        if (countDownTimer >= 0f)
        {
            countDownTimer -= Time.deltaTime;
            Debug.Log("남은 시간 : " + countDownTimer);
        }
        else if (countDownTimer >= -countDownOverTimer)
        {
            countDownTimer -= Time.deltaTime;
            player.GetComponent<PlayerCore>().DisableForSequence();
            player.GetComponent<PlayerCore>().SailboatQuit();

            Debug.Log("캐릭터 이동정지 및 조각배 강제 하차");
        }
        else if (countDownTimer >= -countDownOverTimer - 5f)
        {
            countDownTimer -= Time.deltaTime;
            fade.GetComponent<FadeInOut>().FadeInExecution();
        }
        else
        {
            playerPoint.position = respawnTransgorm;
            fade.GetComponent<FadeInOut>().FadeOutExecution();
            player.GetComponent<PlayerCore>().EnableForSequence();

        }
        
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
