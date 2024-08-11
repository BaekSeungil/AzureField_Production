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
    [SerializeField,LabelText("보트 도약 수직가속증가")] float PlusleapupPower;
    [SerializeField,LabelText("보트 부스터 지속시간 증가")] public float PlusboosterDuration;
    [SerializeField,LabelText("보트 부스터 가속도 증가")] public float PlustboosterMult;


    [Header("업그레이드 창 설정")]
    [SerializeField,LabelText("보트 업그레이드 창")] public GameObject BoatWindow;
    [SerializeField,LabelText("타이틀 텍스쳐")] public TMP_Text TitleText;
    [SerializeField,LabelText("가지고 있는재료 텍스쳐")] public TMP_Text Have_IntText;
    [SerializeField,LabelText("필요한 재료 텍스쳐")] public TMP_Text Need_IntText;
    [SerializeField,LabelText("업글 전 수치")] public TMP_Text BeforeText;
    private float BeforeUpgrade;
    [SerializeField,LabelText("업글 후 수치")] public TMP_Text AfterText;
    private float AtfterUpgrade;
    [SerializeField,LabelText("가속도 아이콘")] private GameObject Duration_ICON;
    [SerializeField,LabelText("점프 아이콘")] private GameObject Jump_ICON;

    [SerializeField,LabelText("부스터 아이콘")] private GameObject Booster_ICON;
    [SerializeField,LabelText("보트 업그레이드 소비아이템")]ItemData Boatitem;
    [SerializeField,LabelText("아이템 소비 초기 값")] private int NeedUseItem;
    [SerializeField,LabelText("아이템 소비 증가 값")] private int UseItemCount;
    private int HaveItem;

    private Coroutine blinkCoroutine;
    private BoatUpgradeType boatUpgradeType;
    private PlayerCore Player;
 
    private void Start()
    {
        Player = FindObjectOfType<PlayerCore>();
        
    }

    private void FixedUpdate()
    {
        SetItemCountText();
        ViewLeaupText();
        ViewBoosterMult();
        ViewBoosterDurationText();
    }

    private void SetItemCountText()
    {
        //현재 보유한 아이템 표시
        HaveItem = PlayerInventoryContainer.Instance.InventoryData.ContainsKey(Boatitem) ?
        PlayerInventoryContainer.Instance.InventoryData[Boatitem] : 0;
        Have_IntText.text = HaveItem.ToString();


    }

    private void ViewLeaupText()
    {
       if(boatUpgradeType == BoatUpgradeType.PlusBoatJumpType)
       {
            BeforeUpgrade = Player.ViewleapupPower;
            BeforeText.text = $"{BeforeUpgrade}";
            BeforeText.text = BeforeUpgrade.ToString("F1");

            AtfterUpgrade =  Player.ViewleapupPower + PlusleapupPower;
            AfterText.text = $"{AtfterUpgrade}";
            AfterText.text = BeforeUpgrade.ToString("F1");
       }

    }

    private void ViewBoosterMult()
    {
        if(boatUpgradeType == BoatUpgradeType.PlusBoatboosterMult)
        {
            BeforeUpgrade = Player.ViewBoosterMult;
            BeforeText.text = $"{BeforeUpgrade}";
            BeforeText.text = BeforeUpgrade.ToString("F1");

            AtfterUpgrade = Player.ViewBoosterMult + PlustboosterMult;
            AfterText.text = $"{AtfterUpgrade}";
            AfterText.text = AtfterUpgrade.ToString("F1");
        }
        
    }

    private void ViewBoosterDurationText()
    {
        if(boatUpgradeType == BoatUpgradeType.PlusBoatboosterDuration)
        {
            BeforeUpgrade = Player.ViewBoosterDuration;
            BeforeText.text = $"{BeforeUpgrade}";
            BeforeText.text = BeforeUpgrade.ToString("F1");

            AtfterUpgrade =  Player.ViewBoosterDuration + PlusboosterDuration;
            AfterText.text = $"{AtfterUpgrade}";
            AfterText.text = AtfterUpgrade.ToString("F1");
        }
        
    }


    public void BoatUpGrade()
    {
        Player = PlayerCore.Instance;
        if (PlayerInventoryContainer.Instance.RemoveItem(Boatitem, NeedUseItem))
        {
            switch (boatUpgradeType)
            {
                case BoatUpgradeType.PlusBoatJumpType:
                    Player.PlayerUpgradeState(PlayerCore.AbilityAttribute.LeapupPower, PlusleapupPower);
                    NeedUseItem += UseItemCount;
                    Debug.Log("점프력: "+ Player.ViewleapupPower);
                    break;

                case BoatUpgradeType.PlusBoatboosterDuration:
                    Player.PlayerUpgradeState(PlayerCore.AbilityAttribute.BoosterDuration, PlusboosterDuration);
                    NeedUseItem += UseItemCount;
                    Debug.Log("가속도: "+ Player.ViewBoosterDuration);
                    break;

                case BoatUpgradeType.PlusBoatboosterMult:
                    Player.PlayerUpgradeState(PlayerCore.AbilityAttribute.BoosterMult, PlustboosterMult);
                    NeedUseItem += UseItemCount;
                    Debug.Log("부스터: "+ Player.ViewBoosterMult);
                    break;
            }
        }
        else
        {
            Debug.Log("아이템 부족");

            if (blinkCoroutine != null)
            {
                StopCoroutine(blinkCoroutine);
                blinkCoroutine = null;
            }

            blinkCoroutine = StartCoroutine(BlinkText(Have_IntText));
        }
    }


    private IEnumerator BlinkText(TMP_Text text)
    {
        Color originalColor = text.color;
        Color blinkColor = Color.red;
        for (int i = 0; i < 4; i++) // 2번 깜빡임
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
        Duration_ICON.SetActive(false);
        Booster_ICON.SetActive(false);
        boatUpgradeType = BoatUpgradeType.PlusBoatJumpType;
    }



    public void ButtonTypeboosterDuration()
    {   
        BoatWindow.SetActive(true);
        Duration_ICON.SetActive(true);
        Booster_ICON.SetActive(false);
        Jump_ICON.SetActive(false);
        boatUpgradeType = BoatUpgradeType.PlusBoatboosterDuration;

    }

    public void ButtonTypeboosterMult()
    {
        BoatWindow.SetActive(true);
        Booster_ICON.SetActive(true);
        Jump_ICON.SetActive(false);
        Duration_ICON.SetActive(false);
        boatUpgradeType = BoatUpgradeType.PlusBoatboosterMult;
    }

    public void GetAskUpgrade()
    {
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
