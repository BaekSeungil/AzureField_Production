using DG.Tweening;
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

    /// <summary>
    /// 변수 타입: StudioEventEmitter
    /// 변수 명: sound
    /// 작업자: 성지훈
    /// 추가사유 - 임시로 음원 출력하기 위한 발버둥
    /// 비고: FMOD 스튜디오를 제공 받은 것이 아니기 때문에 MainCamera에 Audio Source를 넣어 직접적으로 Audio Clip을 출력하는 방식을 채택함.
    /// </summary>
    [SerializeField] private StudioEventEmitter sound;

    [SerializeField, FoldoutGroup("ChildReference")] private GameObject visualGroup;
    [SerializeField, FoldoutGroup("ChildReference")] private GameObject fixedImageObject;
    [SerializeField, FoldoutGroup("ChildReference")] private GameObject longImageObject;
    [SerializeField, FoldoutGroup("ChildReference")] private GameObject blackoutCover;
    [SerializeField, FoldoutGroup("ChildReference")] private GameObject textObject;

    [SerializeField, FoldoutGroup("ChildReference")] private RectTransform skipProgressBar;

    Image fixedImage;
    Image longImage;
    TextMeshProUGUI textMesh;
    Animator fixedAnimator;
    Animator longAnimator;

    private float skipProgress = 0f;

    protected override void Awake()
    {
        base.Awake();
    }

    private void Start()
    {
        visualGroup.SetActive(true);

        fixedImage = fixedImageObject.GetComponent<Image>();
        fixedAnimator = fixedImageObject.GetComponent<Animator>();
        longImage = longImageObject.GetComponent<Image>();
        longAnimator = longImageObject.GetComponent<Animator>();
        textMesh = textObject.GetComponent<TextMeshProUGUI>();
        textMesh.text = string.Empty;

        visualGroup.SetActive(false);
        /// <summary>
        /// 변수 타입: StudioEventEmitter
        /// 변수 명: sound
        /// 작업자: 성지훈
        /// 추가사유 - 임시로 음원 출력하기 위한 발버둥
        /// 비고: FMOD 스튜디오를 제공 받은 것이 아니기 때문에 MainCamera에 Audio Source를 넣어 직접적으로 Audio Clip을 출력하는 방식을 채택함.
        /// </summary>
    }

    private float skipWaitTime = 1f;

    private void Update()
    {
        if (UI_InputManager.Instance.UI_Input.UI.Skip.IsPressed())
        {
            if (skipProgress < skipWaitTime)
            {
                skipProgress += Time.deltaTime;
                skipProgressBar.localScale = new Vector3(skipProgress, 1f, 1f);
            }
            else
            {
                skipProgress = 1f;
                skipProgressBar.localScale = new Vector3(1f, 1f, 1f);
                skipFlag = true;
            }
        }
        else
        {
            skipProgress = 0f;
            skipProgressBar.localScale = new Vector3(0f, 1f, 1f);
            skipFlag = false;
        }
    }

    [SerializeField,Sirenix.OdinInspector.ReadOnly] private bool skipFlag = false;

    public IEnumerator StartCutsceneProgress(Sequence_ImageCutscene.ImgCutsceneSubsequence_Base[] subsequences)
    {
        visualGroup.SetActive(true);
        blackoutCover.SetActive(false);
        longImageObject.SetActive(false);
        fixedImageObject.SetActive(false);
        textObject.SetActive(true);

        CanvasGroup canvasGroup = visualGroup.GetComponent<CanvasGroup>();

        if (canvasGroup.alpha == 0f)
        {
            for (float time = 0f; time < 1f; time += Time.fixedDeltaTime)
            {
                canvasGroup.alpha = time;
                yield return new WaitForFixedUpdate();
            }
            canvasGroup.alpha = 1f;
        }

        skipFlag = false;

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

            if (skipFlag) break;
        }

        skipFlag = false;
        yield return Cor_EndCutsceneProgress();
    }

    float transitionLength = 1.5f;

    private IEnumerator Cor_ImageCutsceneProgress(Sequence_ImageCutscene.ImgCutsceneSubsequence_Short subsequence)
    {
        if (subsequence.blackout)
        {
            blackoutCover.SetActive(true);
            blackoutCover.GetComponent<DOTweenAnimation>().DORestartById("FADEIN");
        }
        else
        {
            if (blackoutCover.activeInHierarchy)
                blackoutCover.GetComponent<DOTweenAnimation>().DORestartById("FADEOUT");
        }

        fixedImageObject.SetActive(true);
        fixedImage.sprite = subsequence.sprite;
        longImageObject.SetActive(false);

        if (!subsequence.blackout)
        {
            fixedAnimator.Play("IN");
            yield return new WaitForSeconds(transitionLength);
        }

        for (int textIndex = 0; textIndex < subsequence.context.Length; textIndex++)
        {
            textObject.SetActive(false);
            textObject.SetActive(true);

            #region 코드 설명
            /// <summary>
            /// 작업자: 성지훈
            /// 추가사유 - 임시로 음원 출력하기 위한 발버둥
            /// 비고: FMOD 스튜디오를 제공 받은 것이 아니기 때문에 MainCamera에 Audio Source를 넣어 직접적으로 Audio Clip을 출력하는 방식을 채택함.
            /// </summary>
            #endregion

            if (subsequence.narration.Length > textIndex)
            {
                sound.ChangeEvent(subsequence.narration[textIndex]);
                sound.Play();
            }


            textMesh.text = subsequence.context[textIndex].GetLocalizedString();
            yield return new WaitForSeconds(0.2f);
            yield return new WaitUntil(() => UI_InputManager.Instance.UI_Input.UI.Positive.IsPressed() || skipFlag);

            #region 코드 설명
            /// <summary>
            /// 작업자: 성지훈
            /// 추가사유 - 임시로 음원 출력하기 위한 발버둥
            /// 비고: FMOD 스튜디오를 제공 받은 것이 아니기 때문에 MainCamera에 Audio Source를 넣어 직접적으로 Audio Clip을 출력하는 방식을 채택함.
            /// </summary>
            #endregion
            sound.Stop();

            if (skipFlag) yield break;
        }

        fixedAnimator.Play("OUT");
        yield return new WaitForSeconds(transitionLength);

    }

    private IEnumerator Cor_LongImageCutsceneProgress(Sequence_ImageCutscene.ImgCutsceneSubsequence_Long subsequence)
    {
        if (subsequence.blackout)
        {
            blackoutCover.SetActive(true);
            blackoutCover.GetComponent<DOTweenAnimation>().DORestartById("FADEIN");
        }
        else
        {
            if (blackoutCover.activeInHierarchy)
                blackoutCover.GetComponent<DOTweenAnimation>().DORestartById("FADEOUT");
        }


        longImageObject.SetActive(true);
        longImage.sprite = subsequence.sprite;
        fixedImageObject.SetActive(false);

        if (!subsequence.blackout)
        {
            longAnimator.Play("IN");
            yield return new WaitForSeconds(transitionLength);
        }

        float prevPoint = 0f;

        for (int seqIndex = 0; seqIndex < subsequence.elements.Length; seqIndex++)
        {
            var current = subsequence.elements[seqIndex];

            yield return new WaitForSeconds(0.5f);

            for (float time = 0; time < current.scrollTime; time += Time.deltaTime)
            {
                if (UI_InputManager.Instance.UI_Input.UI.Positive.IsPressed()) break;
                float t = time / current.scrollTime;
                longImage.rectTransform.anchoredPosition = Vector2.Lerp(Vector2.right * -prevPoint, Vector2.right * -current.scrollPoint, transitionCurve.Evaluate(t));
                yield return null;
            }
            longImage.rectTransform.anchoredPosition = Vector2.right * -current.scrollPoint;

            yield return new WaitForSeconds(0.5f);

            for (int textIndex = 0; textIndex < current.context.Length; textIndex++)
            {
                if (skipFlag) yield break;

                textObject.SetActive(false);
                textObject.SetActive(true);

                #region 코드 설명
                /// <summary>
                /// 작업자: 성지훈
                /// 추가사유 - 임시로 음원 출력하기 위한 발버둥
                /// 비고: FMOD 스튜디오를 제공 받은 것이 아니기 때문에 MainCamera에 Audio Source를 넣어 직접적으로 Audio Clip을 출력하는 방식을 채택함.
                /// </summary>
                #endregion
                if (current.narration.Length > 0)
                    sound.ChangeEvent(current.narration[textIndex]);
                sound.Play();
                textMesh.text = current.context[textIndex].GetLocalizedString();
                yield return new WaitForSeconds(0.2f);
                yield return new WaitUntil(() => UI_InputManager.Instance.UI_Input.UI.Positive.IsPressed() || skipFlag);
                #region 코드 설명
                /// <summary>
                /// 작업자: 성지훈
                /// 추가사유 - 임시로 음원 출력하기 위한 발버둥
                /// 비고: FMOD 스튜디오를 제공 받은 것이 아니기 때문에 MainCamera에 Audio Source를 넣어 직접적으로 Audio Clip을 출력하는 방식을 채택함.
                /// </summary>
                #endregion
                sound.Stop();
            }
            prevPoint = -current.scrollPoint;

        }

        longAnimator.Play("OUT");
        yield return new WaitForSeconds(transitionLength);
    }

    public IEnumerator Cor_EndCutsceneProgress()
    {
        textMesh.text = string.Empty;

        DOTweenAnimation doAnim = visualGroup.GetComponent<DOTweenAnimation>();
        Tween fadeoutTween = doAnim.GetTweens()[1];
        doAnim.DORestartById("FADEOUT");

        yield return fadeoutTween.WaitForCompletion();
    }

}
