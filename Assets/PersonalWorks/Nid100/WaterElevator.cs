using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterElevator : MonoBehaviour
{
    public float minScale = 1f; // 최소 스케일
    public float maxScale = 2f; // 최대 스케일
    public float speed = 1f;    // 엘리베이터 이동 속도

    private bool goingUp = true; // 현재 엘리베이터가 위로 이동 중인지 여부
    private Vector3 initialScale; // 초기 스케일 값

    [SerializeField] private PlayerCore player;
    [SerializeField] private Transform playerTransform;
    [SerializeField] private float moveSpeed = 9.8f;
    [SerializeField] private Transform targetPosition;

    [SerializeField] private GameObject WaterCollider;
    [SerializeField] private ParticleSystem waterStart;
    [SerializeField] private ParticleSystem waterIdle;
    [SerializeField] private ParticleSystem waterEnd;

    private void Start()
    {
        player = PlayerCore.Instance;
        playerTransform = PlayerCore.Instance.transform;
        initialScale = transform.localScale;
        waterStart.Stop();
        waterIdle.Stop();
        waterEnd.Stop();
    }


    private bool targetMoveOnOff = false;
    private void Update()
    {
        // 스케일 값 변경
        if (OnOff == true)
        {
            float scaleFactor = goingUp ? 1f : -1f;
            float newScale = Mathf.Clamp(WaterCollider.transform.localScale.y + Time.deltaTime * speed * scaleFactor, minScale, maxScale);
            WaterCollider.transform.localScale = new Vector3(initialScale.x, newScale, initialScale.z);
            if (newScale >= maxScale || newScale <= minScale)
            {
                goingUp = !goingUp;
                if (newScale >= maxScale)
                {
                    targetMoveOnOff = true;
                }
                OnOff = false;
            }
        }
        if (targetMoveOnOff == true)
        {
                if (Vector3.Distance(playerTransform.position, targetPosition.position) <= 1.0f)
                {
                    targetMoveOnOff = false;
                }
                TargetMove();
        }


    }


    //private Vector3 velocity;
    private void TargetMove() 
    {
            float step = moveSpeed * Time.deltaTime;
            Vector3 newPosition = Vector3.MoveTowards(playerTransform.position, targetPosition.position, step);
            //newPosition.y = playerTransform.position.y; // y축 이동 방지
            playerTransform.position = newPosition;
    }


    private bool OnOff = false;
    public void BtnOn()
    {
        OnOff = true;
        if (goingUp == true)
        {
            waterStart.Play();
            Invoke("WaterIdle", 0.5f);
        }
        else if (goingUp == false) 
        {
            waterEnd.Play();
            waterIdle.Stop();
        }
    }

    public void WaterIdle()
    {
        waterIdle.Play();
    }
}
