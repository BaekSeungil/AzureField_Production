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
    PlayerJump,
    PlayerMoveSpeed,
    WaveSpawnTime

};

public class PlayerUpgrde : MonoBehaviour
{
    [Header("업그레이 설정 값")]
    [SerializeField,LabelText("점프력 증가값")] float PlusJumpPower;
    [SerializeField,LabelText("이동속도 증가값")] public float PlusMoveSpeed;
    [SerializeField,LabelText("에테르 시간 증가값")] public float EtherTimeUp;

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
    void Update()
    {
        
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
        
    }
}
