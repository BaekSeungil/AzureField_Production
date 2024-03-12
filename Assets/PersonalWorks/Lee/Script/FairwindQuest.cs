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


    [SerializeField] private float ClosetPoint; //스플라인 감지 거리
    public float closetPoint {get{return ClosetPoint;}}

    private bool HasWaring = false; //경고를 했는지 여부
    private SplineContainer spline; 
    private void Awake()
    {
        CheckPlayer = GameObject.FindGameObjectWithTag("Player");
        spline = GetComponent<SplineContainer>();
    }

    /// <summary>
    /// 스플라인과 플레이어간 거리 계산
    /// </summary>
    private void FixedUpdate()
    {
       
        
        
        // float distance = Vector3.Distance(pos,CheckPlayer.transform.position);

        // if(distance > ClosetPoint && !HasWaring)
        // {
        //     Debug.Log("경로 이탈");
        //     HasWaring = true;
        // }
        // else if(distance <= ClosetPoint && HasWaring)
        // {
        //     HasWaring = false;
        // }
    }

   private void OnDrawGizmos() 
   {

       foreach(var point in  spline.Spline.ToArray())
       {
    
         Gizmos.color = Color.red;
         Gizmos.DrawSphere(point.Position, closetPoint);
       }
   }


}


