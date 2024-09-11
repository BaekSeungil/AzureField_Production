using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class CallEther : MonoBehaviour
{
    MainPlayerInputActions inputActions;
    EtherSystem etherSystem;

    [SerializeField,LabelText("파도 스폰 위치")] public GameObject Spawn;
    [SerializeField,LabelText("에테르프리펩")] public GameObject EtherWave;
    [SerializeField, LabelText("감지 반경")] private float detectionRadius = 5f;
    [SerializeField,LabelText("레이어 마스크 설정")] public LayerMask layerMask;
    private Collider spawnCollider;
    public bool OnSpawn = false;
    public bool IsCreat = false;
    public int EtherCount = 0; //에테르 입력 값 1번누르면 스폰, 2번누르면 에테르 정면이동
    void Start()
    {
        etherSystem = FindObjectOfType<EtherSystem>();
        inputActions = new MainPlayerInputActions();
        inputActions.Player.Ether.Enable();
    }

    // Update is called once per frame
    void Update()
    {
        if(inputActions.Player.Ether.WasPressedThisFrame())
        {
            Collider[] hitColliders = Physics.OverlapSphere(Spawn.transform.position, detectionRadius, layerMask);

            // 감지된 오브젝트가 있다면 파도를 생성
            if (hitColliders.Length > 0 && !IsCreat)
            {
                Instantiate(EtherWave, Spawn.transform.position, Quaternion.identity);
                IsCreat = true;
                EtherCount = 1;  // 상태를 1로 설정하여 생성된 상태로 표시합니다.
                Debug.Log("파도 생성 (범위 내에 객체 감지)");
            }
            // 파도가 이미 생성된 상태에서 다시 키를 누르면 파도를 이동시킵니다.
            else if (IsCreat && EtherCount == 1)
            {
                EtherCount = 2;  // 상태를 2로 설정하여 이동 신호를 보냅니다.
                Debug.Log("파도 이동 신호 전송");
                if(EtherCount == 2)
                {
                    EtherCount = 0;
                }
            }
        }
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(Spawn.transform.position, detectionRadius);  // 감지 반경을 시각화
    }   


}
