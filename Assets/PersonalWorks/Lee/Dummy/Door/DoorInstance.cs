using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class DoorInstance : Interactable_Base
{

    [SerializeField] protected UnityEvent eventsOnStartInteract; 

    Door door;

    // Update is called once per frame
    void Update()
    {
        door = Door.Instance;
    }

     public override void Interact()
    {
        if (door != null && door.GetOpenType() == OpenType.Interaction)
        {
            door.OpenDoor = true;
        }
    }


}
