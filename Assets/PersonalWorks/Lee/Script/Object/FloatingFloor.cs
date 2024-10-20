using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using Cinemachine;

public class FloatingFloor : MonoBehaviour
{   
    private enum FloatingState
    {
        Floating,
        Sinking,
        Returning
    }


    [Title("부유세팅")]
    
    [SerializeField,LabelText("속도는 0.1~10까지"), Range(0.1f, 10f), Tooltip("속도에 따라 0.1부터 10까지 움직임")]
    private float floatSpeed = 2f;

    [SerializeField,LabelText("반복구간 0.1~5까지"), Range(0.1f, 5f), Tooltip("위아래 반복 구간")]
    private float floatHeight = 1f;

    [SerializeField,LabelText("밀어내는 힘의 크기")] private float pushForce = 10f;
    [SerializeField,LabelText("하강 높이")] private float SinkHeight  = 2f;


    private Vector3 startPos;  
    private float targetY;
    private FloatingState currentState = FloatingState.Floating;

    private void Start()
    {
        startPos = transform.position;
    }

    private void Update()
    {
        switch (currentState)
        {
            case FloatingState.Floating:
                // 부유 상태일 때 상하 움직임
                float newY = startPos.y + Mathf.Sin(Time.time * floatSpeed) * floatHeight;
                transform.position = new Vector3(transform.position.x, newY, transform.position.z);
                break;

            case FloatingState.Sinking:
                // 하강 목표 Y축 설정
                targetY = startPos.y - SinkHeight;  
                transform.position = Vector3.MoveTowards(
                    transform.position, 
                    new Vector3(transform.position.x, targetY, transform.position.z), 
                    Time.deltaTime * floatSpeed
                );

                // 원래 위치로 돌아가는 로직
                if (Mathf.Abs(transform.position.y - targetY) < 0.01f)
                {
                    currentState = FloatingState.Returning;  // 하강 후 복귀 상태로 전환
                }
                break;

            case FloatingState.Returning:
 
                // 원래 위치로 돌아가는 로직
                transform.position = Vector3.MoveTowards(transform.position,startPos,
                Time.deltaTime * floatSpeed
                );

                // 원래 위치에 도달했는지 확인
                if (Mathf.Abs(transform.position.y - startPos.y) < 0.01f)
                {
                    currentState = FloatingState.Floating;  // 원래 위치에 도달하면 다시 부유 상태로 전환
                }
                break;
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
            currentState = FloatingState.Sinking;
        }
    }

    private void OnCollisionStay(Collision other) 
    {
        if(other.gameObject.layer == 6)
        {
            currentState = FloatingState.Sinking; 
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
