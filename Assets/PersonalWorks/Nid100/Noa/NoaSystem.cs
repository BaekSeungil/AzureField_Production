using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class NoaSystem : MonoBehaviour
{
    [SerializeField] private Animator animator;

    [SerializeField] protected UnityEvent eventsOnStartInteract;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void Anima_Standing(bool set)
    {
        animator.SetBool("Standing", set);
    }
    void Anima_Thinking(bool set)
    {
        animator.SetBool("Thinking", set);
    }
    void Anima_Nope(bool set)
    {
        animator.SetBool("Nope", set);
    }
    void Anima_Yes(bool set)
    {
        animator.SetBool("Yes", set);
    }
    void Anima_Bye(bool set)
    {
        animator.SetBool("Bye", set);
    }
    void Anima_Talking_SetFlower(bool set)
    {
        animator.SetBool("Talking_SetFlower", set);
    }
}
