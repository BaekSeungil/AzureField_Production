using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class ElevatorCollider : Interactable_Base
{
    [SerializeField] private bool interestPlayer = true;
    [SerializeField] protected UnityEvent eventsOnStartInteract;    // Interact 됐을 때 호출되는 UnityEvent입니다
    [SerializeField] private SequenceBundleAsset sequenceAsset; 

    Elevator elevator;
  
    // Start is called before the first frame update

    private void Awake() 
    {
        
        
    }

    private void Update() 
    {
        
    }

    public override void Interact()
    {
        eventsOnStartInteract.Invoke();
        if (SequenceInvoker.Instance == null) { Debug.LogWarning("SequenceInvoker가 없습니다."); return; }
        SequenceInvoker.Instance.StartSequence(sequenceAsset.SequenceBundles);
        if (interestPlayer) FindObjectOfType<PlayerCore>().SetInterestPoint(transform);
        
    }
}
