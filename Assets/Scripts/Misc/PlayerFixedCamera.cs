using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerFixedCamera : MonoBehaviour
{
    [SerializeField] private CinemachineVirtualCamera Vcam;
    private PlayerCore player;

    private void OnEnable()
    {
        player = PlayerCore.Instance;
        Debug.Log(Vcam != null);
        Vcam.LookAt = player.transform;
        Vcam.gameObject.SetActive(false);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Vcam.gameObject.SetActive(true);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Vcam.gameObject.SetActive(false);
        }
    }
}
