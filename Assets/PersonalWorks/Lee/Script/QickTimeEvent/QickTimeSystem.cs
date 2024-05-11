using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.InputSystem;
using UnityEngine.Events;
using Unity.Transforms;
using System.Diagnostics.Tracing;
using Sirenix.OdinInspector;
using Unity.Entities.UniversalDelegates;

public class QickTimeSystem : QTEevent
{

    [Header("옵션 구성")]
    [SerializeField,LabelText("월드시간이 느려지는 시간")]public float slowMotionTimeScale = 0.1f;
    [SerializeField,LabelText("성공 실패 UI가 남아있는시간")]public float LimitTime;
    [HideInInspector]
    private bool IsEventStart;
    private QTEevent eventData;
    private bool isAllButtonPressed;
    private bool isFail;
    private bool isEnd;
    private bool isPause;
    private bool wrongKeyPressed;
    private float currentTime;
    private float smoothTimeUpdate;
    private float rememberTimeScalse;

    private bool Setobj = false;

   protected void Update() 
   {      
        
        if(!IsEventStart || eventData == null || isPause)
        {
            return;
        }

        if(keys.Count == 0 || isFail)
        {
            doFinally();
        }

        for(int i = 0; i < eventData.keys.Count; i++)
        {
            checkKeyboardInput(eventData.keys[i]);
        }
        
        StartEvent(eventData);
        updateTimer();

   }

   public void StartEvent(QTEevent eventTable)
   {
        if(Keyboard.current == null)
        {
            UnityEngine.Debug.Log("No keyborad connected");
            return;
        }

        eventData = eventTable;

        if (Keyboard.current == null)
        {
            UnityEngine.Debug.Log("No keyboard connected");
            return;
        }

        keys = new List<QTEKey>(eventData.keys);
        if(eventData.onStart != null)
        {
            eventData.onStart.Invoke();
        }
        isAllButtonPressed = false;
        isEnd = false;
        isFail = false;
        isPause = false;
        rememberTimeScalse = Time.timeScale;
        switch(eventTable.timeType)
        {
            case QTETimeType.Slow:
            Time.timeScale = slowMotionTimeScale;
            break;
            case QTETimeType.Paused:
            Time.timeScale = 0;
            break;
        }
        currentTime = eventData.time;
        smoothTimeUpdate = currentTime;
        setupGUI();
        StartCoroutine(countDown());
   }

   private IEnumerator countDown()
   {
        IsEventStart = true;
        while(currentTime > 0 && IsEventStart && !isEnd)
        {
            if(eventData.keyboardUI.TimerText != null)
            {
                eventData.keyboardUI.TimerText.text = currentTime.ToString();
            }
            currentTime--;
            yield return new WaitWhile(()=>isPause);
            yield return new WaitForSecondsRealtime(1f);
        }
        if(!isAllButtonPressed && !isEnd)
        {
            isFail = true;
            doFinally();
        }
   }

   protected void doFinally()
   {
        if(keys.Count == 0)
        {
            isAllButtonPressed = true;
        }
        isEnd = true;
        IsEventStart = false;
        var ui = getUI();
        if(ui.eventUI != null)
        {
            ui.eventUI.SetActive(false);
        } 
        if(eventData.onEnd != null)
        {
            eventData.onEnd.Invoke();
        }
        if(!isFail)
        {
            eventData.SuccessUI.SetActive(true);
            StartCoroutine(DeativateFaleUI(eventData.SuccessUI));
        }
        if(isFail)
        {
            eventData.FailUI.SetActive(true);
            StartCoroutine(DeativateFaleUI( eventData.FailUI));
        }
        Time.timeScale = 1f;
        eventData = null;
   }

    private IEnumerator DeativateFaleUI(GameObject uiObject)
    {
        yield return new WaitForSeconds(LimitTime);
        
       if(uiObject != null)
       {
            uiObject.SetActive(false);
       }
        
    }



    public void pause()
    {
        isPause = true;
    }

    private void play()
    {
        isPause = false;
    }

    public void checkKeyboardInput(QTEKey key)
    {

        if(Keyboard.current[key.keybordKey].wasPressedThisFrame)
        {
            keys.Remove(key);

            if(Keyboard.current[key.keybordKey].wasPressedThisFrame && eventData.pressType 
            == QTEPressType.Simultaneously)
            {
                if (Keyboard.current[key.keybordKey].wasPressedThisFrame)
                {
                    isFail = false;
                }
                else
                {
                    isFail = true;
                }
            }
            doFinally();
        }
        else
        {
            isFail = true;
        }

    }



    private void setupGUI()
    {
        var ui  = getUI();
        //ui.eventTimerImage.fillAmount = 1f;
        if(ui.eventText != null)
        {
            ui.eventText.text ="";
             if (eventData.keys.Count > 0) 
            {
                eventData.keys.ForEach(key => ui.eventText.text += key.keybordKey + "+");
                eventData.keyboardUI.eventText.text = ui.eventText.text.Remove(ui.eventText.text.Length -1);
            }
        }
        if(ui.eventUI != null)
        {
            ui.eventUI.SetActive(true);
        }
    }

   private QTEUI getUI()
   {
        var ui = eventData.keyboardUI;
        return ui;
   }

    private void updateTimer()
    {
        var ui  = getUI();
        smoothTimeUpdate = Time.unscaledTime;
        if(ui.eventTimerImage.fillAmount > 0)
        {
            ui.eventTimerImage.fillAmount -= Time.smoothDeltaTime  / eventData.time * 5f;
        }
    }
}
