using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class NoaInteract : Interactable_Base
{

    [SerializeField] protected UnityEvent eventsOnStartInteract;
    public override void Interact()
    {
        eventsOnStartInteract.Invoke();
    }
}
