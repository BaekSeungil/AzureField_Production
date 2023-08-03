using JetBrains.Annotations;
using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
[CreateAssetMenu(fileName = "NewSequenceData", menuName = "CreateNewSequenceBundleAsset", order = 1)]
public class SequenceBundleAsset : SerializedScriptableObject
{
    public Sequence_Base[] sequenceBundles;
}

public class Sequence_Base 
{
    public virtual IEnumerator Sequence(SequenceInvoker invoker) { yield return null; }
}

[System.Serializable]
public class Sequence_WaitForSeconds : Sequence_Base
{
    public float time;

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        yield return new WaitForSeconds(time);
    }
}

[System.Serializable]
public class Sequence_Dialogue : Sequence_Base
{
    public DialogueData[] dialogues;
    public bool CloseDialogueAfterFinish = true;

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
[System.Serializable]
public class Sequence_CloseDialogue : Sequence_Base
{
    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        yield return invoker.Dialogue.StartCoroutine(invoker.Dialogue.Cor_CloseDialogue());
    }
}

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

[System.Serializable]
public class Sequence_DialogueBranch : Sequence_Base
{
    public string[] branchAnswers;
    public SequenceBundleAsset[] sequenceAssets;

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        if(branchAnswers.Length != sequenceAssets.Length) { Debug.LogError("Invalid branches-sequenceAssets Length."); yield break; }

        int index = 0;
        yield return invoker.Dialogue.StartCoroutine(invoker.Dialogue.Cor_Branch(branchAnswers, (value) => { index = value; }));

        yield return invoker.StartCoroutine(invoker.Cor_RecurciveSequenceChain(sequenceAssets[index].sequenceBundles));
    }
}

[System.Serializable]
public class Sequence_GainMoney : Sequence_Base
{
    public int amount;

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        if (invoker.InventoryContainer == null) { Debug.LogError("PlayerInvnentoryInvoker를 찾을 수 없습니다."); yield break; }
        invoker.InventoryContainer.AddMoney(amount);
        yield return null;
    }
    
}

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