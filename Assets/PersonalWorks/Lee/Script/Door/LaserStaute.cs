using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LaserStaute : MonoBehaviour
{   
    [SerializeField,LabelText("레이저 시작지점")] public Transform startTrans; // 레이저 시작 위치
    [SerializeField,LabelText("오브젝트 지정")] public PuzzleDoor puzzleDoor; // 퍼즐 도어 스크립트가 있는 오브젝트
    [SerializeField,LabelText("레이저 거리")] public float maxLaserDistance = 20f; // 레이저 최대 거리
    private Vector3 direction; // 레이저 방향
    private LineRenderer laser; // 레이저 시각화를 위한 LineRenderer
    private Vector3 StartLaserPos; //레이저 초기 좌표값
    private bool CountSetKey = false; //오브젝트를 한번만 충돌을 허용하는 장치

    // Start is called before the first frame update
    void Start()
    {
        StartLaserPos = startTrans.position;

        laser = gameObject.GetComponent<LineRenderer>();
        direction = startTrans.forward; // 레이저는 시작점
        puzzleDoor = FindObjectOfType<PuzzleDoor>(); // 퍼즐 도어 찾기
    }

    // Update is called once per frame
    void Update()
    {
        FireLaser(); // 레이저 발사
    }

    // 레이저 발사 함수
    void FireLaser()
    {
        direction = startTrans.forward;
        laser.SetPosition(0,startTrans.position);
        laser.transform.rotation = startTrans.rotation; // 레이저 시작 위치 설정

        Ray ray = new Ray(startTrans.position, direction); // 레이저를 발사할 Ray 설정
        RaycastHit hit; // 충돌 정보 저장
        if (Physics.Raycast(startTrans.position,direction, out hit, maxLaserDistance))
        {
            laser.SetPosition(1, hit.point); // 레이저가 충돌한 지점까지 시각화
            if(!CountSetKey)
            {
                if(hit.collider.gameObject.layer == 8)
                {
                    CountSetKey = true;
                    puzzleDoor.OpenDoorCount ++;
                    Debug.Log("열쇠 카운트 쌓임");
                }
            }

        }
        else
        {
            laser.SetPosition(1, startTrans.position + direction * maxLaserDistance); // 충돌하지 않으면 최대 거리까지 레이저 발사
             if (CountSetKey)
            {
                CountSetKey = false; // 충돌 상태 해제
                puzzleDoor.OpenDoorCount--;
                Debug.Log("열쇠 카운트 감소");
            }
                
        }
    }

     private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red; // 레이저 색상

        Vector3 laserStartPos = startTrans.position; // 레이저 시작 지점
        Vector3 laserEndPos = laserStartPos + startTrans.forward * maxLaserDistance; // 최대 레이저 거리 계산

        RaycastHit hit;
        if (Physics.Raycast(laserStartPos, startTrans.forward, out hit, maxLaserDistance))
        {
            // 레이저가 충돌하면 충돌 지점까지 기즈모로 선 그리기
            Gizmos.DrawLine(laserStartPos, hit.point);
            Gizmos.DrawSphere(hit.point, 0.1f); // 충돌 지점에 작은 구 그리기
        }
        else
        {
            // 충돌하지 않으면 최대 거리까지 선 그리기
            Gizmos.DrawLine(laserStartPos, laserEndPos);
        }
    }

}
