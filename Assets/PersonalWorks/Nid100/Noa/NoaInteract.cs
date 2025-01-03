using Cinemachine;
using FMODUnity;
using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class NoaInteract : Interactable_Base
{
    [SerializeField, LabelText("플레이어 시선 유도")] private bool interestPlayer = true;            // true일 시 플레이어가 가까이 다가가면 해당 오브젝트를 바라봅니다.
    [SerializeField, LabelText("일회성")] private bool disableAfterInteracted = false;   // true일 시 한 번만 재생됩니다.
    [SerializeField, LabelText("시선 고정 지점")] private Transform interestPoint;
    [SerializeField, LabelText("상호작용 시 사운드")] private EventReference sound_interact;
    [SerializeField, LabelText("상호작용 시 이벤트")] protected UnityEvent eventsOnStartInteract;    // Interact 됐을 때 호출되는 UnityEvent입니다
    [SerializeField, LabelText("시작할 시퀀스")] private SequenceBundleAsset sequenceAsset;     // Interact 됐을 때 시작하는 시퀀스 입니다.
    [SerializeField, LabelText("대화 시 카메라(선택)")] private CinemachineVirtualCamera virtualCamera;
    [SerializeField, LabelText("노아 UI")] private GameObject noahUI;
    [SerializeField, LabelText("노아 UI")] private GameObject playUI;
    public override void Interact()
    {
        if (eventsOnStartInteract != null)
        {
            eventsOnStartInteract.Invoke();
        }

        if (!sound_interact.IsNull) RuntimeManager.PlayOneShot(sound_interact);

        if (SequenceInvoker.Instance == null) { Debug.LogWarning("SequenceInvoker가 없습니다."); return; }
        if (sequenceAsset != null)
        {
            SequenceInvoker.Instance.StartSequence(sequenceAsset.SequenceBundles);
            if (virtualCamera != null)
                SequenceInvoker.Instance.SetSequenceCamera(virtualCamera);
        }

        if (interestPlayer) FindObjectOfType<PlayerCore>().SetInterestPoint(interestPoint);
        if (disableAfterInteracted) { this.enabled = false; GetComponent<Collider>().enabled = false; }

    }

    public void NoahUIOn()
    {
        noahUI.SetActive(true);
        playUI.SetActive(true);
    }
    public void NoahUIOff()
    {
        noahUI.SetActive(false);
        playUI.SetActive(false);
    }
}
