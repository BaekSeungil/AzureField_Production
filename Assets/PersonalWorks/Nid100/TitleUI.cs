using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class TitleUI : StaticSerializedMonoBehaviour<TitleUI>
{
    public void QuitGame()
    {
        Application.Quit();
    }
    
}
