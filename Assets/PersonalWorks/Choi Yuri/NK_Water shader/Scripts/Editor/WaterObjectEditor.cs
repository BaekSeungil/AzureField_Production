using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;
using UnityEngine.Rendering.Universal;

namespace NKStudio
{
    [CustomEditor(typeof(WaterObject))]
    [CanEditMultipleObjects]
    public class WaterObjectInspector : Editor
    {
        private WaterObject _component;

        private SerializedProperty _material;
        private SerializedProperty _meshFilter;
        private SerializedProperty _meshRenderer;
        
        private bool _depthTextureRequired;
        private bool _opaqueTextureRequired;

        private bool showInstances
        {
            get => SessionState.GetBool("WATEROBJECT_SHOW_INSTANCES", false);
            set => SessionState.SetBool("WATEROBJECT_SHOW_INSTANCES", value);
        }
        
        private Texture _icon;
        
        private void OnEnable()
        {
            _component = (WaterObject)target;

            _icon = AssetDatabase.LoadAssetAtPath<Texture2D>("");
            _material = serializedObject.FindProperty("Material");
            _meshFilter = serializedObject.FindProperty("MeshFilter");
            _meshRenderer = serializedObject.FindProperty("MeshRenderer");

            CheckMaterial();
        }

        private void CheckMaterial()
        {
            if (UniversalRenderPipeline.asset == null || _component.Material == null) return;

            _depthTextureRequired = UniversalRenderPipeline.asset.supportsCameraDepthTexture == false && _component.Material.GetFloat("_DisableDepthTexture") == 0f;
            _opaqueTextureRequired = UniversalRenderPipeline.asset.supportsCameraOpaqueTexture == false && _component.Material.GetFloat("_RefractionOn") == 1f;
        }
        
        public override void OnInspectorGUI()
        {
            
            if (UniversalRenderPipeline.asset)
            {
                WaterUI.DrawNotification(
                    _depthTextureRequired,
                    "렌더 파이프라인 에셋에 Depth Texture가 비활성화되어 있지만, 이는 Water 머티리얼을 위해 필요합니다.",
                    "Enable",
                    () =>
                    {
                        WaterEditor.EnableDepthTexture();
                        CheckMaterial();
                    },
                    MessageType.Error);
                
                WaterUI.DrawNotification(
                    _opaqueTextureRequired,
                    "렌더 파이프라인 에셋에 Opaque Texture가 비활성화되어 있지만, Water 머티리얼을 위해 필요합니다.",
                    "Enable",
                    () =>
                    {
                        WaterEditor.EnableOpaqueTexture();
                        CheckMaterial();
                    },
                    MessageType.Error);
            }
            
            
            EditorGUILayout.HelpBox("이 컴포넌트는 다른 스크립트들이 Water bodies를 식별하고 찾을 수 있도록 도와줍니다.", MessageType.None);
            
            EditorGUILayout.LabelField("References (Read only)", EditorStyles.boldLabel);
            
            EditorGUI.BeginDisabledGroup(true);
            {
                EditorGUILayout.PropertyField(_material);
                EditorGUILayout.PropertyField(_meshFilter);
                EditorGUILayout.PropertyField(_meshRenderer);
            }
            EditorGUI.EndDisabledGroup();

            //첨부된 Mesh Renderer에서 재질이 변경된 경우 변경사항 반영
            foreach (Object currentTarget in targets)
            {
                WaterObject water = (WaterObject)currentTarget;
                water.FetchWaterMaterial();
            }

            if (WaterObject.Instances.Count > 1)
            {
                EditorGUILayout.Space();
                
                showInstances = EditorGUILayout.BeginFoldoutHeaderGroup(showInstances, $"Instances ({WaterObject.Instances.Count})");

                if (showInstances)
                {
                    Repaint();

                    using (new EditorGUILayout.VerticalScope(EditorStyles.textArea))
                    {
                        foreach (WaterObject obj in WaterObject.Instances)
                        {
                            var rect = EditorGUILayout.BeginHorizontal(EditorStyles.miniLabel);

                            if (rect.Contains(Event.current.mousePosition))
                            {
                                EditorGUIUtility.AddCursorRect(new Rect(Event.current.mousePosition.x, Event.current.mousePosition.y, 27, 27), MouseCursor.Link);
                                EditorGUI.DrawRect(rect, Color.gray * (EditorGUIUtility.isProSkin ? 0.66f : 0.20f));
                            }

                            if (GUILayout.Button(new GUIContent(" " + obj.name, _icon), EditorStyles.miniLabel, GUILayout.Height(20f)))
                            {
                                EditorGUIUtility.PingObject(obj);
                                Selection.activeGameObject = obj.gameObject;
                            }
                            EditorGUILayout.EndHorizontal();
                        }
                    }
                }
                EditorGUILayout.EndFoldoutHeaderGroup();
            }
        }
    }
}