using Mono.Cecil.Cil;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.InputSystem;
public class MiniMapSetting : MonoBehaviour
{
    public Transform targetFollow;
    public bool rotateWidthTheTarget = true;
    [SerializeField] public GameObject minimap;

    [SerializeField] RectTransform scrollViewRectTransform;

    [SerializeField] RectTransform contentRectTransform;

    [SerializeField] float zoomSpeed = 0.1f;
    [SerializeField] float maxZoom= 10f;
    [SerializeField] float minZoom = 1f;

    private Vector2 scrollViewDeaultSize;
    private Vector2 scrollViewDefaultPos;

    private bool SetMinimap = false;

    private void Awake() 
    {
        scrollViewDeaultSize = scrollViewRectTransform.sizeDelta;
        scrollViewDefaultPos = scrollViewRectTransform.anchoredPosition;
    }

    void Update() 
    {
        if(Keyboard.current[Key.M].wasPressedThisFrame)
        {
            if(SetMinimap)
            {
                Outmap();
                
            }
            else
            {
                Setmap();
            }
        }

        // float zoom = Mouse.current.scroll.ReadValue().y;
        // ZoomMap(zoom);
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

    private void ZoomMap(float zoom)
    {
        if(zoom == 0)
        return;

        float currentMapScale = contentRectTransform.localScale.x;
        float zoomAmount = (zoom > 0 ? zoomSpeed : -zoomSpeed) * currentMapScale;
        float newScale = currentMapScale + zoomAmount;
        float clampedScale = Mathf.Clamp(newScale, minZoom, maxZoom);
        contentRectTransform.localScale = Vector3.one * clampedScale;
    }


}
