using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class WaterElevatorInteract : Interactable_Base
{
    [SerializeField] protected UnityEvent eventsOnStartInteract;


    [SerializeField] private WaterElevator waterElevator;

    // Start is called before the first frame update
    void Start()
    {

    }

    public override void Interact()
    {
        if (waterElevator != null)
        {
            eventsOnStartInteract.Invoke();
        }
    }
}
