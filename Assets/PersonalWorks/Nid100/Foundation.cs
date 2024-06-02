using FMODUnity;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Foundation : MonoBehaviour
{
    [SerializeField] private PlayerCore player;
    [SerializeField] private Transform moveTargetObj;
    [SerializeField] private Transform targetPoint;
    [SerializeField] private float speed;
    [SerializeField] private UnityEvent onActivated;
    [SerializeField] private EventReference interactedWrong;
    [SerializeField] private EventReference interactedRight;
    [SerializeField] private EventReference interactedComplete;

    public bool orderSystem = false;

    public bool[] switchOnOff;
    public bool moveCheck=false;

    bool activationFlag = false;

    int currentOrder = 0;

    private void Start()
    {
        player = PlayerCore.Instance;
    }

    private void Update()
    {
        if (activationFlag) return;


        if (moveTargetObj.position == targetPoint.position)
        {
            moveCheck = false;

        }
        if (IsAllSwitchOn())
        {
            moveCheck = true;
        }
        if (moveCheck == true)
        {
            Debug.Log("Activated");
            activationFlag = true;
            onActivated.Invoke();
            //MoveTargetMove();
        }
        
    }

    
    public void SwitchOn(int num)
    {
        if (activationFlag) return;

        switchOnOff[num]= true;

        if (orderSystem == true)
        {
            if(currentOrder != num)
            {
                for(int i = 0; i < switchOnOff.Length; i++)
                {
                    switchOnOff[i] = false;
                }
                currentOrder = 0;
            }
            else
            {
                currentOrder++;
            }
        }

        if (IsAllSwitchOn())
        {
            moveCheck = true;

        }
    }

    public void SwitchOff(int index)
    {
         switchOnOff[index] = false;
    }

    private bool IsAllSwitchOn()
    {
        for(int i = 0; i < switchOnOff.Length; i++)
        {
            if (!switchOnOff[i]) return false;
        }

        return true;
    }

    //private void MoveTargetMove()
    //{
    //    moveTargetObj.position = Vector3.MoveTowards(moveTargetObj.position, targetPoint.position, speed * Time.deltaTime);
    //}


}

