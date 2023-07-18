using DG.Tweening;
using FMODUnity;
using RichTextSubstringHelper;
using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
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

public class DialogueBehavior : MonoBehaviour
{
    [SerializeField] private float textInterval = 0.05f;
    [Title("Sounds")]
    [SerializeField] private EventReference sound_open;
    [SerializeField] private EventReference sound_proceed;
    [SerializeField] private EventReference sound_type;
    [SerializeField] private EventReference sound_close;
    [Title("References")]
    [SerializeField] private GameObject visualGroup;
    [SerializeField] private TextMeshProUGUI speecher;
    [SerializeField] private TextMeshProUGUI context;
    [SerializeField] private GameObject inputWaitObject;
    [SerializeField] private DOTweenAnimation dotweenAnim;


    private MainPlayerInputActions input;

    private bool dialogueOpened = false;

    bool dialogueProceed = false;

    private void Awake()
    {
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
        yield return StartCoroutine(Cor_OpenDialogue());
        yield return StartCoroutine(Cor_TypeDialogue(dialogues));
        yield return StartCoroutine(Cor_CloseDialogue());
        visualGroup.SetActive(false);
    }

    private IEnumerator Cor_TypeDialogue(DialogueData[] dialogues)
    {
        for(int i = 0; i < dialogues.Length; i++)
        {
            inputWaitObject.SetActive(false);
            dialogueProceed = false;

            if (!dialogues[i].speecher.IsEmpty) speecher.text = dialogues[i].speecher.GetLocalizedString();
            else speecher.text = string.Empty;

            if (!dialogues[i].context.IsEmpty)
            {
                string ctx = dialogues[i].context.GetLocalizedString();

                for (int j = 0; j <= ctx.RichTextLength(); j++)
                {
                    if (dialogueProceed == true)
                    { context.text = ctx; break; }
                    context.text = ctx.RichTextSubString(j);
                    RuntimeManager.PlayOneShot(sound_type);
                    yield return new WaitForSeconds(textInterval);
                }

                dialogueProceed = false;
            }
            else context.text = string.Empty;
            inputWaitObject.SetActive(true);
            yield return new WaitForSeconds(0.5f);
     
            yield return new WaitUntil(() => dialogueProceed);
            RuntimeManager.PlayOneShot(sound_proceed);
        }
    }

    private IEnumerator Cor_OpenDialogue()
    {
        if (dialogueOpened) yield break;

        RuntimeManager.PlayOneShot(sound_open);

        dotweenAnim.DORestartById("DialogueFadein");
        Tween openTw = dotweenAnim.GetTweens()[0];

        yield return openTw.WaitForCompletion();
        dialogueOpened = true;
    }

    private IEnumerator Cor_CloseDialogue()
    {
        if (!dialogueOpened) yield break;

        RuntimeManager.PlayOneShot(sound_close);
        dialogueOpened = false;
        dotweenAnim.DORestartById("DialogueFadeout");
        Tween closeTw = dotweenAnim.GetTweens()[1];
        inputWaitObject.SetActive(false);

        yield return closeTw.WaitForCompletion();
        
    }

    private void ClearDialogue()
    {
        speecher.text = string.Empty;
        context.text = string.Empty;
    }
}
