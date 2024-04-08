using System.Collections;
using System.Collections.Generic;
using UnityEditor.Localization.Plugins.XLIFF.V12;
using UnityEngine;

public class DropItemCrash : MonoBehaviour
{
    [SerializeField] private GameObject DropItem;
    [SerializeField] private PlayerCore player;
    [SerializeField] private float addChallengeTime;                                  // 순풍의 도전 추가시간
    [SerializeField] private float addMoveSpeed = 1.0f;                               // 추가이동 속도
    [SerializeField] private float addSprintSpeed = 2.0f;                             // 추가달리기 속도
    [SerializeField] private float addSwimSpeed = 1.0f;                               // 추가 수영시 속도
    [SerializeField] private float addJumpPower = 1.0f;                               // 추가 점프파워
    [SerializeField] private float addBoatSpeed;                                      //추가 조각배 속도
    [SerializeField] private float addSpeedTime;                                      //추가 속도 제한시간


    void Start()
    {
        player = PlayerCore.Instance;
    }

    void Update()
    {
        
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.collider.gameObject.CompareTag("Player"))
        {
            Destroy(DropItem);
        }
    }

}
