using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ElevatorParent : MonoBehaviour
{   
    private void OnCollisionEnter(Collision other) 
    {
        other.transform.SetParent(transform);
    }

    private void OnCollisionEnterExit(Collision other) 
    {
        other.transform.SetParent(null);
    }
    
}
