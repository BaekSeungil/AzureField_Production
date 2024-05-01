using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.InputSystem;
using UnityEngine.Events;
using Unity.Transforms;

public class QickTimeSystem : MonoBehaviour
{

   [Header("옵션 구성")]
   [SerializeField]public float slowMotionTimeScale = 0.1f;

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
   private List<QTEKey> keys = new List<QTEKey>();

    public static QickTimeSystem instance;
    private void Awake() 
    {
        if(instance ==null)
        instance = this;
    }

   protected void Update() 
   {
        if(!IsEventStart || eventData == null || isPause)
        return;
        updateTime();
        if(keys.Count == 0 || isFail)
        {
            doFinally();
        }
        else 
        {
            for(int i =0; i < eventData.keys.Count; i++)
            {
                checkKeyboardInput(eventData.keys[i]);
            }
        }
   }

   public void StartEvent()
   {
        QTEevent eventTable = QTEevent.instance;
        
        if(Keyboard.current == null)
        {
            UnityEngine.Debug.Log("No keyborad connected");
            return;
        }

        eventData = eventTable;
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
        Time.timeScale = rememberTimeScalse;
        var ui = getUI();
        if(ui.eventUI != null)
        {
            ui.eventUI.SetActive(false);
        } 
        if(eventData.onEnd != null)
        {
            eventData.onEnd.Invoke();
        }
        if(eventData.onFail != null && isFail)
        {
            eventData.onFail.Invoke();
        }
        if(eventData.onSuccess != null && isAllButtonPressed)
        {
            eventData.onSuccess.Invoke();
        }
        eventData = null;
   }

    protected void OnGUI() 
    {
        if(eventData == null || isEnd)
        return;

        if(Event.current.isKey 
        && Event.current.type == EventType.KeyDown
        && eventData.failOnWrongKey
        && !Event.current.keyCode.ToString().Equals("None"))
        {
            wrongKeyPressed = true;
            eventData.keys.ForEach(key =>
            wrongKeyPressed = wrongKeyPressed 
            && !key.keybordKey.ToString().Equals(Event.current.keyCode.ToString()));
        }

        isFail = wrongKeyPressed;
    }

    protected void updateTime()
    {
        smoothTimeUpdate -= Time.unscaledTime;
        var ui = getUI();
        if(ui.eventTimerImage != null)
        {
            ui.eventTimerImage.fillAmount = smoothTimeUpdate / eventData.time;
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
        if(Input.GetKeyDown(key.keybordKey))
        {
            keys.Remove(key);
        }
        if(Input.GetKeyUp(key.keybordKey)&& eventData.pressType 
        == QTEPressType.Simultaneously)
        {
            keys.Add(key);
        }
    }



    protected void setupGUI()
    {
        var ui  = getUI();
        if(ui.eventTimerImage != null)
        {
            ui.eventTimerImage.fillAmount = 1;
        }
        if(ui.eventText != null)
        {
            ui.eventText.text ="";
            eventData.keys.ForEach(key => ui.eventText.text += key.keybordKey + "+");
            eventData.keyboardUI.eventText.text = ui.eventText.text.Remove(ui.eventText.text.Length -1);
        }
        if(ui.eventUI != null)
        {
            ui.eventUI.SetActive(true);
        }
    }

   protected QTEUI getUI()
   {
        var ui = eventData.keyboardUI;
        return ui;
   }
}
