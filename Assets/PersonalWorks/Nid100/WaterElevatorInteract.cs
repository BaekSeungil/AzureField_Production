using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class WaterElevatorInteract : Interactable_Base
{
    [SerializeField] protected UnityEvent eventsOnStartInteract;


    [SerializeField] private WaterElevator waterElevator;


    [SerializeField] private PlayerCore player;
    // Start is called before the first frame update
    void Start()
    {
        player = PlayerCore.Instance;
    }

    public override void Interact()
    {

        if (waterElevator != null)
        {
            if (player.movementStateRefernce == "Sailboat")
            {
                eventsOnStartInteract.Invoke();
            }
            else 
            {
                if (waterElevator.goingUp == false)
                {
                    eventsOnStartInteract.Invoke();
                }
            }
        }
        
    }
}
