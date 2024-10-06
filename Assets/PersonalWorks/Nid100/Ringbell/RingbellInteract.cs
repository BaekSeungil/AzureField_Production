using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RingbellInteract : MonoBehaviour
{
    // 오브젝트 본인
    [SerializeField] private GameObject my;
    // 비석 머테리얼이 적용될 오브젝트
    [SerializeField] private Renderer stoneRenderer;  // stone 오브젝트의 Renderer
    // 비활성화 시 적용될 머테리얼
    [SerializeField] private Material originStone;
    // 활성화 시 적용될 머테리얼
    [SerializeField] private Material changeStone;
    // 메인이 되는 링벨 시스템
    [SerializeField] private RingbellSystem ringbellSystem;
    // 본인의 번호
    [SerializeField] private int myNumber;
    // 본인의 활성화 여부
    public bool onoff = false;
    // 해당 오브젝트가 활성화/비활성화 될 경우 영향을 줄 오브젝트 번호
    public int[] connectionNumber;

    // Start is called before the first frame update
    void Start()
    {
        // 초기화 시 머테리얼 설정
        UpdateStoneMaterial();
    }

    // Update is called once per frame
    void Update()
    {

    }

    // 충돌 처리
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "WaterReaction")
        {
            ringbellSystem.connectionBellActive(myNumber);
            Debug.Log(myNumber + "번 종 활성화");

            // 종 활성화 상태에 따른 머테리얼 업데이트
            UpdateStoneMaterial();
        }
    }

    // onoff 상태에 따라 stone 오브젝트의 머테리얼을 업데이트하는 함수
    public void UpdateStoneMaterial()
    {
        if (onoff)
        {
            // 활성화 상태일 경우 changeStone 머테리얼 적용
            stoneRenderer.material = changeStone;
        }
        else
        {
            // 비활성화 상태일 경우 originStone 머테리얼 적용
            stoneRenderer.material = originStone;
        }
    }
}
