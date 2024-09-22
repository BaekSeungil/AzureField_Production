using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Flyingbird : MonoBehaviour
{
    [SerializeField, LabelText("이동속도")] private float Speed;
    [SerializeField, LabelText("최종도착거리")] private float FinalLine;

    
    RandomFlyObj randomFlyObj;
    private Vector3 initialPosition;
    private float startTime;

    void Start()
    {
        initialPosition = transform.position;
        startTime = Time.time;
        randomFlyObj = FindObjectOfType<RandomFlyObj>();
    }

    // Update is called once per frame
    void Update()
    {
        MoveForward();
    }

    // 오브젝트를 앞으로 이동시키는 메서드
    void MoveForward()
    {
        // 이동하는 방향은 오브젝트의 전방 (Z축 방향)
        transform.Translate(Vector3.forward * Speed * Time.deltaTime);

        // 오브젝트가 FinalLine을 넘으면 특정 동작 수행
        if (Vector3.Distance(initialPosition, transform.position) >= FinalLine)
        {
            // 오브젝트를 파괴하거나 다른 동작을 수행
            randomFlyObj.BoolSpawnbird = true;
            Destroy(gameObject);
        }
    }
}
