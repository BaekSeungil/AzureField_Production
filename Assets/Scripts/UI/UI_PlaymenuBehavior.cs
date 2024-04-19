using FMODUnity;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public enum PlaymenuElement // 플레이메뉴 타입
{
    Inventory
}

public class UI_PlaymenuBehavior : StaticSerializedMonoBehaviour<UI_PlaymenuBehavior>
{
    //===============================
    //
    // [싱글턴 오브젝트]
    // 인벤토리나, 지도, 기록 같은 플레이 메뉴 UI를 모두 관리합니다.
    // 메뉴 관련 요소들은 하위 오브젝트가 아닌 여기서 호출하세요!
    //
    //===============================  

    [SerializeField] GameObject visualGroup;
    [SerializeField] GameObject inventoryObject;

    [SerializeField] EventReference sound_Open;         // 소리 : 메뉴 오픈시 소리
    [SerializeField] EventReference sound_Close;        // 소리 : 메뉴 닫을시 소리

    MainPlayerInputActions input;

    protected override void Awake()
    {
        base.Awake();

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

    /// <summary>
    /// 플레이 메뉴를 엽니다.
    /// </summary>
    /// <param name="playmenu">메뉴 종류</param>
    public void OpenPlaymenu(PlaymenuElement playmenu = PlaymenuElement.Inventory)
    {
        visualGroup.SetActive(true);
        CursorLocker.Instance.DisableFreelook();

        PlayerCore gameplayer = PlayerCore.Instance;
        if (gameplayer != null) { gameplayer.DisableForSequence(); }

        if (playmenu == PlaymenuElement.Inventory)
        {
            inventoryObject.SetActive(true);
            PlayerInventoryContainer inventoryContainer = PlayerInventoryContainer.Instance;
            if (inventoryContainer == null) { Debug.Log("인벤토리 열기를 시도했지만 PlayterInventoryContainer를 찾을 수 없었습니다."); return; }

            RuntimeManager.PlayOneShot(sound_Open);
            visualGroup.SetActive(true);
            UI_InventoryBehavior inventory = inventoryObject.GetComponent<UI_InventoryBehavior>();
            inventory.SetInventory(inventoryContainer.InventoryData);
            inventory.SetMoney(inventoryContainer.Money);
        }
    }

    /// <summary>
    /// 플레이 메뉴를 닫습니다.
    /// </summary>
    public void ClosePlaymenu()
    {
        visualGroup.SetActive(false);
        CursorLocker.Instance.EnableFreelook();

        PlayerCore gameplayer = PlayerCore.Instance;
        if (gameplayer != null) { gameplayer.EnableForSequence(); }

        RuntimeManager.PlayOneShot(sound_Close);

    }
}
