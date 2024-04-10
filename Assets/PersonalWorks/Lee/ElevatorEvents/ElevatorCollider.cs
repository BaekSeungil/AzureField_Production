using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class ElevatorCollider : Interactable_Base
{
    [SerializeField] private bool interestPlayer = true;
    [SerializeField] protected UnityEvent eventsOnStartInteract;    // Interact 됐을 때 호출되는 UnityEvent입니다


  
    // Start is called before the first frame update
     Elevator elevator;


    private void Awake() 
    {
         elevator = Elevator.instance;
         elevator = GetComponent<Elevator>();
    }

    public override void Interact()
    {
        // 엘레베이터의 Canmove 변수를 true로 설정
        if (elevator != null )
        {
            elevator.Canmove = true;
        }
    }

 
}
