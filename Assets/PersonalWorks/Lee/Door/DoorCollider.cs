using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorCollider : MonoBehaviour
{
    Door door;

    void Update()
    {
        door = Door.Instance;
    }

    private void OnTriggerEnter(Collider other) 
    {
        if(door != null && door.GetOpenType() == OpenType.Auto)
        {
            if(other.gameObject.layer == 6)
            {
                door.OpenDoor = true;
                Debug.Log("감지");
            }
        }   
    }


    private void OnTriggerExit(Collider other) 
    {
        if(door != null && door.GetOpenType() == OpenType.Auto)
        {
            if(other.gameObject.layer == 6)
            {
                door.OpenDoor = false;
                Debug.Log("감지");
            }
        }   
    }

}
