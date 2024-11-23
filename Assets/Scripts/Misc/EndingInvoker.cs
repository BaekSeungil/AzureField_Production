using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EndingInvoker : MonoBehaviour
{
    public SequenceBundleAsset endingSequence;
    public void StartEnding()
    {
        SequenceInvoker.Instance.StartSequence(endingSequence);
    }
}
