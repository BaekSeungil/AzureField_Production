using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal.Internal;

public class GeyserLift : Interactable_Base
{
    [SerializeField, LabelText("일회성")] private bool disableAfterFinished = false;
    [SerializeField, LabelText("상승 높이")] private float liftHeight = 12f;

    [SerializeField, LabelText("상승 애니메이션")] private AnimationCurve liftAnimation;
    [SerializeField, LabelText("상승 시간")] private float liftingDuration = 1.0f;
    [SerializeField, LabelText("착지 포물선")] private AnimationCurve landingCurve;
    [SerializeField, LabelText("착지 시간")] private float landingDuration = 1.0f;

    [SerializeField, Required(), FoldoutGroup("ChildReferences")] private GameObject idleEffect;
    [SerializeField, Required(), FoldoutGroup("ChildReferences")] private GameObject activateEffect;
    [SerializeField, Required(), FoldoutGroup("ChildReferences")] private GameObject activeLoopEffect;
    [SerializeField, Required(), FoldoutGroup("ChildReferences")] private GameObject disableEffect;
    [SerializeField, Required(), FoldoutGroup("ChildReferences")] private Transform landpoint;

    private bool liftInProgress = false;
    private bool interacted = false;

    public override void Interact()
    {
        base.Interact();

        if (disableAfterFinished && interacted) return;
        if (liftInProgress) return;

        StartCoroutine(Cor_LiftProgress());

    }


    private void FixedUpdate()
    {
        if (!GlobalOceanManager.IsInstanceValid) return;

        transform.position = new Vector3(transform.position.x,GlobalOceanManager.Instance.GetWaveHeight(transform.position),transform.position.z);
    }

    private IEnumerator Cor_LiftProgress()
    {
        liftInProgress = true;
        PlayerCore.Instance.DisableControls();

        float alignTime = 0.5f;

        for(float t = 0; t < alignTime; t += Time.fixedDeltaTime)
        {

        }

        yield return null;
    }


    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        DrawArrow.ForGizmo(transform.position, Vector3.up * liftHeight);
        DrawArrow.ForGizmo(transform.position + Vector3.up * liftHeight, landpoint.position - (transform.position + Vector3.up * liftHeight));
        Gizmos.DrawWireSphere(landpoint.position, 0.5f);
    }

}
