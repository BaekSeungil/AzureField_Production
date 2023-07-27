using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class InventorySlotSingle : MonoBehaviour
{
    [SerializeField,ReadOnly()] private ItemData assignedItem;
    public ItemData AssignedItem { get { return assignedItem; } }

    [SerializeField] private Image itemImage;
    [SerializeField] private TextMeshProUGUI quantityText;

    private Sprite debug_imageError;

    private void Awake()
    {
        debug_imageError = itemImage.sprite;
    }

    public void InitializeSlot(ItemData item, int quantity = 1)
    {
        assignedItem = item;
        itemImage.sprite = item.ItemImage;
        if(quantity >= 1) quantityText.text = quantity.ToString();
    }

    public void ClearSlot()
    {
        assignedItem = null;
        itemImage.sprite = debug_imageError;
        quantityText.text = string.Empty;
    }
}
