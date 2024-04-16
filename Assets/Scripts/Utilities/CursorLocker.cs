using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class CursorLocker : StaticSerializedMonoBehaviour<CursorLocker>
{
    public enum CursorMode
    {
        Freelook,
        CursorVisible
    }

    [SerializeField,ReadOnly] private CursorMode cursorState = CursorMode.Freelook;
    public CursorMode CurrentCursorState { get { return cursorState; } }

    private MainPlayerInputActions input;

    protected override void Awake()
    {
        base.Awake();
        input = new MainPlayerInputActions();
        input.Enable();
    }

    private void Update()
    {
        if(cursorState == CursorMode.CursorVisible)
        {
            if(Cursor.visible == false)
            {
                DisableFreelook();
            }
        }
        else
        {
            if (Cursor.visible == true)
            {
                EnableFreelook();
            }
        }
    }

    public void EnableFreelook()
    {
        cursorState = CursorMode.Freelook;
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    public void DisableFreelook()
    {
        cursorState = CursorMode.CursorVisible;
        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;
    }
}
