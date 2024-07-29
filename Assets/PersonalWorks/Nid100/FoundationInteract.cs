using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class FoundationInteract : Interactable_Base
{
    [SerializeField] protected UnityEvent eventsOnStartInteract;
    [SerializeField] private Foundation foundation;
    [SerializeField] private Animator orbAnimatior;

    public void DisableOrb()
    {
        orbAnimatior.Play("Disable",0);
    }

    public void EnableOrb()
    {
        orbAnimatior.Play("Enabled",0);
    }

    public override void Interact()
    {
        if (foundation != null)
        {
            eventsOnStartInteract.Invoke();
        }
    }
}
