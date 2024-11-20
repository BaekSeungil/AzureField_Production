using FMODUnity;
using Sirenix.OdinInspector;
using System.Collections;
using UnityEngine;

public class RingbellInteract : MonoBehaviour
{
    [SerializeField] private Animator bellAnimator;
    [SerializeField, Required(InfoMessageType.Warning)] private Animator lampAnimatior;
    [SerializeField] private ParticleSystem particle;
    [SerializeField] private StudioEventEmitter sound;

    [SerializeField,Required(InfoMessageType.Warning)] private RingbellSystem ringbellSystem;
    // 본인의 번호
    [SerializeField] private int myNumber;
    // 본인의 활성화 여부
    public bool onoff = false;
    // 해당 오브젝트가 활성화/비활성화 될 경우 영향을 줄 오브젝트 번호
    public int[] connectionNumber;

    // 쿨다운 시간 (5초)
    private float cooldownTime = 5.0f;
    // 현재 쿨다운이 활성화 중인지 여부
    private bool isInCooldown = false;

    // Start is called before the first frame update
    void Start()
    {
        // 초기화 시 머테리얼 설정
        UpdateStoneStatus();
    }

    // Update is called once per frame
    void Update()
    {

    }

    // 충돌 처리
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "WaterReaction" && !isInCooldown)
        {
            if (ringbellSystem.IsOnceActived) return;

            // 연결된 종의 활성화/비활성화 함수 호출
            ringbellSystem.connectionBellActive(myNumber);
            Debug.Log(myNumber + "번 종 활성화");

            // 종 활성화 상태에 따른 머테리얼 업데이트
            UpdateStoneStatus();

            StopAllCoroutines();
            // 쿨다운 시작
            StartCoroutine(StartCooldown());
        }
    }

    // onoff 상태에 따라 stone 오브젝트의 머테리얼을 업데이트하는 함수
    public void UpdateStoneStatus()
    {
        if (onoff)
        {
            lampAnimatior.SetBool("Litup", true);
            sound.Play();
            particle.Play();
        }
        else
        {
            lampAnimatior.SetBool("Litup", false);
        }
    }

    // 쿨다운을 처리하는 코루틴
    private IEnumerator StartCooldown()
    {
        // 쿨다운 활성화
        isInCooldown = true;
        // 5초 동안 대기
        yield return new WaitForSeconds(cooldownTime);
        // 쿨다운 비활성화
        isInCooldown = false;
    }
}
