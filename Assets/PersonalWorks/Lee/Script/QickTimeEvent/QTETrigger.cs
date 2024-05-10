using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;


public class QTETrigger : MonoBehaviour
{
    [SerializeField] UnityEvent Events = new UnityEvent();
    [SerializeField] private QTEevent qickTimeSystem;
    private QTEevent qTEevent
    {
        get{return qTEevent;}
        set{qTEevent=value;}
    }


    private void OnTriggerEnter(Collider other) 
    {
       if(other.gameObject.layer == 6)
       {
           OnEvents();
           Destroy(gameObject);
       }
    }

    public void OnEvents()
    {
        Events.Invoke();
    }

}
