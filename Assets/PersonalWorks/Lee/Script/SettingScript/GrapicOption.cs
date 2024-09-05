using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;
using UnityEngine.Rendering;
using System;

public class GrapicOption : MonoBehaviour
{
    [SerializeField] List<RenderPipelineAsset> RenderPipeLine;
    [SerializeField] TMP_Dropdown screenmodeDropdown;
    [SerializeField] TMP_Dropdown RpDropdown;       // 그래픽 설정 DropDown;
    [SerializeField] TMP_Dropdown resolutionDropDown; //해상도 DropDow
    List<Resolution> resolutions = new List<Resolution>();

    FullScreenMode screenMode;

    int resolutionNum;

    private void OnEnable()
    {
        ViewUI();

        if (Screen.fullScreenMode == FullScreenMode.ExclusiveFullScreen)
            screenmodeDropdown.value = 0;
        else if (Screen.fullScreenMode == FullScreenMode.FullScreenWindow)
            screenmodeDropdown.value = 1;
        else if (Screen.fullScreenMode == FullScreenMode.Windowed)
            screenmodeDropdown.value = 2;

        Screen.fullScreenMode = (FullScreenMode)screenmodeDropdown.value;

        resolutionDropDown.value = Array.FindIndex<Resolution>(Screen.resolutions, res => (res.width == Screen.currentResolution.width) && (res.height == Screen.currentResolution.height));

        RpDropdown.value = QualitySettings.GetQualityLevel();

    }

    public void SetPipeLine(int value)
    {
        PlayerPrefs.SetInt("renderpipeline", value);
        QualitySettings.SetQualityLevel(value);
        QualitySettings.renderPipeline = RenderPipeLine[value];
    }

    void ViewUI()
    {
        //주시율 60HZ제한
        // for(int i = 0; i<Screen.resolutions.Length; i++)
        // {
        //    if(Screen.resolutions[i].refreshRate == 60)
        //    {
        //       resolutions.Add(Screen.resolutions[i]);
        //    }
        // }
        resolutions.Clear();
        resolutions.AddRange(Screen.resolutions);
        resolutionDropDown.options.Clear();
        int optionNum = 0;
        foreach (Resolution item in resolutions)
        {
            TMP_Dropdown.OptionData option = new TMP_Dropdown.OptionData();
            option.text = item.width + " X " + item.height;
            resolutionDropDown.options.Add(option);

            if (item.width == Screen.width && item.height == Screen.height)
            {
                resolutionDropDown.value = optionNum;
            }
            optionNum++;
        }

        resolutionDropDown.RefreshShownValue();
    }

    public void CangeResolution(int index)
    {
        Screen.SetResolution(Screen.resolutions[index].width, Screen.resolutions[index].height,Screen.fullScreenMode);
        PlayerPrefs.SetInt("resolution_x", Screen.resolutions[index].width); PlayerPrefs.SetInt("resolution_y", Screen.resolutions[index].height);
    }

    public void ChangeScreenmode(int index)
    {
        if(index == 0)
        {
#if PLATFORM_STANDALONE_WIN
            Screen.fullScreenMode = FullScreenMode.ExclusiveFullScreen;
#endif
        }
        else if(index == 1)
        {
            Screen.fullScreenMode = FullScreenMode.FullScreenWindow;
        }
        else if(index == 2)
        {
            Screen.fullScreenMode = FullScreenMode.Windowed;
        }

        PlayerPrefs.SetInt("screenmode", index);
    }

    public void okBoolClick()
    {
        Screen.SetResolution(resolutions[resolutionNum].width,
        resolutions[resolutionNum].height, screenMode);
    }
}
