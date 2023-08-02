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
            if(inventoryContainer == null) { Debug.Log("인벤토리 열기를 시도했지만 PlayterInventoryContainer를 찾을 수 없었습니다."); return; }            
        }
    }
}
