using Sirenix.OdinInspector;
using System.Collections;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

//===============================
//
// ������������ ������ ��Ÿ���� ��ũ��Ʈ�Դϴ�.
// ������ : �����÷��� �� ���, �̺�Ʈ, Ÿ�Ӷ��� ���� �͵��� �ڷ�ƾ�� �̿��� ���������� ������� ����� �� �ֵ��� �մϴ�.
// Sequence_Base�� ����� �ڽ� Ŭ������ ����� IEnumerator Sequence(SequenceInvoker invoker)�� �������̵� �Ͽ� ���� ������ ������ ������� ������ �� �ֽ��ϴ�.
//
// ������������ ������ SequenceBundleAsset ��ũ���ͺ������Ʈ ������ �����Ͽ� �ۼ��� �� �ֽ��ϴ�.
// ������� ���������鿡���� SequenceInvoker �ν��Ͻ��� ���� ����� �� �ֽ��ϴ�. �ش� ��ũ��Ʈ�� �����ϼ���.
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
/// �ƹ��͵� ���� �ʰ� time��ŭ ��ٸ��ϴ�.
/// </summary>
[System.Serializable]
public class Sequence_WaitForSeconds : Sequence_Base
{
    public float time;      // �������� �Ѿ�������� �ð�

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        yield return new WaitForSeconds(time);
    }
}

/// <summary>
/// ���â�� ���� dialogues�� ��� �����͵��� ������� ����մϴ�.
/// </summary>
[System.Serializable]
public class Sequence_Dialogue : Sequence_Base
{
    public DialogueData[] dialogues;                    // ��� �����͵�
    public bool CloseDialogueAfterFinish = true;        // true�� �� ���â�� ��� ����Ǹ� ���â UI�� �ݽ��ϴ�.

    public override IEnumerator Sequence(SequenceInvoker invoker) 
    {
        if (invoker.Dialogue == null)
        { Debug.Log("Dialogue UI �ν��Ͻ��� �����ϴ�!"); yield break; }
        yield return invoker.Dialogue.StartCoroutine(invoker.Dialogue.Cor_DialogueSequence(dialogues));
        if(CloseDialogueAfterFinish)
        {
            yield return invoker.Dialogue.StartCoroutine(invoker.Dialogue.Cor_CloseDialogue());
        }
    }
}

/// <summary>
/// ���â�� ������ ���� ���¶�� ���â�� �ݽ��ϴ�.
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
/// ���â�� Ȱ��ȭ �Ǿ��ִ� ���� �÷��̾ ������ �� �ִ� â�� ����ϴ�.
/// </summary>
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

/// <summary>
/// Ÿ�Ӷ����� ����մϴ�.
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
/// ������ amount ��ŭ �����մϴ�.
/// </summary>
[System.Serializable]
public class Sequence_GainMoney : Sequence_Base
{
    public int amount;

    public override IEnumerator Sequence(SequenceInvoker invoker)
    {
        if (invoker.InventoryContainer == null) { Debug.LogError("PlayerInvnentoryContainer�� ã�� �� �����ϴ�."); yield break; }
        invoker.InventoryContainer.AddMoney(amount);
        yield return null;
    }
    
}

/// <summary>
/// �������� �κ��丮�� �߰��մϴ�.
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