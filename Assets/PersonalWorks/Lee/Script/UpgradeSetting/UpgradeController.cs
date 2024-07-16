using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;


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


    [Header("업그레이드 창 설정")]
    [SerializeField,LabelText("보트 업그레이드 창")] public GameObject BoatWindow;
    [SerializeField,LabelText("타이틀 텍스쳐")] public TMPro.TMP_Text TitleText;
    [SerializeField,LabelText("가지고 있는재료 텍스쳐")] public TMPro.TMP_Text Have_IntText;
    [SerializeField,LabelText("필요한 재료 텍스쳐")] public TMPro.TMP_Text Need_IntText;
    [SerializeField,LabelText("업글 전 수치")] public TMPro.TMP_Text BeforeText;
    private float BeforeUpgrade;
    [SerializeField,LabelText("업글 후 수치")] public TMPro.TMP_Text AfterText;
    private float AtfterUpgrade;
    [SerializeField,LabelText("가속도 아이콘")] private GameObject Duration_ICON;
    [SerializeField,LabelText("점프 아이콘")] private GameObject Jump_ICON;

    [SerializeField,LabelText("부스터 아이콘")] private GameObject Booster_ICON;
    [SerializeField,LabelText("보트 업그레이드 소비아이템")]ItemData Boatitem;
    [SerializeField,LabelText("아이템 소비 초기 값")] private int NeedUseItem;
    [SerializeField,LabelText("아이템 소비 증가 값")] private int UseItemCount;
    private int HaveItem;
    private BoatUpgradeType boatUpgradeType;
    private PlayerCore Player;
 
    private void Start()
    {
        Player = FindObjectOfType<PlayerCore>();
        
    }

    public void BoatUpGrade()
    {
        FindObjectOfType<PlayerInventoryContainer>();
        Player = FindObjectOfType<PlayerCore>();
        if(PlayerInventoryContainer.Instance.RemoveItem(Boatitem, NeedUseItem))
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
        else
        {
            Debug.Log("아이템 부족");
            BlinkText(Have_IntText);
        }


    }


    private IEnumerator BlinkText(TMP_Text text)
    {
        Color originalColor = text.color;
        Color blinkColor = new Color(originalColor.r, originalColor.g, originalColor.b, 0);

        for (int i = 0; i < 6; i++) // 3번 깜빡임
        {
            text.color = blinkColor;
            yield return new WaitForSeconds(0.25f);
            text.color = originalColor;
            yield return new WaitForSeconds(0.25f);
        }
    }

    #if UNITY_EDITOR
    public void ButtonTypeJump()
    {
        BoatWindow.SetActive(true);
        Jump_ICON.SetActive(true);
        boatUpgradeType = BoatUpgradeType.PlusBoatJumpType;
        BeforeUpgrade = Player.ViewleapupPower;
        BeforeText.text = $"{BeforeUpgrade}";
        AtfterUpgrade =  Player.ViewleapupPower + PlusBoatJump;
        AfterText.text = $"{AtfterUpgrade}";
        AtfterUpgrade =  Player.ViewleapupPower - PlusBoatJump;
    }

    public void ButtonTypeboosterDuration()
    {   
        BoatWindow.SetActive(true);
        Duration_ICON.SetActive(true);
        boatUpgradeType = BoatUpgradeType.PlusBoatboosterDuration;
        BeforeUpgrade = Player.ViewBoosterDuration;
        BeforeText.text = $"{BeforeUpgrade}";
        AtfterUpgrade =  Player.ViewBoosterDuration + PlusboosterDuration;
        AfterText.text = $"{AtfterUpgrade}";
        AtfterUpgrade =  Player.ViewBoosterDuration - PlusboosterDuration;
    }

    public void ButtonTypeboosterMult()
    {
        BoatWindow.SetActive(true);
        Booster_ICON.SetActive(true);
        boatUpgradeType = BoatUpgradeType.PlusBoatboosterMult;
        BeforeUpgrade = Player.ViewBoosterMult;
        BeforeText.text = $"{BeforeUpgrade}";
        AtfterUpgrade =  Player.ViewBoosterMult + PlustboosterMult;
        AfterText.text = $"{AtfterUpgrade}";
        AtfterUpgrade =  Player.ViewBoosterMult - PlustboosterMult;
    }

    public void GetAskUpgrade()
    {
        NeedUseItem += UseItemCount;
        Need_IntText.text = NeedUseItem.ToString();
        BoatUpGrade();
    }

    public void Outupgrade()
    {
        BoatWindow.SetActive(false);
        Jump_ICON.SetActive(false);
        Duration_ICON.SetActive(false);
        Booster_ICON.SetActive(false);
    }


    #endif
}
