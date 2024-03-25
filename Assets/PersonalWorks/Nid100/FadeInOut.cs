using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FadeInOut : StaticSerializedMonoBehaviour<FadeInOut>
{
    public float fadeSpeed = 1f;

    private CanvasGroup canvasGroup;

    void Start()
    {
        canvasGroup = GetComponent<CanvasGroup>();
        canvasGroup.alpha = 0f;          
    }

    public void FadeInExecution()
    {
        StopAllCoroutines();
        StartCoroutine(FadeIn());
    }

    public void FadeOutExecution()
    {
        StopAllCoroutines();
        StartCoroutine(FadeOut());
    }

    IEnumerator FadeIn()
    {
        while (canvasGroup.alpha < 1)
        {
            canvasGroup.alpha += Time.deltaTime * fadeSpeed;
            yield return null;
        }
    }

    IEnumerator FadeOut()
    {
        while (canvasGroup.alpha > 0)
        {
            canvasGroup.alpha -= Time.deltaTime * fadeSpeed;
            yield return null;
        }
    }
}
