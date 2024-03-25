using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.Rendering;

public class SettingOption : MonoBehaviour
{
   FMOD.Studio.EventInstance VolumeEvent;
   FMOD.Studio.Bus Music;
   FMOD.Studio.Bus SFX;
   FMOD.Studio.Bus Master;

   
   [Header("환경설정")]
    [SerializeField] float MusicVolme;

    [SerializeField] float SFXVolme;
    [SerializeField] float MasterVolme;
   [SerializeField] List<RenderPipelineAsset> RenderPipeLine;
   [SerializeField] TMP_Dropdown Dropdown;


   private void Awake() 
   {
      Music = FMODUnity.RuntimeManager.GetBus("bus:/Master/Music");
      SFX = FMODUnity.RuntimeManager.GetBus("bus:/Master/SFX");
      Master = FMODUnity.RuntimeManager.GetBus("bus:/Master");
      VolumeEvent = FMODUnity.RuntimeManager.CreateInstance("event:/SFX/VolumeEvent");
   }

   private void Update() 
   {
      Music.setVolume(MusicVolme);
      SFX.setVolume(SFXVolme);
      Master.setVolume(MasterVolme);
   }

   

   
   public void SetPipeLine(int value)
   {
        QualitySettings.SetQualityLevel(value);
        QualitySettings.renderPipeline = RenderPipeLine[value];
   }

}
