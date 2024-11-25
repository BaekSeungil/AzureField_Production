using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

public class TitleUI : StaticSerializedMonoBehaviour<TitleUI>
{
    string gamepadSchemeName = "Gamepad";

    public GameObject firstButton;

    private void Start()
    {
        Cursor.lockState = CursorLockMode.None;
    }

    public void QuitGame()
    {
        Application.Quit();
    }

    public void SelectFirstButton()
    {
        if (PlayerInput.all.Count > 0)
        {
            if (PlayerInput.all[0].currentControlScheme != gamepadSchemeName) return;
            EventSystem.current.SetSelectedGameObject(null);
            EventSystem.current.SetSelectedGameObject(firstButton);
        }
    }
    
}
