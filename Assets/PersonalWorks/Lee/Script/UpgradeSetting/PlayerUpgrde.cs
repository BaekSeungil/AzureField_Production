using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.Localization;
using Sirenix.OdinInspector;

public struct PlayerUpLimt
{
    public int PlayercurrentCount;
    public int PlayermaxCount;
    public bool PlayerCanUpgrade() => PlayercurrentCount < PlayermaxCount;
}

public enum PlayerUpgedeType
{
    PlusPlayerJump,
    PlusPlayerMoveSpeed,
    PlusWaveSpawnTime

};

public class PlayerUpgrde : MonoBehaviour
{
    [Header("업그레이 설정 값")]
    [SerializeField,LabelText("점프력 증가값")] float PlusJumpPower;
    [SerializeField,LabelText("이동속도 증가값")] public float PlusMoveSpeed;
    [SerializeField,LabelText("에테르 시간 증가값")] public float PlusEtherTimeUp;

    [Header("업그레이드 창 설정")]
    [SerializeField,LabelText("플레이어 업그레이드 창")] public GameObject PlayerWindow;
    [SerializeField,LabelText("타이틀 텍스쳐")] private TMP_Text TitleText;
    [SerializeField,LabelText("가지고 있는재료 텍스쳐")] private TMP_Text Have_IntText;
    [SerializeField,LabelText("필요한 재료 텍스쳐")] private TMP_Text Need_IntText;
    [SerializeField,LabelText("업글 전 수치")] private TMP_Text BeforeText;
    private int BeforeUpgrade;
    [SerializeField,LabelText("업글 후 수치")] private TMP_Text AfterText;
    private float AfterUpgrade;
    [SerializeField,LabelText("이동속도 아이콘")] private GameObject Speed_ICON;
    [SerializeField,LabelText("점프 아이콘")] private GameObject Jump_ICON;
    [SerializeField,LabelText("에테르 아이콘")] private GameObject Ether_ICON;
    [SerializeField,LabelText("플레이어 업그레이드 소비아이템")]ItemData Playeritem;
    [SerializeField,LabelText("아이템 소비 초기 값")] private int NeedUseItem;
    [SerializeField,LabelText("아이템 소비 증가 값")] private int UseItemCount;

    [SerializeField,LabelText("부스터 업글 횟수 제한")] private PlayerUpLimt UpSpeed_CountLimit = new PlayerUpLimt{PlayermaxCount = 5};
    [SerializeField,LabelText("점프 업글횟수 제한")] private PlayerUpLimt UpJump_CountLimit= new PlayerUpLimt{PlayermaxCount = 5};
    [SerializeField,LabelText("가속도 업글 횟수 제한")] private PlayerUpLimt Ether_CountLimit= new PlayerUpLimt{PlayermaxCount = 5};

    [SerializeField,LabelText("업글제한 점프 메세지 게임")] private GameObject LimitObject;
    [SerializeField,LabelText("필요강화 재료 오브젝트")] private GameObject ItemTitleObj;
    [SerializeField,LabelText("업글 종류 텍스쳐")] private TMP_Text UpTypeText;

    [SerializeField, LabelText("텍스트 : 이동속도 업그레이드")] private LocalizedString TXT_movespeed;
    [SerializeField, LabelText("텍스트 : 점프 업그레이드")] private LocalizedString TXT_PlayerJump;
    [SerializeField, LabelText("텍스트 : 에테르 업그레이드")] private LocalizedString TXT_Ether;

    private int HaveItem;

    private bool CanUpgrade = true; // 업그레이드 가능 여부
    private Coroutine blinkCoroutine;
    private PlayerUpgedeType playerUpgedeType;
    private PlayerCore Player;
    private EtherSystem etherSystem;


    // Start is called before the first frame update
    void Start()
    {
        Player = FindObjectOfType<PlayerCore>();
        etherSystem = FindObjectOfType<EtherSystem>();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        SetItemCountText();
        PlayerUgradeView();
    }



    private void SetItemCountText()
    {
        //현재 보유한 아이템 표시
        HaveItem = PlayerInventoryContainer.Instance.InventoryData.ContainsKey(Playeritem) ?
        PlayerInventoryContainer.Instance.InventoryData[Playeritem] : 0;
        Have_IntText.text = HaveItem.ToString();
    }

    private void PlayerUgradeView()
    {
        switch(playerUpgedeType)
        {
            case PlayerUpgedeType.PlusPlayerJump:
            UpdateView(Player.ViewJumpPower, PlusJumpPower);
            break;
            case PlayerUpgedeType.PlusPlayerMoveSpeed:
            UpdateView(Player.ViewMoveSpeed, PlusMoveSpeed);
            break;
            case PlayerUpgedeType.PlusWaveSpawnTime:
            UpdateView(etherSystem.ViewDeletTime, PlusEtherTimeUp);
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
    private void UpGrade()
    {
        if (!CanUpgrade) return;
        Player = PlayerCore.Instance;

        if(!GetCurrentCanUpgradeStatus())return;

        if (!PlayerInventoryContainer.Instance.RemoveItem(Playeritem, NeedUseItem))
        {
            StartBlinkingText(Have_IntText);
            return;
        }

        switch (playerUpgedeType)
        {
            case PlayerUpgedeType.PlusPlayerJump:
                TryUpgrade(ref UpJump_CountLimit, PlayerCore.AbilityAttribute.JumpPower, PlusJumpPower);
                break;
            case PlayerUpgedeType.PlusPlayerMoveSpeed:
                TryUpgrade(ref UpSpeed_CountLimit, PlayerCore.AbilityAttribute.MoveSpeed, PlusMoveSpeed);
                break;
            case PlayerUpgedeType.PlusWaveSpawnTime:
                TryToEtherUpgrade(ref Ether_CountLimit,PlusEtherTimeUp);
                
                break;
        }

    }

    private bool GetCurrentCanUpgradeStatus()
    {
        switch (playerUpgedeType)
        {
            case PlayerUpgedeType.PlusPlayerJump:
                return UpJump_CountLimit.PlayerCanUpgrade();
            case PlayerUpgedeType.PlusPlayerMoveSpeed:
                return UpSpeed_CountLimit.PlayerCanUpgrade();
            case PlayerUpgedeType.PlusWaveSpawnTime:
                return Ether_CountLimit.PlayerCanUpgrade();
            default:
                return false;
        }
    }

    private void TryUpgrade(ref PlayerUpLimt limit, PlayerCore.AbilityAttribute attribute, float upgradeValue)
    {
        if (limit.PlayerCanUpgrade())
        {
            Player.PlayerUpgradeState(attribute, upgradeValue);
            limit.PlayercurrentCount++;
            NeedUseItem += UseItemCount;
            OffLimitUpgradeObj();  // 강화 가능 상태 유지

            if(!GetCurrentCanUpgradeStatus())
            {
                if(NeedUseItem > UseItemCount)
                LimitUpgradeObj();
            }
            
        }
    }

    private void TryToEtherUpgrade(ref PlayerUpLimt limit, float upgradeValue)
    {
        if (limit.PlayerCanUpgrade())
        {
            etherSystem.EtherUpgradeState(upgradeValue);
            limit.PlayercurrentCount++;
            NeedUseItem += UseItemCount;
            OffLimitUpgradeObj();
            if(!GetCurrentCanUpgradeStatus())
            {
                if(NeedUseItem > UseItemCount)
                LimitUpgradeObj();
            }
        }
    }

    private void LimitUpgradeObj()
    {
    
        LimitObject.SetActive(true);
        ItemTitleObj.SetActive(false);
    }

    private void OffLimitUpgradeObj()
    {
        LimitObject.SetActive(false);
        ItemTitleObj.SetActive(true);
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

    public void ButtonTypeJump()
    {
        PlayerWindow.SetActive(true);
        Jump_ICON.SetActive(true);
        Speed_ICON.SetActive(false);
        Ether_ICON.SetActive(false);
        UpTypeText.text = TXT_PlayerJump.GetLocalizedString();
        playerUpgedeType = PlayerUpgedeType.PlusPlayerJump;
    }

    public void ButtonTypeSpeed()
    {
        PlayerWindow.SetActive(true);
        Speed_ICON.SetActive(true);
        Jump_ICON.SetActive(false);
        Ether_ICON.SetActive(false);
        UpTypeText.text = TXT_movespeed.GetLocalizedString();
        playerUpgedeType = PlayerUpgedeType.PlusPlayerMoveSpeed;
    }

    public void ButtonTypeEther()
    {
        PlayerWindow.SetActive(true);
        Ether_ICON.SetActive(true);
        Speed_ICON.SetActive(false);
        Jump_ICON.SetActive(false);
        UpTypeText.text = TXT_Ether.GetLocalizedString();
        playerUpgedeType = PlayerUpgedeType.PlusWaveSpawnTime;
    }

    private void GetAskUpgrade()
    {
        Need_IntText.text = NeedUseItem.ToString();
        UpGrade();
    }

    private void Outupgrade()
    {
        PlayerWindow.SetActive(false);
        Jump_ICON.SetActive(false);
        Speed_ICON.SetActive(false);
        Ether_ICON.SetActive(false);
    }

}
