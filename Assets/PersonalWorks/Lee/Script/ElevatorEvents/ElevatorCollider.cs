using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class ElevatorCollider : MonoBehaviour
{
 
    // Start is called before the first frame update
    [SerializeField] private Elevator targetElevator;
  
    // Start is called before the first frame update
    public Elevator TargetElevator
    {
        get { return targetElevator; }
        set { targetElevator = value; }
    }
    private void OnTriggerEnter(Collider other) 
    {
        if (TargetElevator != null && TargetElevator.elevatorType == ElevatorType.Auto)
        {
            if(other.gameObject.CompareTag("Player"))
            {
                TargetElevator.Canmove = true;
            }
        }
    }
}
