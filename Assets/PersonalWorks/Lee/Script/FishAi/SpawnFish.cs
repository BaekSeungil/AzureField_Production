using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpawnFish : MonoBehaviour
{
    [SerializeField,LabelText("물고기 오브젝트 배치")] public GameObject[] FishgameObjects;
    [SerializeField, LabelText("스폰 간격(초)")] public float spawnInterval = 2f;

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
    }

    public void SpawnFishgameObject()
    {
        foreach (var fish in FishgameObjects)
        {
            if(!fish.activeInHierarchy)
            {
                fish.SetActive(true);
                break;
            }
        }
       
    }



    // IEnumerator SpawnFishObject()
    // {
    //     while(true)
    //     {
    //         int randomIndex  = Random.Range(0, FishgameObjects.Length);
    //         GameObject fishPrefab = FishgameObjects[randomIndex];

    //         Instantiate(fishPrefab,transform.position,Quaternion.identity);
    //         yield return new WaitForSeconds(spawnInterval);
    //     }
    // }
}
