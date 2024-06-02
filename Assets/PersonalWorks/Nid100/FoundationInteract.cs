using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class FoundationInteract : Interactable_Base
{
    [SerializeField] protected UnityEvent eventsOnStartInteract;
    [SerializeField] private Foundation foundation;

    // Start is called before the first frame update
    void Start()
    {

    }

    public override void Interact()
    {
        if (foundation != null)
        {
            eventsOnStartInteract.Invoke();
        }
    }
}
