using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FoundationCollider : MonoBehaviour
{
    [SerializeField] private Foundation foundation;

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
        if (foundation != null)
        {
            if (other.gameObject.CompareTag("Player"))
            {
                
            }
        }
    }
}
