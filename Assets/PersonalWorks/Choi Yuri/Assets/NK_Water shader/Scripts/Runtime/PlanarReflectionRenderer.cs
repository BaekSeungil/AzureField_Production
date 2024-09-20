using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace NKStudio
{
    [ExecuteInEditMode]
    [AddComponentMenu("Water/Planar Reflection Renderer")]
    public class PlanarReflectionRenderer : MonoBehaviour
    {
#if URP
        public static List<PlanarReflectionRenderer> Instances = new List<PlanarReflectionRenderer>();
        public Dictionary<Camera, Camera> ReflectionCameras = new Dictionary<Camera, Camera>();
        
        //Rendering
        [Tooltip("활성화되면 반사 평면은 이 변환의 위쪽 벡터(녹색 화살표)를 기반으로 합니다.\n\n그렇지 않으면 World의 위쪽 방향이 가정됩니다.")]
        public bool Rotatable;
        
        [Tooltip("반사로 렌더링되어야 하는 레이어를 설정합니다. \"Water\" 레이어는 항상 제외됩니다.")]
        public LayerMask CullingMask = -1;
        
        [Tooltip("반사 카메라가 사용하는 렌더러입니다. 반사를 위해 사용자 정의 렌더링 기능이 실행되지 않도록 별도의 렌더러를 만드는 것이 좋습니다.")]
        public int RendererIndex = -1;

        [Min(0f)]
        public float Offset = 0.05f;
        
        [Tooltip("비활성화되면 스카이박스 반사는 반사 프로브에서 나옵니다. 이는 평면/평면형이 아닌 전방향성이라는 이점이 있습니다. 어쨌든 스카이박스를 평면 반사로 렌더링하려면 이 옵션을 활성화했습니다.")]
        public bool IncludeSkybox;

        //Quality
        public bool RenderShadows;
        
        [Tooltip("이 범위를 벗어나는 개체는 반사에 렌더링되지 않습니다. 이로 인해 크거나 키가 큰 개체의 경우 팝 현상이 발생할 수 있습니다.")]
		public float RenderRange = 500f;
        
        [Range(0.25f, 1f)] 
        [Tooltip("현재 화면 해상도를 기반으로 하는 렌더링 해상도의 승수입니다. 파이프라인 설정에 구성된 렌더 스케일이 여기에 곱해집니다.")]
		public float RenderScale = 0.75f;

        [Range(0, 4)]
        [Tooltip("이 값보다 낮은 LOD 객체를 렌더링하지 마십시오. 예: 값이 1이면 LOD 그룹의 LOD0이 사용되지 않습니다.")]
        public int MaximumLODLevel;
        
        [SerializeField]
        public List<WaterObject> WaterObjects = new List<WaterObject>();
        
        [Tooltip("활성화되면 렌더링 경계의 중심(물 개체를 둘러싸는)이 변환 위치와 함께 이동합니다." +
                 "\n\n그러나 XZ 축에서만 이동하고 있는지 확인해야 합니다.")]
        public bool MoveWithTransform;
        
        [HideInInspector]
        public Bounds Bounds;

        private float _mRenderScale = 1f;
        private float _mRenderRange;

        /// <summary>
        /// Reflections will only render if this is true. Value can be set through the static SetQuality function
        /// </summary>
        public static bool AllowReflections { get; private set; } = true;

        private static readonly int PlanarReflectionsEnabledID = Shader.PropertyToID("_PlanarReflectionsEnabled");
        private static readonly int PlanarReflectionID = Shader.PropertyToID("_PlanarReflection");
        
        [NonSerialized]
        public bool IsRendering;

        private Camera reflectionCamera;
		private static UniversalAdditionalCameraData _mCameraData;
        
        private void Reset()
        {
            gameObject.name = "Planar Reflection Renderer";
        }
        
        private void OnEnable()
        {
            InitializeValues();

            Instances.Add(this);
            EnableReflections();
        }

        private void OnDisable()
        {
            Instances.Remove(this);
            DisableReflections();
        }

        public void InitializeValues()
        {
            _mRenderScale = RenderScale;
            _mRenderRange = RenderRange;
        }

        /// <summary>
        /// WaterObject.Instances 목록의 모든 물 개체를 할당하고 이에 대한 반사를 활성화합니다.
        /// </summary>
        public void ApplyToAllWaterInstances()
        {
            WaterObjects = new List<WaterObject>(WaterObject.Instances);
            RecalculateBounds();
            EnableMaterialReflectionSampling();
        }

        /// <summary>
        /// 반사를 토글하거나 모든 반사 렌더러에 대한 렌더링 배율을 설정합니다. 이는 메뉴의 성능 확장 또는 그래픽 설정과 연결될 수 있습니다.
        /// </summary>
        /// <param name="enableReflections">반사 렌더링을 토글하고 할당된 모든 물 개체에 대해 이를 토글합니다.</param>
        /// <param name="renderScale">현재 화면 해상도에 대한 승수입니다. URP에 구성된 렌더 스케일도 고려됩니다.</param>
        /// <param name="renderRange">이 범위를 넘어서는 객체는 반사로 렌더링되지 않습니다.</param>
        public static void SetQuality(bool enableReflections, float renderScale = -1f, float renderRange = -1f, int maxLodLevel = -1)
        {
            AllowReflections = enableReflections;
            
            foreach (PlanarReflectionRenderer renderer in Instances)
            {
                if (renderScale > 0) renderer.RenderScale = renderScale;
                if (renderRange > 0) renderer.RenderRange = renderRange;
                if (maxLodLevel >= 0) renderer.MaximumLODLevel = maxLodLevel;
                renderer.InitializeValues();

                if (enableReflections) renderer.EnableReflections();
                if (!enableReflections) renderer.DisableReflections();
            }
        }

        public void EnableReflections()
        {
            if (!AllowReflections) return;

            RenderPipelineManager.beginCameraRendering += OnWillRenderCamera;
            ToggleMaterialReflectionSampling(true);
        }

        public void DisableReflections()
        {
            RenderPipelineManager.beginCameraRendering -= OnWillRenderCamera;
            ToggleMaterialReflectionSampling(false);

            //Clear cameras
            foreach (var kvp in ReflectionCameras)
            {
                if (kvp.Value == null) continue;

                if (kvp.Value)
                {
                    RenderTexture.ReleaseTemporary(kvp.Value.targetTexture);
                    DestroyImmediate(kvp.Value.gameObject);
                }
            }

            ReflectionCameras.Clear();
        }

        private void OnDrawGizmosSelected()
        {
            Gizmos.color = Bounds.size.y > 0.01f ? Color.yellow : Color.white;
            Gizmos.DrawWireCube(Bounds.center, Bounds.size);
        }

        public Bounds CalculateBounds()
        {
            Bounds mBounds = new Bounds(Vector3.zero, Vector3.zero);
            
            if (WaterObjects == null) return mBounds;
            if (WaterObjects.Count == 0) return mBounds;

            Vector3 minSum = Vector3.one * Mathf.Infinity;
            Vector3 maxSum = Vector3.one * Mathf.NegativeInfinity;
            
            for (int i = 0; i < WaterObjects.Count; i++)
            {
                if (!WaterObjects[i]) continue;
                    
                minSum = Vector3.Min(WaterObjects[i].MeshRenderer.bounds.min, minSum);
                maxSum = Vector3.Max(WaterObjects[i].MeshRenderer.bounds.max, maxSum);
            }
            
            mBounds.SetMinMax(minSum, maxSum);

            // 중심으로 평평하게 처리
            mBounds.size = new Vector3(mBounds.size.x, 0f, mBounds.size.z);

            return mBounds;
        }

        public void RecalculateBounds()
        {
            Bounds = CalculateBounds();
        }

        /// <summary>
        /// 이 코드는 씬 뷰가 아니고 (SceneView), 리플렉션(Reflection)이나 프리뷰(Preview) 모드를 사용하거나 hideFlags가 설정된(None이 아닌) 카메라를 검색하는 데 사용될 수 있을 것입니다.
        /// </summary>
        /// <param name="camera">카메라 타입을 검사할 카메라</param>
        /// <returns>CameraType.SceneView가 아니고, 다음 세 가지 조건 중 하나라도 참인 경우에 true를 반환합니다</returns>
        public static bool InvalidCamera(Camera camera)
        {
            CameraType cameraType = camera.cameraType;
            return (cameraType != CameraType.SceneView && (cameraType == CameraType.Reflection || cameraType == CameraType.Preview || camera.hideFlags != HideFlags.None));
        }

        private void OnWillRenderCamera(ScriptableRenderContext context, Camera camera)
        {
            // 특수 용도의 카메라는 건너뜁니다. (씬 뷰 카메라 제외)
            if (InvalidCamera(camera))
            {
                IsRendering = false;
                return;
            }

            IsRendering = WaterObjectsVisible(camera);
            
            // 참고: 창에 포커스가 맞춰지지 않은 경우에도 씬 카메라는 계속 렌더링됩니다!
            if (IsRendering == false) return;
            
            if (MoveWithTransform) Bounds.center = transform.position;

            UnityEngine.Profiling.Profiler.BeginSample("Planar Reflections", camera);

            _mCameraData = camera.GetComponent<UniversalAdditionalCameraData>();
            if (_mCameraData && _mCameraData.renderType == CameraRenderType.Overlay) return;

            ReflectionCameras.TryGetValue(camera, out reflectionCamera);
            if (reflectionCamera == null) CreateReflectionCamera(camera);
            
            // 반사를 비활성화하면 이 시점에서 파괴될 가능성이 있습니다.
            if (!reflectionCamera) return;

            if (RenderScale != _mRenderScale)
            {
                RenderTexture.ReleaseTemporary(reflectionCamera.targetTexture);
                CreateRenderTexture(reflectionCamera, camera);
                
                _mRenderScale = RenderScale;
            }
            
            UpdateWaterProperties(reflectionCamera);
   
#if UNITY_EDITOR
            // "절두체 외부의 화면 위치" 오류 방지
            if (camera.orthographic && Vector3.Dot(Vector3.up, camera.transform.up) > 0.9999f) return;
#endif
            
            UpdateCameraProperties(camera, reflectionCamera);
            UpdatePerspective(camera, reflectionCamera);

            bool fogEnabled = RenderSettings.fog;
            // 포그는 클립 공간 z 거리를 기반으로 하며 경사 투영에서는 작동하지 않습니다.
            if (fogEnabled) RenderSettings.fog = false;
            int maxLODLevel = QualitySettings.maximumLODLevel;
            QualitySettings.maximumLODLevel = MaximumLODLevel;
            GL.invertCulling = true;

            #pragma warning disable 0618
            UniversalRenderPipeline.RenderSingleCamera(context, reflectionCamera);
            #pragma warning restore 0618
            
            if (fogEnabled) RenderSettings.fog = true;
            QualitySettings.maximumLODLevel = maxLODLevel;
            GL.invertCulling = false;
            
            UnityEngine.Profiling.Profiler.EndSample();
        }

        private float GetRenderScale()
        {
            return Mathf.Clamp(RenderScale * UniversalRenderPipeline.asset.renderScale, 0.25f, 1f);
        }

        /// <summary>
        /// 런타임 시 렌더러 인덱스가 변경되면 이 함수를 호출하여 반사 카메라를 업데이트해야 합니다.
        /// </summary>
        /// <param name="index"></param>
        public void SetRendererIndex(int index)
        {
            index = PipelineUtilities.ValidateRenderer(index);

            foreach (var kvp in ReflectionCameras)
            {
                if (kvp.Value == null) continue;
                
                _mCameraData = kvp.Value.GetComponent<UniversalAdditionalCameraData>();
                _mCameraData.SetRenderer(index);
            }
        }

        public void ToggleShadows(bool state)
        {
            foreach (var kvp in ReflectionCameras)
            {
                if (kvp.Value == null) continue;
                
                _mCameraData = kvp.Value.GetComponent<UniversalAdditionalCameraData>();
                _mCameraData.renderShadows = state;
            }
        }
        
        /// <summary>
        /// WaterObject를 추가하고 렌더링 범위를 다시 계산합니다.
        /// </summary>
        /// <param name="waterObject"></param>
        public void AddWaterObject(WaterObject waterObject)
        {
            ToggleMaterialReflectionSampling(waterObject, true);
            WaterObjects.Add(waterObject);

            RecalculateBounds();
        }
        
        /// <summary>
        /// WaterObject를 제거하고 렌더링 범위를 다시 계산합니다.
        /// </summary>
        /// <param name="waterObject"></param>
        public void RemoveWaterObject(WaterObject waterObject)
        {
            ToggleMaterialReflectionSampling(waterObject, false);
            WaterObjects.Remove(waterObject);
            
            RecalculateBounds();
        }
        
        /// <summary>
        /// 할당된 물 객체의 MeshRenderers에서 평면 반사를 활성화합니다.
        /// </summary>
        public void EnableMaterialReflectionSampling()
        {
            ToggleMaterialReflectionSampling(AllowReflections);
        }
        
        /// <summary>
        /// 물 셰이더에서 평면 반사 텍스처 샘플링을 토글합니다.
        /// </summary>
        /// <param name="state"></param>
        public void ToggleMaterialReflectionSampling(bool state)
        {
            if (WaterObjects == null) return;

            for (int i = 0; i < WaterObjects.Count; i++)
            {
                if (WaterObjects[i] == null) continue;
                
                ToggleMaterialReflectionSampling(WaterObjects[i], state);
            }
        }

        private void ToggleMaterialReflectionSampling(WaterObject waterObject, bool state)
        {
            waterObject.props.SetFloat(PlanarReflectionsEnabledID, state ? 1f : 0f);
            waterObject.ApplyInstancedProperties();
        }

        private void CreateReflectionCamera(Camera source)
        {
            // 오브젝트 생성
            GameObject go = new GameObject($"{source.name} Planar Reflection");
            go.hideFlags = HideFlags.DontSave | HideFlags.HideInHierarchy;
            
            Camera newCamera = go.AddComponent<Camera>();
            newCamera.hideFlags = HideFlags.DontSave;
            // 씬 뷰 카메라의 경우 원하지 않는 속성도 복사합니다. 카메라 유형과 배경색 등!
            newCamera.CopyFrom(source);
            
            // 항상 물 레이어 제외
            newCamera.cullingMask = ~(1 << 4) & CullingMask;
            // 항상 Game으로 설정해야 합니다. 그렇지 않으면 어쨌든 그림자가 렌더링됩니다.
            newCamera.cameraType = CameraType.Game;
            newCamera.depth = source.depth-1f;
            newCamera.rect = new Rect(0,0,1,1);
            newCamera.enabled = false;
            newCamera.clearFlags = IncludeSkybox ? CameraClearFlags.Skybox : CameraClearFlags.Depth;
            // 씬 뷰의 알파 채널을 유지하는 데 필요합니다.
            newCamera.backgroundColor = Color.clear;
            newCamera.useOcclusionCulling = false;

            // UniversalRenderPipeline.RenderSingleCamera 호출에 필요한 구성요소
            UniversalAdditionalCameraData data = newCamera.gameObject.AddComponent<UniversalAdditionalCameraData>();
            data.requiresDepthTexture = false;
            data.requiresColorTexture = false;
            data.renderShadows = RenderShadows;

            RendererIndex = PipelineUtilities.ValidateRenderer(RendererIndex);
            data.SetRenderer(RendererIndex);

            CreateRenderTexture(newCamera, source);
            
            ReflectionCameras[source] = newCamera;
        }

        private void CreateRenderTexture(Camera targetCamera, Camera source)
        {
            RenderTextureFormat colorFormat = UniversalRenderPipeline.asset.supportsHDR && SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.DefaultHDR) ? RenderTextureFormat.DefaultHDR : RenderTextureFormat.Default;

            float scale = GetRenderScale();

            RenderTextureDescriptor rtDsc = new RenderTextureDescriptor(
                (int)((float)source.scaledPixelWidth * scale),
                (int)((float)source.scaledPixelHeight * scale), 
                colorFormat);

            rtDsc.depthBufferBits = 16;
            
            targetCamera.targetTexture = RenderTexture.GetTemporary(rtDsc);
            targetCamera.targetTexture.name = $"{source.name}_Reflection {rtDsc.width}x{rtDsc.height}";
        }
        
        private static readonly Plane[] FrustrumPlanes = new Plane[6];
        
        public bool WaterObjectsVisible(Camera targetCamera)
        {
            GeometryUtility.CalculateFrustumPlanes(targetCamera.projectionMatrix * targetCamera.worldToCameraMatrix, FrustrumPlanes);

            return GeometryUtility.TestPlanesAABB(FrustrumPlanes, Bounds);
        }

        // 현재 반사 카메라의 렌더 대상을 할당합니다.
        private void UpdateWaterProperties(Camera cam)
        {
            for (int i = 0; i < WaterObjects.Count; i++)
            {
                if (WaterObjects[i] == null) continue;
                
                WaterObjects[i].props.SetTexture(PlanarReflectionID, cam.targetTexture);
                WaterObjects[i].ApplyInstancedProperties();
            }
        }

        private static Vector4 _reflectionPlane;
        private static Matrix4x4 _reflectionBase;
        private static Vector3 _oldCamPos;

        private static Matrix4x4 _worldToCamera;
        private static Matrix4x4 _viewMatrix;
        private static Matrix4x4 _projectionMatrix;
        private static Vector4 _clipPlane;
        private static readonly float[] LayerCullDistances = new float[32];

        private void UpdateCameraProperties(Camera source, Camera reflectionCam)
        {
            reflectionCam.fieldOfView = source.fieldOfView;
            reflectionCam.orthographic = source.orthographic;
            reflectionCam.orthographicSize = source.orthographicSize;
            reflectionCam.useOcclusionCulling = source.useOcclusionCulling;
        }

        private void UpdatePerspective(Camera source, Camera reflectionCam)
        {
            if (!source || !reflectionCam) return;

            Vector3 normal = Rotatable ? transform.up : Vector3.up;
            
            Vector3 position = Bounds.center + (normal * Offset);

            var d = -Vector3.Dot(normal, position);
            _reflectionPlane = new Vector4(normal.x, normal.y, normal.z, d);

            _reflectionBase = Matrix4x4.identity;
            _reflectionBase *= Matrix4x4.Scale(new Vector3(1, -1, 1));

            // View
            CalculateReflectionMatrix(ref _reflectionBase, _reflectionPlane);
            _oldCamPos = source.transform.position - new Vector3(0, position.y * 2, 0);
            reflectionCam.transform.forward = Vector3.Scale(source.transform.forward, new Vector3(1, -1, 1));

            _worldToCamera = source.worldToCameraMatrix;
            _viewMatrix = _worldToCamera * _reflectionBase;

            // Reflect position
            _oldCamPos.y = -_oldCamPos.y;
            reflectionCam.transform.position = _oldCamPos;

            _clipPlane = CameraSpacePlane(reflectionCam.worldToCameraMatrix, position - normal * 0.1f, normal, 1.0f);
            _projectionMatrix = source.CalculateObliqueMatrix(_clipPlane);
            
            // Settings
            reflectionCam.cullingMask = ~(1 << 4) & CullingMask;;
            reflectionCamera.clearFlags = IncludeSkybox ? CameraClearFlags.Skybox : CameraClearFlags.Depth;
            
            // 값 변경 시에만 재적용
            if (_mRenderRange != RenderRange)
            {
                _mRenderRange = RenderRange;
                
                for (int i = 0; i < LayerCullDistances.Length; i++)
                {
                    LayerCullDistances[i] = RenderRange;
                }
            }

            reflectionCam.projectionMatrix = _projectionMatrix;
            reflectionCam.worldToCameraMatrix = _viewMatrix;
            reflectionCam.layerCullDistances = LayerCullDistances;
            reflectionCam.layerCullSpherical = true;
        }

        /// <summary>
        /// 주어진 평면 주위의 반사 행렬을 계산합니다.
        /// </summary>
        /// <param name="reflectionMat">반사 리플랙션</param>
        /// <param name="plane">플랜</param>
        private void CalculateReflectionMatrix(ref Matrix4x4 reflectionMat, Vector4 plane)
        {
            reflectionMat.m00 = (1F - 2F * plane[0] * plane[0]);
            reflectionMat.m01 = (-2F * plane[0] * plane[1]);
            reflectionMat.m02 = (-2F * plane[0] * plane[2]);
            reflectionMat.m03 = (-2F * plane[3] * plane[0]);

            reflectionMat.m10 = (-2F * plane[1] * plane[0]);
            reflectionMat.m11 = (1F - 2F * plane[1] * plane[1]);
            reflectionMat.m12 = (-2F * plane[1] * plane[2]);
            reflectionMat.m13 = (-2F * plane[3] * plane[1]);

            reflectionMat.m20 = (-2F * plane[2] * plane[0]);
            reflectionMat.m21 = (-2F * plane[2] * plane[1]);
            reflectionMat.m22 = (1F - 2F * plane[2] * plane[2]);
            reflectionMat.m23 = (-2F * plane[3] * plane[2]);

            reflectionMat.m30 = 0F;
            reflectionMat.m31 = 0F;
            reflectionMat.m32 = 0F;
            reflectionMat.m33 = 1F;
        }
        
        /// <summary>
        /// 평면의 위치/법선이 주어지면 카메라 공간에서 평면을 계산합니다.
        /// </summary>
        /// <param name="worldToCameraMatrix"></param>
        /// <param name="pos"></param>
        /// <param name="normal"></param>
        /// <param name="sideSign"></param>
        /// <returns></returns>
        private Vector4 CameraSpacePlane(Matrix4x4 worldToCameraMatrix, Vector3 pos, Vector3 normal, float sideSign)
        {
            var offsetPos = pos + normal * Offset;
            var cameraPosition = worldToCameraMatrix.MultiplyPoint(offsetPos);
            var cameraNormal = worldToCameraMatrix.MultiplyVector(normal).normalized * sideSign;
            return new Vector4(cameraNormal.x, cameraNormal.y, cameraNormal.z,
                -Vector3.Dot(cameraPosition, cameraNormal));
        }

        public RenderTexture TryGetReflectionTexture(Camera targetCamera)
        {
            if (targetCamera)
            {
                ReflectionCameras.TryGetValue(targetCamera, out reflectionCamera);
                if (reflectionCamera)
                {
                    return reflectionCamera.targetTexture;
                }
            }

            return null;
        }
#endif
    }
}
