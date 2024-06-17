using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AlphaEndingPanel : MonoBehaviour
{
    [SerializeField] private int fairwindCounts = 6;
    [SerializeField] private GameObject visualGroup;

    [ShowInInspector,ReadOnly]int fairwindCleared = 0;

    public void OnClearedFairwind()
    {
        fairwindCleared++;
        if(fairwindCounts == fairwindCleared)
        {
            PlayerCore.Instance.DisableControls();
            CursorLocker.Instance.DisableFreelook();
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
        CursorLocker.Instance.EnableFreelook();
        visualGroup.SetActive(false);
    }

}
