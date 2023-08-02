using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class DialogueAnswerSingle : MonoBehaviour
{
    [SerializeField] private GameObject SelectedIndicator;
    [SerializeField] private TextMeshProUGUI contextText;

    public void Initialize(string context)
    {
        contextText.text = context;
    }

    public void OnSelected()
    {
        SelectedIndicator.SetActive(true);
    }

    public void OnDeselected()
    {
        SelectedIndicator.SetActive(false);
    }
}
