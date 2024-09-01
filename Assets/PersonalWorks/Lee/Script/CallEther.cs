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
    private Collider spawnCollider;
    public bool OnSpawn = false;
    public bool IsCreat = false;
    public int EtherCount = 0; //에테르 입력 값 1번누르면 스폰, 2번누르면 에테르 정면이동
    void Start()
    {
        etherSystem = FindObjectOfType<EtherSystem>();
        inputActions = new MainPlayerInputActions();
        inputActions.Player.Ether.Enable();

        if(Spawn != null)
        {
            spawnCollider = Spawn.GetComponent<Collider>();
            if(spawnCollider == null)
            {
                Debug.Log("스폰에 콜라이더가 없습니다.");
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        if(inputActions.Player.Ether.WasPressedThisFrame())
        {
            if (!IsCreat)
            {
                Instantiate(EtherWave, Spawn.transform.position, Quaternion.identity);
                IsCreat = true;
                EtherCount = 1;  // 상태를 1로 설정하여 생성된 상태로 표시합니다.
                Debug.Log("파도 생성");
            }
            // 파도가 이미 생성된 상태에서 다시 키를 누르면 파도를 이동시킵니다.
            else if (IsCreat && EtherCount == 1)
            {
                EtherCount = 2;  // 상태를 2로 설정하여 이동 신호를 보냅니다.
                Debug.Log("파도 이동 신호 전송");
            }
        }
    }


    private void OnCollisionEnter(Collision other) 
    {
        if(other.gameObject.layer == 3 && other.gameObject.layer == 4)
        {
            if(OnSpawn)
            {
                if(SpawnRadius(other))
                {
                    
                    etherSystem.CalledWave = true;

                }
            }
        }
    }


    //스폰 콜라이더 범위내 있는지 확인
    private bool SpawnRadius(Collision collision)
    {
        if(spawnCollider == null)
            return false;
        
        foreach(ContactPoint contact in collision.contacts)
        {
            if(spawnCollider.bounds.Contains(contact.point))
            {
                return true;
            }
        }

        return false;
    }

}
