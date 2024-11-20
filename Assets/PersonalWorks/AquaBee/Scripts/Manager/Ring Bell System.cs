using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using Sirenix.OdinInspector;
using UnityEngine.Events;

namespace InteractSystem.Manager
{

    public class RingBellSystem : MonoBehaviour
    {
        [System.Serializable]
        public struct RingInfo
        {
            public InterRingBell RingObject;
            public Animator LampObjectAnimator;

            // 상호작용 순서
            public int[] InterAction;
        }


        public RingInfo[] InterBells;
        
        private Dictionary<int, RingInfo> DicRings;
        [SerializeField] private UnityEvent eventOnAllActive;
        [SerializeField, LabelText("시작할 시퀀스")] private SequenceBundleAsset sequenceAsset;

        public bool Running = true; 

        private void Start()
        {
            DicRings = new Dictionary<int, RingInfo>();
            // Dictionary에 저장
            for(int i =0; i < InterBells.Length; i++)
            {
                DicRings.Add(i, InterBells[i]);
            }
            if(DicRings.Count <= 0)
            {
                CallBackDebugErrorLogs("현재 DicRings Dictionary에 데이터 할당이 되지 않았음.");
            }
        }

        private void CallBackDebugErrorLogs(string str)
        {
#if UNITY_EDITOR
            Debug.LogError(str);
#endif
        }

        private void Update()
        {

        }

        public void HittedWaves(int bellNumber)
        {
            int n = DicRings[bellNumber].InterAction.Length;
            InterRingBell temp;
            for(int i = 0; i < n; i++)
            {
                temp = DicRings[DicRings[bellNumber].InterAction[i]].RingObject;

                temp.Active = !temp.Active;

                SetActiveLamp(temp.RingNumber, temp.Active);
            }

            CheckbellActive();
        }

        private void CheckbellActive()
        {
            foreach(var ring in DicRings)
            {
                if (!ring.Value.RingObject.Active)
                {
                    return;
                }
            }

            if(Running)
            {
                if (sequenceAsset != null)
                    SequenceInvoker.Instance.StartSequence(sequenceAsset.SequenceBundles);

                if (eventOnAllActive != null)
                    eventOnAllActive.Invoke();
                Running = false;
            }

        }

        public void SetActiveLamp(int num, bool active)
        {
            DicRings[num].LampObjectAnimator.SetBool("Litup", active);
            if(active)
            {
                //DicRings[num].RingObject.PlaySoundAndsParticles(); 
            }
        }
    }
}
