using JetBrains.Annotations;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Localization.SmartFormat.Utilities;

public class PlayerInventoryContainer : MonoBehaviour
{
    private Dictionary<ItemData, int> inventoryData;
    public Dictionary<ItemData, int> InventoryData { get { return inventoryData; } }

    private int money;
    public int Money { get { return money; } }

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
    }

    public bool RemoveItem(ItemData item)
    {
        if (inventoryData.ContainsKey(item))
        {
            if (inventoryData[item] <= 1)
            {
                inventoryData.Remove(item);
                return true;
            }
            else
            {
                inventoryData[item]--;
                return true;
            }
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
                return true;
            }
            else if (inventoryData[item] < quantity)
            {
                return false;
            }
            else
            {
                inventoryData[item] -= quantity;
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
        money += value;
    }

    public bool UseMoney(int value)
    {
        if (money < value) return false;
        else return true;
    }
}
