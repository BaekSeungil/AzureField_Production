using FMODUnity;
using Sirenix.Utilities;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class UI_Marker : StaticSerializedMonoBehaviour<UI_Marker>
{
    [HideInInspector] public Transform markerTarget;

    [SerializeField] private float outScreenPadding = 50f;
    [SerializeField] private GameObject markerAnchor;
    [SerializeField] private GameObject outScreenMarkerImage;
    [SerializeField] private GameObject markerImage;
    [SerializeField] private TextMeshProUGUI distance;

    [SerializeField] private Transform debug_testMarker;

    private RectTransform markerTransform;

    private bool isMarkerActive = false;
    public bool IsMarkerActive { get { return isMarkerActive; } }

    public void SetMarker(Transform target)
    {
        markerAnchor.SetActive(true);
        markerTarget = target;
    }

    public void DisableMarker()
    {
        markerAnchor.SetActive(false);
    }

    protected override void Awake()
    {
        base.Awake();
        markerTransform = markerAnchor.GetComponent<RectTransform>();
    }

    private void Start()
    {
        outScreenMarkerImage.SetActive(false);
        markerAnchor.SetActive(false);

        SetMarker(debug_testMarker);
    }

    private void Update()
    {
        if (!markerAnchor.activeInHierarchy) return;
        if (markerTarget == null) { return; }
        if (!PlayerCore.IsInstanceValid)
        {
            Debug.LogError("PlayerCore가 없습니다."); return;
        }

        distance.text = ((int)Vector3.Distance(PlayerCore.Instance.transform.position, markerTarget.position)).ToString() + "M";

        Vector2 markerPosition = Vector2.zero;


        if (TargetVisible(markerTarget.position))
        {
            outScreenMarkerImage.SetActive(false);
            markerImage.SetActive(true);
            markerPosition = Camera.main.WorldToScreenPoint(markerTarget.position);
        }
        else
        {
            outScreenMarkerImage.SetActive(true);
            markerImage.SetActive(false);
            markerPosition = Camera.main.WorldToScreenPoint(markerTarget.position);
            if (Vector3.Dot((markerTarget.position - Camera.main.transform.position), Camera.main.transform.forward) < 0) markerPosition = -markerPosition;
            outScreenMarkerImage.transform.up = markerPosition-(new Vector2(Screen.width / 2f, Screen.height / 2f));

            markerPosition = markerPosition.Clamp(new Vector2(0 + outScreenPadding, +0f + outScreenPadding), new Vector2(Screen.width - outScreenPadding, Screen.height - outScreenPadding));



        }

        markerTransform.position = markerPosition;
    }

    private bool TargetVisible(Vector3 worldPos)
    {
        Vector3 point = Camera.main.WorldToViewportPoint(worldPos);

        
        if (point.x > 0 +outScreenPadding/Screen.width && point.x <= 1 - outScreenPadding / Screen.width && point.y >= 0 + outScreenPadding / Screen.height && point.y <= 1 - outScreenPadding / Screen.height  && point.z > 0)
        {
            return true;
        }
        else
            return false;
    }

}
