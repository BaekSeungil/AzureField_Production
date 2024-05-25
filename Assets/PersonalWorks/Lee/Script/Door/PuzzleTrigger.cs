using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PuzzleTrigger : MonoBehaviour
{
    [SerializeField,LabelText("내려가는 위치값")] public float UnderLocal; 
    [SerializeField,LabelText("내려가는 속도")] public float speed;
    private Rigidbody rigid;

    PuzzleDoor puzzleDoor;
    // Start is called before the first frame update
   private void Awake() 
   {
        rigid = GetComponent<Rigidbody>();
   }

    private void OnTriggerEnter(Collider other)
    {
        puzzleDoor = FindObjectOfType<PuzzleDoor>();
        puzzleDoor.OpenDoorCount += 1;
        
        rigid.AddForce(Vector3.up * UnderLocal,ForceMode.Impulse);
    }

    private void OnTriggerExit(Collider other) 
    {
        puzzleDoor = FindObjectOfType<PuzzleDoor>();
        puzzleDoor.OpenDoorCount -= 1;
        rigid.AddForce(Vector3.up * UnderLocal,ForceMode.Impulse);
    }
}
