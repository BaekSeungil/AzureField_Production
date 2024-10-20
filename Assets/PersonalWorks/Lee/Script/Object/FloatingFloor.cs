using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using Cinemachine;

public class FloatingFloor : MonoBehaviour
{   
    [Title("부유세팅")]
    
    [SerializeField,LabelText("속도는 0.1~10까지"), Range(0.1f, 10f), Tooltip("속도에 따라 0.1부터 10까지 움직임")]
    private float floatSpeed = 2f;

    [SerializeField,LabelText("반복구간 0.1~5까지"), Range(0.1f, 5f), Tooltip("위아래 반복 구간")]
    private float floatHeight = 1f;

    [SerializeField,LabelText("밀어내는 힘의 크기")] private float pushForce = 10f;
    [SerializeField,LabelText("하강 높이")] private float SinkHeight  = 2f;


    private Vector3 startPos;  
    private float targetY;
    private bool isSinking = true;
    private bool isReturning = false;
    private void Start()
    {
        startPos = transform.position;
    }

    private void Update()
    {
        if(isSinking)
        {
            // 부유 상태일 때 상하 움직임
            float newY = startPos.y + Mathf.Sin(Time.time * floatSpeed) * floatHeight;
            transform.position = new Vector3(transform.position.x, newY, transform.position.z);
        }
        else
        {
            // 플레이어 충돌 시 하강
            targetY = startPos.y - SinkHeight;  // 하강 목표 Y축 설정
            transform.position = Vector3.MoveTowards(
                transform.position, 
                new Vector3(transform.position.x, targetY, transform.position.z), 
                Time.deltaTime * floatSpeed
            );

            isReturning = true;   
            // 원래 위치로 돌아가는 로직
            if (isReturning)
            {
                transform.position = Vector3.MoveTowards(
                    transform.position, 
                    new Vector3(transform.position.x, startPos.y, transform.position.z), 
                    Time.deltaTime * floatSpeed
                );

                // 원래 위치에 도달하면 다시 부유 상태로 돌아감
                if (Mathf.Abs(transform.position.y) <= startPos.y)
                {
                    isReturning = false;
                    isSinking = true;
                }
            }
        }
    }

    private void OnCollisionEnter(Collision other) 
    {
        // if (other.gameObject.layer == 0)
        // {
        //     // 밀어내는 힘을 계산하고 적용
        //     Vector3 pushDirection = other.contacts[0].point - transform.position;
        //     pushDirection = -pushDirection.normalized;  // 반대 방향으로 힘을 줌
        //     GetComponent<Rigidbody>().AddForce(pushDirection * pushForce, ForceMode.Impulse);
        // }

        if(other.gameObject.layer == 6)
        {
            isSinking = false;
        }
    }

    private void OnCollisionStay(Collision other) 
    {
        if(other.gameObject.layer == 6)
        {
            isSinking = false;
        }
    }

    private void OnDrawGizmos()
    {
        if (!Application.isPlaying)
        {
            startPos = transform.position;
            Gizmos.color = Color.green;

            Vector3 topPosition1 = new Vector3(startPos.x, startPos.y + floatHeight, startPos.z);
            Vector3 bottomPosition1 = new Vector3(startPos.x, startPos.y - floatHeight, startPos.z);

            Gizmos.DrawLine(topPosition1, bottomPosition1);
            Gizmos.DrawSphere(topPosition1, 0.1f);
            Gizmos.DrawSphere(bottomPosition1, 0.1f);

        }

        Gizmos.color = Color.green;

        Vector3 topPosition = new Vector3(startPos.x, startPos.y + floatHeight, startPos.z);
        Vector3 bottomPosition = new Vector3(startPos.x, startPos.y - floatHeight, startPos.z);

        Gizmos.DrawLine(topPosition, bottomPosition);
        Gizmos.DrawSphere(topPosition, 0.1f);
        Gizmos.DrawSphere(bottomPosition, 0.1f);
    }
}
