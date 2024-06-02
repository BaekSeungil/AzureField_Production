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

        Vector3 horizontalPosition = new Vector3(transform.position.x, transform.position.y, transform.position.z);
        // 설정된 이동 거리를 넘어가면 원래 위치로 돌아옵니다.
        if (Vector3.Distance(initialPosition, horizontalPosition) > FinalLine)
        {
            transform.position = initialPosition; // 다시 스폰에서 생성
            startTime = Time.time; // 시작 시간 재설정
        }
        
    }

    void OnDrawGizmos()
    {
        if (!Application.isPlaying)
    {
        // 게임이 실행되지 않을 때 현재 오브젝트의 위치를 초기 위치로 사용
        initialPosition = transform.position;
    }

    Gizmos.color = Color.cyan;
    // 오브젝트의 앞 방향을 통해 최종 도착 지점을 계산
    Vector3 finalPosition = initialPosition + transform.forward * FinalLine;

    // 초기 위치에서 최종 도착 지점까지 선을 그림
    Gizmos.DrawLine(initialPosition, finalPosition);

    // 점프 경로 그리기
    Vector3 prevPos = initialPosition;
    for (float i = 0; i <= FinalLine; i += 0.1f)
    {
        float fractionOfJourney = i / FinalLine;
        float newY = Mathf.Sin(fractionOfJourney * Mathf.PI * JumpFrequency) * JumpHeight;
        Vector3 offset = transform.forward * i;
        Vector3 nextPos = initialPosition + offset + new Vector3(0, newY, 0);
        Gizmos.DrawLine(prevPos, nextPos);
        prevPos = nextPos;
    }

    // 초기 위치에 빨간색 구 그리기
    Gizmos.color = Color.red;
    Gizmos.DrawSphere(initialPosition, 0.5f);

    // 최종 도착 지점에 초록색 구 그리기
    Gizmos.color = Color.green;
    Gizmos.DrawSphere(finalPosition, 0.5f);
    }

}
