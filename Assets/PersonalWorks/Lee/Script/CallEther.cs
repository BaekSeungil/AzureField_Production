using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CallEther : MonoBehaviour
{
    MainPlayerInputActions inputActions;
    EtherSystem etherSystem;

    [SerializeField,LabelText("파도 스폰 위치")] public GameObject Spawn;

    private Collider spawnCollider;

    void Start()
    {
        etherSystem.GetComponent<EtherSystem>();
        inputActions = new MainPlayerInputActions();
        inputActions.Player.Interact.Enable();

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
 
    }


    private void OnCollisionEnter(Collision other) 
    {
        if(other.gameObject.layer == 4)
        {
            etherSystem.CalledWave = true;
        }
        else
        {
            etherSystem.CalledWave = false;
        }
    }


    //스폰 콜라이더 범위내 있는지 확인
    private void SpawnRadius()
    {
    

    }

}
