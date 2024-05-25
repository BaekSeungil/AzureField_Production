using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UI_Tutorials : SerializedMonoBehaviour
{
    public struct TutorialCollective
    {
        GameObject keyboard;
        GameObject gamepad;
    }

    [SerializeField] private RectTransform tutorialWindowPoint;
    [SerializeField] private Dictionary<string, TutorialCollective> tutorialObjects;

    private void OpenTutorial(string tutorialKey)
    {
        
    }
}
