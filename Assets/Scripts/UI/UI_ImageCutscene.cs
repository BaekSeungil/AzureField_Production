using FMODUnity;
using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.Collections;
using UnityEngine;
using UnityEngine.UI;

public class UI_ImageCutscene : StaticSerializedMonoBehaviour<UI_ImageCutscene>
{
    [SerializeField] EventReference progressSound;
    [SerializeField] private AnimationCurve transitionCurve;

    [SerializeField, FoldoutGroup("ChildReference")] private GameObject visualGroup;
    [SerializeField, FoldoutGroup("ChildReference")] private GameObject fixedImageObject;
    [SerializeField, FoldoutGroup("ChildReference")] private GameObject longImageObject;
    [SerializeField, FoldoutGroup("ChildReference")] private GameObject blackoutCover;
    [SerializeField, FoldoutGroup("ChildReference")] private GameObject textObject;

    Image fixedImage;
    Image longImage;
    TextMeshPro textMesh;
    Animator fixedAnimator;
    Animator longAnimator;

    protected override void Awake()
    {
        base.Awake();

        fixedImage = fixedImageObject.GetComponent<Image>();
        fixedAnimator = fixedImageObject.GetComponent<Animator>();
        longImage = longImageObject.GetComponent<Image>();
        textMesh = textObject.GetComponent<TextMeshPro>();
    }

    private void Start()
    {
        visualGroup.SetActive(false);
    }

    public IEnumerator StartCutsceneProgress(Sequence_ImageCutscene.ImgCutsceneSubsequence_Base[] subsequences)
    {
        visualGroup.SetActive(true);
        blackoutCover.SetActive(false);
        longImageObject.SetActive(false);
        fixedImageObject.SetActive(false);
        textObject.SetActive(true);

        textMesh.text = string.Empty;

        for (int i = 0; i < subsequences.Length; i++)
        {
            if (subsequences[i] == null) continue;

            if (subsequences[i] is Sequence_ImageCutscene.ImgCutsceneSubsequence_Short)
            {
                yield return StartCoroutine(Cor_ImageCutsceneProgress(subsequences[i] as Sequence_ImageCutscene.ImgCutsceneSubsequence_Short));
            }
            else if (subsequences[i] is Sequence_ImageCutscene.ImgCutsceneSubsequence_Long)
            {
                yield return StartCoroutine(Cor_LongImageCutsceneProgress(subsequences[i] as Sequence_ImageCutscene.ImgCutsceneSubsequence_Long));
            }
        }
        yield return Cor_EndCutsceneProgress();
    }

    float transitionLength = 1.5f;

    private IEnumerator Cor_ImageCutsceneProgress(Sequence_ImageCutscene.ImgCutsceneSubsequence_Short subsequence)
    {
        if (subsequence.blackout)
            blackoutCover.SetActive(true);
        else
            blackoutCover.SetActive(false);

        fixedImageObject.SetActive(true);
        fixedImage.sprite = subsequence.sprite;
        longImageObject.SetActive(false);

        fixedAnimator.Play("IN");
        yield return new WaitForSeconds(transitionLength);

        for (int textIndex = 0; textIndex < subsequence.context.Length; textIndex++)
        {
            textObject.SetActive(false);
            textObject.SetActive(true);

            textMesh.text = subsequence.context[textIndex].GetLocalizedString();
            yield return new WaitForSeconds(0.2f);
            yield return new WaitUntil(() => UI_InputManager.Instance.UI_Input.UI.Positive.IsPressed());
        }

        fixedAnimator.Play("OUT");
        yield return new WaitForSeconds(transitionLength);

    }

    private IEnumerator Cor_LongImageCutsceneProgress(Sequence_ImageCutscene.ImgCutsceneSubsequence_Long subsequence)
    {
        if (subsequence.blackout)
            blackoutCover.SetActive(true);
        else
            blackoutCover.SetActive(false);

        longImageObject.SetActive(true);
        longImage.sprite = subsequence.sprite;
        fixedImageObject.SetActive(false);

        longAnimator.Play("IN");
        yield return new WaitForSeconds(transitionLength);

        float prevPoint = 0f;

        for (int seqIndex = 0; seqIndex < subsequence.elements.Length; seqIndex++)
        {
            var current = subsequence.elements[seqIndex];
            for(float time = 0; time < current.scrollTime; time += Time.deltaTime)
            {
                if (UI_InputManager.Instance.UI_Input.UI.Positive.IsPressed()) break;
                float t = time / current.scrollTime;
                longImage.rectTransform.anchoredPosition = Vector2.Lerp(Vector2.right * -prevPoint, Vector2.right * -current.scrollPoint, t);
                yield return null;
            }
            longImage.rectTransform.anchoredPosition = Vector2.right * -current.scrollPoint;

            yield return new WaitForSeconds(0.5f);

            for (int textIndex = 0; textIndex < current.context.Length; textIndex++)
            {
                textObject.SetActive(false);
                textObject.SetActive(true);

                textMesh.text = current.context[textIndex].GetLocalizedString();
                yield return new WaitForSeconds(0.2f);
                yield return new WaitUntil(() => UI_InputManager.Instance.UI_Input.UI.Positive.IsPressed());
            }


            prevPoint = -current.scrollPoint;

        }

        longAnimator.Play("OUT");
        yield return new WaitForSeconds(transitionLength);
    }

    public IEnumerator Cor_EndCutsceneProgress()
    {
        visualGroup.SetActive(true);

        textMesh.text = string.Empty;
        yield return null;
    }

}
