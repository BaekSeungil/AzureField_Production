using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class SeaFlower : Interactable_Base
{
    [SerializeField, LabelText("아이템 데이터")] private ItemData GetItem;
    [SerializeField, LabelText("아이템 개수")] private int ItemQuantity = 1;
    [SerializeField, LabelText("사라질 오브젝트")] private GameObject DestoryObj;
    private Animator animator;
    private void Awake()
    {
        animator = GetComponent<Animator>();
    }    

    // Update is called once per frame
    void Update()
    {
        
    }

    public override void Interact()
    {
        StartCoroutine(PickUpFlower());
    }

    private IEnumerator PickUpFlower()
    {
        animator.SetBool("PickUp",true);
        PlayerInventoryContainer.Instance.AddItem(GetItem, ItemQuantity);
        yield return new WaitForSeconds(5.0f);
        Destroy(DestoryObj);
    }
}
