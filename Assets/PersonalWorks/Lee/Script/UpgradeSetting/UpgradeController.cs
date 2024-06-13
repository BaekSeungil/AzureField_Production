using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum BoatUpgradeType
{
    PlusBoatJumpType,
    PlusBoatboosterDuration,
    PlusBoatboosterMult,
};

public class UpgradeController : MonoBehaviour
{
    [Header("업그레이드 설정값")]
    [SerializeField,LabelText("보트 도약 수직가속증가")] float PlusBoatJump;
    [SerializeField,LabelText("보트 부스터 지속시간 증가")] public float PlusboosterDuration;
    [SerializeField,LabelText("보트 부스터 가속도 증가")] public float PlustboosterMult;
    [SerializeField,LabelText("보트 업그레이드 창")] public GameObject BoatWindow;
    [SerializeField,LabelText("플레이어 업그레이드 창")] public GameObject PlayerWindow;
    [SerializeField,LabelText("되묻는 창")] public GameObject AskUpgradeWindow;
    [SerializeField,LabelText("보트 업그레이드 소비아이템")]ItemData Boatitem;
    private BoatUpgradeType boatUpgradeType;
    private PlayerCore Player;
 
    private void Start()
    {
        Player.GetComponent<PlayerCore>();
    }

    public void BoatUpGrade()
    {
        FindObjectOfType<PlayerInventoryContainer>();
        Player = FindObjectOfType<PlayerCore>();
        if(PlayerInventoryContainer.Instance.RemoveItem(Boatitem))
        {
            switch(boatUpgradeType)
            {
                case BoatUpgradeType.PlusBoatJumpType:
                Player.PlayerUpgradeState(PlusBoatJump);
                break;

                case BoatUpgradeType.PlusBoatboosterDuration:
                Player.PlayerUpgradeState(PlusboosterDuration);
                break;

                case BoatUpgradeType.PlusBoatboosterMult:
                Player.PlayerUpgradeState(PlustboosterMult);
                break;
            }
        }


    }


    #if UNITY_EDITOR
    public void GetChangeTypeButtonJump()
    {
        boatUpgradeType = BoatUpgradeType.PlusBoatJumpType;
    }

    public void GetChangeTypeButtonKeep()
    {
        boatUpgradeType = BoatUpgradeType.PlusBoatboosterDuration;
    }

    public void GetChangeTypeButtonSpeed()
    {
        boatUpgradeType = BoatUpgradeType.PlusBoatboosterMult;
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
