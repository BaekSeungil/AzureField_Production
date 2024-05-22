using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SequenceStarter : MonoBehaviour
{
    [SerializeField] private SequenceBundleAsset SequenceToStart;
    [SerializeField] private bool disableAfterInvoked = true;
    [SerializeField] private bool autoStart = false;

    bool invoked = false;

    private void Start()
    {
        if(autoStart)
        {
            StartSequence();
        }
    }

    public void StartSequence()
    {
        if (disableAfterInvoked)
        {
            if (invoked) return;
        }

        if (!SequenceInvoker.IsInstanceValid) return;

        SequenceInvoker.Instance.StartSequence(SequenceToStart.SequenceBundles);
        invoked = true;
    }
}
