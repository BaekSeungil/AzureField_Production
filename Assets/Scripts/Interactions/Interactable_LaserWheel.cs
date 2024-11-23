using FMODUnity;
using InteractSystem;
using Sirenix.OdinInspector;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UIElements;

public class Interactable_LaserWheel : SerializedMonoBehaviour, IInteract
{
    [Serializable]
    public struct AngleSet
    {
        [LabelText("정지 각도"), Range(0, 360)] public float rotationAngle;
        [LabelText("정답 여부")] public bool isDesiredAngle;
    }
    [SerializeField, LabelText("활성화 됨")] private bool enabled = true;
    public bool Enabled { get { return enabled; } set { enabled = value; } }
    [SerializeField, LabelText("각도 세팅")] private AngleSet[] angleSets;
    [SerializeField, LabelText("회전 커브")] private AnimationCurve rotateCurve;
    [SerializeField, LabelText("회전 시간")] private float rotateTime = 1.0f;
    [SerializeField, LabelText("최대 레이저 길이")] private float laserMaxLength;

    [SerializeField, Title("")] private LayerMask laserCollide;
    [SerializeField,MinMaxSlider(0f,5f)] private Vector2 flareFlikerRange;
    [SerializeField] private float flareFlikerSpeed = 1f;

    [SerializeField, FoldoutGroup("ChildReference")] private GameObject laserObject;
    [SerializeField, FoldoutGroup("ChildReference")] private Transform laserStartPoint;
    [SerializeField, FoldoutGroup("ChildReference")] private GameObject laserRay;
    [SerializeField, FoldoutGroup("ChildReference")] private LensFlareComponentSRP flare;
    [SerializeField, FoldoutGroup("ChildReference")] private GameObject endParticle;
    [SerializeField, FoldoutGroup("ChildReference")] private StudioEventEmitter spinSound;

    int currentIndex = 0;

    public bool IsDesired
    {
        get
        {
            return angleSets[currentIndex].isDesiredAngle && !obstructed;
        }
    }

    private bool isEnabled = true;
    [SerializeField,ReadOnly()]private bool obstructed = false;
    public bool IsEnabled { get { return isEnabled; } set { isEnabled = value; } }

    ParticleSystem endParticlePS;

    Coroutine rotateProgress = null;
    Vector3? initialForward;
    Quaternion initialRotation;
    

    private void Start()
    {

        angleSets = angleSets.OrderBy(i => i.rotationAngle).ToArray();
        initialRotation = transform.localRotation;
        transform.localRotation = initialRotation * Quaternion.AngleAxis(angleSets[0].rotationAngle, transform.up);
        initialForward = transform.forward;
    }

    Vector3 debug_hitpoint;

    private void Update()
    {
        debug_hitpoint = Vector3.zero;

        if(laserObject.activeInHierarchy)
        {
            flare.intensity = Mathf.Lerp(flareFlikerRange.x,flareFlikerRange.y,Mathf.PerlinNoise1D(Time.time * flareFlikerSpeed));

            Ray ray = new Ray(laserStartPoint.position, laserStartPoint.forward);
            RaycastHit[] rhit = Physics.RaycastAll(ray,laserMaxLength,laserCollide,QueryTriggerInteraction.Ignore);

            Vector3 laserScale = laserRay.transform.localScale;
            if (rhit.Length != 0)
            {
                rhit = rhit.OrderBy(i => i.distance).ToArray();

                debug_hitpoint = rhit[0].point;

                float laserLength = Vector3.Distance(rhit[0].point, laserStartPoint.position);
                laserRay.transform.localScale = new Vector3(laserScale.x, laserScale.y, laserLength/transform.localScale.z);
                endParticle.SetActive(true);
                endParticle.transform.localPosition = Vector3.forward * laserLength / transform.localScale.z;

                obstructed = rhit[0].collider.CompareTag("LaserObstruction");
            }
            else
            {
                laserRay.transform.localScale = new Vector3(laserScale.x, laserScale.y, laserMaxLength/transform.localScale.z);
                endParticle.SetActive(false);
            }
        }
    }

    /// <summary>
    /// 조각상이 각도 세팅 배열 순서로 회전합니다.
    /// </summary>
    [HideInEditorMode(),Button()]
    public void RotateWheel()
    {
        if (!enabled) return;

        if (rotateProgress != null) return;
        if (!laserObject.activeInHierarchy) return;
        if (!isEnabled) return;

        spinSound.Play();

        int nextIndex = currentIndex;

        if (nextIndex + 1 >= angleSets.Length) nextIndex = 0;
        else nextIndex++;

        rotateProgress = StartCoroutine(Cor_RotateWheel(angleSets[currentIndex].rotationAngle,angleSets[nextIndex].rotationAngle,nextIndex));

    }

    IEnumerator Cor_RotateWheel(float prev, float next, int index)
    {
        float rotateTime = Mathf.DeltaAngle(prev, next) / 360 * this.rotateTime;

        for (float time = 0; time < rotateTime; time += Time.fixedDeltaTime)
        {
            float t = rotateCurve.Evaluate(time / rotateTime);
            transform.localRotation = initialRotation * Quaternion.LerpUnclamped(Quaternion.AngleAxis(prev, transform.up), Quaternion.AngleAxis(next, transform.up), t);
            yield return new WaitForFixedUpdate();
        }

        transform.localRotation = initialRotation * Quaternion.AngleAxis(next, transform.up);

        currentIndex = index;


        rotateProgress = null;
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.blue;
        DrawArrow.ForGizmo(transform.position + Vector3.up * 1.9f, transform.forward * laserMaxLength);

        for (int i = 0; i < angleSets.Length; i++)
        {
            if (angleSets[i].isDesiredAngle)
            Gizmos.color = Color.green;
            else
            Gizmos.color = Color.red;

            if (initialForward != null)
            {
                Vector3 direction = Quaternion.AngleAxis(angleSets[i].rotationAngle, transform.up) * initialForward.Value * laserMaxLength;
                DrawArrow.ForGizmo(transform.position + Vector3.up * 1, direction);
            }
            else
            {
                Vector3 direction = Quaternion.AngleAxis(angleSets[i].rotationAngle, transform.up) * transform.forward * laserMaxLength;
                DrawArrow.ForGizmo(transform.position + Vector3.up * 1, direction);
            }
        }

        Gizmos.color = Color.cyan;
        Gizmos.DrawSphere(debug_hitpoint, 0.1f);

    }

    public void Interact()
    {
        RotateWheel();
    }
}
