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

    [SerializeField] private InventoryBehavior inventoryManager;
    public InventoryBehavior InventoryManager { get { return inventoryManager; } }

    [SerializeField] private Image itemImage;
    [SerializeField] private TextMeshProUGUI quantityText;

    private MainPlayerInputActions input;
    private Sprite debug_imageError;

    private void Awake()
    {
        debug_imageError = itemImage.sprite;
        input = new MainPlayerInputActions();
        input.UI.Enable();
    }

    public void InitializeSlot(InventoryBehavior inventory, ItemData item, int quantity = 1)
    {
        assignedItem = item;
        itemImage.sprite = item.ItemImage;
        inventoryManager = inventory;
        if(quantity >= 1) quantityText.text = quantity.ToString();
    }

    public void OnItemUsed()
    {
        PlayerInventoryContainer inventoryContainer = PlayerInventoryContainer.Instance;
        if (inventoryContainer == null) { Debug.Log("인벤토리정보에 접근하려 했으나 PlayerInventoryConatiner가 없습니다."); return; }

        inventoryContainer.RemoveItem(assignedItem);
    }

    public void ClearSlot()
    {
        assignedItem = null;
        itemImage.sprite = debug_imageError;
        quantityText.text = string.Empty;
    }
}
