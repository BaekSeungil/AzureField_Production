using UnityEngine;
using UnityEditor;
using PrefabStageUtility = UnityEditor.SceneManagement.PrefabStageUtility;

namespace NKStudio
{
    [CanEditMultipleObjects]
    [CustomEditor(typeof(FloatingObject))]
    public class FloatingEditor : Editor
    {
        private FloatingObject _target;

        private SerializedProperty _waterObject;
        private SerializedProperty _dynamicMaterial;
        private SerializedProperty _heightOffset;
        private SerializedProperty _rollAmount;
        
        private bool _editSamples;
        private bool _wavesEnabled;
        
        private int _selectedSampleIndex;
        private Vector3 _sampleWorldPos;
        private Vector3 _prevSampleWorldPos;
        
        private void OnEnable()
        {
            _target = (FloatingObject)target;

            _waterObject = serializedObject.FindProperty("WaterObject");
            _dynamicMaterial = serializedObject.FindProperty("DynamicMaterial");
            _heightOffset = serializedObject.FindProperty("HeightOffset");
            _rollAmount = serializedObject.FindProperty("RollAmount");
            
            // 씬에 물이 하나만 있는 경우 자동 가져옴
            if (_waterObject.objectReferenceValue == null && WaterObject.Instances.Count == 1)
            {
                serializedObject.Update();
                _waterObject.objectReferenceValue = WaterObject.Instances[0];
                EditorUtility.SetDirty(target);
                serializedObject.ApplyModifiedPropertiesWithoutUndo();
            }
            
            ValidateMaterial();
        }

        private void OnDisable()
        {
            FloatingObject.Disable = false;
            Tools.hidden = false;
        }

        public override void OnInspectorGUI()
        {
            using (new EditorGUILayout.HorizontalScope())
            {
                GUILayout.Space(EditorGUIUtility.labelWidth);
                FloatingObject.EnableInEditor =
                    GUILayout.Toggle(FloatingObject.EnableInEditor, new GUIContent(" Run in edit-mode (global)", EditorGUIUtility.IconContent(
                        (FloatingObject.EnableInEditor ? "animationvisibilitytoggleon" : "animationvisibilitytoggleoff")).image), "Button");
            }
            
            EditorGUILayout.Space();

            serializedObject.Update();

            EditorGUI.BeginChangeCheck();
            
            EditorGUILayout.PropertyField(_waterObject);
            EditorGUI.indentLevel++;
            EditorGUILayout.PropertyField(_dynamicMaterial);
            EditorGUI.indentLevel--;
            
            if(!_wavesEnabled)
                EditorGUILayout.HelpBox("물 오브젝트에 사용된 머티리얼에는 파도가 활성화되어 있지 않습니다.", MessageType.Error);
            
            if (_target.WaterObject && _target.WaterObject.Material)
            {
                if (_target.WaterObject.Material.GetFloat("_WorldSpaceUV") == 0f)
                {
                    EditorGUILayout.HelpBox("머티리얼은 world-projected UV를 사용해야 합니다.", MessageType.Error);
                }
            }

            if(_waterObject.objectReferenceValue == null)
            {
                EditorGUILayout.HelpBox("물 오브젝트를 할당해야 합니다.!", MessageType.Error);
            }
            
            EditorGUILayout.Space();

            EditorGUILayout.PropertyField(_heightOffset);
            EditorGUILayout.PropertyField(_rollAmount);

            EditorGUILayout.Space();

            if (EditorGUI.EndChangeCheck())
            {
                serializedObject.ApplyModifiedProperties();

                ValidateMaterial();
            }
        }

        private void ValidateMaterial()
        {
            if (_target.WaterObject && _target.WaterObject.Material)
            {
                if (_target.WaterObject.Material != _target.WaterObject.MeshRenderer.sharedMaterial) _target.WaterObject.Material = _target.WaterObject.MeshRenderer.sharedMaterial;
                
                _wavesEnabled = WaveParameters.WavesEnabled(_target.WaterObject.Material);
            }
        }
        
        private void OnSceneGUI()
        {
            if (!_target) return;
            
            FloatingObject.Disable = PrefabStageUtility.GetCurrentPrefabStage() != null || _editSamples;
            
            if (_editSamples)
            {
                //Mute default controls
                Tools.hidden = true;
                
                Handles.color = new Color(0.66f, 0.66f, 0.66f, 1);
                
                for (int i = 0; i < _target.Samples.Count; i++)
                {
                    _sampleWorldPos = _target.ConvertToWorldSpace(_target.Samples[i]);

                    float size = HandleUtility.GetHandleSize(_sampleWorldPos) * 0.25f;
                    if (Handles.Button(_sampleWorldPos, Quaternion.identity, size, size, Handles.SphereHandleCap))
                    {
                        _selectedSampleIndex = i;
                    }
                }

                if (_selectedSampleIndex > -1)
                {
                    _sampleWorldPos = _target.ConvertToWorldSpace(_target.Samples[_selectedSampleIndex]);
                    _prevSampleWorldPos = _sampleWorldPos;
                    
                    _sampleWorldPos = Handles.PositionHandle(_sampleWorldPos, _target.ChildTransform ? _target.ChildTransform.rotation : _target.transform.rotation );
                    _target.Samples[_selectedSampleIndex] = _target.ConvertToLocalSpace(_sampleWorldPos);

                    //If moved
                    if (_sampleWorldPos != _prevSampleWorldPos)
                    {
                        _prevSampleWorldPos = _sampleWorldPos;
                        EditorUtility.SetDirty(target);
                    }
                }
            }
            else
            {
                _selectedSampleIndex = -1;
                Tools.hidden = false;
                
                if (_target.Samples == null) return;

                Handles.color = new Color(1,1,1, 0.25f);
                for (int i = 0; i < _target.Samples.Count; i++)
                {
                    _sampleWorldPos = _target.ConvertToWorldSpace(_target.Samples[i]);
                    Handles.SphereHandleCap(0, _sampleWorldPos, SceneView.lastActiveSceneView.camera.transform.rotation, HandleUtility.GetHandleSize(_sampleWorldPos) * 0.25f, EventType.Repaint);
                }
            }
        }
    }
}