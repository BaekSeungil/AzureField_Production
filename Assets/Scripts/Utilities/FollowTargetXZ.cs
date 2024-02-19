using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//============================================
//
// ���� Transform�� Target�� X���� Z���� ���󰡵��� �մϴ�. 
//
//============================================

public class FollowTargetXZ : MonoBehaviour
{
    [Required]
    public Transform target;

    [SerializeField] private bool isCliped = false;     // ���� ������Ʈ�� ���������� �����̱� ���ϸ� false, clipSize�� ���� �ҿ��������� �����̱� ���ϸ� true
    [SerializeField] private float clipSize = 0.1f;     // �ҿ��������� ������ �� �����̴� ����

    private Vector3 offset;

    private void Start()
    {
        offset = transform.position;
    }

    private void Update()
    {
        if (isCliped)
        {
            transform.position = new Vector3(
                (target.position.x + offset.x) - (target.position.x + offset.x) % clipSize,
                offset.y,
                (target.position.z + offset.z) - (target.position.z + offset.z) % clipSize
                );
        }
        else
        {
            transform.position = new Vector3(target.position.x + offset.x, transform.position.y + offset.y, target.position.z + offset.z);
        }
    }
}
