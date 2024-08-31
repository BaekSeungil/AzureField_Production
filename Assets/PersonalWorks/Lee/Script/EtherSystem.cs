using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using UnityEngine;

public class EtherSystem : MonoBehaviour
{

    CallEther callEther;
    public bool CalledWave = false;
    [SerializeField,LabelText("전진 속도")] public float MoveSpeed;
    [SerializeField,LabelText("최종도착 거리")] public float FinalDistance;
    [SerializeField,LabelText("도착 거리 허용 오차")] public float Arrival = 0.1f;
    [SerializeField]private ParticleSystem Idleparticl;

    private Vector3 startPosition; // 에테르가 생성된 초기 위치
     private Vector3 targetPosition; // 목표 위치
    // Start is called before the first frame update
    private void Start()
    {
        callEther = FindObjectOfType<CallEther>();
        Idleparticl.Play();
        startPosition = transform.position;
        targetPosition = startPosition + transform.forward * FinalDistance;
    }

    // Update is called once per frame
    private void FixedUpdate() 
    {
        MoveWave();
    }

    public void MoveWave()
    {
        if(callEther.EtherCount >=2)
        {
           
            transform.position = Vector3.MoveTowards(transform.position, targetPosition, MoveSpeed * Time.deltaTime);

            // 도착 여부 확인
            if (Vector3.Distance(transform.position, targetPosition) < Arrival)
            {
                callEther.IsCreat = false;
                Destroy(gameObject);
            }
        }
    }

    private void OnCollisionEnter(Collision other) 
    {
        if (other.gameObject.tag == "Reef" && other.gameObject.layer == 8)
        {
            Destroy(gameObject);
        }
    }

    private void OnDrawGizmos() 
    {
      
            // 초기 위치가 설정되어 있으면 그 위치를 기준으로 기즈모를 그립니다.
            Gizmos.color = Color.green;
            Gizmos.DrawLine(startPosition, targetPosition);
            
            Gizmos.color = Color.red;
            Gizmos.DrawSphere(targetPosition, 0.2f);

            Gizmos.color = Color.yellow;
            Gizmos.DrawWireSphere(targetPosition, Arrival);

            Gizmos.color = Color.blue;
            Gizmos.DrawRay(startPosition, transform.forward * FinalDistance);
        
    }
}
