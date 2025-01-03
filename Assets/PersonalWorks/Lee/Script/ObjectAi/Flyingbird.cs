using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Animator))]
public class Flyingbird : MonoBehaviour
{
    [SerializeField, LabelText("이동속도")] private float Speed;
    [SerializeField, LabelText("최종도착거리")] private float FinalLine;
    [SerializeField,LabelText("애니메이션 재생속도")]private float AniSpeed;

    
    RandomFlyObj randomFlyObj;
    SpawnBird spawnBird;
    private float startTime;
    private Animator animator;
    private Vector3 startPosition; 
    private Vector3 targetPosition;
    private Vector3 fixedForward;

    void Start()
    {
        startPosition = transform.position;
        fixedForward =  PlayerCore.Instance.transform.forward;
        startTime = Time.time;
        randomFlyObj = FindObjectOfType<RandomFlyObj>();
        spawnBird = FindObjectOfType<SpawnBird>();
        animator = GetComponent<Animator>();
        //BirdObject = GetComponent<GameObject>();
        animator.SetFloat("AniSpeed", AniSpeed);
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

        targetPosition = startPosition + fixedForward.normalized * FinalLine;

        Quaternion rotation = Quaternion.LookRotation(fixedForward);
        transform.rotation = rotation;

        // 오브젝트가 FinalLine을 넘으면 특정 동작 수행
        if (Vector3.Distance( startPosition, transform.position) >= FinalLine)
        {
            // 오브젝트를 파괴하거나 다른 동작을 수행
            randomFlyObj.BoolSpawnbird = true;
            spawnBird.BirdCount++;
            gameObject.SetActive(false);
        }
    }
}
