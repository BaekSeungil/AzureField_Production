using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AlphaEndingPanel : MonoBehaviour
{
    [SerializeField] private int fairwindCounts = 6;
    [SerializeField] private GameObject visualGroup;

    int fairwindCleared = 0;

    public void OnClearedFairwind()
    {
        fairwindCounts++;
        if(fairwindCounts == fairwindCleared)
        {
            PlayerCore.Instance.DisableControls();
            visualGroup.SetActive(true);
        }
    }

    public void OnQuitButtonDown()
    {
        Application.Quit();
    }

    public void OnResume()
    {
        PlayerCore.Instance.EnableControls();
        visualGroup.SetActive(false);
    }

}
