using System.Collections;
using System.Collections.Generic;
using UnityEngine;

enum OpenType
{
    Auto,
    Interaction,
    Key
};

enum DoorType
{
    pos, // 미닫이문
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
    public bool OpenDoor = false;
    public float MoveSpeed;

    private void Awake()
    {
    
    }

    private void Update()
    {
        if(OpenDoor == true)
        {   
            if(openType == OpenType.Auto)
            {
                AutdoOpenDoor();
            }
            else if(openType == OpenType.Interaction)
            {

            }
            else if(openType == OpenType.Key)
            {
                AutdoOpenDoor();
            }
        }

        if(OpenDoor)
        {
            return;
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
    private void OnCollisionEnter(Collision other) 
    {
        if(other.gameObject.CompareTag("Player"))
        {
            OpenDoor = true;
            Debug.Log("감지");
        }
    }

    private void OnCollisionStay(Collision other) 
    {
        OpenDoor = true;
    }
}
