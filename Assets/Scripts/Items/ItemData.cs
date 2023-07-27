using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Localization;

[CreateAssetMenu(fileName = "NewItemData",menuName = "CreateNewItemData",order = 0)]
public class ItemData : ScriptableObject
{
    [SerializeField] private string itemID;
    public string ItemID { get { return itemID; } }
    [SerializeField] private LocalizedString itemName;
    public LocalizedString ItemName { get { return itemName; } }
    [SerializeField] private Sprite itemImage;
    public Sprite ItemImage { get { return itemImage; } }
    [SerializeField] private LocalizedString itemDiscription;
    public LocalizedString ItemDiscription { get { return itemDiscription; } }
    [SerializeField] private string[] tags;
    public string[] Tags { get { return tags; } }

    static bool TryItemFromSet(ItemData[] set, string ID, out ItemData to)
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
    {
        for(int i = 0; i < tags.Length; i++)
        {
            if (tags[i] == tag) return true;
        }

        return false;
    }
}
