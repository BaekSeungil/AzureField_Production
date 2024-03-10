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


