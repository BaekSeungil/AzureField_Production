using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;
public class QTETrigger : MonoBehaviour
{
    
    private void OnTriggerEnter(Collider other) 
    {
       QickTimeSystem.instance.StartEvent();
    }

}
