using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class SeaFlower : Interactable_Base
{
    [SerializeField, LabelText("아이템 데이터")] private ItemData carrotItem;
    [SerializeField, LabelText("아이템 개수")] private int ItemQuantity = 1;
    private Animator animator;
    private void Awake()
    {
        animator = GetComponent<Animator>();
    }    

    // Update is called once per frame
    void Update()
    {
        
    }

    private void PickUpFlower()
    {
        
    }
}
