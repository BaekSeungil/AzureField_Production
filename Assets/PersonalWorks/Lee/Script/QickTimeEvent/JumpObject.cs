using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class JumpObject : PlayerCore
{
    [SerializeField, LabelText("점프 발판 높이")]public float jumpForce = 10f;
    PlayerCore player;
    private void Start() 
    {

    }

    private void OnTriggerEnter(Collider other) 
    {
            if(other.gameObject.layer == 6)
            {
                player.JumpingFromObj();
                Debug.Log("플레이어 체크");
            
            }
    }

    private void OnCollisionEnter(Collision other) 
    {
        if(other.gameObject.layer == 6)
        {
            player.JumpingFromObj();
            Debug.Log("플레이어 체크");
        
        }
    }
}
