using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterElevator : MonoBehaviour
{
    public float minScale = 1f; // 최소 스케일
    public float maxScale = 2f; // 최대 스케일
    public float speed = 1f;    // 엘리베이터 이동 속도

    public bool goingUp = true; // 현재 엘리베이터가 위로 이동 중인지 여부
    private Vector3 initialScale; // 초기 스케일 값

    [SerializeField] private PlayerCore player;
    [SerializeField] private Transform playerTransform;
    [SerializeField] private Rigidbody playerRigidbody;
    [SerializeField] private float moveSpeed = 9.8f;
    [SerializeField] private float force = 9.8f;
    [SerializeField] private Transform targetPosition;

    [SerializeField] private GameObject WaterCollider;
    [SerializeField] private ParticleSystem waterStart;
    [SerializeField] private ParticleSystem waterIdle;
    [SerializeField] private ParticleSystem waterEnd;



    private float dist = 0;

    private void Start()
    {
        player = PlayerCore.Instance;
        playerTransform = PlayerCore.Instance.transform;
        playerRigidbody = PlayerCore.Instance.GetComponent<Rigidbody>();
        initialScale = WaterCollider.transform.localScale;
        waterStart.Stop();
        waterIdle.Stop();
        waterEnd.Stop();


        Vector3 waterPosition = WaterCollider.transform.position;
        Vector3 targetPos = targetPosition.position;
        Vector3 waterPosWithoutY = new Vector3(waterPosition.x, 0, waterPosition.z);
        Vector3 targetPosWithoutY = new Vector3(targetPos.x, 0, targetPos.z);

        dist = Vector3.Distance(waterPosWithoutY, targetPosWithoutY);

    }


    private bool targetMoveOnOff = false;
    private void FixedUpdate()
    {
        // 스케일 값 변경
        if (OnOff == true)
        {
            
            float scaleFactor = goingUp ? 1f : -1f;
            float newScale = Mathf.Clamp(WaterCollider.transform.localScale.y + Time.fixedDeltaTime * speed * scaleFactor, minScale, maxScale);
            WaterCollider.transform.localScale = new Vector3(initialScale.x, newScale, initialScale.z);
            if (goingUp == true) {
                player.DisableControls();
            }


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
            player.DisableControls();
            if (Vector3.Distance(playerTransform.position, targetPosition.position) <= 1.0f)
            {
                player.EnableControlls();
                targetMoveOnOff = false;
            }
                TargetMove();
        }


    }

    private float dist2;
    //private Vector3 velocity;
    private void TargetMove() 
    {
        float step = moveSpeed * Time.fixedDeltaTime;
        Vector3 newPosition = Vector3.MoveTowards(playerTransform.position, targetPosition.position, step);
        playerTransform.position = newPosition;

        Vector3 playerPosition = playerTransform.position;
        Vector3 targetPos = targetPosition.position;

        // Y 값을 무시하고 거리를 계산하기 위해, Y 값을 동일하게 설정합니다.
        Vector3 playerPosWithoutY = new Vector3(playerPosition.x, 0, playerPosition.z);
        Vector3 targetPosWithoutY = new Vector3(targetPos.x, 0, targetPos.z);
        dist2 = Vector3.Distance(playerPosWithoutY, targetPosWithoutY);
        if (dist2 >= dist / 2)
        {
            playerRigidbody.AddForce(new Vector3(0, force, 0));
        }

        Vector3 lookDirection = (targetPosition.position - playerTransform.position).normalized;
        Quaternion targetRotation = Quaternion.LookRotation(lookDirection);
        playerTransform.rotation = Quaternion.Slerp(playerTransform.rotation, targetRotation, step);


        /*
        float step = moveSpeed * Time.deltaTime;

        // Calculate the distance to the target
        Vector3 direction = targetPosition.position - playerTransform.position;
        float distance = direction.magnitude;

        // Calculate horizontal distance
        float horizontalDistance = Vector3.Distance(new Vector3(playerTransform.position.x, 0, playerTransform.position.z), new Vector3(targetPosition.position.x, 0, targetPosition.position.z));

        // Normalize the direction vector
        Vector3 horizontalDirection = new Vector3(direction.x, 0, direction.z).normalized;

        // Calculate the parabola height based on the horizontal distance
        float parabolaHeight = Mathf.Max(10.0f, 5.0f); // Minimum height of 10
        float t = Vector3.Distance(playerTransform.position, targetPosition.position) / horizontalDistance; // Normalized distance
        float height = Mathf.Sin(Mathf.PI * t) * parabolaHeight;

        // Create a new position based on the parabola
        Vector3 newPosition = Vector3.MoveTowards(playerTransform.position, targetPosition.position, step);
        newPosition.y = Mathf.Lerp(playerTransform.position.y, targetPosition.position.y, t) + height;

        // Update the player's position
        playerTransform.position = newPosition;
         */

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
