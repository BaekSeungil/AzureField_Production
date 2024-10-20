using System.Collections.Generic;
using UnityEngine;

public class ObjectPool : MonoBehaviour
{
    public GameObject prefab;  // 풀링할 프리팹
    public int initialSize = 10;  // 초기 생성될 오브젝트 수

    private Queue<GameObject> pool = new Queue<GameObject>();

    void Start()
    {
        // 초기 오브젝트 생성 후 풀에 저장
        for (int i = 0; i < initialSize; i++)
        {
            GameObject obj = Instantiate(prefab);
            obj.SetActive(false);
            pool.Enqueue(obj);
        }
    }

    // 오브젝트를 풀에서 가져오는 함수
    public GameObject GetFromPool()
    {
        if (pool.Count > 0)
        {
            GameObject obj = pool.Dequeue();
            obj.SetActive(true);
            return obj;
        }
        else
        {
            // 풀에 남아있는 오브젝트가 없을 때 새로 생성
            GameObject obj = Instantiate(prefab);
            return obj;
        }
    }

    // 오브젝트를 풀로 반환하는 함수
    public void ReturnToPool(GameObject obj)
    {
        obj.SetActive(false);
        pool.Enqueue(obj);
    }
}
