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
        yield return new WaitForSeconds(1.0f);
        if (DestoryObjQuantity >= DestoryObj.Length)
        {
            DestoryObjQuantity = DestoryObj.Length - 1; // 배열 범위를 초과하지 않도록 조정
            Debug.LogWarning("DestoryObjQuantity 값이 배열 크기를 초과하여 마지막 인덱스로 조정됨.");
        }

        if (DestoryObjQuantity >= 0 && DestoryObj[DestoryObjQuantity] != null)
        {
            Debug.Log("오브젝트 파괴: " + DestoryObj[DestoryObjQuantity].name);
            DOTween.Kill(DestoryObj[DestoryObjQuantity].transform);
            Destroy(DestoryObj[DestoryObjQuantity]);
        }
        else
        {
            Debug.LogWarning("파괴하려는 오브젝트가 비활성화 상태이거나 null입니다.");
        }

        yield return new WaitForSeconds(5.0f); // 추가 대기 시간
    }
}
