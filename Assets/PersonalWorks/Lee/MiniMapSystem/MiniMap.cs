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

        public GameMapData mapdataInfo = new GameMapData();
        public MapMode mapMode;

        public Transform player;

        public RectTransform playerIcon;
       
        public bool enableMap = true;

        // Start is called before the first frame update
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {
            MapUpdate(player);
        }

        public void MapDataInitialization(GameMapData mapdata)
        {
            if(mapdata.sceneMax != null && mapdata.sceneMin != null)
            {
                mapdata.sceneMaxV3 = mapdata.sceneMax.position;
                mapdata.sceneMinV3 = mapdata.sceneMin.position;
            }

            if(mapdata.sceneMaxV3 != null && mapdata.sceneMinV3 != null)
            {
                mapdata.sceneSize.y = mapdata.sceneMaxV3.z - mapdata.sceneMinV3.z;
                mapdata.sceneSize.x = mapdata.sceneMaxV3.x - mapdata.sceneMinV3.x;
                mapdata.MapPoint = (mapdata.sceneMaxV3 + mapdata.sceneMinV3) /2;
            }

            foreach(Transform child in this.gameObject.GetComponentInChildren<Transform>(true))
            {
                if(mapdata.mapimage != null && mapdata.maskRect != null && mapdata.mapCanvasRect != null)
                {
                    break;
                }
            }
        }

        public void MapUpdate(Transform Playerpos)
        {
            if(mapdataInfo.TrackPlayer)
            {
                MapPosTrackTarget(mapdataInfo, Playerpos.position);
                IconPos(mapdataInfo, Playerpos,playerIcon);
            }

            GameMaputilities gameMaputilities= GameMaputilities.GetGameMaputilities();
            float zoom = Mouse.current.scroll.ReadValue().y;
            gameMaputilities.MapZoom(zoom);

            if(mapdataInfo.floor.Length > 1)
            {
                MapImageSwith(mapdataInfo.floor, mapdataInfo.mapSprite, Playerpos, mapdataInfo.mapimage);
            }
        }

        public void IconSpin(RectTransform icon, float angle = 0f)
        {
            var temp_Spin_Value = new Vector3();
            temp_Spin_Value.x = 0;
            temp_Spin_Value.y = 0;
            temp_Spin_Value.z = angle;
            icon.localRotation = Quaternion.Euler(temp_Spin_Value);
        }

        public void IconPos(GameMapData gameMapData, Transform player, RectTransform playerIcon)
        {
            var temp_player_pos_1 = new Vector3();
            var temp_player_pos_2 = player.position - gameMapData.MapPoint;
            
            temp_player_pos_1.x = Mathf.Clamp((temp_player_pos_2.x / gameMapData.sceneSize.x * 
            gameMapData.mapCanvasRect.rect.width),-gameMapData.mapCanvasRect.rect.width /2, gameMapData.mapCanvasRect.rect.width/2);

            temp_player_pos_1.y = Mathf.Clamp((temp_player_pos_2.z / gameMapData.sceneSize.y * gameMapData.mapCanvasRect.rect.height),
            -gameMapData.mapCanvasRect.rect.height / 2, gameMapData.mapCanvasRect.rect.height /2);

            playerIcon.localPosition = temp_player_pos_1;
        }

        public void MapPosTrackTarget(GameMapData mapdata, Vector3 player)
        {   
            var temp_map_pos = new Vector3();
            var temp_player_pos = player - mapdata.MapPoint;
            temp_map_pos.x =
            Mathf.Clamp((-temp_player_pos.x / mapdata.sceneSize.x*mapdata.mapCanvasRect.rect.width),
            -((mapdata.mapCanvasRect.rect.width / 2)- (mapdata.maskRect.rect.width/2)),
            (mapdata.mapCanvasRect.rect.width /2)- (mapdata.maskRect.rect.width/2));

            temp_player_pos.y =
            Mathf.Clamp((-temp_player_pos.z / mapdata.sceneSize.y* mapdata.mapCanvasRect.rect.height),
            ((-mapdata.mapCanvasRect.rect.height / 2)- (mapdata.maskRect.rect.height/2)),
            (mapdata.mapCanvasRect.rect.height/2)-(mapdata.maskRect.rect.height /2));

            mapdata.mapCanvasRect.localPosition = temp_map_pos;


        }

        public void MapImageSwith(float[] floor, Sprite[] imagelist, Transform player, Image map_Image)
        {
            for(int i = floor.Length -1; i> -1; i--)
            {
                if(player.position.y >= floor[i])
                {
                    map_Image.sprite = imagelist[i];
                    break;
                }
            }
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
        public void SetminiMapmode(MapMode mod)
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

        public void MapZoom(float zoom)
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

        public static void MapMove(GameMapData mapData, Vector3 moveTemp)
        {
            mapData.mapCanvasRect.localPosition += moveTemp;
        }


        #endregion
    }


    [Serializable]
    public class GameMapData
    {
        #region Map Data
        // 맵 데이터 조정 클래스
        public static GameMapData DataInstance;
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
            if (DataInstance == null)
            {
                DataInstance = new GameMapData();
            }

            return DataInstance;
        }
        



        #endregion

    }

}

