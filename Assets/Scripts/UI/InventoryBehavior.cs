using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEditor;
using UnityEngine;

public class InventoryBehavior : MonoBehaviour
{
    [SerializeField] private GameObject slotPrefab;
    [SerializeField] private Vector2 slotDistance;
    [SerializeField] private Vector2 offset;
    [SerializeField] private int rowCount;
    [SerializeField] private RectTransform slotViewport;
    [SerializeField] private TextMeshProUGUI moneyText;

    private List<GameObject> instanciatedSlots;

    int currentScroll = 0;

    public void SetInventory(Dictionary<ItemData, int> data)
    {
        if(instanciatedSlots == null) instanciatedSlots = new List<GameObject>();

        KeyValuePair<ItemData, int>[] itemArray = data.ToArray();
        currentScroll = 0;

        for (int y = 0; y < (int)(itemArray.Length / rowCount); y++)
        {
            for (int x = 0; x < rowCount; x++)
            {
                GameObject newSlot = Instantiate(slotPrefab, slotViewport);
                newSlot.GetComponent<RectTransform>().anchoredPosition = new Vector2(slotDistance.x * x + offset.x, slotDistance.y * y + offset.y);
                InventorySlotSingle slot = newSlot.GetComponent<InventorySlotSingle>();
                slot.InitializeSlot(this,itemArray[x + y*rowCount].Key, itemArray[x + y * rowCount].Value);
                instanciatedSlots.Add(newSlot);
            }
        }
    }

    public void SetMoney(int value)
    {
        moneyText.text = value.ToString();
    }

    public void ClearInventory()
    {
        foreach (var slot in instanciatedSlots)
        {
            Destroy(slot.gameObject);
        }

        instanciatedSlots.Clear();

        currentScroll = 0;
    }

    public void ScrollInventoryUP()
    {
        if (currentScroll == 0) return;

        currentScroll--;
    }

    public void ScrollInventoryDOWN()
    {
        if (currentScroll >= instanciatedSlots.Count / rowCount) return;

        currentScroll++;
    }

    private void Update()
    {
        slotViewport.anchoredPosition = Vector2.Lerp(slotViewport.anchoredPosition, new Vector2(slotViewport.anchoredPosition.x, currentScroll * slotDistance.y), 0.2f);
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.green;

        int itemCount = 20;
        float squareSize = 200;
        for (int y = 0; y < (int)(itemCount / rowCount); y++)
        {
            for (int x = 0; x < rowCount; x++)
            {

                Gizmos.DrawWireCube(slotViewport.position + new Vector3(slotDistance.x * x, slotDistance.y * y,0f) + new Vector3(offset.x,offset.y,0f), squareSize * new Vector3(1,1,0));
            }
        }
    }
}
