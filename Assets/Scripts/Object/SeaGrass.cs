using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SeaGrass : MonoBehaviour
{
    private Animator animator;
    private float Speed = 1f;
    // Start is called before the first frame update
    void Awake()
    {
        animator = GetComponent<Animator>();
        animator.SetFloat("AniSpeed", Speed);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
