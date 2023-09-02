using FMODUnity;
using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class IslandArea : MonoBehaviour
{
    [SerializeField] private string islandID;
    [SerializeField] private string islandName;
    [SerializeField] private float areaFadeStart = 50f;
    [SerializeField] private float fullArea = 100f;
    [SerializeField] private EventReference sound_Enter;

    [FoldoutGroup("EnvoirmentSettings"), SerializeField]
    private bool supressWave = true;
    [FoldoutGroup("EnvoirmentSettings"), SerializeField]
    private float waveIntensity = 0.1f;

    private bool playerEnterFlag = false;
    private Transform playerPosition;

    private void OnEnable()
    {
        if(PlayerCore.IsInstanceValid)
        {
            playerPosition = PlayerCore.Instance.transform;
            if (GetAreaInterpolation(playerPosition.position) > 0) playerEnterFlag = true;
        }
    }

    private void Update()
    {
        if(playerPosition != null)
        {
            float distanceValue = GetAreaInterpolation(playerPosition.position);

            if(playerEnterFlag == false)
            {
                if(Vector3.Distance(playerPosition.position,transform.position) < areaFadeStart)
                {
                    playerEnterFlag = true;
                    OnEnterIslandRegion();
                }
            }
            else
            {
                if (Vector3.Distance(playerPosition.position, transform.position) > areaFadeStart)
                {
                    playerEnterFlag = false;
                }
            }
        
            if(distanceValue > 0)
            {
                if(supressWave)
                {
                    GlobalOceanManager.Instance.IslandregionIntensityFactor = Mathf.Lerp(1.0f,waveIntensity,distanceValue);
                }
            }
        }
    }

    public float GetAreaInterpolation(Vector3 t_postion)
    {
        if (Vector3.Distance(transform.position, t_postion) > fullArea) return 0;
        else if(Vector3.Distance(transform.position, t_postion) < areaFadeStart) return 1;
        else
        {
            return Mathf.InverseLerp(fullArea, areaFadeStart, Vector3.Distance(transform.position, t_postion));
        }
    }

    private void OnEnterIslandRegion()
    {
        RegionEnter regionEnter = RegionEnter.Instance;
        if (regionEnter != null)
        {
            regionEnter.OnRegionEnter(islandName);
            RuntimeManager.PlayOneShot(sound_Enter);
        }
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = new Color(0f, 1f, 0f, 1.0f);
        Gizmos.DrawWireSphere(transform.position, areaFadeStart);
        Gizmos.color = new Color(1f, 1f, 0f, 1.0f);
        Gizmos.DrawWireSphere(transform.position, fullArea);
    }
}
