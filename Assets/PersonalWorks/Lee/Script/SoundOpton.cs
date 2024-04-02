using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundOpton : MonoBehaviour
{
    FMOD.Studio.EventInstance VolumeEvent;
    FMOD.Studio.Bus Music;
    FMOD.Studio.Bus SFX;
    FMOD.Studio.Bus Master;

    [SerializeField] float MusicVolme;
    [SerializeField] float SFXVolme;
    [SerializeField] float MasterVolme;

    private void Awake() 
    {
        Music = FMODUnity.RuntimeManager.GetBus("bus:/BackGround/Music");
        SFX = FMODUnity.RuntimeManager.GetBus("bus:/Events/UI");
        SFX = FMODUnity.RuntimeManager.GetBus("bus:/Events/Ambient");
        SFX = FMODUnity.RuntimeManager.GetBus("bus:/Events/SoundEffect");
        Master = FMODUnity.RuntimeManager.GetBus("bus:/Banks/Master");
        VolumeEvent = FMODUnity.RuntimeManager.CreateInstance("event:/SFX/VolumeEvent");
    }

    void Update()
    {
        Music.setVolume(MusicVolme);
        SFX.setVolume(SFXVolme);
        Master.setVolume(MasterVolme);
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
}
