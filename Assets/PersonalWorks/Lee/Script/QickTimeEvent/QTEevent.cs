using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using KeyBord = UnityEngine.InputSystem.Key;
using Sirenix.OdinInspector;

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
    public KeyBord keybordKey;
}

[System.Serializable]
public class QTEUI
{
   [SerializeField, LabelText("메인UI")] public GameObject eventUI;
    [SerializeField, LabelText("키보드 UI 텍스쳐")] public TMPro.TMP_Text eventText;
    [SerializeField, LabelText("타이머 텍스쳐")] public TMPro.TMP_Text TimerText;
    [SerializeField, LabelText("타이머 이미지")]public Image eventTimerImage;
}

public class QTEevent : MonoBehaviour
{
   [Header("이벤트 세팅")]
   public List<QTEKey> keys = new List<QTEKey>();
   public QTETimeType timeType;
   [SerializeField, LabelText("이벤트 수행시간")]public float time = 3f;
   public bool failOnWrongKey;
   public QTEPressType pressType;


   [Header("UI")]
   public QTEUI keyboardUI;

   [Header("이벤트 액션")]
    public UnityEvent onStart;
    public UnityEvent onEnd;
    public UnityEvent onSuccess;
    public UnityEvent onFail;

    static public QTEevent instacne;
    static public QTEevent Instacne{get {return instacne;} }

    private void Awake() 
    {
        if(instacne == null)
        {
            instacne = this;
        }
    }
}
