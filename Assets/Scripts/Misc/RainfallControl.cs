using Sirenix.Utilities;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[RequireComponent(typeof(ParticleSystem))]
public class RainfallControl : MonoBehaviour
{
    [SerializeField] private LayerMask collinsionMask;
    [SerializeField] private float maxDistance = 100f;

    private ParticleSystem particle;
    private ParticleSystem.EmissionModule emission;

    private void Awake()
    {
        particle = GetComponent<ParticleSystem>();
        emission = particle.emission;
    }

    float refreshTime = 0.5f;
    float time = 0;

    private void Update()
    {
        time += Time.deltaTime;

        if (time >= refreshTime)
        {
            time = 0;

            Ray upRay = new Ray(transform.position, Vector3.up);

            if (Physics.Raycast(upRay, maxDistance, collinsionMask))
            {
                emission.enabled = false;
            }
            else
            {
                emission.enabled = true;
            }
        }
    }
}
