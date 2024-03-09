using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.Events;
using UnityEngine.Localization;
using UnityEngine.Splines;

public class Spline_Quest : MonoBehaviour
{
    /*

    해당 스크립트는 Spline 퀘스트 이벤트를 관리하는 스크립트입니다.

    */
    private GameObject CheckPlayer; // 플레이어 타겟
    [SerializeField] private string Spline_Quset_ID; //  Spline 퀘스트 ID
    public string spline_questiD { get { return Spline_Quset_ID; } }

    [SerializeField] private LocalizedString Spline_Quest_Name; // Spline 퀘스트 이름
    public LocalizedString spline_quest_name;

    private SplineComponent spline; //Spline 호출;

    private void Awake()
    {
        CheckPlayer = GameObject.FindGameObjectWithTag("Player");
        spline = GetComponent<SplineComponent>();

    }

    private void Update()
    {
        
    }


}
