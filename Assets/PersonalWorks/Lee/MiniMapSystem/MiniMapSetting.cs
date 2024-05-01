using Mono.Cecil.Cil;
using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.InputSystem;
public class MiniMapSetting : StaticSerializedMonoBehaviour<MiniMapSetting>
{
    [SerializeField] private bool rotateWidthTheTarget = true;
    [SerializeField] private GameObject minimap;
    [SerializeField] private Camera minimapCamera;
    [SerializeField] private RectTransform cursorTransform;
    [SerializeField] private RectTransform northpointTransform;
    [SerializeField] private AnimationCurve sizeTranisitionCurve;

    private bool SetMinimap = false;

    private MainPlayerInputActions input;
    public MainPlayerInputActions Input { get { return input; } }


    protected override void Awake()
    {
        base.Awake();
        input = new MainPlayerInputActions();
    }

    private void OnEnable()
    {
        input.UI.MapToggle.performed += ToggleMap;
    }

    private void OnDisable()
    {
        input.UI.MapToggle.performed -= ToggleMap;
    }

    private void Update()
    {
        if (PlayerCore.IsInstanceValid)
        {
            if (rotateWidthTheTarget)
            {
                minimapCamera.transform.rotation = Quaternion.Euler(90f, 0f, Mathf.Rad2Deg * Mathf.Atan2(Camera.main.transform.forward.z, Camera.main.transform.forward.x) - 90f);
                northpointTransform.transform.rotation = Quaternion.Euler(0f, 0f, Mathf.Rad2Deg * Mathf.Atan2(-Camera.main.transform.forward.z, Camera.main.transform.forward.x) +90f);
                cursorTransform.transform.rotation = Quaternion.Euler(0f, 0f, 0f);
            }
            else
            {
                minimapCamera.transform.rotation = Quaternion.Euler(90f, 0f, 0f);
                northpointTransform.transform.rotation = Quaternion.Euler(0f, 0f,0f);
                cursorTransform.rotation = Quaternion.Euler(0f, 0f, Mathf.Rad2Deg * Mathf.Atan2(Camera.main.transform.forward.z, Camera.main.transform.forward.x) - 90f);
            }

        }
    }

    public void ToggleMap(InputAction.CallbackContext context)
    {

        if (SetMinimap)
        {
            Outmap();

        }
        else
        {
            Setmap();
        }

    }

    public void Setmap()
    {
        minimap.SetActive(true);
        SetMinimap = true;
    }

    public void Outmap()
    {
        minimap.SetActive(false);
        SetMinimap = false;
    }

    float transitionTime = 1.5f;

    [Button()]
    public void SetMapSize(float size)
    {
        StopAllCoroutines();
        StartCoroutine(Cor_SetMapSize(size, transitionTime));

    }

    IEnumerator Cor_SetMapSize(float size, float animationTime)
    {
        float startSize = minimapCamera.orthographicSize;

        for(float t = 0; t < 1f; t+=Time.fixedDeltaTime / animationTime)
        {
            minimapCamera.orthographicSize = Mathf.Lerp(startSize, size, sizeTranisitionCurve.Evaluate(t));
            yield return new WaitForFixedUpdate();
        }

        minimapCamera.orthographicSize = size;
    }


}
