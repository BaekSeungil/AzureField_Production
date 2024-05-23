using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class DoorInstance : Interactable_Base
{

    [SerializeField] protected UnityEvent eventsOnStartInteract; 
    [SerializeField] Door TargetDoor;
 
    public Door targetDoor
    {
        get { return TargetDoor; }
        set { targetDoor = value; }
    }

     public override void Interact()
    {
        if (targetDoor != null && targetDoor.openType == OpenType.Interaction)
        {
            targetDoor.OpenDoor = true;
        }
    }


}
