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
    [SerializeField] private string Spline_Quset_ID; //  Spline 퀘스트 ID
    public string spline_questiD { get { return Spline_Quset_ID; } }

    [SerializeField] private LocalizedString Spline_Quest_Name; // Spline 퀘스트 이름
    private LocalizedString spline_quest_name;


    [SerializeField] private float ClosetPoint; //스플라인 내 감지 거리
    public float closetPoint {get{return ClosetPoint;}}

    [SerializeField] private float OutPoint; //스플라인 외 감지거리
    public float outPoint{get{return OutPoint;}}

    private SplineContainer spline; 
    private void Awake()
    {
        CheckPlayer = GameObject.FindGameObjectWithTag("Player");

    }

    /// <summary>
    /// 스플라인과 플레이어간 거리 계산
    /// </summary>
    private void Update()
    {
             

        
    }

   private void OnDrawGizmos() 
   {
  
        spline = GetComponent<SplineContainer>();

        if (spline == null || spline.Spline == null)
         return;

        foreach(var point in  spline.Spline.ToArray())
        {

            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(transform.TransformPoint(point.Position), closetPoint);
            
            Gizmos.color = Color.green;
            Gizmos.DrawWireSphere(transform.TransformPoint(point.Position), outPoint);

            //float distance = Vector3.Distance(transform.TransformPoint(point.Position),CheckPlayer.transform.position);
            // Gizmos.DrawSphere( new Vector3(point.Position.x,point.Position.y,
            // point.Position.z) + transform.position, closetPoint);

            


        }

        
      
   }


}


