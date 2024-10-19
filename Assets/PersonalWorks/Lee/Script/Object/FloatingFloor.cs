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
    private float SickPower = 0.2f;
    [SerializeField,LabelText("하강속도")] private float SickSpeed = 2f;

    [SerializeField, LabelText("원래 위치로 돌아가는 시간")] private float returnDuration = 1.5f;

    private Vector3 startPos;  
    private Vector3 targetPos;
    private bool isSinking = false;
    private bool returningToStart = false;
     private bool isFloatingEnabled = true;
     private Coroutine returnCoroutine;
    private void Start()
    {
        startPos = transform.position;
        targetPos = startPos;
    }

    private void Update()
    {
        if (!isSinking && returningToStart == false && isFloatingEnabled)
        {
            float newY = startPos.y + Mathf.Sin(Time.time * floatSpeed) * floatHeight;
            transform.position = new Vector3(transform.position.x, newY, transform.position.z);
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

        if (other.gameObject.layer == 6)
        {
            isSinking = true;
            targetPos = new Vector3(startPos.x, startPos.y - SickPower, startPos.z);

            if (returnCoroutine != null)
            {
                StopCoroutine(returnCoroutine); // 이미 진행 중인 복귀 코루틴을 중단
            }

            isFloatingEnabled = false;  // 부양 기능 비활성화
        }
    }

    private void OnCollisionExit(Collision other) 
    {
        if(other.gameObject.layer == 6)
        {
            isSinking = false;
            returningToStart = true;
            returnCoroutine = StartCoroutine(ReturnToStartPosition());
        }
    }

    private IEnumerator ReturnToStartPosition()
    {
        Vector3 initialPos = transform.position;
        float elapsedTime = 0f;

        while (elapsedTime < returnDuration)
        {
            transform.position = Vector3.Lerp(initialPos, startPos, Mathf.SmoothStep(0f, 1f, elapsedTime / returnDuration));
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        transform.position = startPos;
        returningToStart = false;
        isFloatingEnabled = true;
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
