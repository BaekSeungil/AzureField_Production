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

     private void OnDrawGizmosSelected()
    {
        if (StatueObj == null || MoveAngle.Length == 0) return;

        Gizmos.color = Color.blue; // 기즈모 색상 설정

        // 석상의 위치
        Vector3 statuePos = StatueObj.transform.position;

        // 각도에 따른 방향 표시
        for (int i = 0; i < MoveAngle.Length; i++)
        {
            // 각도에 따른 방향 계산
            Quaternion rotation = Quaternion.Euler(0, MoveAngle[i], 0);
            Vector3 direction = rotation * Vector3.forward;

            // 기즈모로 화살표 그리기
            Gizmos.DrawRay(statuePos, direction * 10.0f); // 화살표 길이 2.0f로 설정
            Gizmos.DrawSphere(statuePos + direction * 10.0f, 0.5f); // 화살표 끝에 구 표시
        }
    }
}
