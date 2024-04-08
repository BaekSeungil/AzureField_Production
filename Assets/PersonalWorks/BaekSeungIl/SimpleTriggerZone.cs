using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

[RequireComponent(typeof(Collider))]
public class SimpleTriggerZone : MonoBehaviour
{
    [SerializeField] private UnityEvent onEntered;
    [SerializeField] private LayerMask layer;
    private void OnTriggerEnter(Collider other)
    {
        if( (layer & (1<< other.gameObject.layer)) != 0)
        {
            onEntered.Invoke();
        }
    }
}
