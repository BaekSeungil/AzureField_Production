using Sirenix.OdinInspector;
using Sirenix.Utilities;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Splines;

public class FairwindChallengeInstance : MonoBehaviour
{
    [InfoBox("프리셋 오브젝트는 꼭 Unpack해서 사용하세요! \n시작점은 붉은색, 경유지는 보라색, 도착점은 초록색으로 표시됩니다.\n 노란색은 플레이어가 순풍의 도전을 진행하면서 유지해야될 거리를 나타냅니다. \n 경로를 편집하고싶다면, Route의 스플라인을 편집하세요.")]
    [SerializeField] private string iD;
    public string ID { get { return iD; } }
    [SerializeField, LabelText("제한 시간")] private float timelimit;
    public float Timelimit { get { return timelimit; } }


    [Title("공용 필드")]
    [ShowInInspector, LabelText("판정반경")] private static float triggerDistance = 5f;
    [ShowInInspector, LabelText("이탈거리")] private static float distanceAllowence = 10f;
    [ShowInInspector, LabelText("이탈경고시간")] private static float distanceAllowenceTime = 3f;

    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private GameObject lightPilarPrefab;
    [SerializeField, Required, FoldoutGroup("ChildReferences")] 
    private SplineContainer route;
    /// <summary>
    /// 경로의 스플라인 데이터를 가져옵니다.
    /// </summary>
    public Spline RouteSpline { get { return route.Spline; } }

    enum ChallengeState
    {
        Standby,
        Active,
        Aborted,
        Closed
    }
    private ChallengeState currentState = ChallengeState.Standby;
    private int activeKnotIndex = 0;

    // knots Info
    private Vector3[] routeKnotList;
    private Vector3 startKnotPosition;
    private Vector3 endKnotPosition;

    /// <summary>
    /// 해당 순풍의 도전의 스플라인의 연결지점들을 가져옵니다.
    /// </summary>
    /// <param name="positionList"> 할당할 리스트 </param>
    /// <param name="WorldPosition"> true = 월드좌표계, false = 로컬좌표계 </param>
    public void GetRoutePositions(out Vector3[] positionList, bool WorldPosition = true)
    {
        var bezierKnots = route.Spline.Knots.ToArray();
        positionList = new Vector3[bezierKnots.Length];

        for (int i = 0; i < bezierKnots.Length; i++)
        {
            if (WorldPosition)
                positionList[i] = AZFUtilities.F3ToVec3(bezierKnots[i].Position) + transform.position;
            else
                positionList[i] = AZFUtilities.F3ToVec3(bezierKnots[i].Position);
        }
    }

    /// <summary>
    /// 순풍의 도전이 진행중이라면 강제로 중지합니다.
    /// </summary>
    public void AbortChallenge()
    {

    }

    private void OnChallengeActivated()
    {

    }

    private void Start()
    {
        if(route != null)
        {
            GetRoutePositions(out routeKnotList);
            startKnotPosition = routeKnotList[0];
            if(routeKnotList.Length > 1)
            {
                endKnotPosition = routeKnotList[routeKnotList.Length-1];
            }
        }
    }

    private void Update()
    {
        if (currentState == ChallengeState.Standby)
        {
            
            if (GetProjectedDistanceFromPlayer(startKnotPosition) < triggerDistance)
            {
                currentState = ChallengeState.Active;
                OnChallengeActivated();
            }
        }
        else if(currentState == ChallengeState.Aborted)
        {
            if(GetProjectedDistanceFromPlayer(startKnotPosition) > triggerDistance)
            {
                currentState = ChallengeState.Standby;
            }
        }
    }

    private float GetProjectedDistanceFromPlayer(Vector3 target)
    {
        if (!PlayerCore.IsInstanceValid) { Debug.LogError("플레이어 코어 없음."); return float.NaN; }
        Vector2 projectedPlayerPositon = new Vector2(PlayerCore.Instance.transform.position.x, PlayerCore.Instance.transform.position.z);
        return Vector2.Distance(projectedPlayerPositon, new Vector2(startKnotPosition.x, startKnotPosition.z));
    }

    private void OnDrawGizmos()
    {
        if (route != null)
        {
            Start();

            var knots = route.Spline.Knots.ToArray();

            int knotCount = route.Spline.Knots.Count();

            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(startKnotPosition, triggerDistance);
            Gizmos.color = Color.yellow;
            Gizmos.DrawWireSphere(startKnotPosition, distanceAllowence);

            if (knotCount > 3)
            {
                for (int i = 1; i < knotCount - 1; i++)
                {
                    Gizmos.color = Color.magenta;
                    Gizmos.DrawWireSphere(AZFUtilities.F3ToVec3(knots[i].Position) + transform.position, triggerDistance);
                }
            }
            
            if (knotCount > 2)
            {
                Gizmos.color = Color.green;
                Gizmos.DrawWireSphere(endKnotPosition, triggerDistance);
            }
        }
    }
}
