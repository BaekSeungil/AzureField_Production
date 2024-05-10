using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using TMPro;
using UnityEngine.Rendering;
using Unity.Entities;
using UnityEngine.InputSystem;
using UnityEngine.PlayerLoop;
using FMOD;

public class SettingOption : StaticSerializedMonoBehaviour<SettingOption>
{
    [SerializeField] public GameObject Setting;
    [SerializeField] public GameObject SoundSetting;
    [SerializeField] public GameObject GrapicSetting;
    [SerializeField] public GameObject MoveSetting;
    [SerializeField] private GameObject backPanel;

    MainPlayerInputActions settigUI_inputs;


    private static bool GameIsPaused = false;

    protected override void Awake()
    {
        settigUI_inputs = new MainPlayerInputActions();
        settigUI_inputs.UI.Enable();
    }

    private void Update()
    {
        if (Keyboard.current[Key.Escape].wasPressedThisFrame)
        {
            if (GameIsPaused)
            {
                UI_InputManager.Instance.UI_Input.Enable();
                Resume();
            }
            else
            {
                UI_InputManager.Instance.UI_Input.Disable();
                Pause();
            }
        }

    }
    public void Resume()
    {
        CursorLocker.Instance.EnableFreelook();
        backPanel.SetActive(false);
        Setting.SetActive(false);
        GrapicSetting.SetActive(false);
        SoundSetting.SetActive(false);
        MoveSetting.SetActive(false);
        Time.timeScale = 1f;
        GameIsPaused = false;

    }

    public void Pause()
    {
        CursorLocker.Instance.DisableFreelook();
        backPanel.SetActive(true);
        Setting.SetActive(true);
        Time.timeScale = 0f;
        GameIsPaused = true;
    }

    public void SetSoundprefab()
    {
        SoundSetting.SetActive(true);
        Setting.SetActive(false);
        GrapicSetting.SetActive(false);
    }

    public void Exitprefab()
    {
        Setting.SetActive(true);
        GrapicSetting.SetActive(false);
        SoundSetting.SetActive(false);
        MoveSetting.SetActive(false);
    }

    public void SetGrapicprefab()
    {
        GrapicSetting.SetActive(true);
        Setting.SetActive(false);
        SoundSetting.SetActive(false);
        MoveSetting.SetActive(false);

    }
    public void SetMoveprefab()
    {
        MoveSetting.SetActive(true);
        Setting.SetActive(false);
        SoundSetting.SetActive(false);
        MoveSetting.SetActive(false);
    }


    public void QuitGame()
    {
        Application.Quit();
#if UNITY_EDITOR
        EditorApplication.ExitPlaymode();
#endif
    }
}
