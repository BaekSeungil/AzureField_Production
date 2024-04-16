using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class ElevatorCollider : MonoBehaviour
{
 
    // Start is called before the first frame update
     Elevator elevator;


   
    private void Update() 
    {
        elevator = Elevator.instance;
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
