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

    private Vector3 startPos;

    private void Start()
    {
        startPos = transform.position;
    }

    private void Update()
    {
        // Floating up and down using Mathf.Sin
        float newY = startPos.y + Mathf.Sin(Time.time * floatSpeed) * floatHeight;
        transform.position = new Vector3(transform.position.x, newY, transform.position.z);
    }

    private void OnCollisionEnter(Collision other) 
    {
        if (other.gameObject.layer == 0)
        {
            // 밀어내는 힘을 계산하고 적용
            Vector3 pushDirection = other.contacts[0].point - transform.position;
            pushDirection = -pushDirection.normalized;  // 반대 방향으로 힘을 줌

            float pushForce = 10f;  // 밀어내는 힘의 크기
            GetComponent<Rigidbody>().AddForce(pushDirection * pushForce, ForceMode.Impulse);
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
