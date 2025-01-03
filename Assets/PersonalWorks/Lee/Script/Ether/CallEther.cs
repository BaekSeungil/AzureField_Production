using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class CallEther : MonoBehaviour
{
    public enum EEtherCount
    {
        ETHERSPAWN,
        ETHERMOVE,
        ETHEREND,
    }

    MainPlayerInputActions inputActions;
    EtherSystem etherSystem;

    //[SerializeField,LabelText("파도 스폰 위치")] public GameObject Spawn;
    [LabelText("파도 스폰 위치")]public Vector3 SpawnPoint;
    [LabelText("에테르프리펩")] public GameObject EtherWave;
    [SerializeField, LabelText("감지 반경")] private float detectionRadius = 5f;
    [LabelText("레이어 마스크 설정")] public LayerMask layerMask;

    private Collider[] hitColliders;
    private GameObject etherWave;

    public bool OnSpawn = false;
    public bool IsCreat = false;
    public float SearchRange;
    public LayerMask TargetMask;
    public EEtherCount EtherCount = EEtherCount.ETHERSPAWN; //에테르 입력 값 1번누르면 스폰, 2번누르면 에테르 정면이동
    private void Start()
    {
        Initialized();
    }

    // Update is called once per frame
    private void Update()
    {
        if(inputActions.Player.Ether.WasPressedThisFrame())
        {
            InteractWaves();
        }
    }

    private void InteractWaves()
    {
        hitColliders = Physics.OverlapSphere(SpawnPoint, detectionRadius, layerMask);

        // 감지된 오브젝트가 있다면 파도를 생성
        if (hitColliders.Length > 0 && !IsCreat)
        {
            SpawnWave();
        }
        // 파도가 이미 생성된 상태에서 다시 키를 누르면 파도를 이동시킵니다.
        else if (IsCreat && EtherCount == EEtherCount.ETHERSPAWN)
        {
            EtherCount = EEtherCount.ETHERMOVE;  // 상태를 2로 설정하여 이동 신호를 보냅니다.
            PrintDebug("파도 이동 신호 전송");
        }
        else if (IsCreat && EtherCount == EEtherCount.ETHERMOVE)
        {
            EtherCount = EEtherCount.ETHEREND;  // 상태를 2로 설정하여 이동 신호를 보냅니다.
            PrintDebug("파도 이동 신호 전송");
        }
    }

    private void SpawnWave()
    {
        // 스폰 위치를 결정하고 앞을 바라보게 함.
        etherWave.SetActive(true);
        IsCreat = true;
        EtherCount = EEtherCount.ETHERSPAWN;  // 상태를 1로 설정하여 생성된 상태로 표시합니다.
        PrintDebug("파도 생성 (범위 내에 객체 감지)");
        etherWave.GetComponent<EtherSystem>().Initialized(SearchRange, TargetMask);
    }

    private void Initialized()
    {
        etherSystem = FindObjectOfType<EtherSystem>();
        inputActions = new MainPlayerInputActions();
        inputActions.Player.Ether.Enable();

        if (SpawnPoint.magnitude == 0)
            SpawnPoint.z = 6.46f;

        etherWave = Instantiate(EtherWave, SpawnPoint, Quaternion.identity);
        etherWave.transform.position = transform.position + (transform.forward * SpawnPoint.z);
        etherWave.SetActive(false);
    }

    public bool isCarry;
    public float m_horizontalViewHalfAngle;
    public float HorizontalViewAngle;
    public float m_viewRotateZ;

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        if(transform != null)
            Gizmos.DrawWireSphere(transform.position + transform.forward * SpawnPoint.z, detectionRadius);  // 감지 반경을 시각화

        Gizmos.color = Color.blue;
        //Gizmos.DrawWireSphere(transform.position, SearchRange * 0.5f);

        if (!isCarry)
        {
            m_horizontalViewHalfAngle = HorizontalViewAngle * 0.5f;

            Vector3 originPos = transform.position;

            Gizmos.DrawWireSphere(originPos, SearchRange);

            Vector3 horizontalRightDir = AngleToDirY(transform.position, -m_horizontalViewHalfAngle + m_viewRotateZ);
            Vector3 horizontalLeftDir = AngleToDirY(transform.position, m_horizontalViewHalfAngle + m_viewRotateZ);
            Vector3 lookDir = AngleToDirY(transform.position, m_viewRotateZ);

            Debug.DrawRay(originPos, horizontalLeftDir * SearchRange, Color.cyan);
            Debug.DrawRay(originPos, lookDir * SearchRange, Color.green);
            Debug.DrawRay(originPos, horizontalRightDir * SearchRange, Color.cyan);
        }

        else
        {
            //m_horizontalViewHalfAngle = HorizontalViewAngle * 0.5f;

            //Vector3 originPos = transform.position;

            ////Gizmos.DrawWireSphere(originPos, throwRange);

            //Vector3 horizontalRightDir = AngleToDirY(PlayerCore.Instance.transform.position, -m_horizontalViewHalfAngle + m_viewRotateZ);
            //Vector3 horizontalLeftDir = AngleToDirY(PlayerCore.Instance.transform.position, m_horizontalViewHalfAngle + m_viewRotateZ);
            //Vector3 lookDir = AngleToDirY(PlayerCore.Instance.transform.position, m_viewRotateZ);

            //Debug.DrawRay(originPos, horizontalLeftDir * throwRange, Color.cyan);
            //Debug.DrawRay(originPos, lookDir * throwRange, Color.green);
            //Debug.DrawRay(originPos, horizontalRightDir * throwRange, Color.cyan);
        }
    }
    private Vector3 AngleToDirY(Vector3 pos, float angleInDegree)
    {
        float radian = (angleInDegree + pos.y) * Mathf.Deg2Rad;
        return new Vector3(Mathf.Sin(radian), 0f, Mathf.Cos(radian));

    }

    private void PrintDebug(string str)
    {
#if UNITY_EDITOR
        Debug.Log(str);
#endif
    }

}
