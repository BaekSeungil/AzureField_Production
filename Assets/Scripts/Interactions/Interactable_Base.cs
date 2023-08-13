using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;

public class Interactable_Base : SerializedMonoBehaviour
{
    protected MainPlayerInputActions input;
    protected bool isEnabled = true;

    public virtual void Interact() { }

    public void OnInteractInput(InputAction.CallbackContext context)
    {
        if (!isEnabled) return;

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
            if (input != null)
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
