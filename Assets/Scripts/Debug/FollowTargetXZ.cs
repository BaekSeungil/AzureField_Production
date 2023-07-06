using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FollowTargetXZ : MonoBehaviour
{
    [Required]
    public Transform target;

    private Vector3 offset;

    private void Start()
    {
        offset = transform.position;
    }

    private void Update()
    {
        transform.position = new Vector3(target.position.x + offset.x, transform.position.y + offset.y , target.position.z + offset.z);
    }
}
