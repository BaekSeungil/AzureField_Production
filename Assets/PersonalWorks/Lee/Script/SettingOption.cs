using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.Rendering;
using Unity.Entities;
using UnityEngine.InputSystem;

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

   public void Enable()
   {
      
   }

   public void Disable()
   {

   }

   private void Update() 
   {
      
   }

   public void Resume()
   {
      Setting.SetActive(false);
      Time.timeScale = 1f;
      GameIsPaused = false;
   }

   public void Pasue()
   {
      Setting.SetActive(true);
      Time.timeScale = 0f;
      GameIsPaused  = true;
   }

   public void SetSoundprefab()
   {
      SoundSetting.SetActive(true);
      Setting.SetActive(false);

   }

   public void ExitSoundprefab()
   {
      SoundSetting.SetActive(false);
      Setting.SetActive(true);
   }

   public void SetGrapicprefab()
   {
      GrapicSetting.SetActive(true);
      Setting.SetActive(false);
   }

   public void ExitGrapicprefab()
   {
      GrapicSetting.SetActive(false);
      Setting.SetActive(true);
   }

   public void SetMoveprefab()
   {
      MoveSetting.SetActive(true);
      Setting.SetActive(false);
   }

   public void ExitMoveprefab()
   {
      MoveSetting.SetActive(false);
      Setting.SetActive(true);
   }

   public void QuitGame()
   {
      Application.Quit();
   }
}
