using System.Collections;
using System.Collections.Generic;
using UnityEditor.Localization.Plugins.XLIFF.V12;
using UnityEngine;

public class DropItemCrash : MonoBehaviour
{
    [SerializeField] private GameObject DropItem;
    [SerializeField] private PlayerCore player;
    [SerializeField] private FairwindQuest fairwind;
    [SerializeField] private float addChallengeTime = 0f;                                  // 순풍의 도전 추가시간
    [SerializeField] private float addMoveSpeed = 0f;                               // 추가이동 속도
    [SerializeField] private float addSprintSpeed = 0f;                             // 추가달리기 속도
    [SerializeField] private float addSwimSpeed = 0f;                               // 추가 수영시 속도
    [SerializeField] private float addJumpPower = 0f;                               // 추가 점프파워
    [SerializeField] private float addBoatSpeed = 0f;                                      //추가 조각배 속도
    [SerializeField] private float addSpeedTime = 0f;                                      //추가 속도 제한시간

    [SerializeField]private bool itemActive = true;                                     //드롭아이템 활성화여부


    void Start()
    {
        player = PlayerCore.Instance;
    }

    void Update()
    {
        
    }

    IEnumerator CrashEvent()
    {
        player.DropItemCrash(addMoveSpeed, addSprintSpeed, addSwimSpeed, addJumpPower, addBoatSpeed);
        fairwind.AddTimer(addChallengeTime);
        yield return new WaitForSeconds(addSpeedTime);
        player.DropItemCrash(-addMoveSpeed, -addSprintSpeed, -addSwimSpeed, -addJumpPower, -addBoatSpeed);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            if (itemActive == true)
            {
                StartCoroutine(CrashEvent());
                itemActive = false;
            }
            Destroy(DropItem);
        }
    }

}
