using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnableTriggerSequence : MonoBehaviour
{
    [SerializeField] private SequenceBundleAsset SequenceToStart;
    [SerializeField] private bool disableAfterInvoked = true;

    bool invoked = false;

    private void OnEnable()
    {
        if (disableAfterInvoked)
        {
            if (invoked) return;
        }

        if (!SequenceInvoker.IsInstanceValid) return;

        SequenceInvoker.Instance.StartSequence(SequenceToStart.SequenceBundles);
    }
}
