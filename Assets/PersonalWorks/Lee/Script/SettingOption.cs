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

public class SettingOption : MonoBehaviour
{


   [SerializeField] GameObject Setting;
   [SerializeField] GameObject SoundSetting;
   [SerializeField] GameObject GrapicSetting;
   [SerializeField] GameObject MoveSetting;

   MainPlayerInputActions inputs;


   private static bool GameIsPaused = false;

   private void Awake() 
   {
      inputs = new MainPlayerInputActions();
      inputs.UI.Enable();
   }

   private void Update()
   {
      if (Keyboard.current[Key.Escape].wasPressedThisFrame)
        {
            if (GameIsPaused)
            {
                Resume();
            }
            else
            {
                Pause();
            }
        }
    
   }
   public void Resume()
   {
      Setting.SetActive(false);
      GrapicSetting.SetActive(false);
      SoundSetting.SetActive(false);
      MoveSetting.SetActive(false);
      Time.timeScale = 1f;
      GameIsPaused = false;

   }

   public void Pause()
   {
      Setting.SetActive(true);
      Time.timeScale = 0f;
      GameIsPaused  = true;
   }

   public void SetSoundprefab()
   {
      SoundSetting.SetActive(true);
      Setting.SetActive(false);
      GrapicSetting.SetActive(false);
      MoveSetting.SetActive(false);
     
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
