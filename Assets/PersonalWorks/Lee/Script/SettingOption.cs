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

   //그래픽 파이프라인
   public void SetPipeLine(int value)
   {
        QualitySettings.SetQualityLevel(value);
        QualitySettings.renderPipeline = RenderPipeLine[value];
   }

   public void MasterVolumeLevel(float newMasterVolume)
   {
      MasterVolme = newMasterVolume;
   }
   public void MusicVolumeLevel(float newMusicVolume)
   {
      MasterVolme =  newMusicVolume;
   }

   public void SFXVolumeLevel(float newSFXVolume)
   {
      MasterVolme =  newSFXVolume;
      FMOD.Studio.PLAYBACK_STATE PbState;
      VolumeEvent.getPlaybackState(out PbState);
      if(PbState != FMOD.Studio.PLAYBACK_STATE.PLAYING)
      {
         VolumeEvent.start();
      }

   }

   public void InButton()
   {
      
   }

   public void ExitWindow()
   {
      Destroy(gameObject);
   }



}
