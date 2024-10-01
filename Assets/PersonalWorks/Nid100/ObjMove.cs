using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjMove : MonoBehaviour
{
    public GameObject moveObj;
    public Transform movePoint;
    public float speed = 2.0f;

    public bool moveOnoff = false;

    void Update()
    {
        if (moveOnoff == true)
        {
            if (moveObj != null && movePoint != null)
            {
                moveObj.transform.position = Vector3.MoveTowards(
                    moveObj.transform.position,  // 현재 위치
                    movePoint.position,           // 목표 위치
                    speed * Time.deltaTime        // 속도 (프레임 독립적)
                );
            }
        }
    }

}
