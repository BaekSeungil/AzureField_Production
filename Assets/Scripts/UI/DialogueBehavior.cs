using DG.Tweening;
using FMODUnity;
using RichTextSubstringHelper;
using Sirenix.OdinInspector;
using System;
using System.Collections;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Localization;

[System.Serializable]
public class DialogueData
{
    public LocalizedString speecher;
    public LocalizedString context;
}

public class DialogueBehavior : StaticSerializedMonoBehaviour<DialogueBehavior>
{
    [SerializeField] private float textInterval = 0.05f;
    [SerializeField] private float answerSpawnSpace = 50f;
    [SerializeField] private GameObject answerSinglePrefab;

    [Title("Sounds")]
    [SerializeField] private EventReference sound_open;
    [SerializeField] private EventReference sound_proceed;
    [SerializeField] private EventReference sound_type;
    [SerializeField] private EventReference sound_select;
    [SerializeField] private EventReference sound_close;
    [Title("References")]
    [SerializeField] private GameObject visualGroup;
    [SerializeField] private TextMeshProUGUI speecher;
    [SerializeField] private TextMeshProUGUI context;
    [SerializeField] private GameObject inputWaitObject;
    [SerializeField] private Transform answerStartPosition;
    [SerializeField] private DOTweenAnimation visualGroupAnim;
    [SerializeField] private DOTweenAnimation dialogueAnswerAnimation;

    private MainPlayerInputActions input;
    public MainPlayerInputActions Input { get { return input; } }

    private bool dialogueOpened = false;
    public bool DialogueOpened { get { return dialogueOpened; } }

    bool dialogueProceed = false;

    protected override void Awake()
    {
        base.Awake();

        input = new MainPlayerInputActions();
        input.UI.Enable();
        input.UI.Positive.performed += OnPressedPositive;
    }

    private void Start()
    {
        inputWaitObject.SetActive(false);
        visualGroup.SetActive(false);
        visualGroup.GetComponent<CanvasGroup>().alpha = 0f;
    }

    private void OnPressedPositive(InputAction.CallbackContext context)
    {
        dialogueProceed = true;
    }

    public IEnumerator Cor_DialogueSequence(DialogueData[] dialogues)
    {
        visualGroup.SetActive(true);
        ClearDialogue();
        if (!dialogueOpened)
        {
            yield return StartCoroutine(Cor_OpenDialogue());
        }
        yield return StartCoroutine(Cor_TypeDialogue(dialogues));
    }

    private IEnumerator Cor_TypeDialogue(DialogueData[] dialogues)
    {
        for (int i = 0; i < dialogues.Length; i++)
        {
            inputWaitObject.SetActive(false);
            dialogueProceed = false;

            string localized_speecher = dialogues[i].speecher.GetLocalizedString();
            string localized_context = dialogues[i].context.GetLocalizedString();

            if (localized_speecher == string.Empty) speecher.text = string.Empty;
            else speecher.text = localized_speecher;

            string ctx = localized_context;

            for (int j = 0; j <= ctx.RichTextLength(); j++)
            {
                if (dialogueProceed == true)
                { context.text = ctx; break; }
                context.text = ctx.RichTextSubString(j);
                RuntimeManager.PlayOneShot(sound_type);
                yield return new WaitForSeconds(textInterval);
            }

            dialogueProceed = false;

            inputWaitObject.SetActive(true);
            yield return new WaitForSeconds(0.5f);

            yield return new WaitUntil(() => dialogueProceed);
            inputWaitObject.SetActive(false);
            RuntimeManager.PlayOneShot(sound_proceed);
        }
    }

    private IEnumerator Cor_OpenDialogue()
    {
        if (dialogueOpened) yield break;

        RuntimeManager.PlayOneShot(sound_open);

        visualGroupAnim.DORestartById("DialogueFadein");
        Tween openTw = visualGroupAnim.GetTweens()[0];

        yield return openTw.WaitForCompletion();
        dialogueOpened = true;
    }

    public IEnumerator Cor_CloseDialogue()
    {
        if (!dialogueOpened) yield break;

        RuntimeManager.PlayOneShot(sound_close);
        dialogueOpened = false;
        visualGroupAnim.DORestartById("DialogueFadeout");
        Tween closeTw = visualGroupAnim.GetTweens()[1];
        inputWaitObject.SetActive(false);

        yield return closeTw.WaitForCompletion();

        visualGroup.SetActive(false);

    }

    private DialogueAnswerSingle[] answerObjects;
    int index = 0;
    bool whileBreak = false;
    bool answerEntered = false;
    public bool WhileBreak { get { return whileBreak; } }

    public void OnAnswerSelectedByMouse(int index)
    {
        if (answerEntered == false) return;
        whileBreak = true;
    }

    public void OnAnswerMouseEnter(int index)
    {
        RuntimeManager.PlayOneShot(sound_select);
        answerObjects[this.index].OnDeselected();
        this.index = index;
        answerObjects[this.index].OnSelected();
    }

    public IEnumerator Cor_Branch(LocalizedString[] answerStrings,Action<int> outCallback)
    {
        index = 0;
        whileBreak = false;

        if(!dialogueOpened)
        {
            yield return StartCoroutine(Cor_OpenDialogue());
        }

        dialogueAnswerAnimation.DORestartById("Branch_Open");
        Tween tw = dialogueAnswerAnimation.GetTweens()[0];
        yield return tw.WaitForCompletion();

        answerObjects = new DialogueAnswerSingle[answerStrings.Length];

        for(int i = 0; i < answerStrings.Length; i++)
        {
            GameObject newObject = Instantiate(answerSinglePrefab, answerStartPosition);
            newObject.transform.localPosition = new Vector3(0f, i * answerSpawnSpace);
            answerObjects[i] = newObject.GetComponent<DialogueAnswerSingle>();
            answerObjects[i].Initialize(this,answerStrings[i].GetLocalizedString(),i);
        }


        yield return new WaitForSeconds(0.5f);

        if(index == 0) answerObjects[0].OnSelected();
        answerEntered = true;
        
        while(!(input.UI.Positive.WasPerformedThisFrame()&&!input.UI.Click.WasPerformedThisFrame()))
        {
            if(input.UI.Navigate.WasPressedThisFrame())
            {
                Vector2 inp = input.UI.Navigate.ReadValue<Vector2>();
                if (inp.y == 1f)
                {
                    RuntimeManager.PlayOneShot(sound_select);
                    answerObjects[index].OnDeselected();

                    if (index == answerObjects.Length-1)
                        index = 0;
                    else
                        index++;

                    answerObjects[index].OnSelected();
                }
                else if (inp.y == -1f)
                {
                    RuntimeManager.PlayOneShot(sound_select);
                    answerObjects[index].OnDeselected();

                    if(index == 0)
                        index = answerObjects.Length-1;
                    else
                        index--;

                    answerObjects[index].OnSelected();
                }
            }

            if (whileBreak) break;

            yield return null;
        }

        answerEntered = false;

        RuntimeManager.PlayOneShot(sound_open);

        for(int i = answerObjects.Length - 1; i >= 0; i--)
        {
            Destroy(answerObjects[i].gameObject);
        }

        answerObjects = null;

        dialogueAnswerAnimation.DORestartById("Branch_Close");
        tw = dialogueAnswerAnimation.GetTweens()[1];
        yield return tw.WaitForCompletion();

        outCallback(index);
    }

    private void ClearDialogue()
    {
        speecher.text = string.Empty;
        context.text = string.Empty;
    }
}
