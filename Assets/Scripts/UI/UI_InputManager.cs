using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UI_InputManager : StaticSerializedMonoBehaviour<UI_InputManager>
{
    private MainPlayerInputActions ui_input;
    public MainPlayerInputActions UI_Input { get { return ui_input; } }


    protected override void Awake()
    {
        base.Awake();
        ui_input = new MainPlayerInputActions();
        ui_input.Enable();
    }

    public void DisableUIInputs()
    {
        ui_input.Disable();
    }

    public void EnableUIInputs()
    {
        ui_input.Enable();
    }
}
