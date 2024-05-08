using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UI_DisplayImage : StaticSerializedMonoBehaviour<UI_DisplayImage>
{
    [SerializeField] private GameObject visualGroup;
    [SerializeField] private Image image;
    [SerializeField] private GameObject progressTriangle;
    [SerializeField] private DOTweenAnimation imageTween;

    private void Start()
    {
        visualGroup.SetActive(false);
    }

    public IEnumerator ImageProgress(Sprite[] sprite)
    {
        visualGroup.SetActive(true);

        for (int i = 0; i < sprite.Length; i++)
        {
            imageTween.DORestart();
            image.sprite = sprite[i];
            yield return new WaitForSeconds(0.5f);
            progressTriangle.SetActive(true);
            yield return new WaitUntil(() => UI_InputManager.Instance.UI_Input.UI.Positive.IsPressed());
            progressTriangle.SetActive(false);
        }

        visualGroup.SetActive(false);
    }
}
