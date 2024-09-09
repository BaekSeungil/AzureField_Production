using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

public class UISelectInitializer : MonoBehaviour
{
    public GameObject FirstButton;
    public GameObject SelectOnDisable;

    string gamepadSchemeName = "Gamepad";

    private void OnEnable()
    {
        if(UI_PlaymenuBehavior.IsInstanceValid)
        {
            if (UI_PlaymenuBehavior.Instance.IsTitlelineSelected) return;
        }

        if (FirstButton != null)
        {
            if (PlayerInput.all[0].currentControlScheme == gamepadSchemeName)
            {
                //EventSystem.current.SetSelectedGameObject(null);
                EventSystem.current.SetSelectedGameObject(FirstButton);
                Debug.Log("EventSystem.current Changed : " + FirstButton.name);
            }
        }
    }

    private void OnDisable()
    {
        if (UI_PlaymenuBehavior.IsInstanceValid)
        {
            if (UI_PlaymenuBehavior.Instance.IsTitlelineSelected) return;
        }

        if (SelectOnDisable != null)
        {
            if (PlayerInput.all[0].currentControlScheme == gamepadSchemeName)
            {
                //EventSystem.current.SetSelectedGameObject(null);
                EventSystem.current.SetSelectedGameObject(SelectOnDisable);
                Debug.Log("EventSystem.current Changed : " + SelectOnDisable.name);
            }
        }
    }
}
