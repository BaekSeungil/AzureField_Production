using System.Collections;
using System.Collections.Generic;
using UnityEngine;

enum OpenType
{
    Auto,
    Interaction,
    Stay
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

    [SerializeField] OpenType openType;
    [SerializeField] DoorType doorType;


    bool OpenDoor;
    public float MoveSpeed;

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

            }
        }

    }


    private void PosDoorType()
    {
        if(openType == OpenType.Auto)
        {
            AutdoOpenDoor();
        }
        else if(openType == OpenType.Interaction)
        {

        }
        else if(openType == OpenType.Stay)
        {
            AutdoOpenDoor();
        }

    }

    private void AutdoOpenDoor()
    {
        
        Vector3 leftcurrentPos = LeftDoor_Prefab.transform.position;
        Vector3 rightcurrentPos = RightDoor_Prefab.transform.position;
        Vector3 leftTargetPos = LeftPoint.transform.position;
        Vector3 rightTargetPos = RightPoint.transform.position;

         // 좌측 문을 이동시키기
         LeftDoor_Prefab.transform.position = Vector3.MoveTowards(leftcurrentPos, leftTargetPos, MoveSpeed * Time.deltaTime);

         // 우측 문을 이동시키기
         RightDoor_Prefab.transform.position = Vector3.MoveTowards(rightcurrentPos, rightTargetPos, MoveSpeed * Time.deltaTime);

    }

    
    private void OnTriggerEnter(Collider other) 
    {
        if(other.gameObject.layer == 6)
        {
            OpenDoor = true;
            Debug.Log("감지");
        }
    }

    private void OnTriggerStay(Collider other) 
    {
        OpenDoor = true;
    }

}
