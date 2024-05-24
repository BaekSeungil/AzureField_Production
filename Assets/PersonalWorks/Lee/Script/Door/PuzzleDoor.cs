using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using Cinemachine;

public class PuzzleDoor : Interactable_Base
{
    
    [Header("시스템 설정")]
    [SerializeField, LabelText("플레이어 시선 유도")] private bool interestPlayer = true;            // true일 시 플레이어가 가까이 다가가면 해당 오브젝트를 바라봅니다.
    [SerializeField, LabelText("일회성")] private bool disableAfterInteracted = false;   // true일 시 한 번만 재생됩니다.
    [SerializeField, LabelText("시선 고정 지점")] private Transform interestPoint;
    [SerializeField, LabelText("상호작용 시 이벤트")] protected UnityEvent eventsOnStartInteract;    // Interact 됐을 때 호출되는 UnityEvent입니다
    [SerializeField, LabelText("시작할 시퀀스")] private SequenceBundleAsset sequenceAsset;     // Interact 됐을 때 시작하는 시퀀스 입니다.
    [SerializeField, LabelText("대화 시 카메라(선택)")] private CinemachineVirtualCamera virtualCamera;

    [Header("퍼즐문 이벤트 설정")]
    [SerializeField,LabelText("문을여는 열쇠 갯수")] public int OpenDoorCount;
    [SerializeField,LabelText("열쇠의 갯수")] public int KeyCount;
    [SerializeField,LabelText("문이 열리는가의 여부")]public bool Opendoor = false;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //문을 여는 코드
    private void OpenMoveToTrans()
    {
        if(KeyCount == OpenDoorCount)
        {
            Opendoor = true;
        }
    }

    public override void Interact()
    {
        if (eventsOnStartInteract != null)
            eventsOnStartInteract.Invoke();

        if (SequenceInvoker.Instance == null) { Debug.LogWarning("SequenceInvoker가 없습니다."); return; }
        if (sequenceAsset != null)
        {
            SequenceInvoker.Instance.StartSequence(sequenceAsset.SequenceBundles);
            if (virtualCamera != null)
                SequenceInvoker.Instance.SetSequenceCamera(virtualCamera);
        }

        if (interestPlayer) FindObjectOfType<PlayerCore>().SetInterestPoint(interestPoint);
        if (disableAfterInteracted) { this.enabled = false; GetComponent<Collider>().enabled = false; }
    }
}

