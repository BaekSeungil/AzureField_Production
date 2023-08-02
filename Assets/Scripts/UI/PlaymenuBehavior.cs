using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum PlaymenuElement
{
    Inventory
}

public class PlaymenuBehavior : MonoBehaviour
{
    [SerializeField] GameObject visualGroup;
    [SerializeField] GameObject inventoryObject;



    public void OpenPlaymenu(PlaymenuElement playmenu = PlaymenuElement.Inventory)
    {
        visualGroup.SetActive(true);

        if(playmenu == PlaymenuElement.Inventory)
        {
            inventoryObject.SetActive(true);
            PlayerInventoryContainer inventoryContainer = FindFirstObjectByType<PlayerInventoryContainer>();
            if(inventoryContainer == null) { Debug.Log("�κ��丮 ���⸦ �õ������� PlayterInventoryContainer�� ã�� �� �������ϴ�."); return; }            
        }
    }
}
