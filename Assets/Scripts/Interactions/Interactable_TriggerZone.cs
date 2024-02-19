using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Interactable_TriggerZone : Interactable_Base
{
    //================================================
    //
    // Interactable_Base�� �ڽ� Ŭ����,  Interact�� �������̵�
    // Interact�� sequenceAsset�� ���� ��糪 �ƽŰ��� �������� �����մϴ�.
    //
    //================================================

    [SerializeField] private bool interestPlayer = true;            // true�� �� �÷��̾ ������ �ٰ����� �ش� ������Ʈ�� �ٶ󺾴ϴ�.
    [SerializeField] protected UnityEvent eventsOnStartInteract;    // Interact ���� �� ȣ��Ǵ� UnityEvent�Դϴ�
    [SerializeField] private SequenceBundleAsset sequenceAsset;     // Interact ���� �� �����ϴ� ������ �Դϴ�.

    public override void Interact()
    {
        eventsOnStartInteract.Invoke();
        if (SequenceInvoker.Instance == null) { Debug.LogWarning("SequenceInvoker�� �����ϴ�."); return; }
        SequenceInvoker.Instance.StartSequence(sequenceAsset.sequenceBundles);
        if (interestPlayer) FindObjectOfType<PlayerCore>().SetInterestPoint(transform);
    }
}
