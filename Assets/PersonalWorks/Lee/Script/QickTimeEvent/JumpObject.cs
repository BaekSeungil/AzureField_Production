using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class JumpObject : MonoBehaviour
{
    [SerializeField,LabelText("점프 발판 높이")]public float jumpForce = 10f;

    private void OnTriggerEnter(Collider other) 
    {
        if(other.gameObject.layer == 6)
        {
            Rigidbody rb = other.gameObject.GetComponent<Rigidbody>();
            if(rb != null)
            {
                rb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
            }
        }
    }
}
