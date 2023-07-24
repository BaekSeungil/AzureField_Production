using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OceanBorderBuilder : MonoBehaviour
{
    private BoxCollider border;

    GlobalOceanManager oceanManager;

    private void Awake()
    {
        border = GetComponent<BoxCollider>();
    }

    private void Start()
    {
        oceanManager = FindFirstObjectByType<GlobalOceanManager>();
        if (oceanManager == null) Debug.LogWarning("OceanBorderBuilder는 GlobalOceanManager와 함께 사용하세요");
    }

    private void FixedUpdate()
    {
        
    }


}
