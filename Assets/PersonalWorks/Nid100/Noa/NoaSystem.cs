using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class NoaSystem : MonoBehaviour
{
    [SerializeField] private Animator animator;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    

    public void Anima_Standing(bool set)
    {
        animator.SetBool("Standing", set);
    }
    public void Anima_Thinking(bool set)
    {
        animator.SetBool("Thinking", set);
    }
    public void Anima_Nope(bool set)
    {
        animator.SetBool("Nope", set);
    }
    public void Anima_Yes(bool set)
    {
        animator.SetBool("Yes", set);
    }
    public void Anima_Bye(bool set)
    {
        animator.SetBool("Bye", set);
    }
    public void Anima_Talking_SetFlower(bool set)
    {
        animator.SetBool("Talking_SetFlower", set);
    }
}
