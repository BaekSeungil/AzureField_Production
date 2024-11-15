using FMODUnity;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;


// 매우 불안정한 코드 : 추후 재사용시 리팩토링 필수
public class Foundation : MonoBehaviour
{
    [SerializeField] private PlayerCore player;
    [SerializeField] private Transform moveTargetObj;
    [SerializeField] private Transform targetPoint;
    [SerializeField] private float speed;
    [SerializeField] private GameObject[] foundationChilds;
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
                    if (switchOnOff[i] == true) foundationChilds[i].GetComponent<FoundationInteract>().DisableOrb();
                    switchOnOff[i] = false;
                    
                }
                currentOrder = 0;
                RuntimeManager.PlayOneShot(interactedWrong);
            }
            else
            {
                Debug.Log("CurrentOrder:" + currentOrder);
                foundationChilds[currentOrder].GetComponent<FoundationInteract>().EnableOrb();
                currentOrder++;
                RuntimeManager.PlayOneShot(interactedRight);
            }
        }

        if (IsAllSwitchOn())
        {
            moveCheck = true;
            RuntimeManager.PlayOneShot(interactedComplete);

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

