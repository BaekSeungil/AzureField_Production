using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "NewItemData",menuName = "CreateNewItemData",order = 1)]
public class ItemData : ScriptableObject
{
    //================================================
    //
    // 아이템 정보를 담는 스크립터블 오브젝트입니다.
    //
    //================================================

    [SerializeField] private string itemID;                                 // 아이템 구분용 ID
    public string ItemID { get { return itemID; } }                         
    [SerializeField] private string itemName;                               // 아이템의 이름
    public string ItemName { get { return itemName; } }
    [SerializeField] private Sprite itemImage;                              // 아이템의 이미지
    public Sprite ItemImage { get { return itemImage; } }
    [SerializeField,TextArea()] private string itemDiscription;             // 아이템 설명
    public string ItemDiscription { get { return itemDiscription; } }
    [SerializeField] private string[] tags;                                 // 아이템 태그
    public string[] Tags { get { return tags; } }

    static bool TryItemFromSet(ItemData[] set, string ID)
    // set에 있는 아이템들 중 ID값의 아이템이 있는지 확인합니다. 
    {
        for (int i = 0; i < set.Length; i++)
        {
            if (set[i].itemID == ID)
            {
                return true;
            }
        }
        return false;
    }


    static bool TryItemFromSet(ItemData[] set, string ID, out ItemData to)
    // set에 있는 아이템들 중 ID값의 아이템이 있는지 확인합니다. 있다면 to 레퍼런스에 아이템을 저장합니다.
    {
        for (int i = 0; i < set.Length; i++)
        {
            if (set[i].itemID == ID)
            {
                to = set[i];
                return true;
            }
        }

        to = null;
        return false;
    }

    public bool HasTag(string tag)
    // 이 아이템이 tag에 해당하는 아이템 태그가 적어도 하나 이상 있는지 확인합니다.
    {
        for(int i = 0; i < tags.Length; i++)
        {
            if (tags[i] == tag) return true;
        }
        return false;
    }
}
