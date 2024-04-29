using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.InputSystem;


public class QickTimeSystem : MonoBehaviour
{

   [Header("옵션 구성")]
   [SerializeField]public float slowMotionTimeScale = 0.1f;

   [HideInInspector]
   private bool IsEventStart;
   private bool isAllButtonPressed;
   private bool isFall;
   private bool isEnd;
   private bool wrongKeyPressed;
   private float currentTime;
   private float smoothTimeUpdate;
   private float rememberTimeScalse;

   protected void Update() 
   {
    
   }
}
