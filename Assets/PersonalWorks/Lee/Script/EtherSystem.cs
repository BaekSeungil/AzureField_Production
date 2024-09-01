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
    [SerializeField,LabelText("소멸시간")] public float DeletTime;
    [SerializeField]private ParticleSystem Idleparticl;


    private Vector3 startPosition; // 에테르가 생성된 초기 위치
    private Vector3 targetPosition;
    // Start is called before the first frame update
    private void Start()
    {
        callEther = FindObjectOfType<CallEther>();
        Idleparticl.Play();
        startPosition = callEther.Spawn.transform.position;
        transform.position = startPosition;

        Vector3 playerForward = callEther.Spawn.transform.forward;

        targetPosition = startPosition + playerForward.normalized * FinalDistance;


         // 목표 지점을 향하도록 오브젝트 회전 설정
        Quaternion rotation = Quaternion.LookRotation(playerForward);
        transform.rotation = rotation;

        StartCoroutine(DestroyAfterTime());
    }

    // Update is called once per frame
    private void Update() 
    {
        MoveWave();
    }

    public void MoveWave()
    {
        if(callEther.EtherCount >=2)
        {
            transform.position = Vector3.MoveTowards(transform.position, targetPosition, MoveSpeed * Time.deltaTime);
            // 도착 여부 확인
            if (Vector3.Distance(startPosition, targetPosition) < 0.1f)
            {
                callEther.IsCreat = false;
                callEther.EtherCount = 0;
                Destroy(gameObject);
                Debug.Log("파도소멸");
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Reef" || other.gameObject.layer == 8)
        {
            Destroy(gameObject);
            callEther.IsCreat = false;
        }
    }

    private IEnumerator DestroyAfterTime()
    {
        // 일정 시간이 지난 후 파도를 소멸시키는 코루틴
        yield return new WaitForSeconds(DeletTime);
        callEther.IsCreat = false;
        Destroy(gameObject);
    }

    private void OnDrawGizmos() 
    {
      
        Gizmos.color = Color.green;
        Gizmos.DrawLine(startPosition, transform.position);
        
        Gizmos.color = Color.red;
        Gizmos.DrawSphere(targetPosition, 0.2f);
        
    }
}
