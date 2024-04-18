using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace NKStudio
{
    /// <summary>
    /// Water 셰이더를 사용하여 모든 메시에 연결
    /// 물 개체를 식별하고 해당 속성에 액세스하는 일반적인 방법을 제공합니다.
    /// </summary>
    [ExecuteInEditMode]
    [AddComponentMenu("Water/Water Object")]
    [DisallowMultipleComponent]
    public class WaterObject : MonoBehaviour
    {
        /// <summary>
        /// 사용 가능한 모든 WaterObject 인스턴스의 컬렉션입니다. 인스턴스는 OnEnable/OnDisable 함수에 자신을 등록(취소)합니다.
        /// </summary>
        public static readonly List<WaterObject> Instances = new();
        
        public Material Material;
        public MeshFilter MeshFilter;
        public MeshRenderer MeshRenderer;
        
        private MaterialPropertyBlock _props;
        public MaterialPropertyBlock props
        {
            get
            {
                //필요할 때 가져오며, 그렇지 않으면 실행 순서를 신뢰할 수 없게 만듭니다.
                if (_props == null)
                {
                    CreatePropertyBlock(MeshRenderer);
                }
                return _props;
            }
            private set => _props = value;
        }

        private void CreatePropertyBlock(Renderer sourceRenderer)
        {
            _props = new MaterialPropertyBlock();
            sourceRenderer.GetPropertyBlock(_props);
        }

        private void Reset()
        {
            MeshRenderer = GetComponent<MeshRenderer>();
            CreatePropertyBlock(MeshRenderer);
            MeshFilter = GetComponent<MeshFilter>();
        }

        private void OnEnable()
        {
            Instances.Add(this);
        }

        private void OnDisable()
        {
            Instances.Remove(this);
        }

        private void OnValidate()
        {
            if (!MeshRenderer) MeshRenderer = GetComponent<MeshRenderer>();
            if (!MeshFilter) MeshFilter = GetComponent<MeshFilter>();
            FetchWaterMaterial();
        }

        /// <summary>
        /// 연결된 메시 렌더러에서 재료를 가져옵니다.
        /// </summary>
        public Material FetchWaterMaterial()
        {
            if (MeshRenderer)
            {
                Material = MeshRenderer.sharedMaterial;
                return Material;
            }

            return null;
        }

        /// <summary>
        /// 재료 속성 블록('props' 속성)에 대한 변경 사항에 적용됩니다.
        /// </summary>
        public void ApplyInstancedProperties()
        {
            if(props != null) MeshRenderer.SetPropertyBlock(props);
        }

        /// <summary>
        /// Checks if the position is below the maximum possible wave height. Can be used as a fast broad-phase check, before actually using the more expensive SampleWaves function
        /// </summary>
        /// <param name="position"></param>
        public bool CanTouch(Vector3 position)
        {
            return Buoyancy.CanTouchWater(position, this);
        }

        public void AssignMesh(Mesh mesh)
        {
            if (MeshFilter) MeshFilter.sharedMesh = mesh;
        }

        public void AssignMaterial(Material newMaterial)
        {
            if (MeshRenderer) MeshRenderer.sharedMaterial = newMaterial;
            Material = newMaterial;
        }

        /// <summary>
        /// MeshFilter, MeshRenderer 및 WaterObject 구성 요소를 사용하여 새로운 GameObject를 만듭니다.
        /// </summary>
        /// <param name="waterMaterial">할당된 경우 이 재질은 MeshRenderer에 자동으로 추가됩니다.</param>
        /// <returns></returns>
        public static WaterObject New(Material waterMaterial = null, Mesh mesh = null)
        {
            GameObject go = new GameObject("Water Object", typeof(MeshFilter), typeof(MeshRenderer), typeof(WaterObject));
            go.layer = LayerMask.NameToLayer("Water");
            
            #if UNITY_EDITOR
            UnityEditor.Undo.RegisterCreatedObjectUndo(go, "Created Water Object");
            #endif
            
            WaterObject waterObject = go.GetComponent<WaterObject>();
            
            waterObject.MeshRenderer = waterObject.gameObject.GetComponent<MeshRenderer>();
            waterObject.MeshFilter = waterObject.gameObject.GetComponent<MeshFilter>();
            
            waterObject.MeshFilter.sharedMesh = mesh;
            waterObject.MeshRenderer.sharedMaterial = waterMaterial;
            waterObject.MeshRenderer.shadowCastingMode = ShadowCastingMode.Off;
            waterObject.Material = waterMaterial;

            return waterObject;
        }

        /// <summary>
        /// 위치 위 또는 아래에서 WaterObject를 찾으려고 시도합니다. XZ 평면에서 레이캐스팅하여 모든 물 개체 메시의 경계를 확인합니다.
        /// </summary>
        /// <param name="position">월드 공간에서의 위치(높이는 관련이 없음)</param>
        /// <param name="rotationSupport">이것이 사실이 아닌 경우 Y축으로 회전하는 물은 잘못된 결과를 산출합니다(그러나 더 빠릅니다).</param>
        /// <returns></returns>
        public static WaterObject Find(Vector3 position, bool rotationSupport)
        {
            Ray ray = new Ray(position + (Vector3.up * 1000f), Vector3.down);
            
            foreach (WaterObject obj in Instances)
            {
                if (rotationSupport)
                {
                    //Local space
                    ray.origin = obj.transform.InverseTransformPoint(ray.origin);
                    if (obj.MeshFilter.sharedMesh.bounds.IntersectRay(ray)) return obj;
                }
                else
                {
                    //Axis-aligned bounds
                    if (obj.MeshRenderer.bounds.IntersectRay(ray)) return obj;
                }
            }
            
            return null;
        }
    }
}