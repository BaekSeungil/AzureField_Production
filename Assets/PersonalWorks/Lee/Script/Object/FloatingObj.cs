using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class FloatingObj : MonoBehaviour
{
    [SerializeField] float bouyancyPower = 1.0f;        // 부력 세기
    [SerializeField] Transform[] floatingPoint;         // 부력을 받는 지점
    //[SerializeField,LabelText("움직이는 거리")] private float MoveDistance;
    //[SerializeField,LabelText("움직이는 속도")] private float movespeed = 3.0f;
    [SerializeField] float submergeOffset = 0f;
    private float submergeRate = 0.0f;
    public float SubmergeRateZeroClamped { get { return Mathf.Clamp(submergeRate, float.NegativeInfinity, 0.0f); } }     // 물체가 얼마나 침수됐는지 표현합니다.( 0 미만으로 내려가지 않습니다. )
    public float SubmergeRate01 { get { return Mathf.Clamp01(submergeRate); } }                                     // 물체가 얼마나 침수됐는지 표현합니다.( 0과 1사이의 값으로 표현됩니다. )
    public float SubmergeRate { get { return submergeRate; } }                                                      // 물체가 얼마나 침수됐는지 표현합니다.
    private bool waterDetected = false;
    public bool WaterDetected { get { return waterDetected; } }                                                        // 물체의 아래나 위에 연산 가능한 물이 있는지 나타냅니다.

    private Rigidbody rbody;
    private Vector3 TargetPos;
    private bool IsMove = false;
    private void Awake()
    {
        rbody = GetComponent<Rigidbody>();
       
    }

    private void Start()
    {
        if (GlobalOceanManager.Instance == null)
        {
            Debug.Log("BuoyancyBehavior를 사용하려면 Global Ocean Manager를 생성하세요!");
            this.enabled = false;
        }
    }

    const int oceanLayerMask = 1 << 3;

    private void FixedUpdate()
    {
        waterDetected = false;

        if (Physics.Raycast(transform.position, Vector3.up, float.PositiveInfinity, oceanLayerMask) ||
            Physics.Raycast(transform.position, Vector3.down, float.PositiveInfinity, oceanLayerMask))
        {
            waterDetected = true;

            float[] submerged = new float[floatingPoint.Length];
            float average = 0f;

            for (int i = 0; i < submerged.Length; i++)
            {
                submerged[i] = floatingPoint[i].position.y - GlobalOceanManager.Instance.GetWaveHeight(floatingPoint[i].position);
                if (submerged[i] < 0)
                {
                    rbody.AddForceAtPosition(Vector3.up * bouyancyPower / floatingPoint.Length * -Mathf.Clamp(submerged[i], -1f, 0f), floatingPoint[i].position, ForceMode.Acceleration);
                }

                average += submerged[i];
            }

            average /= submerged.Length;
            submergeRate = average;
        }
        else
        {
            submergeRate = float.PositiveInfinity;
            waterDetected = false;
        }

        // if (IsMove)
        // {
        //     MoveFloatingObj();
        // }
    }

    private void MoveFloatingObj()
    {
        if (!IsMove) return; 
        Debug.Log("현재 위치: " + transform.position + " / 목표 위치: " + TargetPos);
        float distanceToTarget = Vector3.Distance(transform.position, TargetPos);

        Debug.Log("목표까지 거리: " + distanceToTarget); // 목표까지 거리 로그 추가

        // 목표 위치에 가까이 가면 바로 목표 위치로 스냅
        if (distanceToTarget < 0.1f)
        {
            rbody.velocity = Vector3.zero;
            IsMove = false;
            Debug.Log("위치 도달");
        }
        else
        {
            Vector3 direction = (TargetPos - transform.position).normalized;
            //rbody.MovePosition(transform.position + direction * movespeed * Time.deltaTime);
        }
        
    }

    private void OnCollisionEnter(Collision other) 
    {
        if(other.gameObject.layer == 4 && !IsMove)
        {
            IsMove = true;
            // 충돌 방향으로 목표 위치 설정
            //TargetPos = transform.position + transform.forward  * MoveDistance;
        }
    }

    private void OnDrawGizmos()
    {

        // 도착 지점(TargetPos)을 빨간 구체로 표시
        Gizmos.color = Color.red;
        Gizmos.DrawSphere(TargetPos, 0.5f);  // 0.5는 구체의 크기   

        foreach (Transform point in floatingPoint)
        {
            if (point != null)
            {
                Gizmos.DrawSphere(point.position, 0.5f);  // 0.5는 구체의 크기
            }
        }

        // 시작 지점(StartPos)과 도착 지점(TargetPos)을 잇는 선 그리기
        Gizmos.color = Color.green;
        Gizmos.DrawLine(transform.position, TargetPos);
    }

}
