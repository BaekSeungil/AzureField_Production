using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveAndBounce : MonoBehaviour
{
    public float moveSpeed = 5.0f;  // 오브젝트의 전진 속도
    public float bounceAmplitude = 2.0f;  // Y축으로 움직이는 범위 (진폭)
    public float bounceFrequency = 1.0f;  // Y축으로 흔들리는 속도 (주파수)
    public float detectionRadius = 10f;  // 플레이어 감지 범위
    public LayerMask playerLayer;  // Player 태그가 포함된 레이어 설정

    private GameObject MoveObject;

    private float originalY;  // 원래의 Y좌표를 저장할 변수

    // Start is called before the first frame update
    void Start()
    {
        // 시작 시 오브젝트의 Y좌표를 저장합니다.
        originalY = transform.position.y;
        MoveObject = GetComponent<GameObject>();
    }

    // Update is called once per frame
    void Update()
    {
        // 오브젝트가 바라보는 방향으로 이동하도록 합니다.
        transform.Translate(transform.forward * moveSpeed * Time.deltaTime, Space.World);

        // 오브젝트의 Y축을 상하로 반복적으로 움직이게 합니다.
        float newY = originalY + Mathf.Sin(Time.time * bounceFrequency) * bounceAmplitude;

        // 오브젝트의 Y좌표를 설정합니다.
        transform.position = new Vector3(transform.position.x, newY, transform.position.z);

        // 일정 범위 내에 Player 태그가 있는지 확인합니다.
        if (!IsPlayerInRange())
        {
            // 범위 내에 Player가 없으면 오브젝트를 비활성화합니다.
            MoveObject.SetActive(false);
        }
    }

    // 일정 범위 내에 Player가 있는지 확인하는 함수
    private bool IsPlayerInRange()
    {
        // 감지 범위 안에 있는 콜라이더를 찾습니다.
        Collider[] hitColliders = Physics.OverlapSphere(transform.position, detectionRadius, playerLayer);

        // 감지된 콜라이더 중 Player 태그를 가진 오브젝트가 있는지 확인합니다.
        foreach (Collider collider in hitColliders)
        {
            if (collider.CompareTag("Player"))
            {
                return true; // Player가 감지되면 true 반환
            }
        }

        return false; // Player가 감지되지 않으면 false 반환
    }

    // 감지 범위를 시각적으로 표시하기 위한 디버그용 함수
    private void OnDrawGizmosSelected()
    {
        // 감지 범위의 반경을 그립니다.
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, detectionRadius);
    }
}

