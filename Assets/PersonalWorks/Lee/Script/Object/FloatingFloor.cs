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

    [SerializeField,LabelText("충돌시 하강량"),Tooltip("플레이어와 충돌시 얼마나 하강하는 힘의 크기")]
    private float SickPower = 4f;

    private Vector3 startPos;  
    private Vector3 targetPos;
    private bool isSinking = true;
    private bool isReturning = false;
    private void Start()
    {
        startPos = transform.position;
        targetPos = startPos;
    }

    private void Update()
    {
       if (isSinking)
        {
            // 부유 상태일 때 상하 움직임
            float newY = startPos.y + Mathf.Sin(Time.time * floatSpeed) * floatHeight;
            transform.position = new Vector3(transform.position.x, newY, transform.position.z);
        }
        else if (!isSinking && !isReturning)
        {
            // 플레이어 충돌 시 하강
            targetPos = new Vector3(startPos.x, startPos.y - SickPower, startPos.z);
            transform.position = Vector3.Lerp(transform.position, targetPos, Time.deltaTime * floatSpeed);
        }
        else if (isReturning)
        {
            // 플레이어가 떠난 후 원래 위치로 돌아감
            transform.position = Vector3.Lerp(transform.position, startPos, Time.deltaTime * floatSpeed);

            // 원래 위치에 도달하면 부유 상태로 돌아감
            if (Vector3.Distance(transform.position, startPos) < 0.01f)
            {
                isReturning = false;
                isSinking = true;
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

    private void OnCollisionExit(Collision other) 
    {
        if(other.gameObject.layer == 6)
        {
          isReturning = true;
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
