using Sirenix.OdinInspector;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UIElements;

public class Interactable_LaserWheel : SerializedMonoBehaviour
{
    [SerializeField,Range(0,360)] private float[] rotationAngles;
    [SerializeField] private AnimationCurve rotateCurve;
    [SerializeField] private float rotateTime = 1.0f;
    [SerializeField] private float laserMaxLength;
    [SerializeField,MinMaxSlider(0f,5f)] private Vector2 flareFlikerRange;
    [SerializeField] private float flareFlikerSpeed = 1f;
    [SerializeField, FoldoutGroup("ChildReference")] private Transform laserStartPoint;
    [SerializeField, FoldoutGroup("ChildReference")] private LensFlareComponentSRP flare;


    Coroutine rotateProgress = null;
    int currentIndex = 0;
    Vector3? initialForward;

    private void Start()
    {
        Array.Sort(rotationAngles);
        initialForward = transform.forward;
    }

    private void Update()
    {
        if(flare != null)
        {
            flare.intensity = Mathf.Lerp(flareFlikerRange.x,flareFlikerRange.y,Mathf.PerlinNoise1D(Time.time * flareFlikerSpeed));
        }
    }

    [HideInEditorMode(),Button()]
    public void RotateWheel()
    {
        if (rotateProgress != null) return;

        int nextIndex = currentIndex;

        if (nextIndex + 1 >= rotationAngles.Length) nextIndex = 0;
        else nextIndex++;

        rotateProgress = StartCoroutine(Cor_RotateWheel(rotationAngles[currentIndex],rotationAngles[nextIndex]));
        currentIndex = nextIndex;
    }

    IEnumerator Cor_RotateWheel(float prev,float next)
    {
        float rotateTime = Mathf.DeltaAngle(prev, next)/360 * this.rotateTime;

        for (float time = 0; time < rotateTime; time+= Time.fixedDeltaTime)
        {
            float t = rotateCurve.Evaluate(time/rotateTime);
            transform.localRotation = Quaternion.LerpUnclamped(Quaternion.AngleAxis(prev,transform.up),Quaternion.AngleAxis(next,transform.up), t);
            yield return new WaitForFixedUpdate();
        }

        transform.localRotation = Quaternion.AngleAxis(next, transform.up);

        rotateProgress = null;
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.blue;
        DrawArrow.ForGizmo(transform.position + Vector3.up * 1.9f, transform.forward * laserMaxLength);

        for (int i = 0; i < rotationAngles.Length; i++)
        {
            Gizmos.color = Color.red;
            if (initialForward != null)
            {
                Vector3 direction = Quaternion.AngleAxis(rotationAngles[i], transform.up) * initialForward.Value * laserMaxLength;
                DrawArrow.ForGizmo(transform.position + Vector3.up * 1, direction);
            }
            else
            {
                Vector3 direction = Quaternion.AngleAxis(rotationAngles[i], transform.up) * transform.forward * laserMaxLength;
                DrawArrow.ForGizmo(transform.position + Vector3.up * 1, direction);
            }
        }


    }


}
