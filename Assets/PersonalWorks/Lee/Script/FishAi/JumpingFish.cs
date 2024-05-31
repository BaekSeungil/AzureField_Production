using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class JumpingFish : MonoBehaviour
{
    [SerializeField,LabelText("이동속도")] public float Speed;
    [SerializeField,LabelText("이동거리")] public float MoveLine;
  
    private Vector3 initialPosition;


    void Start()
    {
        initialPosition = transform.position;
    }

    // Update is called once per frame
    void Update()
    {
       MoveFish();
    }

    public void MoveFish()
    {
       
        // 물고기를 앞으로 이동시킵니다.
        transform.Translate(Vector3.forward * Speed * Time.deltaTime);

        // 설정된 이동 거리를 넘어가면 원래 위치로 돌아옵니다.
        if (Vector3.Distance(initialPosition, transform.position) >= MoveLine)
        {
            transform.position = initialPosition; // 이동 방향을 반대로 바꿉니다.
        }
        
    }
}
