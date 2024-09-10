using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public enum StatueMoveType
{
    realTimeType = 0, // 실시간으로 움직임
    AngleType = 1 // 정해진 각도로 움직임
};

public class Statue : MonoBehaviour
{
    [SerializeField,LabelText("석상 움직임 타입")] public StatueMoveType movetype;
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
        if (movetype == StatueMoveType.AngleType)
        {
            AngleMoveStatue();
        }
        else if (movetype == StatueMoveType.realTimeType)
        {
            RealTimeStatue();
        }
        
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

    public void RealTimeStatue()
    {

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
}
