using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;


enum Weather
{
    Sun = 0,
    Cloud = 1,
    Rain = 2
};
public class AtmosphereProfile : ScriptableObject
{
    [Header("시간설정")]
    [SerializeField] private float SetTimer;

    
    void Start()
    {
        
    }

    
    void Update()
    {
        
    }
}
