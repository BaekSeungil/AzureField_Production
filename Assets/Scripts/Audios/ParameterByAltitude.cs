using FMODUnity;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParameterByAltitude : MonoBehaviour
{
    [SerializeField] string ParameterName;
    [SerializeField] float heightStart;
    [SerializeField] float heightEnd;
    [SerializeField] bool isGlobalParam;

    Transform playerTF;
    StudioEventEmitter sound;

    bool hasEventComp = false;

    private void Start()
    {
        PlayerCore player = FindObjectOfType<PlayerCore>();
        hasEventComp = TryGetComponent<StudioEventEmitter>(out sound);
        if(player != null)
        {
            playerTF = player.transform;
        }
    }

    private void Update()
    {
        if (playerTF != null)
        {
            if (isGlobalParam)
            {
                RuntimeManager.StudioSystem.setParameterByName(ParameterName, Mathf.InverseLerp(heightStart,heightEnd,playerTF.position.y));
            }
            else
            {
                if(hasEventComp)
                {
                    sound.EventInstance.setParameterByName(ParameterName, Mathf.InverseLerp(heightStart, heightEnd, playerTF.position.y));
                }
            }
        }
    }
}
