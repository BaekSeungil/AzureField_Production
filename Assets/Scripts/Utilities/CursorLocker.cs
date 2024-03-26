using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CursorLocker : StaticSerializedMonoBehaviour<CursorLocker>
{
    public enum CursorMode
    {
        Freelook,
        CursorVisible
    }

    [SerializeField,ReadOnly] private CursorMode cursorState = CursorMode.Freelook;
    public CursorMode CurrentCursorState { get { return cursorState; } }

    private void Start()
    {
        EnableFreelook();
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
