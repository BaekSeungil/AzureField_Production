using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Splines;

public class SplinePlayerTracker : MonoBehaviour
{
    [SerializeField] private SplineContainer track;
    [SerializeField] private float maxTrackDistance = 100f;
    Transform playerTF;

    private void Start()
    {
        var player = FindFirstObjectByType<PlayerCore>();
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
}
