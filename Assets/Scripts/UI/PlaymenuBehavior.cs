using FMODUnity;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public enum PlaymenuElement
{
    Inventory
}

public class PlaymenuBehavior : MonoBehaviour
{
    [SerializeField] GameObject visualGroup;
    [SerializeField] GameObject inventoryObject;

    [SerializeField] EventReference sound_Open;
    [SerializeField] EventReference sound_Close;

    MainPlayerInputActions input;

    private void Awake()
    {
        input = new MainPlayerInputActions();
        input.Player.Enable();
        input.Player.OpenPlaymenu.performed += OnOpenKeydown;
    }

    public void EnableInput()
    {
        input.Player.Enable();
    }

    public void DisableInput()
    {
        input.Player.Disable();
    }

    public void OnOpenKeydown(InputAction.CallbackContext context)
    {
        if (visualGroup.activeInHierarchy == false)
        {
            OpenPlaymenu();
        }
        else
        {
            ClosePlaymenu();
        }
    }

    public void OpenPlaymenu(PlaymenuElement playmenu = PlaymenuElement.Inventory)
    {
        visualGroup.SetActive(true);

        PlayerCore gameplayer = FindFirstObjectByType<PlayerCore>();
        if (gameplayer != null) { gameplayer.DisableForSequence(); }

        if (playmenu == PlaymenuElement.Inventory)
        {
            inventoryObject.SetActive(true);
            PlayerInventoryContainer inventoryContainer = FindFirstObjectByType<PlayerInventoryContainer>();
            if (inventoryContainer == null) { Debug.Log("인벤토리 열기를 시도했지만 PlayterInventoryContainer를 찾을 수 없었습니다."); return; }

            RuntimeManager.PlayOneShot(sound_Open);
            visualGroup.SetActive(true);
            InventoryBehavior inventory = inventoryObject.GetComponent<InventoryBehavior>();
            inventory.SetInventory(inventoryContainer.InventoryData);
            inventory.SetMoney(inventoryContainer.Money);
        }
    }

    public void ClosePlaymenu()
    {
        visualGroup.SetActive(false);

        PlayerCore gameplayer = FindFirstObjectByType<PlayerCore>();
        if (gameplayer != null) { gameplayer.EnableForSequence(); }

        RuntimeManager.PlayOneShot(sound_Close);

    }
}
