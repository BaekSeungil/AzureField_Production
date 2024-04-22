using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UI_SailboatSkillInfo : StaticSerializedMonoBehaviour<UI_SailboatSkillInfo>
{
    [SerializeField] private Image boosterRing;
    [SerializeField] private DOTweenAnimation boosterAnimation;
    [SerializeField] private Image leapupRing;
    [SerializeField] private DOTweenAnimation leapupAnimation;
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

    public void AnimateBoosterRing()
    {
        boosterAnimation.DORestart();
    }

    public void SetLeapupRing(float value)
    {
        value = Mathf.Clamp01(value);
        leapupRing.fillAmount = value;
    }

    public void AnimateLeapupRing()
    {
        leapupAnimation.DORestart();
    }
}
