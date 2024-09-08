using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LaserStaute : MonoBehaviour
{   
    [SerializeField,LabelText("레이저 시작지점")] public Transform startTrans; // 레이저 시작 위치
    [SerializeField,LabelText("오브젝트 지정")] public PuzzleDoor puzzleDoor; // 퍼즐 도어 오브젝트
    private Vector3 direction; // 레이저 방향
    LineRenderer laser; // 레이저 시각화를 위한 LineRenderer
    GameObject tempReflector; // 임시 반사 오브젝트
    public float maxLaserDistance = 100f; // 레이저 최대 거리

    // Start is called before the first frame update
    void Start()
    {
        laser = gameObject.GetComponent<LineRenderer>();
        direction = startTrans.forward; // 레이저는 시작점의 forward 방향으로 발사됨
        puzzleDoor = FindObjectOfType<PuzzleDoor>(); // 퍼즐 도어 찾기
        laser.SetPosition(0, startTrans.position);
    }

    // Update is called once per frame
    void Update()
    {
        FireLaser(); // 레이저 발사
    }

    // 레이저 발사 함수
    void FireLaser()
    {
        //laser.SetPosition(0, startTrans.position); // 레이저 시작 위치 설정
        Ray ray = new Ray(startTrans.position, direction); // 레이저를 발사할 Ray 설정
        RaycastHit hit; // 충돌 정보 저장

        if (Physics.Raycast(startTrans.position,direction, out hit, maxLaserDistance))
        {
            laser.SetPosition(1, hit.point); // 레이저가 충돌한 지점까지 시각화
           
        }
        else
        {
            laser.SetPosition(1, startTrans.position + direction * maxLaserDistance); // 충돌하지 않으면 최대 거리까지 레이저 발사
        }
    }

    // 레이저 반사 함수
    void ReflectLaser(RaycastHit hit)
    {
        Vector3 reflectDir = Vector3.Reflect(direction, hit.normal); // 반사 방향 계산
        direction = reflectDir; // 새로운 방향 설정
    }

    private void OnCollisionStay(Collision other) 
    {
        
    }
}
