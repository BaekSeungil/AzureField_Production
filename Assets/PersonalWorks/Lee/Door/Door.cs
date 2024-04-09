using System.Collections;
using System.Collections.Generic;
using UnityEngine;

enum OpenType
{
    Auto,
    Interaction, // 상호작용
    Key //열쇠
};

enum DoorType
{
    Pos, // 미닫이문
    Rot // 회전문
};

public class Door : MonoBehaviour
{
    [SerializeField] GameObject LeftDoor_Prefab;
    [SerializeField] GameObject RightDoor_Prefab;

    [SerializeField] GameObject LeftPoint;
    [SerializeField] GameObject RightPoint;

    [SerializeField] Transform rotationAxis; // 회전 축
    [SerializeField] float openAngle = 90f; // 회전할 각도

    [SerializeField] OpenType openType;
    [SerializeField] DoorType doorType;


    bool OpenDoor;
    bool KeyCode;
    public float MoveSpeed;


    private void Awake() 
    {
    
    }
    private void Update()
    {
        if(OpenDoor)
        {   
            if(doorType == DoorType.Pos)
            {   
               PosDoorType();
            }

            if(doorType == DoorType.Rot)
            {
                RotDoorType();
            }
        }

    }


    private void PosDoorType()
    {
        if(openType == OpenType.Auto)
        {
            if(OpenDoor)
            {
                AutdoOpenDoor();
            }
            else if(OpenDoor==false)
            {
                CloseDoor();
            }
        }
        else if(openType == OpenType.Interaction)
        {
            AutdoOpenDoor();
        }
        else if(openType == OpenType. Key)
        {
            if(KeyCode==true)
            {
                AutdoOpenDoor();
            }
            
        }

    }

    private void RotDoorType()
    { 
        if (openType == OpenType.Auto)
        {
            if (OpenDoor)
            {
                RotateDoor();
            }
        }
        else if (openType == OpenType.Interaction)
        {
            if (OpenDoor)
            {
                RotateDoor();
            }
        }
        else if (openType == OpenType.Key)
        {
            if (KeyCode == true)
            {
                RotateDoor();
            }
        }
      
    }

    private void RotateDoor()
    {
        // 회전각을 계산
        float currentAngle = Vector3.Angle(LeftDoor_Prefab.transform.position - rotationAxis.position, rotationAxis.up);

        // 회전각을 설정
        float targetAngle = Mathf.Clamp(currentAngle + openAngle, 0f, 90f);

        // 회전하는 각도만큼 좌측 문과 우측 문을 회전
        Quaternion leftTargetRotation = Quaternion.Euler(0f, -targetAngle, 0f);
        Quaternion rightTargetRotation = Quaternion.Euler(0f, +targetAngle, 0f);

        // 좌측 문과 우측 문의 회전 로테이션 설정
        LeftDoor_Prefab.transform.rotation = Quaternion.RotateTowards(LeftDoor_Prefab.transform.rotation, leftTargetRotation, MoveSpeed * Time.deltaTime);
        RightDoor_Prefab.transform.rotation = Quaternion.RotateTowards(RightDoor_Prefab.transform.rotation, rightTargetRotation, MoveSpeed * Time.deltaTime);

    }
    private void AutdoOpenDoor()
    {
        
        Vector3 leftcurrentPos = LeftDoor_Prefab.transform.position;
        Vector3 rightcurrentPos = RightDoor_Prefab.transform.position;
        Vector3 leftTargetPos = LeftPoint.transform.position;
        Vector3 rightTargetPos = RightPoint.transform.position;

         // 좌측 문을 이동
         LeftDoor_Prefab.transform.position = Vector3.MoveTowards(leftcurrentPos, leftTargetPos, MoveSpeed * Time.deltaTime);

         // 우측 문을 이동
         RightDoor_Prefab.transform.position = Vector3.MoveTowards(rightcurrentPos, rightTargetPos, MoveSpeed * Time.deltaTime);

    }

    private void CloseDoor()
    {   
        Vector3 leftcurrentPos = LeftDoor_Prefab.transform.position;
        Vector3 rightcurrentPos = RightDoor_Prefab.transform.position;


        // 좌측 문을 이동시키기
        LeftDoor_Prefab.transform.position = Vector3.MoveTowards(leftcurrentPos, leftcurrentPos, MoveSpeed * Time.deltaTime);

        // 우측 문을 이동시키기
        RightDoor_Prefab.transform.position = Vector3.MoveTowards(rightcurrentPos, rightcurrentPos, MoveSpeed * Time.deltaTime);

    }

    
    private void OnTriggerEnter(Collider other) 
    {
        if(other.gameObject.layer == 6)
        {
            OpenDoor = true;
            Debug.Log("감지");
        }
        OpenDoor = false;
    }

    private void OnTriggerStay(Collider other) 
    {   
        KeyCode = true;
        OpenDoor = true;
    }

    private void OnTriggerExit(Collider other) 
    {
        OpenDoor = false;
    }

}
