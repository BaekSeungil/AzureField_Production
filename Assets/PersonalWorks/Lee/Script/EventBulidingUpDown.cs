using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class EventBulidingUpDown : MonoBehaviour
{
    [SerializeField] GameObject BulidingObjects;
    public float MoveTime;
    public float MoveSpeed;
    private void OnTriggerEnter(Collider other) 
    {
        if(other.gameObject.tag=="Player")
        {
            Transform ObjectsTransform = BulidingObjects.transform;

            if(ObjectsTransform != null)
            {
                ObjectsTransform.position = new Vector3(0f,  MoveSpeed +( MoveTime * Time.deltaTime), 0f);
            }
            else
            {
                Debug.Log("오브젝트 탐지불가");
            }
        }
    }




}
