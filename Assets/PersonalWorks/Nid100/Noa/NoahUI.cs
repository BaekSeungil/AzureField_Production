using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.Localization;
using Sirenix.OdinInspector;

// 플레이어 업그레이드 횟수 제한을 나타내는 구조체
public struct PlayerUpgradeLimit
{
    public int CurrentCount;   // 현재 업그레이드 횟수
    public int MaxCount;       // 최대 업그레이드 횟수

    // 업그레이드 가능한지 여부를 반환하는 함수
    public bool CanUpgrade() => CurrentCount < MaxCount;
}

// 플레이어 업그레이드의 종류를 정의하는 열거형
public enum PlayerUpgradeType
{
    JumpPower,     // 점프력
    MoveSpeed,     // 이동 속도
    EtherTime      // 에테르 지속 시간
}

public class NoahUI : MonoBehaviour
{
    [Header("업그레이드 설정 값")]
    [SerializeField, LabelText("점프력 증가값")] private float jumpIncrease;       // 점프력 증가 값
    [SerializeField, LabelText("이동속도 증가값")] private float speedIncrease;    // 이동 속도 증가 값
    [SerializeField, LabelText("에테르 시간 증가값")] private float etherTimeIncrease;  // 에테르 시간 증가 값

    [Header("업그레이드 UI 설정")]
    [SerializeField, LabelText("업그레이드 창")] private GameObject upgradeWindow;   // 업그레이드 UI 창
    [SerializeField, LabelText("타이틀 텍스트")] private TMP_Text titleText;          // 업그레이드 창의 타이틀 텍스트
    [SerializeField, LabelText("보유 아이템 텍스트")] private TMP_Text currentItemText; // 현재 보유한 아이템 수 텍스트
    [SerializeField, LabelText("필요 아이템 텍스트")] private TMP_Text requiredItemText; // 필요한 아이템 수 텍스트
    [SerializeField, LabelText("업글 전 수치")] private TMP_Text beforeValueText;     // 업그레이드 전 수치 텍스트
    [SerializeField, LabelText("업글 후 수치")] private TMP_Text afterValueText;      // 업그레이드 후 수치 텍스트

    [SerializeField, LabelText("필요 아이템 아이콘")] private GameObject itemIcon;      // 이동속도 아이콘
    [SerializeField, LabelText("이동속도 아이콘")] private GameObject speedIcon;      // 이동속도 아이콘
    [SerializeField, LabelText("점프 아이콘")] private GameObject jumpIcon;           // 점프 아이콘
    [SerializeField, LabelText("에테르 아이콘")] private GameObject etherIcon;         // 에테르 아이콘

    [SerializeField, LabelText("소비 아이템")] private ItemData requiredItem;          // 업그레이드에 필요한 아이템 데이터
    [SerializeField, LabelText("기본 소비 아이템 수")] private int baseItemCost;       // 기본적으로 필요한 아이템 수
    [SerializeField, LabelText("소비 아이템 증가 수")] private int itemCostIncrement;  // 업그레이드할 때마다 증가하는 아이템 수

    // 각 업그레이드 종류별로 횟수 제한을 설정
    [SerializeField, LabelText("이동속도 업글 제한")] private PlayerUpgradeLimit speedLimit = new PlayerUpgradeLimit { MaxCount = 5 };
    [SerializeField, LabelText("점프 업글 제한")] private PlayerUpgradeLimit jumpLimit = new PlayerUpgradeLimit { MaxCount = 5 };
    [SerializeField, LabelText("에테르 업글 제한")] private PlayerUpgradeLimit etherLimit = new PlayerUpgradeLimit { MaxCount = 5 };

    [SerializeField, LabelText("업글 제한 메시지")] private GameObject limitMessage;    // 업그레이드 제한 메시지 UI
    [SerializeField, LabelText("아이템 요구 메시지")] private GameObject itemTitle;     // 아이템 요구 메시지 UI
    [SerializeField, LabelText("업글 종류 텍스트")] private TMP_Text upgradeTypeText;   // 업그레이드 종류 텍스트

    // 업그레이드 종류별 텍스트 (지역화된 문자열)
    [SerializeField, LabelText("이동속도 업글 텍스트")] private LocalizedString speedUpgradeText;
    [SerializeField, LabelText("점프 업글 텍스트")] private LocalizedString jumpUpgradeText;
    [SerializeField, LabelText("에테르 업글 텍스트")] private LocalizedString etherUpgradeText;

    private int currentItemCount;      // 현재 보유한 아이템 수
    private int requiredItemCount;     // 업그레이드에 필요한 아이템 수

    private bool canUpgrade = true;    // 업그레이드 가능 여부
    private Coroutine blinkCoroutine;  // 깜빡이는 텍스트 코루틴
    private PlayerUpgradeType currentUpgradeType;  // 현재 선택된 업그레이드 타입

    private PlayerCore player;        // 플레이어 데이터 접근
    private EtherSystem etherSystem;  // 에테르 시스템 접근

    // 시작 시 호출되는 함수
    void Start()
    {
        // PlayerCore와 EtherSystem 오브젝트를 찾아서 할당
        player = FindObjectOfType<PlayerCore>();
        etherSystem = FindObjectOfType<EtherSystem>();
        UpdateItemCount();  // 아이템 수 업데이트
    }

    // 매 프레임마다 호출되는 함수 (FixedUpdate는 물리 연산에 자주 사용됨)
    void FixedUpdate()
    {
        UpdateItemCount();  // 보유한 아이템 수를 업데이트
        UpdateUpgradeUI();  // 업그레이드 UI를 업데이트
    }

    // 현재 보유한 아이템 수를 업데이트
    private void UpdateItemCount()
    {
        currentItemCount = PlayerInventoryContainer.Instance.InventoryData.ContainsKey(requiredItem) ?
            PlayerInventoryContainer.Instance.InventoryData[requiredItem] : 0;

        currentItemText.text = currentItemCount.ToString();  // UI에 아이템 수 표시
    }

    // 업그레이드 UI를 업데이트
    private void UpdateUpgradeUI()
    {
        // 현재 선택된 업그레이드 타입에 따라 수치 업데이트
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

        // 업그레이드 가능한지 여부에 따라 제한 메시지를 보여줌
        if (!CanCurrentUpgradeProceed())
        {
            ShowLimitMessage();  // 제한 메시지 표시
        }
        else
        {
            HideLimitMessage();  // 제한 메시지 숨김
        }
    }

    // 현재 값과 업그레이드 후 값을 UI에 표시
    private void UpdateView(float currentValue, float increaseValue)
    {
        beforeValueText.text = currentValue.ToString("F1");         // 현재 값 표시
        afterValueText.text = (currentValue + increaseValue).ToString("F1");  // 업그레이드 후 값 표시
    }

    // 업그레이드 시작
    public void StartUpgrade()
    {
        // 업그레이드 가능 여부 체크
        if (!canUpgrade || !CanCurrentUpgradeProceed()) return;

        // 아이템을 소비할 수 있는지 체크
        if (!PlayerInventoryContainer.Instance.RemoveItem(requiredItem, requiredItemCount))
        {
            StartBlinkingText(currentItemText);  // 보유한 아이템 수 부족 시 텍스트 깜빡임
            return;
        }

        ApplyUpgrade();  // 업그레이드 적용
        requiredItemCount += itemCostIncrement;  // 업그레이드할 때마다 필요한 아이템 수 증가
    }

    // 업그레이드 적용 함수
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

    // 현재 업그레이드 가능한지 여부를 반환
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

    // 플레이어 속성에 대해 업그레이드 실행
    private void ExecuteUpgrade(ref PlayerUpgradeLimit limit, PlayerCore.AbilityAttribute attribute, float increaseValue)
    {
        if (!limit.CanUpgrade()) return;

        player.PlayerUpgradeState(attribute, increaseValue);  // 플레이어 속성 업그레이드 적용
        limit.CurrentCount++;  // 업그레이드 횟수 증가
    }

    // 에테르 시간 업그레이드 실행
    private void ExecuteUpgrade(ref PlayerUpgradeLimit limit, float increaseValue)
    {
        if (!limit.CanUpgrade()) return;

        etherSystem.EtherUpgradeState(increaseValue);  // 에테르 시스템 업그레이드 적용
        limit.CurrentCount++;  // 업그레이드 횟수 증가
    }

    // 업그레이드 제한 메시지 표시
    private void ShowLimitMessage()
    {
        limitMessage.SetActive(true);
        itemTitle.SetActive(false);
    }

    // 업그레이드 제한 메시지 숨김
    private void HideLimitMessage()
    {
        limitMessage.SetActive(false);
        itemTitle.SetActive(true);
    }

    // 텍스트 깜빡임 코루틴 시작
    private void StartBlinkingText(TMP_Text text)
    {
        if (blinkCoroutine != null) StopCoroutine(blinkCoroutine);
        blinkCoroutine = StartCoroutine(BlinkText(text));
    }

    // 텍스트를 빨간색으로 깜빡이게 하는 코루틴
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

    // 업그레이드 타입 설정
    public void SetUpgradeType(PlayerUpgradeType type)
    {
        currentUpgradeType = type;
        upgradeWindow.SetActive(true);

        // 업그레이드 종류에 따라 아이콘과 텍스트 설정
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

    // 업그레이드 창 닫기
    public void CloseUpgradeWindow()
    {
        upgradeWindow.SetActive(false);
    }
}
