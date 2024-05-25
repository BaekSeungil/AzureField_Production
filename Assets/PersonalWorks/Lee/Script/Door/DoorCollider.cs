using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorCollider : MonoBehaviour
{    
    [SerializeField] Door TargetDoor;
 
    public Door targetDoor
    {
        get { return TargetDoor; }
        set { targetDoor = value; }
    }

    private void OnTriggerEnter(Collider other) 
    {
        if(TargetDoor != null && TargetDoor.openType == OpenType.Auto)
        {
            if(other.gameObject.layer == 6)
            {
                TargetDoor.OpenDoor = true;
                Debug.Log("감지");
            }
        }   
    }


    private void OnTriggerExit(Collider other) 
    {
        if(TargetDoor != null && TargetDoor.openType == OpenType.Auto)
        {
            if(other.gameObject.layer == 6)
            {
                TargetDoor.OpenDoor = false;
                Debug.Log("감지");
            }
        }   
    }

}
