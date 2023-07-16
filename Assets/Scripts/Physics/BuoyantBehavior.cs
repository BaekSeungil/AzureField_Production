using AmplifyShaderEditor;
using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class BuoyantBehavior : MonoBehaviour
{
    [SerializeField] float bouyancyPower = 1.0f;
    [SerializeField] Transform[] floatingPoint;

    [SerializeField,ReadOnly] private float submergeRate = 0.0f;
    public float SubmergeRateZeroClamped { get {return Mathf.Clamp(submergeRate,float.NegativeInfinity,0.0f);}}
    public float SubmergeRate { get { return submergeRate; } }
    private bool waterDetected = false;
    public bool WaterDetected { get {return waterDetected;}}

    Rigidbody rbody;

    private void Awake() 
    {
        rbody = GetComponent<Rigidbody>();
    }

    private void Start() 
    {
        if(GlobalOceanManager.Instance == null)
        {
            Debug.Log("BuoyancyBehavior를 사용하려면 Global Ocean Manager를 생성하세요!");
        }
    }

    private void FixedUpdate()
    {
        if (floatingPoint.Length > 0)
        {
            if (Physics.Raycast(transform.position, Vector3.up, float.PositiveInfinity, 1 << 3) ||
                Physics.Raycast(transform.position, Vector3.down, float.PositiveInfinity, 1 << 3))
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
        }

    }
}
