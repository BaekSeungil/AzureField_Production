using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using Unity.VectorGraphics;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class AlphaSceneloader : PersistentSerializedMonoBehaviour<AlphaSceneloader>
{
    [SerializeField] private Slider loadingBar;
    [SerializeField] private CanvasGroup panelCover;
    [SerializeField] private DOTweenAnimation coverTween;

    bool sceneLoading = false;

    public void LoadNewScene(string sceneName)
    {
        if (sceneLoading) return;

        StartCoroutine(Cor_LoadingNewScene(sceneName));
    }

    public void LoadNewScene(int index)
    {
        if (sceneLoading) return;

        StartCoroutine(Cor_LoadingNewScene(index));
    }

    IEnumerator Cor_LoadingNewScene(string sceneName)
    {
        if (PlayerCore.IsInstanceValid) PlayerCore.Instance.DisableControls();

        panelCover.gameObject.SetActive(true);

        coverTween.DORestartById("OpenLoader");
        Tween tw = coverTween.tween;

        yield return tw.WaitForCompletion();

        AsyncOperation loadAsync = SceneManager.LoadSceneAsync(sceneName,LoadSceneMode.Single);

        for(float t = 0; !loadAsync.isDone;)
        {
            loadingBar.value = t;
            yield return null;
        }

        coverTween.DORestartById("CloseLoader");
        tw = coverTween.tween;

        yield return tw.WaitForCompletion();

        panelCover.gameObject.SetActive(false);
    }

    IEnumerator Cor_LoadingNewScene(int index)
    {
        if (PlayerCore.IsInstanceValid) PlayerCore.Instance.DisableControls();

        panelCover.gameObject.SetActive(true);

        coverTween.DORestartById("OpenLoader");
        Tween tw = coverTween.tween;

        yield return tw.WaitForCompletion();

        AsyncOperation loadAsync = SceneManager.LoadSceneAsync(index,LoadSceneMode.Single);

        for (float t = 0; !loadAsync.isDone;)
        {
            loadingBar.value = t;
            yield return null;
        }

        coverTween.DORestartById("CloseLoader");
        tw = coverTween.tween;

        yield return tw.WaitForCompletion();

        panelCover.gameObject.SetActive(false);
    }

}
