using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RingbellSystem : MonoBehaviour
{
    [SerializeField] private RingbellInteract[] bell;
    [SerializeField] private ObjMove objmove;
    


    void Start()
    {
        
    }

    void Update()
    {
        
    }

    //num번의 종이 활성화/비활성화 되면 해당 종과 연동된 종의 활성화/비활성화 
    public void connectionBellActive(int num)
    {
        if (bell[num].onoff == true)
        {
            bell[num].onoff = false;
        }
        else if (bell[num].onoff == false)
        {
            bell[num].onoff = true;
        }

        for (int i = 0; i < bell[num].connectionNumber.Length; i++)
        {
            if (bell[bell[num].connectionNumber[i]].onoff == true)
            {
                bell[bell[num].connectionNumber[i]].onoff = false;
            }
            else if (bell[bell[num].connectionNumber[i]].onoff == false)
            {
                bell[bell[num].connectionNumber[i]].onoff = true;
            }
        }

        AllbellActiveCheck();

    }

    int checknum = 0;
    void AllbellActiveCheck()
    {
        for (int i = 0; i < bell.Length; i++)
        {
            if (bell[i].onoff == true)
            {
                checknum++;
            }
        }
        if (checknum == bell.Length)
        {
            objmove.moveOnoff = true;
        }

        checknum = 0;
    }
}
