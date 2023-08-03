using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class DialogueAnswerSingle : MonoBehaviour
{
    [SerializeField] private GameObject SelectedIndicator;
    [SerializeField] private TextMeshProUGUI contextText;
    [SerializeField] private Button button;
    private int index;
    private DialogueBehavior dialogueBehavior;

    public void Initialize(DialogueBehavior behavior,string context,int _index)
    {
        dialogueBehavior = behavior;
        contextText.text = context;
        index = _index;
        Vector2 point = behavior.Input.UI.Point.ReadValue<Vector2>();
    }

    public void OnButtonDown()
    {
        dialogueBehavior.OnAnswerSelectedByMouse(index);
    }

    public void OnButtonMouseEnter()
    {
        if(!dialogueBehavior.WhileBreak)
        {
            dialogueBehavior.OnAnswerMouseEnter(index);
        }
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
