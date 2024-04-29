using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;
using UnityEngine.Rendering;

public class GrapicOption : MonoBehaviour
{   
   [SerializeField] List<RenderPipelineAsset> RenderPipeLine;
   [SerializeField] TMP_Dropdown Dropdown;       // 그래픽 설정 DropDown;
   [SerializeField] TMP_Dropdown resolutionDropDown; //해상도 DropDow
   [SerializeField] Toggle fullButton;
   List<Resolution> resolutions = new List<Resolution>();

   FullScreenMode screenMode;

   int resolutionNum;
   private void Start() 
   {
      ViewUI();
   }
   public void SetPipeLine(int value)
   {
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
      resolutions.AddRange(Screen.resolutions);
      resolutionDropDown.options.Clear();
      int optionNum = 0;
      foreach(Resolution item in resolutions)
      {
         TMP_Dropdown.OptionData option = new TMP_Dropdown.OptionData();
         option.text = item.width + " X " + item.height;
         resolutionDropDown.options.Add(option);

         if(item.width == Screen.width && item.height == Screen.height)
         {
            resolutionDropDown.value = optionNum;
         }
         optionNum++;
      }

      resolutionDropDown.RefreshShownValue();
      fullButton.isOn = Screen.fullScreenMode.Equals
      (FullScreenMode.FullScreenWindow) ? true:false;
   }

   public void DropDownChange(int X)
   {
      resolutionNum = X;
   }

   public void FullScreenBool(bool isFull)
   {
      screenMode = isFull ? FullScreenMode.FullScreenWindow :
      FullScreenMode.Windowed;
   }
   public void okBoolClick()
   {
      Screen.SetResolution(resolutions[resolutionNum].width,
      resolutions[resolutionNum].height,screenMode);
   }
}
