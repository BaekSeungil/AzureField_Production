using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;
using UnityEngine.InputSystem;
using Sirenix.OdinInspector;


public class QTETrigger : MonoBehaviour
{
    [SerializeField] UnityEvent Events = new UnityEvent();
    [SerializeField] private QTEevent qickTimeSystem;

    [SerializeField, LabelText("이벤트 연속성")] public bool SetEvent;

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
           if(SetEvent == false)
           {
                Destroy(gameObject);
           }
        
       }
    }

    public void OnEvents()
    {
        Events.Invoke();
    }

}
