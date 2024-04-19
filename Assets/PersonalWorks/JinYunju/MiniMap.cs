using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Serialization;
using UnityEngine.InputSystem;
using Unity.Transforms;
using Unity.Entities.UniversalDelegates;

namespace MapScripts
{
    public enum MapMode
    {
        mini,
        Fullscreen
    }

    public class MiniMap : MonoBehaviour
    {
        public static MiniMap MiniMapInstance;
        public MapMode mapMode;

        public Transform player;

        public RectTransform playerIcon;
        


        
        public bool enableMap = false;

        // Start is called before the first frame update
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {
            float zoom = Mouse.current.scroll.ReadValue().y;

        }

        public static MiniMap GetMiniMapInstance()
        {
            if(MiniMapInstance == null)
            {
                return new MiniMap();
            }

            return MiniMapInstance;
        }
    }


    public class GameMaputilities
    {
        #region Map Function
        // 맵 기능 관련 클래스

        public static GameMaputilities FunctionInstace;
        public static GameMaputilities GetGameMaputilities()
        {
            if(FunctionInstace == null)
            {
                return new GameMaputilities();
            }

            return FunctionInstace;
        }

        // 맵 줌 관련 기능

        private static Vector2 halfVector2 = new Vector2(0.5f,0.5f);
        public static void SetminiMapmode(MapMode mod)
        {   
            
            GameMapData gameMapData1= GameMapData.GetInstance();
            MiniMap miniMap = MiniMap.GetMiniMapInstance();
            const float defaultScaleWhenFullScreen = 1.3f;
            if(mod == MiniMap.MiniMapInstance.mapMode)
            return;

            switch(mod)
            {
                case MapMode.mini:
                gameMapData1.mapScrollRect.sizeDelta = gameMapData1.scrollViewDefaultSize;
                gameMapData1.mapScrollRect.anchorMin = Vector2.one;
                gameMapData1.mapScrollRect.anchorMax = Vector2.one;
                gameMapData1.mapScrollRect.pivot = Vector2.one;
                gameMapData1.mapScrollRect.anchoredPosition = gameMapData1.scrollViewDefaultPosition;
                MiniMap.MiniMapInstance.mapMode = MapMode.mini;
                break;

                case MapMode.Fullscreen:
                gameMapData1.mapScrollRect.sizeDelta = gameMapData1.fullScreenDimensions;
                gameMapData1.mapScrollRect.anchorMin = halfVector2;
                gameMapData1.mapScrollRect.anchorMax = halfVector2;
                gameMapData1.mapScrollRect.pivot = halfVector2;
                gameMapData1.mapScrollRect.anchoredPosition = Vector2.zero;
                MiniMap.MiniMapInstance.mapMode = MapMode.Fullscreen;
                gameMapData1.mapCanvasRect.transform.localScale = 
                Vector3.one * defaultScaleWhenFullScreen;
                break;

            }
        }




        public static void MapZoom(float zoom)
        {
            if(zoom == 0)
            return;

            GameMapData gameMapData1= GameMapData.GetInstance();
            RectTransform mapCavasRect = gameMapData1.mapCanvasRect;
            float currentMapScale = mapCavasRect.localScale.x;

            float zoomAmount = (zoom > 0 ? gameMapData1.zoomSpeed : -gameMapData1.zoomSpeed) * currentMapScale;
            float newScale = currentMapScale + zoomAmount;
            float clampedScale = Mathf.Clamp(newScale, gameMapData1.minZoom, gameMapData1.maxZoom);
            mapCavasRect.localScale = Vector3.one * clampedScale;
        }






        #endregion
    }


    [Serializable]
    public class GameMapData
    {
        #region Map Data
        // 맵 데이터 조정 클래스
        public static GameMapData Datainstance;
        public Transform sceneMax;
        public Vector3 sceneMaxV3;
        public Transform sceneMin;
        public Vector3 sceneMinV3;

        public bool TrackPlayer = true;

        [HideInInspector] public Vector2 sceneSize;
        [HideInInspector] public Vector3 MapPoint;
        [HideInInspector] public RectTransform maskRect;
        
        [HideInInspector] public Image mapimage;
        [HideInInspector] public MapMode StartMode = 0;
        [HideInInspector] public bool switchMapType;

        [SerializeField] public float zoomSpeed = 0.1f;
        [SerializeField] public float maxZoom= 10f;
        [SerializeField] public float minZoom = 1f;
        [SerializeField] public RectTransform mapCanvasRect;
        [SerializeField] public RectTransform mapScrollRect;        
        public float[] floor;
        public Sprite[] mapSprite;

        public Vector2 fullScreenDimensions = new Vector2(1000,1000);

        public Vector2 scrollViewDefaultSize;
        public Vector2 scrollViewDefaultPosition;

        public static GameMapData GetInstance()
        {
            if (Datainstance == null)
            {
                Datainstance = new GameMapData();
            }

            return Datainstance;
        }
        



        #endregion

    }

}

