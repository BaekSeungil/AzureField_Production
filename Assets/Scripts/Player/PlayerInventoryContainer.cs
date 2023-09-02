using JetBrains.Annotations;
using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInventoryContainer : StaticSerializedMonoBehaviour<PlayerInventoryContainer>
{
    [SerializeField, ReadOnly] private Dictionary<ItemData, int> inventoryData;
    public Dictionary<ItemData, int> InventoryData { get { return inventoryData; } }

    private Dictionary<ItemData, int> debug_items;

    [SerializeField,ReadOnly] private int money;
    public int Money { get { return money; } }

    protected override void Awake()
    {
        base.Awake();

        inventoryData = new Dictionary<ItemData, int>();
        if(debug_items != null)
        {
            foreach(var item in debug_items)
            {
                inventoryData.Add(item.Key, item.Value);
            }
        }
    }

    public void AddItem(ItemData item)
    {
        if (inventoryData.ContainsKey(item))
        {
            inventoryData[item]++;
        }
        else
        {
            inventoryData.Add(item, 1);
        }

        TryResetInventoryUI();
    }

    public void AddItem(ItemData item, int quantity)
    {
        if (quantity < 0) { Debug.LogWarning("InventoryContainer : 비정상적인 아이템 추가 시도"); return; }

        if (inventoryData.ContainsKey(item))
        {
            inventoryData[item] += quantity;
        }
        else
        {
            inventoryData.Add(item, quantity);
        }

        TryResetInventoryUI();
    }

    public IEnumerator Cor_ItemWindow(ItemData item,int quantity)
    {
        ItemObtainInfo info = ItemObtainInfo.Instance;
        if (info == null) yield break;

        yield return info.StartCoroutine(info.Cor_OpenWindow(item,quantity));
    }

    public bool RemoveItem(ItemData item)
    {
        if (inventoryData.ContainsKey(item))
        {
            if (inventoryData[item] <= 1)
            {
                inventoryData.Remove(item);
            }
            else
            {
                inventoryData[item]--;
            }

            TryResetInventoryUI();

            return true;
        }
        else
        {
            return false;
        }


    }

    public bool RemoveItem(ItemData item, int quantity)
    {
        if (inventoryData.ContainsKey(item))
        {
            if (inventoryData[item] == quantity)
            {
                inventoryData.Remove(item);
                TryResetInventoryUI();
                return true;
            }
            else if (inventoryData[item] < quantity)
            {
                return false;
            }
            else
            {
                inventoryData[item] -= quantity;
                TryResetInventoryUI();
                return true;
            }
        }
        else
        {
            return false;
        }
    }

    public bool HasItem(string itemID)
    {
        var items = inventoryData.Keys;

        foreach (var item in items)
        {
            if (item.ItemID == itemID) return true;
        }
        return false;
    }

    public void AddMoney(int value)
    {
        int le = money;
        money += value;

        MoneyObtainInfo info = MoneyObtainInfo.Instance;
        if (info != null) { info.MoneyChanged(le, value); return; }
    }

    public bool UseMoney(int value)
    {
        if (money < value) return false;
        else
        {
            int le = money;
            money -= value;

            MoneyObtainInfo info = MoneyObtainInfo.Instance;
            if (info != null) { info.MoneyChanged(le, -value); }

            TryResetInventoryUI();

            return true;
        }
    }

    private void TryResetInventoryUI()
    {
        InventoryBehavior uiInventory = InventoryBehavior.Instance;
        if (uiInventory != null) 
        { 
            uiInventory.SetInventory(inventoryData);
            uiInventory.SetMoney(money);
        }
    }
}
