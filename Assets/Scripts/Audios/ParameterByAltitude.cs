using FMODUnity;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


//============================================
//
// ParameterByAltitude
// �÷��̾��� ���� ���� FMOD�� �Ķ���� ���� �ٲߴϴ�.
//
//============================================

public class ParameterByAltitude : MonoBehaviour
{
    [SerializeField] string ParameterName;      // FMOD �Ķ���� �̸�
    [SerializeField] float heightStart;         // �� �ּҰ�
    [SerializeField] float heightEnd;           // �� �ִ밪
    [SerializeField] bool isGlobalParam;        // �ش� �Ķ���Ͱ� Global���� ��� true, StudioEventEmitter ������Ʈ�� �ٿ������ false

    Transform playerTF;
    StudioEventEmitter sound;

    bool hasEventComp = false;

    private void OnEnable()
    {
        PlayerCore player = FindFirstObjectByType<PlayerCore>();
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
                float value = 0f;
                if (RuntimeManager.StudioSystem.getParameterByName(ParameterName, out value) == FMOD.RESULT.OK)
                    RuntimeManager.StudioSystem.setParameterByName(ParameterName, Mathf.InverseLerp(heightStart, heightEnd, playerTF.position.y));
            }
            else
            {
                if (hasEventComp)
                {
                    sound.EventInstance.setParameterByName(ParameterName, Mathf.InverseLerp(heightStart, heightEnd, playerTF.position.y));
                }
            }
        }
    }
}
