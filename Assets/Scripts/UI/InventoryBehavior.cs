using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEditor;
using UnityEngine;
using UnityEngine.InputSystem;

public class InventoryBehavior : MonoBehaviour
{
    [SerializeField] private GameObject slotPrefab;
    [SerializeField] private Vector2 slotDistance;
    [SerializeField] private Vector2 offset;
    [SerializeField] private int rowCount;
    [SerializeField] private RectTransform slotViewport;
    [SerializeField] private TextMeshProUGUI moneyText;
    [SerializeField] private TextMeshProUGUI noItemText;

    private MainPlayerInputActions input;

    private List<GameObject> instanciatedSlots;

    int currentScroll = 0;

    private void Awake()
    {
        input = new MainPlayerInputActions();
    }

    private void OnEnable()
    {
        input.Enable();
        input.UI.Navigate.performed += NavigateInventory;
    }

    public void SetInventory(Dictionary<ItemData, int> data)
    {
        if (instanciatedSlots == null) instanciatedSlots = new List<GameObject>();

        ClearInventory();

        KeyValuePair<ItemData, int>[] itemArray = data.ToArray();
        currentScroll = 0;

        if(itemArray.Length == 0) { noItemText.gameObject.SetActive(true); return; }
        else { noItemText.gameObject.SetActive(false); }

        for (int y = 0; y <= (int)(itemArray.Length / rowCount); y++)
        {
            for (int x = 0; x < Mathf.Clamp(itemArray.Length - y*rowCount,0,rowCount); x++)
            {
                GameObject newSlot = Instantiate(slotPrefab, slotViewport);
                newSlot.GetComponent<RectTransform>().anchoredPosition = new Vector2(slotDistance.x * x + offset.x, slotDistance.y * y + offset.y);
                InventorySlotSingle slot = newSlot.GetComponent<InventorySlotSingle>();
                slot.InitializeSlot(this,itemArray[x + y*rowCount].Key, itemArray[x + y *rowCount].Value);
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

    public void NavigateInventory(InputAction.CallbackContext context)
    {
        if(context.ReadValue<Vector2>() == Vector2.up)
        {
            ScrollInventoryUP();
        }
        else if(context.ReadValue<Vector2>() == Vector2.down)
        {
            ScrollInventoryDOWN();
        }               
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

    private void OnDisable()
    {
        input.Disable();
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.green;

        int itemCount = 20;
        float squareSize = 100;
        for (int y = 0; y < (int)(itemCount / rowCount); y++)
        {
            for (int x = 0; x < rowCount; x++)
            {
                Gizmos.DrawWireCube(slotViewport.position + new Vector3(slotDistance.x * x, slotDistance.y * y, 0f) + new Vector3(offset.x,offset.y,0f), squareSize * new Vector3(1,1,0));
            }
        }
    }
}
