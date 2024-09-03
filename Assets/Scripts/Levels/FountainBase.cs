using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FountainBase : MonoBehaviour
{
    [SerializeField] private float defaultHeight = 10f;
    [SerializeField] private bool isSleep = true;
    [SerializeField] private AnimationCurve movingCurve;
    [SerializeField] private float movingDuration = 1.0f;

    [Header("ChildReferences")]
    [SerializeField] private Transform fountainTF;
    [SerializeField] private GameObject[] objectOnActived;

    float currentHeight = 0f;
    bool isSleeping = true;
    public bool IsSleeping { get { return isSleeping; } }

    private Coroutine transitionCoroutine;

    private void Start()
    {
        if (!isSleep)
            Activate();
        else
        {
            foreach (var obj in objectOnActived) { obj.SetActive(false); }
        }

    }

    public void Activate()
    {
        if (transitionCoroutine != null) return;
        if (!isSleeping) return;
        transitionCoroutine = StartCoroutine(Cor_SetHeight(defaultHeight));
    }

    public void SetHeigh(float height)
    {
        if (transitionCoroutine != null) return;
        transitionCoroutine = StartCoroutine(Cor_SetHeight(defaultHeight));
    }

    public void Disable()
    {
        if (transitionCoroutine != null) return;
        if (isSleeping) return;
        transitionCoroutine = StartCoroutine(Cor_Deactivate());
    }

    public IEnumerator Cor_SetHeight(float height)
    {
        foreach (var obj in objectOnActived) { obj.SetActive(true); }

        for (float t = 0; t < movingDuration; t += Time.fixedDeltaTime)
        {
            float segment = t / movingDuration;
            fountainTF.transform.localScale = new Vector3(fountainTF.localScale.x, fountainTF.localScale.y, Mathf.Lerp(currentHeight/10f,height/10f,movingCurve.Evaluate(segment)));
            yield return new WaitForFixedUpdate();
        }

        currentHeight = height;
        fountainTF.transform.localScale = new Vector3(fountainTF.localScale.x, fountainTF.localScale.y, height / 10f);
        isSleeping = false;
        transitionCoroutine = null;
    }

    public IEnumerator Cor_Deactivate()
    {
        for (float t = 0; t < movingDuration; t += Time.fixedDeltaTime)
        {
            float segment = t / movingDuration;
            fountainTF.transform.localScale = new Vector3(fountainTF.localScale.x, fountainTF.localScale.y, Mathf.Lerp(currentHeight/10f,0f,movingCurve.Evaluate(segment)));
            yield return new WaitForFixedUpdate();
        }

        currentHeight = 0;
        fountainTF.transform.localScale = new Vector3(fountainTF.localScale.x, fountainTF.localScale.y, 0f);
        isSleeping = true;

        foreach (var obj in objectOnActived) { obj.SetActive(false); }
        transitionCoroutine = null;
    }

    private void OnDrawGizmos()
    {
        DrawArrow.ForGizmo(transform.position, Vector3.up * defaultHeight, Color.magenta);
    }
}
