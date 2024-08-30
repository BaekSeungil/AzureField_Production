using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CallEther : MonoBehaviour
{
    MainPlayerInputActions inputActions;
    EtherSystem etherSystem;



    void Start()
    {
        etherSystem.GetComponent<EtherSystem>();
        inputActions = new MainPlayerInputActions();
        inputActions.Player.Interact.Enable();
    }

    // Update is called once per frame
    void Update()
    {
        
        if (inputActions.Player.Interact.triggered)
        {
            SendboolTrigger();
        }
    }

    private void SendboolTrigger()
    {
        etherSystem.CalledWave = true;
    }

    public void CreatedBoxObject()
    {
        
    }
}
