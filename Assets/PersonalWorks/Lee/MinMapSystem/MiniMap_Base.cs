using AmplifyShaderEditor;
using System.Collections;
using System.Collections.Generic;
using Unity.Entities;
using UnityEditor.Experimental.GraphView;
using UnityEngine;
using UnityEngine.InputSystem;

public enum MiniMapMod
{
    Mini,
    Fullscreen
}

public class MiniMap_Base : MonoBehaviour
{
    public static MiniMap_Base Instance;
    [SerializeField] Vector2 worldsize;
    [SerializeField] 
    Vector2 fullScrennDimensions = new Vector2(1000,1000);
    [SerializeField] float zoomSpeed = 0.1f;
    [SerializeField] float maxZoom= 10f;
    [SerializeField] float minZoom = 1f;

    [SerializeField]
    RectTransform scrollViewRectTransform;
    [SerializeField]
    RectTransform contentRectTransform;
    [SerializeField]
    MiniMap_Icon miniMapPrefab;

    Matrix4x4 transformationMatix;

    private MiniMapMod currentMiniMapMode =  MiniMapMod.Mini;
    private MiniMap_Icon followIcon;
    private Vector2 scrollViewDefaultSize;
    private Vector2 scrollViewDefaultPosition;


    Dictionary<MiniMap_Object,MiniMap_Icon> miniMapWorldObjectLookup =
    new Dictionary<MiniMap_Object, MiniMap_Icon>();

    private void Awake()
    {
        Instance = this;
        scrollViewDefaultSize = scrollViewRectTransform.sizeDelta;
        scrollViewDefaultPosition = scrollViewRectTransform.anchoredPosition;

    }

    private void Start() 
    {
        CalculateTransformationMatrix();
    }

    private void Update()
    {
        if(Keyboard.current[Key.M].wasPressedThisFrame)
        {
            SetMinimapMode(currentMiniMapMode == MiniMapMod.Mini ? MiniMapMod.Fullscreen : MiniMapMod.Mini);
        }

       float zoom = Mouse.current.scroll.ReadValue().y;
       ZoomMap(zoom);
       UpdateMiniMapIcons();
       CenterMapOnIcon();
    }

    public void RegisterMinimapWorldObject(MiniMap_Object miniMap_Object, bool followObject = false)
    {
        var minimapIcon = Instantiate(miniMapPrefab);
        minimapIcon.transform.SetParent(contentRectTransform);
        minimapIcon.transform.SetParent(contentRectTransform);
        minimapIcon.Image.sprite = miniMap_Object.MiniMapIcon;
        miniMapWorldObjectLookup[miniMap_Object] = minimapIcon;

        if(followObject)
        {
            followIcon = minimapIcon;
        }

    }

    public void RemoveMiniMapWolrdObject(MiniMap_Object minimapobject)
    {
        if(miniMapWorldObjectLookup.TryGetValue(minimapobject,out MiniMap_Icon icon))
        {
            miniMapWorldObjectLookup.Remove(minimapobject);
            Destroy(icon.gameObject);
        }
    }


    // 미니맵 크기 설정
    private Vector2 halfVector2 = new Vector2(0.5f,0.5f);
    public void SetMinimapMode(MiniMapMod mod)
    {
        const float defaultScaleWhenFullScreen = 1.3f;

        if(mod == currentMiniMapMode)
        return;

        switch (mod)
        {
            case MiniMapMod.Mini:
            scrollViewRectTransform.sizeDelta = scrollViewDefaultSize;
            scrollViewRectTransform.anchorMin = Vector2.one;
            scrollViewRectTransform.anchorMax = Vector2.one;
            scrollViewRectTransform.pivot = Vector2.one;
            scrollViewRectTransform.anchoredPosition =scrollViewDefaultPosition;
            currentMiniMapMode = MiniMapMod.Mini;
            break;

            case MiniMapMod.Fullscreen:
            scrollViewRectTransform.sizeDelta = fullScrennDimensions;
            scrollViewRectTransform.anchorMin = halfVector2;
            scrollViewRectTransform.anchorMax = halfVector2;
            scrollViewRectTransform.pivot = halfVector2;
            scrollViewRectTransform.anchoredPosition = Vector2.zero;
            currentMiniMapMode = MiniMapMod.Fullscreen;
            contentRectTransform.transform.localScale = Vector3.one *
            defaultScaleWhenFullScreen;           
            break;   
        }
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

    private void CenterMapOnIcon()
    {
        if(followIcon != null)
        {
            float mapScale = contentRectTransform.transform.localScale.x;

            contentRectTransform.anchoredPosition = (-followIcon.rectTransform.anchoredPosition * mapScale);

        }
    }

    private void UpdateMiniMapIcons()
    {
        float iconscale = 1 / contentRectTransform.transform.localScale.x;
        foreach(var kvp in miniMapWorldObjectLookup)
        {
            var miniMap_Object = kvp.Value;
            var miniMapIcon = kvp.Value;
            var mapPosition = WorldPositionToMapPosition(miniMap_Object.transform.position);

            miniMapIcon.rectTransform.anchoredPosition = mapPosition;
            var rotation = miniMap_Object.transform.rotation.eulerAngles;
            miniMapIcon.iconRectTrans.localRotation = Quaternion.AngleAxis(-rotation.y, Vector3.forward);

        }


    }

    private Vector2 WorldPositionToMapPosition(Vector3 worldPos)
    {
        var pos = new Vector2(worldPos.x, worldPos.z);
        return transformationMatix.MultiplyPoint3x4(pos);
    }

    private void CalculateTransformationMatrix()
    {
        var minimapSize = contentRectTransform.rect.size;
        var worldSize = new Vector2(this.worldsize.x, this.worldsize.y);

        var translation = -minimapSize / 2;
        var scaleRatio = minimapSize / worldSize;

        transformationMatix = Matrix4x4.TRS(translation, Quaternion.identity, scaleRatio);
    }

}
