using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.Localization;

public struct UpgradeLimit
{
    public int currentCount;
    public int maxCount;

    public bool CanUpgrade() => currentCount < maxCount;
}

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
    [SerializeField,LabelText("타이틀 텍스쳐")] private TMP_Text TitleText;
    [SerializeField,LabelText("가지고 있는재료 텍스쳐")] private TMP_Text Have_IntText;
    [SerializeField,LabelText("필요한 재료 텍스쳐")] private TMP_Text Need_IntText;
    [SerializeField,LabelText("업글 전 수치")] private TMP_Text BeforeText;
    private int BeforeUpgrade;
    [SerializeField,LabelText("업글 후 수치")] private TMP_Text AfterText;
    private float AfterUpgrade;
    [SerializeField,LabelText("가속도 아이콘")] private GameObject Duration_ICON;
    [SerializeField,LabelText("점프 아이콘")] private GameObject Jump_ICON;
    [SerializeField,LabelText("부스터 아이콘")] private GameObject Booster_ICON;
    [SerializeField,LabelText("보트 업그레이드 소비아이템")]ItemData Boatitem;
    [SerializeField,LabelText("아이템 소비 초기 값")] private int NeedUseItem;
    [SerializeField,LabelText("아이템 소비 증가 값")] private int UseItemCount;

    [SerializeField,LabelText("부스터 업글 횟수 제한")] private UpgradeLimit UpBooster_CountLimit = new UpgradeLimit{maxCount = 5};
    [SerializeField,LabelText("점프 업글횟수 제한")] private UpgradeLimit UpJump_CountLimit= new UpgradeLimit{maxCount = 5};
    [SerializeField,LabelText("가속도 업글 횟수 제한")] private UpgradeLimit UpDuration_CountLimit= new UpgradeLimit{maxCount = 5};

    [SerializeField,LabelText("업글제한 점프 메세지 게임")] private GameObject LimitObject;
    [SerializeField,LabelText("필요강화 재료 오브젝트")] private GameObject ItemTitleObj;
    [SerializeField,LabelText("업글 종류 텍스쳐")] private TMP_Text UpTypeText;

    [SerializeField, LabelText("텍스트 : 가속도 업그레이드")] private LocalizedString TXT_duration;
    [SerializeField, LabelText("텍스트 : 점프 업그레이드")] private LocalizedString TXT_Jump;
    [SerializeField, LabelText("텍스트 : 부스터 업그레이드")] private LocalizedString TXT_Booster;

    private int HaveItem;

    private bool CanUpgrade = true; // 업그레이드 가능 여부

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
        UpdateUpgradeView();
        
        
    }

    private void SetItemCountText()
    {
        //현재 보유한 아이템 표시
        HaveItem = PlayerInventoryContainer.Instance.InventoryData.ContainsKey(Boatitem) ?
        PlayerInventoryContainer.Instance.InventoryData[Boatitem] : 0;
        Have_IntText.text = HaveItem.ToString();


    }

    // 텍스쳐 업데이트
    private void UpdateUpgradeView()
    {
        switch (boatUpgradeType)
        {
            case BoatUpgradeType.PlusBoatJumpType:
                UpdateView(Player.ViewleapupPower, PlusleapupPower);
                break;
            case BoatUpgradeType.PlusBoatboosterDuration:
                UpdateView(Player.ViewBoosterDuration, PlusboosterDuration);
                break;
            case BoatUpgradeType.PlusBoatboosterMult:
                UpdateView(Player.ViewBoosterMult, PlustboosterMult);
                break;
        }

        if(!GetCurrentCanUpgradeStatus())
        {
            if(NeedUseItem > UseItemCount)
            LimitUpgradeObj();
        }
        else
        {
            OffLimitUpgradeObj();
        }
    }

    private void UpdateView(float beforeValue, float upgradeValue)
    {
        BeforeUpgrade = (int)beforeValue;
        BeforeText.text = BeforeUpgrade.ToString("F1");

        AfterUpgrade = beforeValue + upgradeValue;
        AfterText.text = AfterUpgrade.ToString("F1");
    }



    //보트 강화 아이템 소비하고 업그레이드 수치처리
    private void BoatUpGrade()
    {
        if (!CanUpgrade) return;
        Player = PlayerCore.Instance;

        if(!GetCurrentCanUpgradeStatus())return;

        if (!PlayerInventoryContainer.Instance.RemoveItem(Boatitem, NeedUseItem))
        {
            StartBlinkingText(Have_IntText);
            return;
        }

        switch (boatUpgradeType)
        {
            case BoatUpgradeType.PlusBoatJumpType:
                TryUpgrade(ref UpJump_CountLimit, PlayerCore.AbilityAttribute.LeapupPower, PlusleapupPower);
                break;
            case BoatUpgradeType.PlusBoatboosterDuration:
                TryUpgrade(ref UpDuration_CountLimit, PlayerCore.AbilityAttribute.BoosterDuration, PlusboosterDuration);
                break;
            case BoatUpgradeType.PlusBoatboosterMult:
                TryUpgrade(ref UpBooster_CountLimit, PlayerCore.AbilityAttribute.BoosterMult, PlustboosterMult);
                break;
        }

    }

    //강화 상태및 필요한 아이템 개수 증가
    private void TryUpgrade(ref UpgradeLimit limit, PlayerCore.AbilityAttribute attribute, float upgradeValue)
    {
        if (limit.CanUpgrade())
        {
            Player.PlayerUpgradeState(attribute, upgradeValue);
            limit.currentCount++;
            NeedUseItem += UseItemCount;
            OffLimitUpgradeObj();  // 강화 가능 상태 유지

            if(!GetCurrentCanUpgradeStatus())
            {
                if(NeedUseItem > UseItemCount)
                LimitUpgradeObj();
            }
            
        }
     
    }

    // 타입별 강화 가능 여부 판별
    private bool GetCurrentCanUpgradeStatus()
    {
        switch (boatUpgradeType)
        {
            case BoatUpgradeType.PlusBoatJumpType:
                return UpJump_CountLimit.CanUpgrade();
            case BoatUpgradeType.PlusBoatboosterDuration:
                return UpDuration_CountLimit.CanUpgrade();
            case BoatUpgradeType.PlusBoatboosterMult:
                return UpBooster_CountLimit.CanUpgrade();
            default:
                return false;
        }
    }

    private void StartBlinkingText(TMP_Text text)
    {
        if (blinkCoroutine != null)
        {
            StopCoroutine(blinkCoroutine);
        }
        blinkCoroutine = StartCoroutine(BlinkText(text));
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

 //   #if UNITY_EDITOR
    public void ButtonTypeJump()
    {
        BoatWindow.SetActive(true);
        //Jump_ICON.SetActive(true);
        //Duration_ICON.SetActive(false);
        //Booster_ICON.SetActive(false);
        UpTypeText.text = TXT_Jump.GetLocalizedString();
        boatUpgradeType = BoatUpgradeType.PlusBoatJumpType;
    }



    public void ButtonTypeboosterDuration()
    {   
        BoatWindow.SetActive(true);
        //Duration_ICON.SetActive(true);
        //Booster_ICON.SetActive(false);
        //Jump_ICON.SetActive(false);
        UpTypeText.text = TXT_duration.GetLocalizedString();
        boatUpgradeType = BoatUpgradeType.PlusBoatboosterDuration;

    }

    public void ButtonTypeboosterMult()
    {
        BoatWindow.SetActive(true);
        //Booster_ICON.SetActive(true);
        //Jump_ICON.SetActive(false);
        //Duration_ICON.SetActive(false);
        UpTypeText.text = TXT_Booster.GetLocalizedString();
        boatUpgradeType = BoatUpgradeType.PlusBoatboosterMult;
    }

    public void GetAskUpgrade()
    {
        Need_IntText.text = NeedUseItem.ToString();
        BoatUpGrade();
    }

    public void LimitUpgradeObj()
    {
        LimitObject.SetActive(true);
        ItemTitleObj.SetActive(false);
    }

    public void OffLimitUpgradeObj()
    {
        LimitObject.SetActive(false);
        ItemTitleObj.SetActive(true);
    }

    public void Outupgrade()
    {
        BoatWindow.SetActive(false);
        Jump_ICON.SetActive(false);
        Duration_ICON.SetActive(false);
        Booster_ICON.SetActive(false);
    }


#if UNITY_EDITOR
    [Button(), DisableInEditorMode(),FoldoutGroup("디버그")]
    public void Debug_UpgradeLeapup()
    {
        Player.AddPermernentAttribute(PlayerCore.AbilityAttribute.LeapupPower, PlusleapupPower);
        NeedUseItem += UseItemCount;
        Debug.Log("점프력: " + Player.ViewleapupPower);
    }

    [Button(), DisableInEditorMode(), FoldoutGroup("디버그")]
    public void Debug_UpgradeBoosterDuration()
    {
        Player.AddPermernentAttribute(PlayerCore.AbilityAttribute.BoosterDuration, PlusboosterDuration);
        NeedUseItem += UseItemCount;
        Debug.Log("부스터 지속시간: " + Player.ViewBoosterDuration);
    }

    [Button(), DisableInEditorMode(), FoldoutGroup("디버그")]
    public void Debug_UpgradeBoosterMult()
    {
        Player.AddPermernentAttribute(PlayerCore.AbilityAttribute.BoosterMult, PlustboosterMult);
        NeedUseItem += UseItemCount;
        Debug.Log("부스터 가속도: " + Player.ViewBoosterMult);
    }
#endif

    //   #endif
}
