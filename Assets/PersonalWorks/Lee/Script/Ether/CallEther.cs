using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class CallEther : MonoBehaviour
{
    MainPlayerInputActions inputActions;
    EtherSystem etherSystem;

    //[SerializeField,LabelText("파도 스폰 위치")] public GameObject Spawn;
    [LabelText("파도 스폰 위치")]public Vector3 SpawnPoint;
    [LabelText("에테르프리펩")] public GameObject EtherWave;
    [SerializeField, LabelText("감지 반경")] private float detectionRadius = 5f;
    [LabelText("레이어 마스크 설정")] public LayerMask layerMask;

    private Collider[] hitColliders;
    private GameObject etherWave;

    public bool OnSpawn = false;
    public bool IsCreat = false;
    public int EtherCount = 0; //에테르 입력 값 1번누르면 스폰, 2번누르면 에테르 정면이동
    private void Start()
    {
        Initialized();
    }

    // Update is called once per frame
    private void Update()
    {
        if(inputActions.Player.Ether.WasPressedThisFrame())
        {
            InteractWaves();
        }
    }

    private void InteractWaves()
    {
        hitColliders = Physics.OverlapSphere(SpawnPoint, detectionRadius, layerMask);

        // 감지된 오브젝트가 있다면 파도를 생성
        if (hitColliders.Length > 0 && !IsCreat)
        {
            SpawnWave();
        }
        // 파도가 이미 생성된 상태에서 다시 키를 누르면 파도를 이동시킵니다.
        else if (IsCreat && EtherCount == 1)
        {
            EtherCount = 2;  // 상태를 2로 설정하여 이동 신호를 보냅니다.
            PrintDebug("파도 이동 신호 전송");

        }
        else if (IsCreat && EtherCount == 2)
        {
            EtherCount = 3;  // 상태를 2로 설정하여 이동 신호를 보냅니다.
            PrintDebug("파도 이동 신호 전송");
        }
    }

    private void SpawnWave()
    {
        etherWave.SetActive(true);
        //Physics.Raycast(transform.position, Vector3.down, out RaycastHit ray, layerMask);
        //etherWave.transform.position = new Vector3(ray.point.x, 0, ray.point.z);
        IsCreat = true;
        EtherCount = 1;  // 상태를 1로 설정하여 생성된 상태로 표시합니다.
        PrintDebug("파도 생성 (범위 내에 객체 감지)");
    }

    private void Initialized()
    {
        etherSystem = FindObjectOfType<EtherSystem>();
        inputActions = new MainPlayerInputActions();
        inputActions.Player.Ether.Enable();

        if (SpawnPoint.magnitude == 0)
            SpawnPoint.z = 6.46f;

        etherWave = Instantiate(EtherWave, SpawnPoint, Quaternion.identity);
        etherWave.transform.position = transform.position + (transform.forward * SpawnPoint.z);
        etherWave.SetActive(false);
    }


    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(SpawnPoint, detectionRadius);  // 감지 반경을 시각화
    }   

    private void PrintDebug(string str)
    {
#if UNITY_EDITOR
        Debug.Log(str);
#endif
    }

}
