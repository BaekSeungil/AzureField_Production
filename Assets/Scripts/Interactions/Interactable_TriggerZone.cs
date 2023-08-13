using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Interactable_TriggerZone : Interactable_Base
{
    [SerializeField] private bool interestPlayer = true;
    [SerializeField] protected UnityEvent eventsOnStartInteract;
    [SerializeField] private SequenceBundleAsset sequenceAsset;

    public override void Interact()
    {
        eventsOnStartInteract.Invoke();
        if (SequenceInvoker.Instance == null) { Debug.LogWarning("SequenceInvoker가 없습니다."); return; }
        SequenceInvoker.Instance.StartSequence(sequenceAsset.sequenceBundles);
        if (interestPlayer) FindObjectOfType<PlayerCore>().SetInterestPoint(transform);
    }
}
