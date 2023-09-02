using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEditor.Searcher;
using UnityEngine;
using UnityEngine.UI;

public class InteractionInfo : StaticSerializedMonoBehaviour<InteractionInfo>
{
    [SerializeField] private CanvasGroup visualGroup;
    [SerializeField] private RectTransform panelRect;
    [SerializeField] private TextMeshProUGUI textMesh;

    private Transform worldObjectTarget = null;

    private void Start()
    {
        visualGroup.gameObject.SetActive(false);
    }

    const float yOffsetTarget = 100f;
    float yOffset = 0;

    private void Update()
    {
        if (visualGroup.gameObject.activeInHierarchy && worldObjectTarget != null)
        {
            if (PlayerCore.IsInstanceValid)
            {
                if (PlayerCore.Instance.IsHoldingSomething || !PlayerCore.Instance.Input.Player.enabled) HideCurrentInfo();
            }

            if (worldObjectTarget != null)
                panelRect.position = Camera.main.WorldToScreenPoint(worldObjectTarget.position) + Vector3.up * yOffset;

            textMesh.rectTransform.anchoredPosition = panelRect.anchoredPosition;
            yOffset = Mathf.Lerp(yOffset, yOffsetTarget, 0.2f);
        }
    }

    public void SetNewInteractionInfo(Transform target, string infoName)
    {
        yOffset = 0f;
        visualGroup.gameObject.SetActive(true);
        worldObjectTarget = target;
        textMesh.text = infoName;
        Canvas.ForceUpdateCanvases();
        panelRect.sizeDelta = textMesh.rectTransform.sizeDelta;
    }

    public bool CompareCurrentTarget(Transform target)
    {
        if (worldObjectTarget == target) return true;
        else return false;
    }

    public void HideCurrentInfo()
    {
        yOffset = 0f;
        visualGroup.gameObject.SetActive(false);
        worldObjectTarget = null;
    }
}
