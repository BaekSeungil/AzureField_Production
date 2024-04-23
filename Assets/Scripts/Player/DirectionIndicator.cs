using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DirectionIndicator : MonoBehaviour
{
    private Transform target_transform;
    private Vector3 target_vector;
    [SerializeField] private GameObject visualGroup;
    [SerializeField] private Transform directionTransformObject;

    bool isTransformMode = false;

    private void Update()
    {
        if (visualGroup.activeInHierarchy)
        {
            if (isTransformMode)
                directionTransformObject.forward = (target_transform.position - PlayerCore.Instance.transform.position).normalized;
            if (!isTransformMode)
                directionTransformObject.forward = (target_vector - PlayerCore.Instance.transform.position).normalized;
        }
    }

    public void EnableIndicator(Transform target)
    {
        visualGroup.SetActive(true);
        isTransformMode = true;
        target_transform = target;
    }

    public void EnableIndicator(Vector3 target)
    {
        visualGroup.SetActive(true);
        isTransformMode = false;
        target_vector = target;
    }

    public void DisableIndicator()
    {
        visualGroup.SetActive(false);
    }


}
