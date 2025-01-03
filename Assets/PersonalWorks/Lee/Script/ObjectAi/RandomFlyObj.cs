using Sirenix.OdinInspector;
using Sirenix.Utilities;
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
    [SerializeField,LabelText("오브젝트 소멸 시간")] private float DeltaTime = 70f;
    public bool BoolSpawnbird  = true;
    public Color GizmoColor = Color.green;  // 기즈모 색상

    private Vector3 initialPosition;
    private float startTime;


    void Start()
    {
        startTime = Time.time;
        if (BoolSpawnbird)
        {
            StartCoroutine(SpawnWithInterval());  // 코루틴 시작
        }
    }

    // 오브젝트 풀 초기화

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
        if (BoolSpawnbird && Random.Range(0f, 1f) < spawnRate)
        {
            if (ObjectToSpawn.IsNullOrEmpty()) return;

            // 배열에서 무작위로 오브젝트 선택
            int randomIndex = Random.Range(0, ObjectToSpawn.Length);
            GameObject objToSpawn = ObjectToSpawn[randomIndex];

            Vector3 spawnPosition = PlayerCore.Instance.transform.position + Random.insideUnitSphere * spawnRadius;
            spawnPosition.y = PlayerCore.Instance.transform.position.y + heightOffset;

            GameObject spawnedObj = Instantiate(objToSpawn, spawnPosition, Quaternion.identity);
            Destroy(spawnedObj, DeltaTime); // 생성된 오브젝트는 지정된 소멸 시간이후 삭제
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
