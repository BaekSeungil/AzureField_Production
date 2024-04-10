using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class ElevatorCollider : Interactable_Base
{
    [SerializeField] protected UnityEvent eventsOnStartInteract;    // Interact 됐을 때 호출되는 UnityEvent입니다


  
    // Start is called before the first frame update
     Elevator elevator;


   
    private void Update() 
    {
        elevator = Elevator.instance;
    }

    public override void Interact()
    {
        if (elevator != null && elevator.GetElevatorType() == ElevatorType.Interaction)
        {
            elevator.Canmove = true;
        }
    }

    private void OnTriggerEnter(Collider other) 
    {
        if (elevator != null && elevator.GetElevatorType() == ElevatorType.Auto)
        {
            if(other.gameObject.CompareTag("Player"))
            {
            elevator.Canmove = true;
            }
        }
    }
}
