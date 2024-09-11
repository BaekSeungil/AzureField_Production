using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RingbellInteract : MonoBehaviour
{
    //오브젝트 본인
    [SerializeField] private GameObject my;
    //메인이 되는 링벨시스템
    [SerializeField] private RingbellSystem ringbellSystem;
    //본인의 번호
    [SerializeField] private int myNumber;
    //본인의 활성화여부
    public bool onoff = false;
    //해당 오브젝트가 활성화/비활성화 될 경우 영향을 줄 오브젝트 번호
    public int[] connectionNumber;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Water")
        {
            
            ringbellSystem.connectionBellActive(myNumber);
        }
    }
}
