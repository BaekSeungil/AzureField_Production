using FMODUnity;
using InteractSystem;
using Sirenix.OdinInspector;
using System.Collections;
using UnityEngine;

public class RingbellInteract : MonoBehaviour, IInteract
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
        UpdateStoneStatus();
    }

    // 충돌 처리
    private void OnBellRinged()
    {
        if (ringbellSystem.IsOnceActived) return;
        if (isInCooldown) return;

        // 연결된 종의 활성화/비활성화 함수 호출
        ringbellSystem.connectionBellActive(myNumber);

        bellAnimator.Play("BellBody");
        sound.Play();
        particle.Play();

        UpdateStoneStatus();

        StopAllCoroutines();
        StartCoroutine(StartCooldown());

    }

    // onoff 상태에 따라 stone 오브젝트의 머테리얼을 업데이트하는 함수
    public void UpdateStoneStatus()
    {
        if (onoff)
        {
            lampAnimatior.SetBool("Litup", true);
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

    public void Interact()
    {
        OnBellRinged();
    }
}
