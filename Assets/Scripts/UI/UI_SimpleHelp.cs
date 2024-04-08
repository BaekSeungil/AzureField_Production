using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;



public class UI_SimpleHelp : MonoBehaviour
{
    [SerializeField] private GameObject helpWindow;
    [SerializeField] private GameObject helpFolded;

    private MainPlayerInputActions input;

    private void Awake()
    {
        input = new MainPlayerInputActions();
        input.Enable();
        input.UI.SimpleHelp.started += KeyDown;
        input.UI.SimpleHelp.canceled += KeyUp;
    }

    public void KeyDown(InputAction.CallbackContext context)
    {
        helpFolded.SetActive(false);
        helpWindow.SetActive(true);
    }

    public void KeyUp(InputAction.CallbackContext context) 
    {
        helpFolded.SetActive(true);
        helpWindow.SetActive(false);
    }
}
