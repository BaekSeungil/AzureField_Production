using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomFlyObj : MonoBehaviour
{
    [SerializeField, LabelText("이동속도")] private float Speed;
    [SerializeField, LabelText("최종도착거리")] private float FinalLine;
    private Vector3 initialPosition;
    private float startTime;
    void Start()
    {
        initialPosition = transform.position;
        startTime = Time.time;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
