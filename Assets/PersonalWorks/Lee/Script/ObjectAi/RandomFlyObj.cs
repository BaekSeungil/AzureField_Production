using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomFlyObj : MonoBehaviour
{
    [SerializeField,LabelText("스폰할 오브젝트 선택")] public GameObject objectToSpawn;  // 스폰할 오브젝트
    public Transform player;  // 플레이어 Transform
    private float spawnRadius = 45f;  // 스폰 범위 반경
    [SerializeField,LabelText("스폰확률")]private float spawnRate = 0.6f;  // 스폰 확률 (0~1, 예: 0.01f는 1% 확률)
    [SerializeField,LabelText("스폰간격")]private float spawnInterval = 120f;  // 스폰 간격 (초)
    public bool BoolSpawnbird  = true;
    public Color gizmoColor = Color.green;  // 기즈모 색상

    private float heightOffset = 60f;

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
        if(BoolSpawnbird)
        {   
            // 스폰 확률
            if (Random.Range(0f, 1f) < spawnRate)
            {
                // 플레이어를 기준으로 무작위 위치 생성
                Vector3 spawnPosition = player.position + Random.insideUnitSphere * spawnRadius;

                // Y축을 플레이어보다 heightOffset만큼 더 높은 위치로 설정
                spawnPosition.y = player.position.y + heightOffset;

                // 오브젝트 스폰
                Instantiate(objectToSpawn, spawnPosition, Quaternion.identity);
                BoolSpawnbird = false;
            }

        }
    }

    // 기즈모로 스폰 반경을 시각화
    void OnDrawGizmosSelected()
    {
        if (player != null)
        {
            Gizmos.color = gizmoColor;
            Gizmos.DrawWireSphere(player.position, spawnRadius);  // 플레이어 위치 기준으로 원형 기즈모 그리기
        }
    }
}
