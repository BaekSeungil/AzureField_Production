using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum BoatUpgradeType
{
    PlusBoatJumpType,
    PlusBoatKeepType,
    PlusBoatSpeedType,
};

public class UpgradeController : MonoBehaviour
{
    [Header("업그레이드 설정값")]
    [SerializeField,LabelText("보트 도약 수직가속증가")] float PlusBoatJump;
    [SerializeField,LabelText("보트 부스터 지속시간 증가")] public float PlusBoatKeep;
    [SerializeField,LabelText("보트 부스터 가속도 증가")] public float PlusBoatSpeed;
    [SerializeField,LabelText("보트 업그레이드 창")] public GameObject BoatWindow;
    [SerializeField,LabelText("플레이어 업그레이드 창")] public GameObject PlayerWindow;
    [SerializeField,LabelText("되묻는 창")] public GameObject AskUpgradeWindow;

    private BoatUpgradeType boatUpgradeType;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }







    public void BoatUpGrade()
    {

    }


    #if UNITY_EDITOR
    public void GetChangeTypeButtonJump()
    {
        boatUpgradeType = BoatUpgradeType.PlusBoatJumpType;
        BoatUpGrade();
    }

    public void GetChangeTypeButtonKeep()
    {
        boatUpgradeType = BoatUpgradeType.PlusBoatKeepType;
        BoatUpGrade();
    }

    public void GetChangeTypeButtonSpeed()
    {
        boatUpgradeType = BoatUpgradeType.PlusBoatSpeedType;
        BoatUpGrade();
    }

    public void GetAskUpgrade()
    {
        AskUpgradeWindow.SetActive(true);
        BoatUpGrade();
    }

    public void OutAskUpgrade()
    {
        AskUpgradeWindow.SetActive(false);
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


    #endif
}
