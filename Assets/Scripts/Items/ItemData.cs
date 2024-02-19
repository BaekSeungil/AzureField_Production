using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "NewItemData",menuName = "CreateNewItemData",order = 1)]
public class ItemData : ScriptableObject
{
    //================================================
    //
    // ������ ������ ��� ��ũ���ͺ� ������Ʈ�Դϴ�.
    //
    //================================================

    [SerializeField] private string itemID;                                 // ������ ���п� ID
    public string ItemID { get { return itemID; } }                         
    [SerializeField] private string itemName;                               // �������� �̸�
    public string ItemName { get { return itemName; } }
    [SerializeField] private Sprite itemImage;                              // �������� �̹���
    public Sprite ItemImage { get { return itemImage; } }
    [SerializeField,TextArea()] private string itemDiscription;             // ������ ����
    public string ItemDiscription { get { return itemDiscription; } }
    [SerializeField] private string[] tags;                                 // ������ �±�
    public string[] Tags { get { return tags; } }

    static bool TryItemFromSet(ItemData[] set, string ID)
    // set�� �ִ� �����۵� �� ID���� �������� �ִ��� Ȯ���մϴ�. 
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
    // set�� �ִ� �����۵� �� ID���� �������� �ִ��� Ȯ���մϴ�. �ִٸ� to ���۷����� �������� �����մϴ�.
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
    // �� �������� tag�� �ش��ϴ� ������ �±װ� ��� �ϳ� �̻� �ִ��� Ȯ���մϴ�.
    {
        for(int i = 0; i < tags.Length; i++)
        {
            if (tags[i] == tag) return true;
        }
        return false;
    }
}
