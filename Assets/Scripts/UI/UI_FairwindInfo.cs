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
            }

        }
    }

    public void UpdateIcon(float totalNodes, float progress)
    {
        // 기존 아이콘 초기화
        foreach (GameObject icon in nodeIcons)
        {
            Destroy(icon);
        }
        nodeIcons.Clear();

        // 각 슬라이더마다 아이콘을 생성
        foreach (Slider slider in SetProcessSlider)
        {
            if (slider != null)
            {
                RectTransform sliderRect = slider.GetComponent<RectTransform>();
                float sliderWidth = sliderRect.sizeDelta.x;

                // 노드 개수에 따라 아이콘 위치 설정
                for (int i = 0; i <= totalNodes-1; i++)
                {
                    float nodeProgress = (int)i / (float)totalNodes; // 0부터 1까지 균등하게 분배
                    float iconXPosition = sliderWidth * nodeProgress;

                    // 아이콘 생성
                    GameObject newIcon = Instantiate(ProcessIcon, slider.transform);
                    // 아이콘의 위치 설정
                     RectTransform iconTransform = newIcon.GetComponent<RectTransform>();
                    iconTransform.anchoredPosition = new Vector2(iconXPosition, 0);
                    newIcon.SetActive(nodeProgress > progress); // 진행전 아이콘 활성화

                    if (nodeProgress < progress)  // 진행된 부분은 아이콘을 비활성화
                    {
                        newIcon.SetActive(false);
                    }
                    
                    // 생성한 아이콘을 리스트에 추가하여 관리
                    nodeIcons.Add(newIcon);
                }
                
            }
        
        }
    }

}
