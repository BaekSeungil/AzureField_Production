using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum BoatUpgradeType
{

};

public class UpgradeController : MonoBehaviour
{
    [Header("업그레이드 설정값")]

    [SerializeField,LabelText("조각배 수직점프력 증가")] public float PlusJump;
    [SerializeField,LabelText("보트 도약 수직가속증가")] float PlusBoatJump;
    [SerializeField,LabelText("보트 부스터 지속시간 증가")] public float PlusBoatKeep;

    [SerializeField,LabelText("보트 업그레이드 창")] public GameObject BoatWindow;
    [SerializeField,LabelText("플레이어 업그레이드 창")] public GameObject PlayerWindow;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }





    public void Inupgrade()
    {
        BoatWindow.SetActive(true);
        PlayerWindow.SetActive(true);
    }

    public void Outupgrade()
    {
        BoatWindow.SetActive(false);
        PlayerWindow.SetActive(false);
    }
}
