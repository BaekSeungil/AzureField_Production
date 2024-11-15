using JetBrains.Annotations;
using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Interactable_BubbleFlower : Interactable_Base
{
    [Title("편집불가")]
    [SerializeField] private Sequence_Base[] sequenceOnPickup;
    [Title("ChildReferences")]
    [SerializeField] private Animator anim;
    [SerializeField] private ParticleSystem glitter;
    [SerializeField] private GameObject budObject;

    private bool picked = false;
    public bool IsPicked { get { return picked; } }

    public override void Interact()
    {
        if (!SequenceInvoker.IsInstanceValid) return;
        if (picked) return;

        picked = true;
        isEnabled = false;
        base.OnDisable();

        budObject.SetActive(false);
        glitter.Stop(true, ParticleSystemStopBehavior.StopEmitting);
        anim.SetTrigger("Picked");
        SequenceInvoker.Instance.StartSequence(sequenceOnPickup);
    }
}
