using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class LaserWheelsPuzzle : MonoBehaviour
{
    [SerializeField,LabelText("연결된 레이저")] private Interactable_LaserWheel[] assignedLaserWheels;
    [SerializeField,LabelText("퍼즐 완료시 이벤트")] private UnityEvent OnPassedPuzzle;
    [SerializeField, LabelText("퍼즐 완료시 시퀀스")] private SequenceBundleAsset sequenceBundle;

    private bool puzzleDone = false;
    public bool IsPuzzleDone { get { return puzzleDone; } }

    private float checkInterval = 0.5f;
    private float timer = 0f;
    public void Update()
    {
        if(puzzleDone) return;

        timer += Time.deltaTime;

        if (timer > checkInterval)
        {
            checkInterval = 0f;
            bool result = true;

            foreach (Interactable_LaserWheel wheel in assignedLaserWheels)
            {
                if (!wheel.IsDesired)
                {
                    result = false;
                    break;
                }
            }

            if (result) OnPassed();
        }
    }

    public void OnPassed()
    {
        OnPassedPuzzle.Invoke();
        if (sequenceBundle != null)
        {
            SequenceInvoker.Instance.StartSequence(sequenceBundle.SequenceBundles);
        }
        puzzleDone = true;
        DisableLaserWheels();
    }

    public void DisableLaserWheels()
    {
        foreach(Interactable_LaserWheel wheel in assignedLaserWheels)
        {
            wheel.IsEnabled = false;
        }
    }
}
