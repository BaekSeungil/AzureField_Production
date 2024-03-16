using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.Events;
using UnityEngine.Localization;
using UnityEngine.Splines;

//FairwindQuest
public class FairwindQuest : MonoBehaviour
{
    /*

    해당 스크립트는 Spline 퀘스트 이벤트를 관리하는 스크립트입니다.

    */
    private GameObject CheckPlayer; // 플레이어 타겟
    private Transform KontTarget; //노트타겟
    [SerializeField] private string Spline_Quset_ID; //  Spline 퀘스트 ID
    public string spline_questiD { get { return Spline_Quset_ID; } }

    [SerializeField] private LocalizedString Spline_Quest_Name; // Spline 퀘스트 이름
    private LocalizedString spline_quest_name;


    [SerializeField] private float ClosetPoint; //스플라인 좌표 확인 범위
    public float closetPoint {get{return ClosetPoint;}}

    [SerializeField] private float CountTime;

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

    

}


