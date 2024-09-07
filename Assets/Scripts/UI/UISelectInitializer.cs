using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class UISelectInitializer : MonoBehaviour
{
    public GameObject FirstButton;
    public GameObject SelectOnDisable;
    private void OnEnable()
    {
        if (FirstButton != null)
        {
            //EventSystem.current.SetSelectedGameObject(null);
            EventSystem.current.SetSelectedGameObject(FirstButton);
            Debug.Log("EventSystem.current Changed : " + FirstButton.name);
        }
    }

    private void OnDisable()
    {
        if (SelectOnDisable != null)
        {
            //EventSystem.current.SetSelectedGameObject(null);
            EventSystem.current.SetSelectedGameObject(SelectOnDisable);
            Debug.Log("EventSystem.current Changed : " + SelectOnDisable.name);
        }
    }
}
