using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PuzzleTrigger : MonoBehaviour
{
    [SerializeField,LabelText("내려가는 위치값")] public float UnderLocal; 
    Rigidbody rigidbody;

    PuzzleDoor puzzleDoor;
    // Start is called before the first frame update
   private void Awake() 
   {
        puzzleDoor = FindObjectOfType<PuzzleDoor>();
   }

    private void OnTriggerStay(Collider other)
    {
        puzzleDoor.OpenDoorCount += 1;
        
    }

    private void OnTriggerExit(Collider other) 
    {
        puzzleDoor.OpenDoorCount -= 1;
    }
}
