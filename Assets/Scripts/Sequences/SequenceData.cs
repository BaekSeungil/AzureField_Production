using Sirenix.OdinInspector;
using System.Collections;
using UnityEngine;
using UnityEngine.Localization;
using UnityEngine.Playables;
using UnityEngine.Timeline;

//===============================
//
// 시퀀스번들의 정보를 나타내는 스크립트입니다.
// 시퀀스 : 게임플레이 중 대사, 이벤트, 타임라인 같은 것들을 코루틴을 이용해 연속적으로 순서대로 재생할 수 있도록 합니다.
// Sequence_Base를 상속한 자식 클래스를 만들고 IEnumerator Sequence(SequenceInvoker invoker)를 오버라이드 하여 여러 유형의 시퀀스 내용들을 정의할 수 있습니다.
//
// 시퀀스번들의 정보는 SequenceBundleAsset 스크립터블오브젝트 파일을 생성하여 작성할 수 있습니다.
// 만들어진 시퀀스번들에셋은 SequenceInvoker 인스턴스를 통해 재생할 수 있습니다. 해당 스크립트를 참고하세요.
//
//===============================

[CreateAssetMenu(fileName = "NewSequenceData", menuName = "CreateNewSequenceBundleAsset", order = 1)]
public class SequenceBundleAsset : SerializedScriptableObject
{
    public Sequence_Base[] sequenceBundles;
}

public class Sequence_Base 
{
    public virtual IEnumerator Sequence(SequenceInvoker invoker) { yield return null; }
}

/// <summary>
/// 아무것도 하지 않고 time만큼 기다립니다.
/// </summary>
[System.Serializable]
public class Sequence_WaitForSeconds : Sequence_Base
{
    public float time;      // 다음으로 넘어갈때까지의 시간

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        yield return new WaitForSeconds(time);
    }
}

/// <summary>
/// 대사창을 열고 dialogues의 대사 데이터들을 순서대로 출력합니다.
/// </summary>
[System.Serializable]
public class Sequence_Dialogue : Sequence_Base
{
    public DialogueData[] dialogues;                    // 대사 데이터들
    public bool CloseDialogueAfterFinish = true;        // true일 시 대사창이 모두 재생되면 대사창 UI를 닫습니다.

    public override IEnumerator Sequence(SequenceInvoker invoker) 
    {
        if (invoker.Dialogue == null)
        { Debug.Log("Dialogue UI 인스턴스가 없습니다!"); yield break; }
        yield return invoker.Dialogue.StartCoroutine(invoker.Dialogue.Cor_DialogueSequence(dialogues));
        if(CloseDialogueAfterFinish)
        {
            yield return invoker.Dialogue.StartCoroutine(invoker.Dialogue.Cor_CloseDialogue());
        }
    }
}

/// <summary>
/// 대사창이 닫히지 않은 상태라면 대사창을 닫습니다.
/// </summary>
[System.Serializable]
public class Sequence_CloseDialogue : Sequence_Base
{
    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        yield return invoker.Dialogue.StartCoroutine(invoker.Dialogue.Cor_CloseDialogue());
    }
}

/// <summary>
/// 대사창이 활성화 되어있는 도중 플레이어가 선택할 수 있는 창을 만듭니다.
/// </summary>
[System.Serializable]
public class Sequence_DialogueBranch : Sequence_Base
{
    public LocalizedString[] branchAnswers;
    public SequenceBundleAsset[] sequenceAssets;

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        if(branchAnswers.Length != sequenceAssets.Length) { Debug.LogError("Invalid branches-sequenceAssets Length."); yield break; }

        int index = 0;
        yield return invoker.Dialogue.StartCoroutine(invoker.Dialogue.Cor_Branch(branchAnswers, (value) => { index = value; }));

        yield return invoker.StartCoroutine(invoker.Cor_RecurciveSequenceChain(sequenceAssets[index].sequenceBundles));
    }
}

/// <summary>
/// 타임라인을 재생합니다.
/// </summary>
[System.Serializable]
public class Sequence_Timeline : Sequence_Base
{
    public TimelineAsset timeline;

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        PlayableDirector playable = invoker.Playable;
        playable.Play(timeline);
        yield return new WaitUntil(() => playable.time >= playable.duration);
    }
}

/// <summary>
/// 조개를 amount 만큼 지급합니다.
/// </summary>
[System.Serializable]
public class Sequence_GainMoney : Sequence_Base
{
    public int amount;

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        if (invoker.InventoryContainer == null) { Debug.LogError("PlayerInvnentoryContainer를 찾을 수 없습니다."); yield break; }
        invoker.InventoryContainer.AddMoney(amount);
        yield return null;
    }
    
}

/// <summary>
/// 아이템을 인벤토리에 추가합니다.
/// </summary>
[System.Serializable]
public class Sequence_ObtainItem : Sequence_Base
{
    public ItemData item;
    public int quantity = 1;

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        invoker.InventoryContainer.AddItem(item, quantity);
        yield return invoker.StartCoroutine(invoker.InventoryContainer.Cor_ItemWindow(item, quantity));
    }
}