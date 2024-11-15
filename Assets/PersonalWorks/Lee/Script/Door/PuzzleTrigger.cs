using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PuzzleTrigger : MonoBehaviour
{

    [SerializeField,LabelText("오브젝트 지정")] public  PuzzleDoor puzzleDoor;
    [SerializeField,LabelText("레이저석상 지정")] public LaserStaute laserStaute;


    private bool Callaction = false;

   private void Awake() 
   {
        
   }

    private void OnTriggerEnter(Collider other) 
    {
        if (puzzleDoor == null) return;
        if (laserStaute == null) return;    

        if(!Callaction && (other.gameObject == laserStaute.gameObject))
        {
            puzzleDoor = FindObjectOfType<PuzzleDoor>();
            puzzleDoor.OpenDoorCount ++;
            Callaction = true;
        }
    }

    // private void OnTriggerStay(Collider other) 
    // {
    //     if(!Callaction && (other.gameObject.layer == 8))
    //     {
    //         puzzleDoor = FindObjectOfType<PuzzleDoor>();
    //         puzzleDoor.OpenDoorCount++;
    //     }
    // }

    private void OnTriggerExit(Collider other)
    {
        if (puzzleDoor == null) return;
        if (laserStaute == null) return;

        if (Callaction && (other.gameObject == laserStaute.gameObject))
        {
            puzzleDoor = FindObjectOfType<PuzzleDoor>();
            Debug.Log("빠짐 " + puzzleDoor.OpenDoorCount);
            puzzleDoor.OpenDoorCount --;
            Callaction = false;
        }

    }

}
