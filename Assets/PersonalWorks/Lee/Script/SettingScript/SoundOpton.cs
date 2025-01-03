using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FMOD.Studio;
using UnityEngine.UI;

public class SoundOpton : MonoBehaviour
{
    [SerializeField] private Slider MasterSlider;
    [SerializeField] private Slider SFXSlider;
    [SerializeField] private Slider AmbientSlider;
    [SerializeField] private Slider UISlider;
    [SerializeField] private Slider MusicSlider;
    [SerializeField] private Slider VoiceSlider;

    Bus Music;
    Bus SFX;
    Bus Ambient;
    Bus UI;
    Bus Master;
    Bus Voice;

    private void Awake()
    {
        Master = FMODUnity.RuntimeManager.GetBus("bus:/Master");
        Music = FMODUnity.RuntimeManager.GetBus("bus:/Master/Music");
        Ambient = FMODUnity.RuntimeManager.GetBus("bus:/Master/Ambient");
        UI = FMODUnity.RuntimeManager.GetBus("bus:/Master/UI");
        SFX = FMODUnity.RuntimeManager.GetBus("bus:/Master/SFX");
        Voice = FMODUnity.RuntimeManager.GetBus("bus:/Master/Voice");
    }

    private void OnEnable()
    {
        float f = 0;

        Master.getVolume(out f);
        MasterSlider.value = f;

        Music.getVolume(out f);
        MusicSlider.value = f;

        Ambient.getVolume(out f);
        AmbientSlider.value = f;

        UI.getVolume(out f);
        UISlider.value = f;

        SFX.getVolume(out f);
        SFXSlider.value = f;

        Voice.getVolume(out f);
        VoiceSlider.value = f;
    }

    public void SetMaster(float value)
    {
        Master.setVolume(value);
        PlayerPrefs.SetFloat("master_volume", value);
    }

    public void SetSFX(float value)
    {
        SFX.setVolume(value);
        PlayerPrefs.SetFloat("sfx_volume", value);
    }

    public void SetAmbient(float value)
    {
        Ambient.setVolume(value);
        PlayerPrefs.SetFloat("ambient_volume", value);
    }

    public void SetUI(float value)
    {
        UI.setVolume(value);
        PlayerPrefs.SetFloat("ui_volume", value);
    }

    public void SetMusic(float value)
    {
        Music.setVolume(value);
        PlayerPrefs.SetFloat("music_volume", value);
    }

    public void SetVoice(float value)
    {
        Voice.setVolume(value);
        PlayerPrefs.SetFloat("voice_volume", value);
    }
}
