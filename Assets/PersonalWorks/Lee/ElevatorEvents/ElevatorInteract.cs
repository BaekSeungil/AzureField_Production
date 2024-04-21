using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class ElevatorInteract : Interactable_Base
{
    [SerializeField] protected UnityEvent eventsOnStartInteract;    // Interact 됐을 때 호출되는 UnityEvent입니다


  
    // Start is called before the first frame update
    private Elevator elevator;

    private void Start() 
    {
        elevator = Elevator.instance;
    }

    public override void Interact()
    {
       if (elevator != null && elevator.elevatorType == ElevatorType.Interaction)
        {
            eventsOnStartInteract.Invoke();
            elevator.Canmove = true;
            
        }
    }


}
