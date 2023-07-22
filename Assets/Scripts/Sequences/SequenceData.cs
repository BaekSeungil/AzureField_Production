using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Localization;
using UnityEngine.Playables;
using UnityEngine.Timeline;

public class Sequence_Base
{
    public bool DisablePlayer = true;
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
    public LocalizedDialogueData[] dialogues;

    public override IEnumerator Sequence(SequenceInvoker invoker) 
    {
        if (invoker.Dialogue == null) yield break;
        yield return invoker.Dialogue.StartCoroutine(invoker.Dialogue.Cor_DialogueSequence(dialogues));
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
