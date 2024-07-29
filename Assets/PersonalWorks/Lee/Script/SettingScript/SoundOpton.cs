using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FMOD.Studio;
using FMODUnity;
using UnityEngine.UI;

public class SoundOpton : MonoBehaviour
{
    [SerializeField] private Slider MasterSlider;
    [SerializeField] private Slider SFXSlider;
    [SerializeField] private Slider AmbientSlider;
    [SerializeField] private Slider UISlider;
    [SerializeField] private Slider MusicSlider;

    Bus Music;
    Bus SFX;
    Bus Ambient;
    Bus UI;
    Bus Master;

    private void Awake()
    {
        Master = FMODUnity.RuntimeManager.GetBus("bus:/Master");
        Music = FMODUnity.RuntimeManager.GetBus("bus:/Master/Music");
        Ambient = FMODUnity.RuntimeManager.GetBus("bus:/Master/Ambient");
        UI = FMODUnity.RuntimeManager.GetBus("bus:/Master/UI");
        SFX = FMODUnity.RuntimeManager.GetBus("bus:/Master/SFX");
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

    }

    public void SetMaster(float value)
    {
        Master.setVolume(value);
    }

    public void SetSFX(float value)
    {
        SFX.setVolume(value);
    }

    public void SetAmbient(float value)
    {
        Ambient.setVolume(value);
    }

    public void SetUI(float value)
    {
        UI.setVolume(value);
    }

    public void SetMusic(float value)
    {
        Music.setVolume(value);
    }
}
