using DG.Tweening;
using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Localization;
using UnityEngine.UI;

public class UI_FairwindInfo : StaticSerializedMonoBehaviour<UI_FairwindInfo>
{
    [SerializeField] private LocalizedString message_succeed;
    [SerializeField] private LocalizedString message_failTimeout;
    [SerializeField] private LocalizedString message_failRouteout;

    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private GameObject visualGroup;
    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private GameObject fairwnindObject;
    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private TextMeshProUGUI fairwindCountdown_integer;
    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private TextMeshProUGUI fairwindCountdown_frac;
    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private GameObject alertObject;
    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private TextMeshProUGUI alertCountdown_integer;
    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private TextMeshProUGUI alertCountdown_frac;
    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private GameObject successUI;
    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private TextMeshProUGUI successUI_text;
    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private GameObject failedUI;
    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private TextMeshProUGUI failedUI_text;
    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private GameObject additinalTime;
    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private TextMeshProUGUI additinalTime_text;

    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private GameObject FairProcess;
    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private GameObject AlertProcess;
    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private Slider[] SetProcessSlider;

    [SerializeField, Required, FoldoutGroup("ChildReferences")]
    private GameObject ProcessIcon;

    private List<GameObject> nodeIcons = new List<GameObject>();
     bool SetChalleng = false;
     private float Progress;
    private void Start()
    {
        visualGroup.SetActive(false);
        successUI.SetActive(false);
        failedUI.SetActive(false);
        
        fairwindCountdown_integer.text = "00";
        fairwindCountdown_frac.text = "00";
        alertCountdown_integer.text = "00";
        alertCountdown_frac.text = "00";

        foreach (var slider in SetProcessSlider)
        {
            if (slider != null)
                Debug.Log("슬라이더 초기화됨: " + slider.gameObject.name);
            else
            {
                Debug.Log("슬라이더가 null입니다.");
            }
        }

    }

    public void ToggleFairwindUI(bool value)
    {
        if (value == true)
        {
            visualGroup.SetActive(true);
            SetChalleng = true;
        }
        else
        {
            successUI.SetActive(false);
            failedUI.SetActive(false);
            ToggleAlertUI(false);
            visualGroup.SetActive(false);
        }
    }

    public void ToggleAlertUI(bool value)
    {
        if(value != alertObject.activeInHierarchy)
        {
            alertObject.SetActive(value);
            AlertProcess.SetActive(value);
            FairProcess.SetActive(false);
        }
        else
        {
            FairProcess.SetActive(true);
        }
    }

    public void SetFairwindCountdown(float time)
    {
        if (time < 0f) time = 0f;
        if (!visualGroup.activeInHierarchy) return;
        fairwindCountdown_integer.text = ((int)time).ToString();
        fairwindCountdown_frac.text = (((int)(time*100))%100).ToString();
    }

    public void SetAlertCountdown(float time)
    {
        if (time < 0f) time = 0f;
        if (!alertObject.activeInHierarchy) return;
        alertCountdown_integer.text = ((int)time).ToString();
        alertCountdown_frac.text = (((int)(time * 100)) % 100).ToString();
    }

    public void OnFairwindSuccessed()
    {
        ToggleAlertUI(false);       
        successUI.SetActive(true);
        successUI_text.text = message_succeed.GetLocalizedString();
        SetChalleng = false;
    }

    public void OnFairwindTimeoutFailed()
    {
        ToggleAlertUI(false);
        failedUI.SetActive(true);
        failedUI_text.text = message_failTimeout.GetLocalizedString();
        SetChalleng = false;
    }

    public void OnFairwindRouteoutFailed()
    {
        ToggleAlertUI(false);
        failedUI.SetActive(true);
        failedUI_text.text = message_failRouteout.GetLocalizedString();
    }

    public void OnAdditionalTime(float time)
    {
        additinalTime.SetActive(false);
        additinalTime.SetActive(true);
        additinalTime_text.text = "+ " + ((int)time).ToString();
    }

/// <summary>
/// 순풍의 도전 시작지점과 도착지점에서 값을 받아온 뒤
/// 슬라이드에 반영
/// </summary>
    public void UpdateSlider(float progress)
    {   
        foreach(Slider slider in SetProcessSlider)
        {
            if (slider != null)
            {
                slider.value = Mathf.Clamp(progress, 0f, 1f);
                Debug.Log("슬라이더" + slider.value);
            }

        }

        UpdateNodeIcons(progress);
    }

    private void UpdateNodeIcons(float progress)
    {
        int completedIcons = Mathf.FloorToInt(progress * nodeIcons.Count);  // 진행된 아이콘의 수 계산

        for (int i = 0; i < nodeIcons.Count; i++)
        {
            if (i < completedIcons)
            {
                nodeIcons[i].SetActive(false);  // 활성화된 아이콘
            }
            else
            {
                nodeIcons[i].SetActive(true);  // 비활성화된 아이콘
            }
        }
    }
}
