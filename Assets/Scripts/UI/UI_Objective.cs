using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class UI_Objective : MonoBehaviour
{
    [SerializeField] private GameObject visualGroup;
    [SerializeField] private TextMeshProUGUI questTitleText;
    [SerializeField] private TextMeshProUGUI objectiveText;
    [SerializeField] private DOTweenAnimation moveCloseAnimation;

    private void Start()
    {
        visualGroup.SetActive(false);
    }

    public void OpenObjective()
    {
        visualGroup.SetActive(false);
        visualGroup.SetActive(true);
    }

    public void OpenObjective(string questTitle, string objective)
    {
        visualGroup.SetActive(false);
        visualGroup.SetActive(true);

        questTitleText.text = questTitle;
        objectiveText.text = objective;
    }

    public void CloseObjective()
    {
        moveCloseAnimation.DOPlayById("Close");
    }
}
