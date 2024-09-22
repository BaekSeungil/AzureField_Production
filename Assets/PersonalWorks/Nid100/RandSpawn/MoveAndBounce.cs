using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveAndBounce : MonoBehaviour
{
    public float moveSpeed = 5.0f;  // 오브젝트의 전진 속도
    public float bounceAmplitude = 2.0f;  // Y축으로 움직이는 범위 (진폭)
    public float bounceFrequency = 1.0f;  // Y축으로 흔들리는 속도 (주파수)

    private float originalY;  // 원래의 Y좌표를 저장할 변수

    // Start is called before the first frame update
    void Start()
    {
        // 시작 시 오브젝트의 Y좌표를 저장합니다.
        originalY = transform.position.y;
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
    }
}
