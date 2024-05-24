using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterElevatorCollider : MonoBehaviour
{
    [SerializeField] private WaterElevator waterElevator;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }

    private void OnTriggerEnter(Collider other)
    {
        if (waterElevator != null)
        {
            if (other.gameObject.CompareTag("Player"))
            {

            }
        }
    }
}
