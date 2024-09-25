using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ActivateOnPlayerProximity : MonoBehaviour
{
    public float detectionRadius = 10f;  // 플레이어를 감지할 범위
    public LayerMask playerLayer;        // Player 태그를 가진 오브젝트의 레이어 설정

    private bool isPlayerInRange = false; // 플레이어가 범위 내에 있는지 확인하는 플래그

    private void Start()
    {
        // 오브젝트를 처음에 비활성화 상태로 설정
        gameObject.SetActive(false);
    }

    private void Update()
    {
        // 일정 범위 내에 Player 태그를 가진 오브젝트가 있는지 확인
        if (IsPlayerInRange())
        {
            // Player가 범위 내에 있으면 오브젝트를 활성화
            gameObject.SetActive(true);
        }
        else
        {
            // Player가 범위 내에 없으면 오브젝트를 비활성화
            gameObject.SetActive(false);
        }
    }

    // 플레이어가 범위 내에 있는지 확인하는 함수
    private bool IsPlayerInRange()
    {
        // 감지 범위 안에 있는 콜라이더들을 가져옴
        Collider[] hitColliders = Physics.OverlapSphere(transform.position, detectionRadius, playerLayer);

        // 감지된 콜라이더들 중에서 Player 태그를 가진 오브젝트가 있는지 확인
        foreach (Collider collider in hitColliders)
        {
            if (collider.CompareTag("Player"))
            {
                return true;  // Player가 감지되면 true 반환
            }
        }

        return false;  // Player가 감지되지 않으면 false 반환
    }

    // 감지 범위를 시각적으로 확인하기 위한 디버그 용도
    private void OnDrawGizmosSelected()
    {
        // 감지 범위를 시각적으로 표시 (붉은색 원)
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, detectionRadius);
    }
}
