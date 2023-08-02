using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;

public class Interactable_TriggerZone : SerializedMonoBehaviour
{
    [SerializeField] private bool interestPlayer = true;
    [SerializeField] private UnityEvent eventsOnStartInteract;
    [SerializeField] private SequenceBundleAsset sequenceAsset;
    //[SerializeField] private Sequence_Base[] sequences;

    MainPlayerInputActions input;

    public void Interact()
    {
        eventsOnStartInteract.Invoke();
        if (SequenceInvoker.Instance == null) { Debug.LogWarning("SequenceInvoker가 없습니다."); return; }
        SequenceInvoker.Instance.StartSequence(sequenceAsset.sequenceBundles);
        if (interestPlayer) FindObjectOfType<PlayerCore>().SetInterestPoint(transform);
    }

    public void OnInteractInput(InputAction.CallbackContext context)
    {
        Interact();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("Player"))
        {
            input = other.GetComponentInParent<PlayerCore>().Input;
            input.Player.Interact.performed += OnInteractInput;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("Player"))
        {
            if(input != null)
            input.Player.Interact.performed -= OnInteractInput;
            input = null;
        }
    }

    private void OnDisable()
    {
        if (input != null)
        {
            input.Player.Interact.performed -= OnInteractInput;
            input = null;
        }
    }
}
