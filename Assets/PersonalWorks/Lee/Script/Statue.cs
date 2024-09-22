using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class Statue : MonoBehaviour
{
    [SerializeField,LabelText("석상 움직이는 각도")] public float[] MoveAngle; // 석상 움직이는 각도
    [SerializeField,LabelText("석상 오브젝트")] public GameObject StatueObj; // 석상 오브젝트 지정
    [SerializeField, LabelText("회전 속도")] public float rotationSpeed = 1.0f; // 회전 속도
    private Vector3 StartStatuePos; // 석상 초기 좌표값
    private int currentAngleIndex = 0; // 각도 배열 인덱스
    private bool isRotating = false;
    private Quaternion targetRotation;

    void Start()
    {
        StartStatuePos = StatueObj.transform.position;
        targetRotation = StatueObj.transform.rotation;
    }

    // Update is called once per frame
    void Update()
    {
        if(isRotating)
        {
            MoveStatueType();
        }
    }

    
    public void MoveStatueType()
    {

        AngleMoveStatue();
        
        
    }

    private void OnCollisionEnter(Collision other) 
    {
        if(other.gameObject.layer == 4 || other.gameObject.layer == 6)
        {
           isRotating = true;
           Debug.Log("닿음1");
        }
    }

    private void OnTriggerEnter(Collider other) 
    {
        if(other.gameObject.layer == 4 || other.gameObject.layer == 6)
        {
            isRotating = true;
            Debug.Log("닿음2");
        }
    }
    public void AngleMoveStatue()
    {

        // 목표 각도 설정
        float targetAngle = MoveAngle[currentAngleIndex];
        targetRotation = Quaternion.Euler(0, targetAngle, 0);
        StatueObj.transform.rotation = Quaternion.Lerp(StatueObj.transform.rotation, targetRotation, Time.deltaTime * rotationSpeed);

        if (Quaternion.Angle(StatueObj.transform.rotation, targetRotation) < 0.1f)
        {
            // 각도에 도달했을 때, 다음 각도로 이동
            currentAngleIndex++;

            if (currentAngleIndex >= MoveAngle.Length)
            {
                currentAngleIndex = 0; // 인덱스 1부터 다시 시작
            }
            Debug.Log("인덱스 위치" + currentAngleIndex);

            // 회전을 멈춤
            isRotating = false;
        }
    }
    
    private void OnDrawGizmos() 
    {
        Gizmos.color = Color.blue;

        for(int i =0; i < MoveAngle.Length; i++)
        {
            // 레이저의 발사 지점 기준으로 석상의 각도값을 적용
            float statueAngle = MoveAngle[i]; // 석상 각도
            Quaternion rotation = Quaternion.Euler(0, statueAngle, 0); // 석상 각도를 레이저에 적용
            Vector3 rotatedDirection = rotation * Vector3.forward; // 레이저 방향 회전

            Vector3 targetPos = StartStatuePos + rotatedDirection * 20f; // 회전된 방향에 맞춰 최대 거리까지 예상 경로 계산
            Gizmos.DrawLine(StartStatuePos, targetPos); // 예상 경로 그리기
            Gizmos.DrawSphere(targetPos, 0.1f); // 예상 충돌 지점에 구 그리기
        }


    }

}
