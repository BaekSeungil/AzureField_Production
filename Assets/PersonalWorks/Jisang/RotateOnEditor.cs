using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RotateOnEditor : MonoBehaviour
{
    [SerializeField]
    private Vector3 Axis;

    [SerializeField]
    private AnimationCurve curve;

    void Update()
    {
        transform.Rotate(Axis * curve.Evaluate(Mathf.Repeat(Time.time, 1)), Space.Self);
    }
}
