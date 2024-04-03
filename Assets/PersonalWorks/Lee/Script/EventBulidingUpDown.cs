using System.Collections;
using System.Collections.Generic;
using Unity.Entities.UniversalDelegates;
using UnityEngine;
using UnityEngine.UIElements;

public class EventBulidingUpDown : MonoBehaviour
{
    [SerializeField] GameObject BulidingObjects;
    [SerializeField] GameObject target;
    public float moveSpeed; 
    bool Ismove = false;
    private void Start()
    {
    }  

    private void Update()
    {
        if(Ismove == true)
        {
            if (target != null)
            {
                
                Vector3 targetPosition = new Vector3(transform.position.x, target.transform.position.y, transform.position.z);

                transform.position = Vector3.MoveTowards(transform.position, targetPosition, moveSpeed * Time.deltaTime);
            }
        }
       
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.CompareTag("Player"))
        {
            Ismove = true;
            Debug.Log("플레이어 확인");
        }
    }


}
