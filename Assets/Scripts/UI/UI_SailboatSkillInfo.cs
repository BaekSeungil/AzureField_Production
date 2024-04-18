using DG.Tweening;
using DG.Tweening.Core;
using Sirenix.OdinInspector.Editor.Validation;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UI_SailboatSkillInfo : StaticSerializedMonoBehaviour<UI_SailboatSkillInfo>
{
    [SerializeField] private Image boosterRing;
    [SerializeField] private Image LeapupRing;
    [SerializeField] private DOTweenAnimation tweenAnimation;

    public void ToggleInfo(bool value)
    {
        if (value)
        {
            tweenAnimation.DORestartAllById("Open");
        }
        else
        {
            tweenAnimation.DORestartAllById("Close");
        }
    }

    public void SetBoosterRing(float value)
    {
        value = Mathf.Clamp01(value);
        boosterRing.fillAmount = value;
    }

    public void SetLeapupRing(float value)
    {
        value = Mathf.Clamp01(value);
        LeapupRing.fillAmount = value;
    }
}
