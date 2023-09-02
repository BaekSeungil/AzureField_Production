using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.SceneManagement;

public class SequenceInvoker : StaticSerializedMonoBehaviour<SequenceInvoker>
{
    private DialogueBehavior dialogue;
    public DialogueBehavior Dialogue { get { return dialogue; } }
    private PlayerInventoryContainer inventoryContainer;
    public PlayerInventoryContainer InventoryContainer { get { return inventoryContainer; } }
    private PlayableDirector playable;
    public PlayableDirector Playable { get { return playable; } }

    protected override void Awake()
    {
        base.Awake();

        playable = GetComponent<PlayableDirector>();
        SceneManager.sceneLoaded += OnSceneLoaded;
    }

    private void Start()
    {
        dialogue = DialogueBehavior.Instance;
        inventoryContainer = PlayerInventoryContainer.Instance;
    }

    private bool sequenceRunning = false;
    public bool IsSequenceRunning { get { return sequenceRunning; } }

    public void StartSequence(Sequence_Base[] sequenceChain)
    {
        if(sequenceRunning) { Debug.LogWarning("작동중인 시퀀스가 있습니다. 시작될 시퀀스가 무시됩니다."); return; }

        StartCoroutine(Cor_StartSequenceChain(sequenceChain));
    }

    private IEnumerator Cor_StartSequenceChain(Sequence_Base[] sequenceChain)
    {
        sequenceRunning = true;
        PlaymenuBehavior playmenu = PlaymenuBehavior.Instance;
        playmenu.DisableInput();
        PlayerCore player = PlayerCore.Instance;
        player.DisableForSequence();

        for (int i = 0; i < sequenceChain.Length; i++)
        {
            yield return StartCoroutine(sequenceChain[i].Sequence(this));
        }

        if(dialogue.DialogueOpened) { yield return dialogue.StartCoroutine(dialogue.Cor_CloseDialogue()); }

        yield return null;
        playmenu.EnableInput();
        player.EnableForSequence();

        sequenceRunning = false;
    }

    public IEnumerator Cor_RecurciveSequenceChain(Sequence_Base[] sequenceChain)
    {
        for (int i = 0; i < sequenceChain.Length; i++)
        {
            yield return StartCoroutine(sequenceChain[i].Sequence(this));
        }
    }

    public void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        dialogue = DialogueBehavior.Instance;
    }

    private void OnDestroy()
    {
        SceneManager.sceneLoaded -= OnSceneLoaded;
    }

}
