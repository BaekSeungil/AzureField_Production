using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerFixedCamera : MonoBehaviour
{
    [SerializeField] private CinemachineVirtualCamera Vcam;
    private PlayerCore player;

    private void Awake()
    {
        player = PlayerCore.Instance;
        Vcam.gameObject.SetActive(false);

        Vcam.LookAt = player.transform;
    }

    private void OnTriggerEnter(Collider other)
    {
        Debug.Log("Enter");
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
