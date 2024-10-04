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
    [SerializeField,LabelText("플레이어 업그레이드 창")] public GameObject Upwindow;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
