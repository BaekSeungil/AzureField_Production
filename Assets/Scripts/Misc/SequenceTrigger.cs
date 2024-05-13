using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SequenceTrigger : SerializedMonoBehaviour
{
    [SerializeField, LabelText("일회성 트리거")] private bool disableAfterTriggered = true;
    [SerializeField, LabelText("재생할 시퀀스")] private SequenceBundleAsset sequenceBundle;

    private void OnTriggerEnter(Collider other)
    {
        if (!SequenceInvoker.IsInstanceValid) { Debug.LogWarning("SequenceTrigger : SequenceInvoker가 없습니다."); return; }
        if (other.attachedRigidbody == null) return;

        if (other.attachedRigidbody.CompareTag("Player"))
        {
            SequenceInvoker.Instance.StartSequence(sequenceBundle.SequenceBundles);
            if (disableAfterTriggered) gameObject.SetActive(false);
        }
    }
}
