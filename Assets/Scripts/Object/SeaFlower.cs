using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using FMODUnity;


public class SeaFlower : Interactable_Base
{
    [SerializeField, LabelText("아이템 데이터")] private ItemData GetItem;
    [SerializeField, LabelText("아이템 개수")] private int ItemQuantity = 1;
    [SerializeField, LabelText("사라질 오브젝트")] private GameObject[] DestoryObj;
    [SerializeField, LabelText("사라질 오브젝트 개수")] private int DestoryObjQuantity;

    [SerializeField] private EventReference sound_CarrotPicked;
    [SerializeField] private EventReference sound_CarrotGone;
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
        Debug.Log("Interact 호출됨");
        StartCoroutine(PickUpFlower());
    }

    private IEnumerator PickUpFlower()
    {
        Debug.Log("PickUpFlower 시작");
        animator.SetTrigger("Pickup");
        PlayerInventoryContainer.Instance.AddItem(GetItem, ItemQuantity);
        yield return new WaitForSeconds(5.0f);
        for (int i = 0; i < DestoryObj.Length; i++)
        {
            if (DestoryObj[i] != null)
            {
                Debug.Log("파괴할 오브젝트: " + DestoryObj[i].name);
                Destroy(DestoryObj[i]); // 오브젝트 파괴
            }
            else
            {
                Debug.LogWarning("오브젝트가 null이거나 이미 파괴됨: 인덱스 " + i);
            }
        }
    }
}
