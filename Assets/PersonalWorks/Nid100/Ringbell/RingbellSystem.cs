using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class RingbellSystem : MonoBehaviour
{
    [SerializeField] private RingbellInteract[] bell;
    [SerializeField] private UnityEvent eventOnAllActive;
    [SerializeField, LabelText("시작할 시퀀스")] private SequenceBundleAsset sequenceAsset;
    private int checknum = 0;

    private bool isOnceActived;
    public bool IsOnceActived { get { return isOnceActived; } }

    // num번의 종이 활성화/비활성화 되면 해당 종과 연동된 종의 활성화/비활성화 
    public void connectionBellActive(int num)
    {
        // num번 종의 onoff 값을 토글
        //bell[num].onoff = !bell[num].onoff;

        // num번 종과 연동된 종들의 onoff 값을 토글
        for (int i = 0; i < bell[num].connectionNumber.Length; i++)
        {
            int connectedBellIndex = bell[num].connectionNumber[i];
            bell[connectedBellIndex].onoff = !bell[connectedBellIndex].onoff;
            bell[connectedBellIndex].UpdateStoneStatus();
        }

        // 모든 종의 onoff 상태를 확인
        AllbellActiveCheck();
    }

    // 모든 bell[] 배열의 onoff 상태를 확인하고, 모두 true면 objmove의 moveOnoff를 true로 설정
    void AllbellActiveCheck()
    {
        // 모든 종의 onoff 상태가 true인지 확인
        bool allBellsActive = true;  // 모든 종이 활성화 상태인지 확인하는 플래그
        for (int i = 0; i < bell.Length; i++)
        {
            if (!bell[i].onoff)  // 하나라도 false인 종이 있으면 allBellsActive를 false로 설정
            {
                allBellsActive = false;
                break;
            }
        }

        // 모든 종이 활성화 상태이면 objmove의 moveOnoff를 true로 설정
        if (allBellsActive)
        {

            if(!isOnceActived) // 등록된 이벤트 발동
            {
                if (sequenceAsset != null)
                {
                    SequenceInvoker.Instance.StartSequence(sequenceAsset.SequenceBundles);
                }

                if (eventOnAllActive != null)
                {
                    eventOnAllActive.Invoke();
                }

                isOnceActived = true;

            }
        }
        else
        {

        }
    }
}

