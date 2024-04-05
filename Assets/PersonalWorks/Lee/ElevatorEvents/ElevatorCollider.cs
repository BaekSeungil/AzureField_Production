using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ElevatorCollider : MonoBehaviour
{
    Elevator elevator;
    // Start is called before the first frame update

    private void Awake() 
    {
        elevator = GetComponent<Elevator>();
    }

    private void OnTriggerEnter(Collider other) 
    {
        if(other.gameObject.CompareTag("Player"))
        {
            elevator.Canmove = true;
        }
    }
}
