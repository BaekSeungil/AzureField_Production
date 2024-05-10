using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FMOD.Studio;
using FMODUnity;

public class SoundOpton : MonoBehaviour
{
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
