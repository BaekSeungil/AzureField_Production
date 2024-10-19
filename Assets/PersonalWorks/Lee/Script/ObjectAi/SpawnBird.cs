using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpawnBird : MonoBehaviour
{
    [SerializeField,LabelText("새 오브젝트 배치")] public GameObject[] BirdgameObjects;
    [SerializeField, LabelText("스폰 간격(초)")] public float spawnInterval = 2f;
    [SerializeField,LabelText("오브젝트 수")]private int DestroyCount;
    public int BirdCount = 0;
    private float timeSinceLastSpawn;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        timeSinceLastSpawn += Time.deltaTime;
        if(timeSinceLastSpawn >= spawnInterval)
        {
            SpawnFishgameObject();
            timeSinceLastSpawn = 0f;
        }

        if(DestroyCount == BirdCount)
        {
            gameObject.SetActive(false);
        }
    }

    public void SpawnFishgameObject()
    {
        foreach (var fish in BirdgameObjects)
        {
            if(!fish.activeInHierarchy)
            {
                fish.SetActive(true);
                break;
            }
        }
    }

}
