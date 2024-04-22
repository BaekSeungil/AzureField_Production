using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class ElevatorInteract : Interactable_Base
{
    [SerializeField] protected UnityEvent eventsOnStartInteract;    // Interact 됐을 때 호출되는 UnityEvent입니다

     [SerializeField] private Elevator targetElevator;
  
    // Start is called before the first frame update
    public Elevator TargetElevator
    {
        get { return targetElevator; }
        set { targetElevator = value; }
    }
    public override void Interact()
    {
       if (targetElevator != null && targetElevator.elevatorType == ElevatorType.Interaction)
        {
            eventsOnStartInteract.Invoke();
            targetElevator.Canmove = true;
            
        }
    }


}
