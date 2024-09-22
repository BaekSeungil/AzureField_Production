using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PrefabSpawner : MonoBehaviour
{
    public GameObject[] prefabs; // 생성할 프리팹 배열
    public Transform player; // 플레이어를 기준으로
    public float spawnRangeX = 10f; // X축 범위
    public float spawnRangeZ = 10f; // Z축 범위
    public float minSpawnInterval = 1f; // 최소 생성 간격(초)
    public float maxSpawnInterval = 5f; // 최대 생성 간격(초)

    private int oceanLayer; // Ocean 레이어 인덱스

    private void Start()
    {
        // Ocean 레이어의 인덱스를 가져옴
        oceanLayer = LayerMask.NameToLayer("Ocean");

        // 일정 시간마다 무작위 프리팹을 생성하는 함수를 호출
        StartCoroutine(SpawnPrefabAtRandomInterval());
    }

    private IEnumerator SpawnPrefabAtRandomInterval()
    {
        while (true)
        {
            // 최소~최대 생성 간격 사이의 랜덤한 시간 설정
            float spawnInterval = Random.Range(minSpawnInterval, maxSpawnInterval);

            // 생성 간격만큼 대기
            yield return new WaitForSeconds(spawnInterval);

            // 무작위로 X, Z 좌표 계산
            float randomX = Random.Range(-spawnRangeX, spawnRangeX);
            float randomZ = Random.Range(-spawnRangeZ, spawnRangeZ);

            // Y축을 -3으로 고정하고, 무작위로 생성된 X, Z 좌표를 설정
            Vector3 spawnPosition = new Vector3(player.position.x + randomX, -3f, player.position.z + randomZ);

            // 무작위로 프리팹 선택
            GameObject prefabToSpawn = prefabs[Random.Range(0, prefabs.Length)];

            // 프리팹 생성
            GameObject spawnedPrefab = Instantiate(prefabToSpawn, spawnPosition, Quaternion.identity);

            // 생성된 프리팹의 레이어를 Ocean으로 설정
            SetLayerRecursively(spawnedPrefab, oceanLayer);
        }
    }

    // 오브젝트와 모든 자식 오브젝트의 레이어를 재귀적으로 설정하는 함수
    private void SetLayerRecursively(GameObject obj, int layer)
    {
        obj.layer = layer;
        foreach (Transform child in obj.transform)
        {
            SetLayerRecursively(child.gameObject, layer);
        }
    }
}
