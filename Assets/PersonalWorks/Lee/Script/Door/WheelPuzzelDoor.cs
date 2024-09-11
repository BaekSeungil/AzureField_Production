using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using Cinemachine;


public enum WheelDoorType
{
    Norlmal = 0, //실시간으로 돌리는 타입
    CountWheel = 1 //정해진 횟수에 도달하면 목표지점으로 옮겨진다.
};

public class NewBehaviourScript : MonoBehaviour
{
    [Header("시스템 설정")]
    [SerializeField, LabelText("플레이어 시선 유도")] private bool interestPlayer = true;            // true일 시 플레이어가 가까이 다가가면 해당 오브젝트를 바라봅니다.
    [SerializeField, LabelText("일회성")] private bool disableAfterInteracted = false;   // true일 시 한 번만 재생됩니다.
    [SerializeField, LabelText("시선 고정 지점")] private Transform interestPoint;
    [SerializeField, LabelText("상호작용 시 이벤트")] protected UnityEvent eventsOnStartInteract;    // Interact 됐을 때 호출되는 UnityEvent입니다
    [SerializeField, LabelText("시작할 시퀀스")] private SequenceBundleAsset sequenceAsset;     // Interact 됐을 때 시작하는 시퀀스 입니다.
    [SerializeField, LabelText("대화 시 카메라(선택)")] private CinemachineVirtualCamera virtualCamera;


    [SerializeField,LabelText("목표 타겟")] public GameObject TargetObj; 

    [SerializeField,LabelText("오차허용 범위")] public float MoiveDistacne;
    [SerializeField,LabelText("타겟까지 움직이는 횟수")] public int MoveCount; // 움직이는 횟수
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other) 
    {
        if(other.gameObject.layer == 4)
        {
            
        }
    }
}
