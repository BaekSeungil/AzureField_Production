using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomFlyObj : MonoBehaviour
{
    [LabelText("스폰할 오브젝트 선택")] public GameObject[] ObjectToSpawn;  // 스폰할 오브젝트
    //public Transform Player;  // 플레이어 Transform
    private float spawnRadius = 45f;  // 스폰 범위 반경
    [SerializeField,LabelText("스폰확률")]private float spawnRate = 0.6f;  // 스폰 확률 (0~1, 예: 0.01f는 1% 확률)
    [SerializeField,LabelText("스폰간격")]private float spawnInterval = 120f;  // 스폰 간격 (초)
    [SerializeField,LabelText("스폰높이")]private float heightOffset = 60f;
    public bool BoolSpawnbird  = true;
    public Color GizmoColor = Color.green;  // 기즈모 색상

    private Vector3 initialPosition;
    private float startTime;

    void Start()
    {
        initialPosition = transform.position;
        startTime = Time.time;
        if (BoolSpawnbird)
        {
            StartCoroutine(SpawnWithInterval());  // 코루틴 시작
        }
    }
    public void StartSpawning()
    {
        if (!BoolSpawnbird)
        {
            BoolSpawnbird = true;
            StopAllCoroutines();
            StartCoroutine(SpawnWithInterval());  // 다시 코루틴 시작
        }
    }
    private IEnumerator SpawnWithInterval()
    {
        while (BoolSpawnbird)
        {
            yield return new WaitForSeconds(spawnInterval);  // 일정 간격 대기
            TrySpawnObject();  // 스폰 시도
        }
    }

    void TrySpawnObject()
    {
       if (BoolSpawnbird)
        {   
            // 스폰 확률
            if (Random.Range(0f, 1f) < spawnRate)
            {
                // 배열의 모든 오브젝트를 순회하며 동시에 스폰
                foreach (GameObject obj in ObjectToSpawn)
                {
                    // 플레이어를 기준으로 무작위 위치 생성
                    Vector3 spawnPosition = PlayerCore.Instance.transform.position + Random.insideUnitSphere * spawnRadius;

                    // Y축을 플레이어보다 heightOffset만큼 더 높은 위치로 설정
                    spawnPosition.y = PlayerCore.Instance.transform.position.y + heightOffset;

                    // 오브젝트 스폰
                    Instantiate(obj, spawnPosition, Quaternion.identity);
                }
                BoolSpawnbird = false;  // 스폰 후 스폰 중지 (원한다면 이 부분을 수정 가능)
            }
        }
    }

    // 기즈모로 스폰 반경을 시각화
    void OnDrawGizmosSelected()
    {
        if (PlayerCore.Instance != null)
        {
            Gizmos.color = GizmoColor;
            Gizmos.DrawWireSphere(PlayerCore.Instance.transform.position, spawnRadius);  // 플레이어 위치 기준으로 원형 기즈모 그리기
        }
    }
}
