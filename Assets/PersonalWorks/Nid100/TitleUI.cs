using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions.Must;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class TitleUI : StaticSerializedMonoBehaviour<TitleUI>
{
    public GameObject firstButton;
    
    public void QuitGame()
    {
        Application.Quit();
    }

    public void SelectFirstButton()
    {
        EventSystem.current.SetSelectedGameObject(null);
        EventSystem.current.SetSelectedGameObject(firstButton);
    }
    
}
