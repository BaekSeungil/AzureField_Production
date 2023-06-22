using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class BuoyantBehavior : MonoBehaviour
{
    [SerializeField] float bouyancyPower = 1.0f;
    [SerializeField] Transform[] floatingPoint;

    Rigidbody rbody;


    private void Awake() 
    {
        rbody = GetComponent<Rigidbody>();
    }

    private void OnEnable() 
    {
        if(GlobalOceanManager.Instance == null)
        {
            Debug.Log("BuoyancyBehavior를 사용하려면 Global Ocean Manager를 생성하세요!");
        }
    }

    private void FixedUpdate()
    {
        float[] submerged = new float[floatingPoint.Length];

        for(int i = 0; i < submerged.Length; i++)
        {
            submerged[i] = floatingPoint[i].position.y - GlobalOceanManager.Instance.GetWaveHeight(floatingPoint[i].position);
            if(submerged[i] < 0)
            {
                rbody.AddForceAtPosition(Vector3.up * bouyancyPower/floatingPoint.Length * -Mathf.Clamp(submerged[i],-1f,0f),floatingPoint[i].position,ForceMode.Acceleration);
            }
        }
    }
}
