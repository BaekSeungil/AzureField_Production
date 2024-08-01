using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TreasureObj : Interactable_Base
{
    [SerializeField, LabelText("자기자신")] private GameObject treasureObject;
    [SerializeField, LabelText("이 유물과 관련된 단서")] private GameObject[] hintObject;

    [SerializeField] private string _ID;
    public string ID { get { return _ID; } }
    [SerializeField, LabelText("유물 데이터")] private ItemData treasureItem;
    [SerializeField, LabelText("단서삭제On/off")] private bool hintDestory;

    bool treasurePickFlag = false;

    //유물을 획득할 경우 유물파괴, 단서삭제On/off 여부에 따라서 연결된 힌트도 삭제
    public void DestroyTreasure()
    {
        Destroy(treasureObject);
        if (hintDestory == true)
        {
            for(int i = 0; i < hintObject.Length; i++)
            {
                Destroy(hintObject[i]);

            }
        }
    }

    public override void Interact()
    {
        if (treasurePickFlag) return;

        GetComponent<Collider>().enabled = false;
        StartCoroutine(Cor_PickTreasure());
    }

    IEnumerator Cor_PickTreasure()
    {
        treasurePickFlag = true;
        
        PlayerInventoryContainer.Instance.AddItem(treasureItem, 1);
        yield return StartCoroutine(PlayerInventoryContainer.Instance.Cor_ItemWindow(treasureItem, 1));
        DestroyTreasure();

    }
}


