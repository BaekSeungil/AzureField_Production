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
using UnityEngine.Localization.Settings;
using UnityEngine.Localization;
using System.Linq;
using UnityEngine.EventSystems;

public class SettingOption : StaticSerializedMonoBehaviour<SettingOption>
{
    [SerializeField] public GameObject Setting;
    [SerializeField] public GameObject SoundSetting;
    [SerializeField] public GameObject GrapicSetting;
    [SerializeField] public GameObject ControllSetting;
    [SerializeField] public TMP_Dropdown languageDropdown;

    MainPlayerInputActions settigUI_inputs;
    List<Locale> locales;

    protected override void Awake()
    {
        settigUI_inputs = new MainPlayerInputActions();
        settigUI_inputs.UI.Enable();


    }

    //private void Update()
    //{
    //    if (Keyboard.current[Key.Escape].wasPressedThisFrame)
    //    {
    //        if (GameIsPaused)
    //        {
    //            UI_InputManager.Instance.UI_Input.Enable();
    //            Resume();
    //        }
    //        else
    //        {
    //            UI_InputManager.Instance.UI_Input.Disable();
    //            Pause();
    //        }
    //    }

    //}
    //public void Resume()
    //{
    //    CursorLocker.Instance.EnableFreelook();
    //    Setting.SetActive(false);
    //    GrapicSetting.SetActive(false);
    //    SoundSetting.SetActive(false);
    //    MoveSetting.SetActive(false);
    //    Time.timeScale = 1f;
    //    GameIsPaused = false;

    //}

    //public void Pause()
    //{
    //    CursorLocker.Instance.DisableFreelook();
    //    Setting.SetActive(true);
    //    Time.timeScale = 0f;
    //    GameIsPaused = true;
    //}

    public void OnEnable()
    {
        Setting.SetActive(true);
        GrapicSetting.SetActive(false);
        SoundSetting.SetActive(false);
        ControllSetting.SetActive(false);
        
    }

    public void Start()
    {
        locales = LocalizationSettings.AvailableLocales.Locales;
        string[] localeNames = locales.Select(l => l.LocaleName).ToArray();

        List<TMP_Dropdown.OptionData> opt = new List<TMP_Dropdown.OptionData>();
        foreach(var loc in localeNames)
        {
            opt.Add(new TMP_Dropdown.OptionData(loc));
        }

        languageDropdown.ClearOptions();
        languageDropdown.AddOptions(opt);
        languageDropdown.value = opt.FindIndex(o => o.text == LocalizationSettings.SelectedLocale.LocaleName);
    }

    public void OnDisable()
    {
        Setting.SetActive(false);
        GrapicSetting.SetActive(false);
        SoundSetting.SetActive(false);
        ControllSetting.SetActive(false);

        if (TitleUI.IsInstanceValid)
        {
            TitleUI.Instance.SelectFirstButton();
        }
        else
        {
            EventSystem.current.SetSelectedGameObject(null);
        }
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
        ControllSetting.SetActive(false);
    }

    public void SetGrapicprefab()
    {
        GrapicSetting.SetActive(true);
        Setting.SetActive(false);
        SoundSetting.SetActive(false);
        ControllSetting.SetActive(false);

    }

    public void SetControllprefab()
    {
        ControllSetting.SetActive(true);
        Setting.SetActive(false);
        SoundSetting.SetActive(false);
        GrapicSetting.SetActive(false);
    }

    public void SetLanguage(int index)
    {
        LocalizationSettings.SelectedLocale = locales[index];
        PlayerPrefs.SetInt("language", index);
    }
    
    public void QuitGame()
    {
        Application.Quit();
#if UNITY_EDITOR
        EditorApplication.ExitPlaymode();
#endif
    }
}
