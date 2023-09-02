using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;

public class Interactable_Base : SerializedMonoBehaviour
{
    [SerializeField] protected string interactionUIText;
    protected MainPlayerInputActions input;
    protected bool isEnabled = true;

    public virtual void Interact() { }

    public void OnInteractInput(InputAction.CallbackContext context)
    {
        if (!isEnabled) return;

        if(PlayerCore.IsInstanceValid)
        {
            if (PlayerCore.Instance.IsHoldingSomething)
                return;
        }

        if(InteractionInfo.IsInstanceValid)
        {
            InteractionInfo.Instance.HideCurrentInfo();
        }

        Interact();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("Player"))
        {
            input = other.GetComponentInParent<PlayerCore>().Input;
            input.Player.Interact.performed += OnInteractInput;

            if (interactionUIText != string.Empty)
            {
                if (InteractionInfo.IsInstanceValid)
                {
                    var infoUI = InteractionInfo.Instance;

                    if (!infoUI.CompareCurrentTarget(transform))
                    {
                        infoUI.SetNewInteractionInfo(transform, interactionUIText);
                    }
                }
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("Player"))
        {
            if (input != null)
                input.Player.Interact.performed -= OnInteractInput;
            input = null;

            if (InteractionInfo.IsInstanceValid)
            {
                var infoUI = InteractionInfo.Instance;

                if (infoUI.CompareCurrentTarget(transform))
                {
                    infoUI.HideCurrentInfo();
                }
            }
        }
    }

    private void OnDisable()
    {
        if (input != null)
        {
            input.Player.Interact.performed -= OnInteractInput;
            input = null;
        }

        if (InteractionInfo.IsInstanceValid)
        {
            var infoUI = InteractionInfo.Instance;

            if (infoUI.CompareCurrentTarget(transform))
            {
                infoUI.HideCurrentInfo();
            }
        }
    }
}
