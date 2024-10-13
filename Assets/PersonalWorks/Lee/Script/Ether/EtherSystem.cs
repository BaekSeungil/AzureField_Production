using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using UnityEngine;

public class EtherSystem : MonoBehaviour
{

    CallEther callEther;
    public bool CalledWave = false;
    [SerializeField,LabelText("전진 속도")] private float MoveSpeed;
    [SerializeField,LabelText("최종도착 거리")] private float FinalDistance;
    [SerializeField,LabelText("소멸시간")] private float DeletTime;
    [SerializeField]private ParticleSystem Idleparticl;

    private Vector3 startPosition; // 에테르가 생성된 초기 위치
    private Vector3 targetPosition;

    private float currentSpeed = 0;
    
    public static EtherSystem Instance { get; private set; }

    public float ViewDeletTime{get{return DeletTime;}}

    private void Awake() 
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject); // 씬 전환 시에도 파괴되지 않도록
        }
        else
        {
            gameObject.SetActive(false);
        }
        callEther = FindObjectOfType<CallEther>();
    }

    private void Start()
    {
        Initialized();

    }
    
    // Update is called once per frame
    private void Update() 
    {
        MoveWave();
    }

    public void MoveWave()
    {
        if (callEther.EtherCount == 3)
        {
            // 파도 멈추기
            currentSpeed = 0;
            Debug.Log("파도 멈춤");
            return;  // 더 이상 아래 코드 실행하지 않음
        }

        if(callEther.EtherCount ==2)
        {
            transform.position = Vector3.MoveTowards(transform.position, targetPosition, currentSpeed * Time.deltaTime);
            // 도착 여부 확인
            if (Vector3.Distance(transform.position, targetPosition) < 0.1f)
            {
                callEther.IsCreat = false;
                Debug.Log("파도소멸");
                gameObject.SetActive(false);
            }
        }
    }

    public void EtherUpgradeState(float upgrdestate)
    {
        DeletTime += upgrdestate;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Reef" || other.gameObject.layer == 8)
        {
            callEther.IsCreat = false;
            gameObject.SetActive(false);
        }
    }

    private IEnumerator DestroyAfterTime()
    {
        // 일정 시간이 지난 후 파도를 소멸시키는 코루틴
        yield return new WaitForSeconds(DeletTime);
        callEther.IsCreat = false;
        gameObject.SetActive(false);
    }

    public Vector3 GetWaveDirection()
    {
        Vector3 playerForward = PlayerCore.Instance.transform.forward;
        targetPosition = startPosition + playerForward.normalized * FinalDistance;
        return (targetPosition - startPosition).normalized;
    }

    private void OnEnable()
    {
        //SetTransform();
        Initialized();
    }
    private void Initialized()
    {
        Idleparticl.Play();
        currentSpeed = MoveSpeed;

        SetTransform();

        StartCoroutine(DestroyAfterTime());
    }

    private void SetTransform()
    {
        startPosition = (callEther.transform.forward * callEther.SpawnPoint.z) + callEther.transform.position;
        transform.position = new Vector3(startPosition.x, 0, startPosition.z);

        Vector3 playerForward = PlayerCore.Instance.transform.forward;

        targetPosition = startPosition + playerForward.normalized * FinalDistance;


        // 목표 지점을 향하도록 오브젝트 회전 설정
        Quaternion rotation = Quaternion.LookRotation(playerForward);
        transform.rotation = rotation;

    }

    private void OnDrawGizmos() 
    {
      
        Gizmos.color = Color.green;
        Gizmos.DrawLine(startPosition, transform.position);
        
        Gizmos.color = Color.red;
        Gizmos.DrawSphere(targetPosition, 0.2f);
        
    }
}
