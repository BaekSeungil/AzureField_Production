using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Interactable_TriggerZone : Interactable_Base
{
    //================================================
    //
    // Interactable_Base의 자식 클래스,  Interact를 오버라이드
    // Interact시 sequenceAsset을 통해 대사나 컷신같은 시퀀스를 시작합니다.
    //
    //================================================

    [SerializeField] private bool interestPlayer = true;            // true일 시 플레이어가 가까이 다가가면 해당 오브젝트를 바라봅니다.
    [SerializeField] protected UnityEvent eventsOnStartInteract;    // Interact 됐을 때 호출되는 UnityEvent입니다
    [SerializeField] private SequenceBundleAsset sequenceAsset;     // Interact 됐을 때 시작하는 시퀀스 입니다.

    public override void Interact()
    {
        eventsOnStartInteract.Invoke();
        if (SequenceInvoker.Instance == null) { Debug.LogWarning("SequenceInvoker가 없습니다."); return; }
        SequenceInvoker.Instance.StartSequence(sequenceAsset.sequenceBundles);
        if (interestPlayer) FindObjectOfType<PlayerCore>().SetInterestPoint(transform);
    }
}
