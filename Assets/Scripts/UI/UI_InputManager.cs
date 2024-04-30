using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UI_InputManager : PersistentSerializedMonoBehaviour<UI_InputManager>
{
    private MainPlayerInputActions ui_input;
    public MainPlayerInputActions UI_Input { get { return ui_input; } }

    [ShowInInspector, ReadOnly()] bool UI_Enabled = true;

    protected override void Awake()
    {
        base.Awake();
        Debug.Log("InputInitialized");
        ui_input = new MainPlayerInputActions();
        ui_input.Enable();
    }

    public void DisableUIInputs()
    {
        ui_input.Disable();
        UI_Enabled = false;
    }

    public void EnableUIInputs()
    {
        ui_input.Enable();
        UI_Enabled = true;
    }
}
