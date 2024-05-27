using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Foundation : MonoBehaviour
{
    [SerializeField] private PlayerCore player;
    [SerializeField] private Transform moveTargetObj;
    [SerializeField] private Transform targetPoint;
    [SerializeField] private float speed;

    public bool orderSystem = false;

    public bool[] switchOnOff;
    private int switchCheck=0;
    public bool moveCheck=false;
    

    private void Start()
    {
        player = PlayerCore.Instance;


    }

    private void Update()
    {
        Debug.Log(switchOnOff.Length);

        if (moveTargetObj.position == targetPoint.position)
        {
            moveCheck = false;

        }
        if (switchCheck == switchOnOff.Length)
        {
            moveCheck = true;
        }
        if (moveCheck == true)
        {
            MoveTargetMove();
        }
        
    }

    
    public void SwitchOn(int num)
    {
        switchOnOff[num]= true;

        if (orderSystem == true)
        {
            if (switchOnOff[num - 1] == true)
            {
                for (int i = 0; i < switchOnOff.Length; i++)
                {
                    if (switchOnOff[i] == true)
                    {
                        switchCheck++;
                        if (switchCheck == switchOnOff.Length)
                        {
                            moveCheck = true;
                        }
                    }
                }
            }
            else 
            {
                SwitchOff();
            }
        }

        if (orderSystem == false)
        {
            for (int i = 0; i < switchOnOff.Length; i++)
            {
                
                if (switchOnOff[i] == true)
                {
                    switchCheck++;
                    if (switchCheck == switchOnOff.Length)
                    {
                        moveCheck = true;
                    }

                }
            }
        }



        

        switchCheck = 0;

    }

    public void SwitchOff()
    {
        for (int i = 0; i < switchOnOff.Length; i++)
        {
            switchOnOff[i] = false;
        }
    }

    private void MoveTargetMove()
    {
        moveTargetObj.position = Vector3.MoveTowards(moveTargetObj.position, targetPoint.position, speed * Time.deltaTime);
    }


}

