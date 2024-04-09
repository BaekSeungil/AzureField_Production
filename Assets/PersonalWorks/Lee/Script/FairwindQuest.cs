using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.Events;
using UnityEngine.Localization;
using UnityEngine.Splines;

//FairwindQuest

public enum QuestType
{
    Start, //퀘스트 시작(중간 지점용으로 사용가능)
    End    //퀘스트 마무리(보상 지급과 퀘스트 빌드중 퀘스트 영구 삭제)
};

public class FairwindQuest : MonoBehaviour
{
    /*

    해당 스크립트는 Spline 퀘스트 이벤트를 관리하는 스크립트입니다.

    */
    private GameObject CheckPlayer; // 플레이어 타겟
    private Transform KontTarget; //노트타겟
    [SerializeField] private string Spline_Quset_ID; //  Spline 퀘스트 ID
    public string spline_questiD { get { return Spline_Quset_ID; } }

    [SerializeField] private QuestType questType; // 퀘스트 타입
    public QuestType QuestType { get { return questType; } }

    [SerializeField] private LocalizedString Spline_Quest_Name; // Spline 퀘스트 이름
    private LocalizedString spline_quest_name;


    [SerializeField] private float ClosetPoint; //스플라인 좌표 확인 범위
    public float closetPoint {get{return ClosetPoint;}}

    [SerializeField] private int StartKnotIndex; //처음 시작 좌표

    [SerializeField] private int LastKontIndex; // 마지막 좌표값 배열

    [SerializeField] private float CountTime; // 카운트다운 시간 설정

    private float timer;

    private bool timerOnOff = false;

    private SplineContainer spline; //스플라인


    private void Awake()
    {   timer = CountTime;
        CheckPlayer = GameObject.FindGameObjectWithTag("Player");

    }

    /// <summary>
    /// 스플라인과 플레이어간 거리 계산
    /// </summary>
    private void Update()
    {
             
        if(timerOnOff == true)
        {
            timer -= Time.deltaTime;
            Debug.Log(timer + "초");
            if(timer <= 0)
            {
                Debug.Log("미션실패");
                timerOnOff = false;
            }
        }
        else if(timerOnOff == false)
        {
            timer = CountTime;
        }

        
    }

   private void OnDrawGizmos() 
   {
  
        spline = GetComponent<SplineContainer>();


        if (spline == null || spline.Spline == null)
         return;

        foreach(var point in  spline.Spline.ToArray())
        {
            //Gizmos 좌표 범위 설정
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(transform.TransformPoint(point.Position), closetPoint);

          
        }

        

   }

    private void OnTriggerEnter(Collider other) 
    {
       if(other.CompareTag("Player"))
       {    
            timerOnOff = false;

            Debug.Log("경로에 플레이어 감지");
       }
    }

    private void OnTriggerExit(Collider other) 
    {
        if(other.CompareTag("Player"))
       {
            timerOnOff = true;

            Debug.Log("경로를 벗어남");
       }
    }
    /// <summary>
    /// DropItemCrash에서 접근하기위한 함수
    /// </summary>
    public void AddTimer(float addTimer)
    {
        timer += addTimer;
    }

}


