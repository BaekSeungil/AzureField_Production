using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class TitleUI : MonoBehaviour
{
    public string sceneName;
    public GameObject endPopup;

    void Start()
    {
        
    }

    void Update()
    {
        
    }

    public void MoveScene()
    {
        SceneManager.LoadScene(sceneName);
    }

    public void EndBtnPopupOn()
    {
        endPopup.SetActive(true);
    }
    public void EndBtnPopupOff()
    {
        endPopup.SetActive(false);
    }
    public void GameEnd()
    {
        Application.Quit();
    }
}
