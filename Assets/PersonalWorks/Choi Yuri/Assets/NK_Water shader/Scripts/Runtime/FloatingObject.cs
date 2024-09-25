#define USE_LEGACY_FUNCTIONS

using System.Collections.Generic;
using UnityEngine;

namespace NKStudio
{
    [ExecuteInEditMode]
    [AddComponentMenu("Water/Floating Transform")]
    public class FloatingObject : MonoBehaviour
    {
        [Tooltip("이 참조는 파동 거리 및 높이 값을 파악하는 데 필요합니다.")]
        public WaterObject WaterObject;

        [Tooltip("머티리얼의 웨이브 매개변수가 실시간으로 변경되는 경우에만 활성화하세요. 이는 약간의 성능 오버헤드가 있습니다.\n\n편집 모드에서는 웨이브 매개변수를 항상 가져오므로 변경 사항이 직접 표시됩니다.")]
        public bool DynamicMaterial;
        
        [Tooltip("여기에서 하위 메시 개체를 할당할 수 있습니다. 할당되면 샘플 포인트는 구성 요소가 연결된 변환 대신 변환에 따라 회전/크기 조정됩니다.")]
        public Transform ChildTransform;

        public float HeightOffset;
        
        [Min(0)]
        [Tooltip("파동 곡률에 맞춰 변환이 얼마나 강하게 회전해야 하는지 제어합니다.")]
        public float RollAmount = 0.1f;
        
        public List<Vector3> Samples = new();
        
        private Vector3 _normal;
        private float _height;
        private float _waterLevel;
        
        /// <summary>
        /// 애니메이션을 비활성화하는 전역 토글입니다. 이는 프리팹을 편집하거나 편집기에서 샘플 위치를 편집할 때 모든 인스턴스를 일시적으로 비활성화하는 데 사용됩니다.
        /// </summary>
        public static bool Disable;
        
#if UNITY_EDITOR
        public static bool EnableInEditor
        {
            get => UnityEditor.EditorPrefs.GetBool("BUOYANCY_EDITOR_ENABLED", true);
            set => UnityEditor.EditorPrefs.SetBool("BUOYANCY_EDITOR_ENABLED", value);
        }
#endif
        
#if UNITY_EDITOR
        private void OnEnable()
        {
            UnityEditor.EditorApplication.update += FixedUpdate;
        }

        private void Reset()
        {
            // 물 개체가 하나만 있는 경우 자동 할당
            if (WaterObject == null && WaterObject.Instances.Count > 0)
            {
                WaterObject = WaterObject.Instances[0];
                UnityEditor.EditorUtility.SetDirty(this);
            }
        }

        private void OnDisable()
        {
            UnityEditor.EditorApplication.update -= FixedUpdate;
        }
#endif

        public void FixedUpdate()
        {
            if (!this || !enabled || Disable) return;
            
#if UNITY_EDITOR
            if (!EnableInEditor && Application.isPlaying == false) return;
#endif
            
            if (!WaterObject || !WaterObject.Material) return;

            _waterLevel = WaterObject.transform.position.y;
            
            _normal = Vector3.up;
            _height = 0f;
            if (Samples.Count == 0)
            {
                _height = Buoyancy.SampleWaves(transform.position, WaterObject.Material, _waterLevel, RollAmount, DynamicMaterial, out _normal);
            }
            else
            {
                Vector3 avgNormal = Vector3.zero;
                for (int i = 0; i < Samples.Count; i++)
                {
                    _height += Buoyancy.SampleWaves(ConvertToWorldSpace(Samples[i]), WaterObject.Material, _waterLevel, RollAmount, DynamicMaterial, out _normal);
                    avgNormal += _normal;
                }

                _height /= Samples.Count;
                _normal = (avgNormal / Samples.Count).normalized;
            }

            _height += HeightOffset;

            
            ApplyTransform();
        }

        private void ApplyTransform()
        {
            if(RollAmount > 0) transform.up = _normal;
            transform.position = new Vector3(transform.position.x, _height, transform.position.z);
        }
        
        public Vector3 ConvertToWorldSpace(Vector3 position)
        {
            if (ChildTransform) return ChildTransform.TransformPoint(position);

            return transform.TransformPoint(position);
        }

        public Vector3 ConvertToLocalSpace(Vector3 position)
        {
            if (ChildTransform) return ChildTransform.InverseTransformPoint(position);

            return transform.InverseTransformPoint(position);
        }

    }
}