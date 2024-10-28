using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.Localization;
using Sirenix.OdinInspector;

public struct PlayerUpgradeLimit
{
    public int CurrentCount;
    public int MaxCount;

    public bool CanUpgrade() => CurrentCount < MaxCount;
}

public enum PlayerUpgradeType
{
    JumpPower,
    MoveSpeed,
    EtherTime
}

public class NoahUI : MonoBehaviour
{
    [Header("업그레이드 설정 값")]
    [SerializeField, LabelText("점프력 증가값")] private float jumpIncrease;
    [SerializeField, LabelText("이동속도 증가값")] private float speedIncrease;
    [SerializeField, LabelText("에테르 시간 증가값")] private float etherTimeIncrease;

    [Header("업그레이드 UI 설정")]
    [SerializeField, LabelText("업그레이드 창")] private GameObject upgradeWindow;
    [SerializeField, LabelText("타이틀 텍스트")] private TMP_Text titleText;
    [SerializeField, LabelText("보유 아이템 텍스트")] private TMP_Text currentItemText;
    [SerializeField, LabelText("필요 아이템 텍스트")] private TMP_Text requiredItemText;
    [SerializeField, LabelText("업글 전 수치")] private TMP_Text beforeValueText;
    [SerializeField, LabelText("업글 후 수치")] private TMP_Text afterValueText;

    [SerializeField, LabelText("이동속도 아이콘")] private GameObject speedIcon;
    [SerializeField, LabelText("점프 아이콘")] private GameObject jumpIcon;
    [SerializeField, LabelText("에테르 아이콘")] private GameObject etherIcon;

    [SerializeField, LabelText("소비 아이템")] private ItemData requiredItem;
    [SerializeField, LabelText("기본 소비 아이템 수")] private int baseItemCost;
    [SerializeField, LabelText("소비 아이템 증가 수")] private int itemCostIncrement;

    [SerializeField, LabelText("이동속도 업글 제한")] private PlayerUpgradeLimit speedLimit = new PlayerUpgradeLimit { MaxCount = 5 };
    [SerializeField, LabelText("점프 업글 제한")] private PlayerUpgradeLimit jumpLimit = new PlayerUpgradeLimit { MaxCount = 5 };
    [SerializeField, LabelText("에테르 업글 제한")] private PlayerUpgradeLimit etherLimit = new PlayerUpgradeLimit { MaxCount = 5 };

    [SerializeField, LabelText("업글 제한 메시지")] private GameObject limitMessage;
    [SerializeField, LabelText("아이템 요구 메시지")] private GameObject itemTitle;
    [SerializeField, LabelText("업글 종류 텍스트")] private TMP_Text upgradeTypeText;

    [SerializeField, LabelText("이동속도 업글 텍스트")] private LocalizedString speedUpgradeText;
    [SerializeField, LabelText("점프 업글 텍스트")] private LocalizedString jumpUpgradeText;
    [SerializeField, LabelText("에테르 업글 텍스트")] private LocalizedString etherUpgradeText;

    private int currentItemCount;
    private int requiredItemCount;

    private bool canUpgrade = true;
    private Coroutine blinkCoroutine;
    private PlayerUpgradeType currentUpgradeType;

    private PlayerCore player;
    private EtherSystem etherSystem;

    void Start()
    {
        player = FindObjectOfType<PlayerCore>();
        etherSystem = FindObjectOfType<EtherSystem>();
        UpdateItemCount();
    }

    void FixedUpdate()
    {
        UpdateItemCount();
        UpdateUpgradeUI();
    }

    private void UpdateItemCount()
    {
        // 보유한 아이템 수를 업데이트
        currentItemCount = PlayerInventoryContainer.Instance.InventoryData.ContainsKey(requiredItem) ?
            PlayerInventoryContainer.Instance.InventoryData[requiredItem] : 0;

        currentItemText.text = currentItemCount.ToString();
    }

    private void UpdateUpgradeUI()
    {
        switch (currentUpgradeType)
        {
            case PlayerUpgradeType.JumpPower:
                UpdateView(player.ViewJumpPower, jumpIncrease);
                break;
            case PlayerUpgradeType.MoveSpeed:
                UpdateView(player.ViewMoveSpeed, speedIncrease);
                break;
            case PlayerUpgradeType.EtherTime:
                UpdateView(etherSystem.ViewDeletTime, etherTimeIncrease);
                break;
        }

        if (!CanCurrentUpgradeProceed())
        {
            ShowLimitMessage();
        }
        else
        {
            HideLimitMessage();
        }
    }

    private void UpdateView(float currentValue, float increaseValue)
    {
        beforeValueText.text = currentValue.ToString("F1");
        afterValueText.text = (currentValue + increaseValue).ToString("F1");
    }

    public void StartUpgrade()
    {
        if (!canUpgrade || !CanCurrentUpgradeProceed()) return;

        if (!PlayerInventoryContainer.Instance.RemoveItem(requiredItem, requiredItemCount))
        {
            StartBlinkingText(currentItemText);
            return;
        }

        ApplyUpgrade();
        requiredItemCount += itemCostIncrement;
    }

    private void ApplyUpgrade()
    {
        switch (currentUpgradeType)
        {
            case PlayerUpgradeType.JumpPower:
                ExecuteUpgrade(ref jumpLimit, PlayerCore.AbilityAttribute.JumpPower, jumpIncrease);
                break;
            case PlayerUpgradeType.MoveSpeed:
                ExecuteUpgrade(ref speedLimit, PlayerCore.AbilityAttribute.MoveSpeed, speedIncrease);
                break;
            case PlayerUpgradeType.EtherTime:
                ExecuteUpgrade(ref etherLimit, etherTimeIncrease);
                break;
        }
    }

    private bool CanCurrentUpgradeProceed()
    {
        return currentUpgradeType switch
        {
            PlayerUpgradeType.JumpPower => jumpLimit.CanUpgrade(),
            PlayerUpgradeType.MoveSpeed => speedLimit.CanUpgrade(),
            PlayerUpgradeType.EtherTime => etherLimit.CanUpgrade(),
            _ => false,
        };
    }

    private void ExecuteUpgrade(ref PlayerUpgradeLimit limit, PlayerCore.AbilityAttribute attribute, float increaseValue)
    {
        if (!limit.CanUpgrade()) return;

        player.PlayerUpgradeState(attribute, increaseValue);
        limit.CurrentCount++;
    }

    private void ExecuteUpgrade(ref PlayerUpgradeLimit limit, float increaseValue)
    {
        if (!limit.CanUpgrade()) return;

        etherSystem.EtherUpgradeState(increaseValue);
        limit.CurrentCount++;
    }

    private void ShowLimitMessage()
    {
        limitMessage.SetActive(true);
        itemTitle.SetActive(false);
    }

    private void HideLimitMessage()
    {
        limitMessage.SetActive(false);
        itemTitle.SetActive(true);
    }

    private void StartBlinkingText(TMP_Text text)
    {
        if (blinkCoroutine != null) StopCoroutine(blinkCoroutine);
        blinkCoroutine = StartCoroutine(BlinkText(text));
    }

    private IEnumerator BlinkText(TMP_Text text)
    {
        Color originalColor = text.color;
        Color blinkColor = Color.red;

        for (int i = 0; i < 4; i++)
        {
            text.color = blinkColor;
            yield return new WaitForSeconds(0.25f);
            text.color = originalColor;
            yield return new WaitForSeconds(0.25f);
        }
    }

    public void SetUpgradeType(PlayerUpgradeType type)
    {
        currentUpgradeType = type;
        upgradeWindow.SetActive(true);

        jumpIcon.SetActive(type == PlayerUpgradeType.JumpPower);
        speedIcon.SetActive(type == PlayerUpgradeType.MoveSpeed);
        etherIcon.SetActive(type == PlayerUpgradeType.EtherTime);

        upgradeTypeText.text = type switch
        {
            PlayerUpgradeType.JumpPower => jumpUpgradeText.GetLocalizedString(),
            PlayerUpgradeType.MoveSpeed => speedUpgradeText.GetLocalizedString(),
            PlayerUpgradeType.EtherTime => etherUpgradeText.GetLocalizedString(),
            _ => ""
        };
    }

    public void CloseUpgradeWindow()
    {
        upgradeWindow.SetActive(false);
    }
}
