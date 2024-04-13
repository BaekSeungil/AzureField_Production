using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class UI_Objective : StaticSerializedMonoBehaviour<UI_Objective>
{
    [SerializeField] private GameObject visualGroup;
    [SerializeField] private TextMeshProUGUI questTitleText;
    [SerializeField] private TextMeshProUGUI objectiveText;
    [SerializeField] private GameObject moveCloseAnimation;

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
        //moveCloseAnimation.GetComponent<DOTweenAnimation>().DOPlayAllById("Close");
    }
}
