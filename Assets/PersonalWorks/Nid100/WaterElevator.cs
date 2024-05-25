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

    private void Start()
    {
        initialScale = transform.localScale;
    }

    private void Update()
    {
        // 스케일 값 변경
        if (OnOff == true)
        {
            float scaleFactor = goingUp ? 1f : -1f;
            float newScale = Mathf.Clamp(transform.localScale.y + Time.deltaTime * speed * scaleFactor, minScale, maxScale);
            transform.localScale = new Vector3(initialScale.x, newScale, initialScale.z);
            if (newScale >= maxScale || newScale <= minScale)
            {
                goingUp = !goingUp;
                OnOff = false;
            }
        }

        
    }


    private bool OnOff = false;
    public void BtnOn()
    {
        OnOff = true;
    }
}
