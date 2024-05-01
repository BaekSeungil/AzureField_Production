using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using KeyBord = UnityEngine.InputSystem.Key;

public enum QTETimeType
{
    Normal,
    Slow,
    Paused
};

public enum QTEPressType
{
    Single,
    Simultaneously
};

[System.Serializable]
public class QTEKey
{
    public KeyCode keybordKey;
}

[System.Serializable]
public class QTEUI
{
    public GameObject eventUI;
    public TMPro.TMP_Text eventText;
    public TMPro.TMP_Text TimerText;
    public Image eventTimerImage;
}

public class QTEevent : MonoBehaviour
{
   [Header("이벤트 세팅")]
   public List<QTEKey> keys = new List<QTEKey>();
   public QTETimeType timeType;
   public float time = 3f;
   public bool failOnWrongKey;
   public QTEPressType pressType;
   [Header("UI")]
   public QTEUI keyboardUI;

   [Header("이벤트 액션")]
    public UnityEvent onStart;
    public UnityEvent onEnd;
    public UnityEvent onSuccess;
    public UnityEvent onFail;

    public static QTEevent instance;

    private void Awake() 
    {
        if(instance == null)
        {
            instance = this;
        }


    }
        
    

}
