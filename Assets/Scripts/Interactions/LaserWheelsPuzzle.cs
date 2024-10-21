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

    private void Start()
    {
        foreach (var wheels in assignedLaserWheels)
        {
            wheels.OnLaserWheelRotated += LaserWheelRotated;
        }
    }

    public void LaserWheelRotated()
    {
        bool result = true;
        foreach (Interactable_LaserWheel wheel in assignedLaserWheels)
        {
            if(!wheel.IsDesired)
            {
                result = false;
                break;
            }
        }

        if(result) OnPassed();

    }

    public void OnPassed()
    {
        OnPassedPuzzle.Invoke();
        if (sequenceBundle != null)
        {
            SequenceInvoker.Instance.StartSequence(sequenceBundle.SequenceBundles);
        }
        DisableLaserWheels();
    }

    public void DisableLaserWheels()
    {
        foreach(Interactable_LaserWheel wheel in assignedLaserWheels)
        {
            wheel.IsEnabled = false;
            wheel.OnLaserWheelRotated -= LaserWheelRotated;
        }
    }
}
