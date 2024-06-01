using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class FlyingFish : MonoBehaviour
{
    [SerializeField,LabelText("이동속도")] public float Speed;
    [SerializeField,LabelText("최종도착거리")] public float FinalLine;
    [SerializeField, LabelText("점프 높이")] public float JumpHeight;
    [SerializeField, LabelText("점프 주기")] public float JumpFrequency;
  
    private Vector3 initialPosition;
    private float journeyLength;
    private float startTime;

    void Start()
    {
        initialPosition = transform.position;
        startTime = Time.time;
        journeyLength = Vector3.Distance(initialPosition, new Vector3(initialPosition.x, initialPosition.y, initialPosition.z + FinalLine));
    }

    // Update is called once per frame
    void Update()
    {
       MoveFish();
    }

    public void MoveFish()
    {
       
       // 물고기를 앞으로 이동시킵니다.
        float distCovered = (Time.time - startTime) * Speed;
        float fractionOfJourney = distCovered / journeyLength;
        
        transform.Translate(Vector3.forward * Speed * Time.deltaTime);

        // 물고기가 곡선으로 이동하도록 합니다.
        float newY = Mathf.Sin(fractionOfJourney * Mathf.PI * JumpFrequency) * JumpHeight;
        transform.position = new Vector3(transform.position.x, initialPosition.y + newY, transform.position.z);

        // 설정된 이동 거리를 넘어가면 원래 위치로 돌아옵니다.
        if (Vector3.Distance(initialPosition, transform.position) == FinalLine)
        {
            transform.position = initialPosition; // 다시 스폰에서 생성
            startTime = Time.time; // 시작 시간 재설정
        }
        
    }


}
