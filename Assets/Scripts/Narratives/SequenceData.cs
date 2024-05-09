using Sirenix.OdinInspector;
using System.Collections;
using UnityEditor.Timeline.Actions;
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

[CreateAssetMenu(fileName = "NewSequenceData", menuName = "새 시퀀스 번들 에셋 추가", order = 1)]
public class SequenceBundleAsset : SerializedScriptableObject
{
    public Sequence_Base[] SequenceBundles;
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
    [InfoBox("아무것도 하지 않고 time만큼 기다립니다.",InfoMessageType = InfoMessageType.None)]
    public float time;      // 기다리는 시간
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
    [InfoBox("대사창을 열고 dialogues의 대사 데이터들을 순서대로 출력합니다.", InfoMessageType = InfoMessageType.None)]
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
    [InfoBox("대사창이 닫히지 않은 상태라면 대사창을 닫습니다.", InfoMessageType = InfoMessageType.None)]
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
    [InfoBox("대사창이 활성화 되어있는 도중 플레이어가 선택할 수 있는 창을 만듭니다.", InfoMessageType = InfoMessageType.None)]
    public LocalizedString[] branchAnswers;                 // 선택할 수 있는 텍스트 (UI)
    public SequenceBundleAsset[] sequenceAssets;            // 선택지들에 대응되는 새롭게 시작할 시퀀스 에셋들

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        if(branchAnswers.Length != sequenceAssets.Length) { Debug.LogError("branchAnswers와 sequenceAssets의 개수는 같아야 합니다."); yield break; }

        int index = 0;
        yield return invoker.Dialogue.StartCoroutine(invoker.Dialogue.Cor_Branch(branchAnswers, (value) => { index = value; }));

        Debug.Log(sequenceAssets[index]);

        yield return invoker.StartCoroutine(invoker.Cor_RecurciveSequenceChain(sequenceAssets[index].SequenceBundles));
    }
}

/// <summary>
/// 타임라인을 재생합니다.
/// </summary>
[System.Serializable]
public class Sequence_Timeline : Sequence_Base
{
    [InfoBox("타임라인을 재생합니다.", InfoMessageType = InfoMessageType.None)]
    public TimelineAsset timeline;      // 실행할 타임라인 에셋

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        PlayableDirector playable = invoker.Playable;
        playable.Play(timeline);
        yield return new WaitUntil(() => playable.state != PlayState.Playing);
    }
}

/// <summary>
/// 조개를 amount 만큼 지급합니다.
/// </summary>
[System.Serializable]
public class Sequence_GainMoney : Sequence_Base
{
    [InfoBox("조개를 amount 만큼 지급합니다.", InfoMessageType = InfoMessageType.None)]
    public int amount;      // 획득할 조개 개수

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
    [InfoBox("아이템을 인벤토리에 추가합니다.", InfoMessageType = InfoMessageType.None)]
    public ItemData item;               // 획득할 아이템 데이터
    public int quantity = 1;            // 개수

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        invoker.InventoryContainer.AddItem(item, quantity);
        yield return invoker.StartCoroutine(invoker.InventoryContainer.Cor_ItemWindow(item, quantity));
    }
}

/// <summary>
/// 글로벌 값 목록에서 ID를 찾아 해당 값을 설정합니다. 
/// 새로운 글로벌 값 ID를 생성하고자 한다면, 
/// 프로젝트 파일에서 "Assets/ScriptableObjects/GlobalParamSettings"에 정보를 추가하고, 
/// 노션에서 "프로그래머문서/글로벌 값/값 리스트"에 해당 정보를 적어두고 사용하세요
/// </summary>
[System.Serializable]
public class Sequence_SetGlobalParameter : Sequence_Base
{
    [InfoBox("글로벌 값 목록에서 ID를 찾아 해당 값을 설정합니다.\r새로운 글로벌 값 ID를 생성하고자 한다면\r " +
        "프로젝트 파일에서 \"Assets/ScriptableObjects/GlobalParamSettings\"에 정보를 추가하고\r " +
        "노션에서 \"프로그래머문서/글로벌 값/값 리스트\"에 해당 정보를 적어두고 사용하세요", InfoMessageType = InfoMessageType.None)]
    public string paramKey;         // ID
    public int value;            // 지정할 값

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        if(!GlobalGameParameters.IsInstanceValid) { Debug.LogError("GlobalGameParameters가 없습니다!"); yield break; }

        GlobalGameParameters.Instance.Data[paramKey] = value;

        yield return null;
    }

}

/// <summary>
/// 대사창이 활성화 되어있는 도중 플레이어가 선택에 따라 각자 다른 글로벌 값을 설정해줄 수 있습니다.
/// </summary>
[System.Serializable]
public class Sequence_SelectGlobalParameter : Sequence_Base
{
    [InfoBox("대사창이 활성화 되어있는 도중 플레이어가 선택에 따라 각자 다른 글로벌 값을 설정해줄 수 있습니다.", InfoMessageType = InfoMessageType.None)]
    public string paramKey;                              // ID
    public LocalizedString[] branchAnswers;              // 선택할 수 있는 텍스트 (UI)
    public int[] values;                                 // 각 선택지들에 대응되는 값들

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        if (!GlobalGameParameters.IsInstanceValid) { Debug.LogError("글로벌 패러미터 오브젝트가 없습니다."); yield break; }

        if (string.IsNullOrEmpty(paramKey))
        {
            Debug.LogError("paramKey가 비어있습니다.");
            yield break;
        }

        if (branchAnswers.Length != values.Length) { Debug.LogError("branchAnswers와 values의 개수는 같아야 합니다."); yield break; }

        int index = 0;
        yield return invoker.Dialogue.StartCoroutine(invoker.Dialogue.Cor_Branch(branchAnswers, (value) => { index = value; }));

        int value = values[index];
        GlobalGameParameters.Instance.Data[paramKey] = value;

        yield return null;
    }
}


/// <summary>
/// 글로벌 값에서 ID를 가져와 값을 비교하여 특정 숫자 값일 때 해당하는 시퀀스 에셋을 재생합니다.
/// </summary>
[System.Serializable]
public class Sequence_BranchByParameter : Sequence_Base
{
    [InfoBox("글로벌 값에서 ID를 가져와 값을 비교하여 특정 숫자 값일 때 해당하는 시퀀스 에셋을 재생합니다.", InfoMessageType = InfoMessageType.None)]
    public string paramKey;                         // ID
    public int[] valueCases;                        // 값 리스트
    public SequenceBundleAsset[] sequences;         // 시퀀스 리스트
    public SequenceBundleAsset defaultSequence;     // 아무것도 만족하지 않을 때 시퀀스 ( 비워둘 수 있음 )

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        if (!GlobalGameParameters.IsInstanceValid) { Debug.LogError("글로벌 패러미터 오브젝트가 없습니다."); yield break; }
        if (sequences.Length != sequences.Length) { Debug.LogError("valueCases와 sequences의 개수가 같아야 합니다."); yield break; }
        if (string.IsNullOrEmpty(paramKey))
        {
            Debug.LogError("paramKey가 비어있습니다.");
            yield break;
        }

        int value = GlobalGameParameters.Instance.Data[paramKey];

        Debug.Log("Sequence_BranchByParameter / Global parameter : " + paramKey + " is " + value);

        for(int i = 0; i < valueCases.Length; i++)
        {
            if(value == valueCases[i])
            {
                if (sequences[i] == null) yield break;
                else
                {
                    yield return invoker.StartCoroutine(invoker.Cor_RecurciveSequenceChain(sequences[i].SequenceBundles));
                    yield break;
                }
            }
        }

        if (defaultSequence == null) yield break;
        yield return invoker.StartCoroutine(invoker.Cor_RecurciveSequenceChain(defaultSequence.SequenceBundles));
    }

}

public class Sequence_ShowImage : Sequence_Base
{
    [InfoBox("이미지묶음을 보여줍니다.", InfoMessageType = InfoMessageType.None)]
    [LabelText("이미지 모두 표시 후 닫기")] public bool closeImageAfterFinish = true;
    [PreviewField(Alignment = ObjectFieldAlignment.Center,Height = 100)] public Sprite[] Images;


    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        yield return invoker.DisplayImage.ImageProgress(Images,closeImageAfterFinish);
    }
}

public class Sequence_CloseImage : Sequence_Base
{
    [InfoBox("열려있는 이미지 창을 닫습니다.")]
    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        invoker.DisplayImage.CloseImage();
        yield return null;
    }
}

public class Sequence_EnableGameobject : Sequence_Base
{
    [InfoBox("해당 이름을 가진 오브젝트를 활성화 합니다.")]
    [LabelText("오브젝트 이름")] public string name;

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        GameObject.Find(name).SetActive(true);
        yield return null;
    }
}

public class Sequence_DisableGameobject : Sequence_Base
{
    [InfoBox("해당 이름을 가진 오브젝트를 비활성화 합니다.")]
    [LabelText("오브젝트 이름")] public string name;

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        GameObject.Find(name).SetActive(false);
        yield return null;
    }
}
