using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.UIElements;

namespace NKStudio
{
    [CustomEditor(typeof(PlanarReflectionRenderer))]
    public class PlanarReflectionRendererEditor : Editor
    {
        [SerializeField] private VisualTreeAsset _planerReflectionTemplate;
        [SerializeField] private VisualTreeAsset _messageBoxElementTemplate;
        private Label _stateText;
        
        private PlanarReflectionRenderer _renderer;

        //Rendering
        private SerializedProperty _rendererIndex;
        private SerializedProperty _waterObjectsProperty;
        private SerializedProperty _moveWithTransform;

        private Bounds _curBounds;
        private bool _waterLayerError;

        private const string RenderDataListFieldName = "m_RendererDataList";
        private const string RenderFeaturesListFieldName = "m_RendererFeatures";

        private List<string> _rendererDisplayList = new List<string>();

        private bool PreviewReflection
        {
            get => EditorPrefs.GetBool("PREVIEW_REFLECTION_ENABLED", true);
            set => EditorPrefs.SetBool("PREVIEW_REFLECTION_ENABLED", value);
        }

        private RenderTexture _previewTexture;

        private StringBuilder _stateStringBuilder = new StringBuilder();
        
        private void OnEnable()
        {
            PipelineUtilities.RefreshRendererList();

            _renderer = (PlanarReflectionRenderer)target;

            if (_renderer.WaterObjects.Count == 0 && WaterObject.Instances.Count == 1)
            {
                _renderer.WaterObjects.Add(WaterObject.Instances[0]);
                _renderer.RecalculateBounds();
                _renderer.EnableMaterialReflectionSampling();

                EditorUtility.SetDirty(target);
                serializedObject.ApplyModifiedPropertiesWithoutUndo();
            }

            ValidateWaterObjectLayer();
            _curBounds = _renderer.CalculateBounds();
            RenderPipelineManager.endCameraRendering += OnEndCameraRendering;
        }

        private Camera _currentCamera;
        private string _currentCameraName;
        private bool _waterObjectsVisible;

        private void OnEndCameraRendering(ScriptableRenderContext context, Camera camera)
        {
            if (!PreviewReflection) return;

            if (PlanarReflectionRenderer.InvalidCamera(camera)) return;

            _currentCamera = camera;

            _waterObjectsVisible = _renderer.WaterObjectsVisible(_currentCamera);

            _previewTexture = _renderer.TryGetReflectionTexture(_currentCamera);
            _currentCameraName = _currentCamera.name;
        }

        private void OnDisable()
        {
            RenderPipelineManager.endCameraRendering -= OnEndCameraRendering;
        }

        private void FindProperties()
        {
            _rendererIndex = serializedObject.FindProperty("RendererIndex");
            _waterObjectsProperty = serializedObject.FindProperty("WaterObjects");
            _moveWithTransform = serializedObject.FindProperty("MoveWithTransform");
        }

        public override VisualElement CreateInspectorGUI()
        {
            FindProperties();

            var root = _planerReflectionTemplate.Instantiate();
            var waterObjectListView = root.Q<ListView>("WaterObjects-ListView");
            waterObjectListView.headerTitle = _waterObjectsProperty.displayName;
            waterObjectListView.bindingPath = "WaterObjects";
            waterObjectListView.makeItem = MakeItem;
            waterObjectListView.bindItem = BindItem;
            waterObjectListView.itemsAdded += _ => ReCalculateBounds();
            waterObjectListView.itemsRemoved += _ => ReCalculateBounds();

            _stateText = root.Q<Label>("State-Text");

            RefreshRendererList();
            var renderIndexPopup = root.Q<DropdownField>("RenderIndex-popup");
            renderIndexPopup.label = _rendererIndex.displayName;
            renderIndexPopup.choices = _rendererDisplayList;
            renderIndexPopup.index = _rendererIndex.intValue;
            renderIndexPopup.AddToClassList("unity-base-field__aligned");
            renderIndexPopup.RegisterValueChangedCallback(evt =>
            {
                _rendererIndex.intValue = renderIndexPopup.index;
                serializedObject.ApplyModifiedProperties();
            });

            PropertyField moveBoundsWithToggle = root.Q<PropertyField>("MoveBoundsWithTransform");
            moveBoundsWithToggle.label = "Move bounds with transform";

            root.Q<Button>("AutoFind-Button").clicked += OnAutoFind;
            root.Q<Button>("Clear-Button").clicked += OnClear;

            var messageBoxGroup = root.Q<VisualElement>("MessageBoxGroup");
            var noWaterInfo = _messageBoxElementTemplate.Instantiate();
            noWaterInfo.style.display = DisplayStyle.None;
            InfoMessageStyle(noWaterInfo, "1개 이상의 물 오브젝트를 추가해주세요.");
            
            var recalculate = _messageBoxElementTemplate.Instantiate();
            recalculate.style.display = DisplayStyle.None;
            EventMessageStyle(recalculate, "물 오브젝트가 변경되거나 이동했습니다.\nBounds를 다시 계산해야 합니다.", "Recalculate");
            
            var waterLayer = _messageBoxElementTemplate.Instantiate();
            waterLayer.style.display = DisplayStyle.None;
            EventMessageStyle(waterLayer, "씬에 \"Water\" 레이어를 가진 물 오브젝트가 존재하지 않습니다.\n\n이로 인해 재귀 반사가 발생합니다.", "Fix");
            
            messageBoxGroup.Add(noWaterInfo);
            messageBoxGroup.Add(recalculate);
            messageBoxGroup.Add(waterLayer);

            root.schedule.Execute(() =>
            {
                RefreshStateText();
                RefreshMessageBoxGroup(noWaterInfo, recalculate, waterLayer);
            }).Every(100);

            var recalculateButton = recalculate.Q<Button>("Event-Button");
            recalculateButton.clicked += () => RecalculateBounds();
            
            var waterLayerButton = waterLayer.Q<Button>("Event-Button");
            waterLayerButton.clicked += () => SetObjectsOnWaterLayer();

            var previewButton = root.Q<Button>("PreviewButton");
            RefreshPreviewButtonStyle(previewButton);
            previewButton.clicked += () =>
            {
                PreviewReflection = !PreviewReflection;
                RefreshPreviewButtonStyle(previewButton);
            };

            return root;
        }

        private void RefreshMessageBoxGroup(VisualElement noWaterInfo, VisualElement recalculate, VisualElement waterLayer)
        {
            if (_renderer.WaterObjects != null)
            {
                if (_renderer.WaterObjects.Count == 0) 
                    noWaterInfo.style.display = DisplayStyle.Flex;
                else
                    noWaterInfo.style.display = DisplayStyle.None;

                if (_renderer.WaterObjects.Count > 0)
                {
                    if (_curBounds.size != _renderer.Bounds.size || (_moveWithTransform.boolValue == false && _curBounds.center != _renderer.Bounds.center))
                        recalculate.style.display = DisplayStyle.Flex;
                    else
                        recalculate.style.display = DisplayStyle.None;
                }

                if (_waterLayerError) 
                    waterLayer.style.display = DisplayStyle.Flex;
                else
                    waterLayer.style.display = DisplayStyle.None;
            }
        }
        
        private void RefreshStateText()
        {
            _stateStringBuilder.Clear();
            _stateStringBuilder.Append("상태: ");

            if (_waterObjectsVisible && _currentCamera)
                _stateStringBuilder.Append($"Rendering (camera: {_currentCamera.name})");
            else
                _stateStringBuilder.Append("Not rendering (어떤 카메라에도 물이 보이지 않습니다)");

            _stateText.text = _stateStringBuilder.ToString();
        }
        
        /// <summary>
        /// 미리보기 버튼의 스타일을 변경합니다.
        /// </summary>
        /// <param name="element">변경할 버튼 요소</param>
        private void RefreshPreviewButtonStyle(Button element)
        {
            if (PreviewReflection)
            {
                if (EditorGUIUtility.isProSkin)
                    element.AddToClassList("SelectedButton__Dark");
                else
                    element.AddToClassList("SelectedButton__Light");
            }
            else
            {
                if (EditorGUIUtility.isProSkin)
                    element.RemoveFromClassList("SelectedButton__Dark");
                else
                    element.RemoveFromClassList("SelectedButton__Light");
            }
        }
        
        private void InfoMessageStyle(VisualElement element, string message)
        {
            element.style.marginTop = 3f;
            element.style.marginBottom = 3f;
            
            var point = element.Q<VisualElement>("Point");
            var messageText = element.Q<Label>("Message");
            var icon = element.Q<VisualElement>("Icon");
            var eventButton = element.Q<Button>("Event-Button");

            point.style.backgroundColor = Color.white;
            messageText.text = message;
            icon.style.display = DisplayStyle.Flex;
            eventButton.style.display = DisplayStyle.None;

            if (EditorGUIUtility.isProSkin)
            {
                var black = Color.black;
                black.a = 0.15f;
                element.style.backgroundColor = new StyleColor(black);
            }
            else
            {
                var light = Color.white;
                light.a = 0.19f;
                element.style.backgroundColor = new StyleColor(light);
            }
        }

        private void EventMessageStyle(VisualElement element, string message, string buttonTitle)
        {
            element.style.marginTop = 3f;
            element.style.marginBottom = 3f;
            
            var point = element.Q<VisualElement>("Point");
            var messageText = element.Q<Label>("Message");
            var icon = element.Q<VisualElement>("Icon");
            var eventButton = element.Q<Button>("Event-Button");

            icon.style.display = DisplayStyle.None;
            eventButton.style.display = DisplayStyle.Flex;
            
            point.style.backgroundColor = new Color(1f, 0.4313726f, 0.4313726f, 1f);
            messageText.text = message;
            eventButton.text = buttonTitle;

            if (EditorGUIUtility.isProSkin)
            {
                var black = Color.black;
                black.a = 0.15f;
                element.style.backgroundColor = new StyleColor(black);
            }
            else
            {
                var light = Color.white;
                light.a = 0.19f;
                element.style.backgroundColor = new StyleColor(light);
            }
        }

        private VisualElement MakeItem()
        {
            var waterObjectField = new ObjectField();
            waterObjectField.objectType = typeof(WaterObject);
            waterObjectField.allowSceneObjects = true;
            waterObjectField.schedule.Execute(() =>
            {
                waterObjectField.RegisterValueChangedCallback(evt =>
                {
                    RefreshLitItem(waterObjectField, evt.newValue as WaterObject);
                    ReCalculateBounds();
                });
            });

            return waterObjectField;
        }

        private void BindItem(VisualElement element, int index)
        {
            if (element is ObjectField waterObjectField)
            {
                waterObjectField.BindProperty(_waterObjectsProperty.GetArrayElementAtIndex(index));
                if (waterObjectField.value)
                {
                    waterObjectField.label =
                        _waterObjectsProperty.GetArrayElementAtIndex(index).objectReferenceValue.name;
                }
                else
                {
                    waterObjectField.label = "None";
                }
            }

            element.userData = index;
        }

        private void RefreshLitItem(ObjectField element, WaterObject waterObject)
        {
            if (element.userData != null)
            {
                if (waterObject)
                    element.label = waterObject.name;
                else
                    element.label = "None";
            }
        }

        private void ReCalculateBounds()
        {
            _curBounds = _renderer.CalculateBounds();
        }

        private void OnClear()
        {
            _renderer.ToggleMaterialReflectionSampling(false);
            _renderer.WaterObjects.Clear();
            _renderer.RecalculateBounds();

            EditorUtility.SetDirty(target);
        }

        private void OnAutoFind()
        {
            _renderer.WaterObjects = new List<WaterObject>(WaterObject.Instances);

            _renderer.RecalculateBounds();
            _curBounds = _renderer.Bounds;
            _renderer.EnableMaterialReflectionSampling();

            ValidateWaterObjectLayer();

            EditorUtility.SetDirty(target);
        }

        private void RefreshRendererList()
        {
            if (UniversalRenderPipeline.asset == null)
            {
                Debug.LogError("활성화된 파이프라인이 없습니다. 그렇지 않은 경우 이 기능을 사용하는 UI를 표시하지 마세요!");
            }

            ScriptableRendererData[] rendererDataList = GetRenderDataList(UniversalRenderPipeline.asset);

            //Display names
            _rendererDisplayList = new List<string>(rendererDataList.Length + 1);

            int defaultIndex = GetDefaultRendererIndex(UniversalRenderPipeline.asset);

            _rendererDisplayList.Insert(0, $"Default {rendererDataList[defaultIndex].name}");

            for (int i = 1; i < _rendererDisplayList.Count; i++)
                _rendererDisplayList.Insert(i, $"{(i - 1).ToString()}: {(rendererDataList[i - 1]).name}");
        }

        private static int GetDefaultRendererIndex(UniversalRenderPipelineAsset asset)
        {
            return (int)typeof(UniversalRenderPipelineAsset)
                .GetField("m_DefaultRendererIndex", BindingFlags.NonPublic | BindingFlags.Instance).GetValue(asset);
        }

        private static ScriptableRendererData[] GetRenderDataList(UniversalRenderPipelineAsset asset)
        {
            FieldInfo renderDataListField = typeof(UniversalRenderPipelineAsset).GetField(RenderDataListFieldName,
                BindingFlags.NonPublic | BindingFlags.Instance);

            if (renderDataListField != null)
            {
                return (ScriptableRendererData[])renderDataListField.GetValue(asset);
            }

            throw new Exception(
                "Reflection failed on field \"m_RendererDataList\" from class \"UniversalRenderPipelineAsset\". URP API likely changed");
        }

        public override bool HasPreviewGUI()
        {
            return PreviewReflection && _previewTexture;
        }

        public override bool RequiresConstantRepaint()
        {
            return HasPreviewGUI();
        }

        public override GUIContent GetPreviewTitle()
        {
            return _currentCamera ? new GUIContent(_currentCameraName + " reflection") : new GUIContent("Reflection");
        }

        public override void OnPreviewSettings()
        {
            if (HasPreviewGUI() == false) return;

            GUILayout.Label($"Resolution ({_previewTexture.width}x{_previewTexture.height})");
        }

        private bool _drawAlpha;

        public override void OnPreviewGUI(Rect r, GUIStyle background)
        {
            if (_drawAlpha)
            {
                EditorGUI.DrawTextureAlpha(r, _previewTexture, ScaleMode.ScaleToFit);
            }
            else
            {
                GUI.DrawTexture(r, _previewTexture, ScaleMode.ScaleToFit, false);
            }

            Rect btnRect = r;
            btnRect.x += 10f;
            btnRect.y += 10f;
            btnRect.width = 150f;
            btnRect.height = 20f;

            GUIStyle whiteFontStyle = new GUIStyle(GUI.skin.toggle);
            whiteFontStyle.normal.textColor = Color.white;
            _drawAlpha = GUI.Toggle(btnRect, _drawAlpha, new GUIContent(" Alpha channel"), whiteFontStyle);
        }

        private void ValidateWaterObjectLayer()
        {
            if (_renderer.WaterObjects == null) return;

            _waterLayerError = false;
            int layerID = LayerMask.NameToLayer("Water");

            foreach (WaterObject obj in _renderer.WaterObjects)
            {
                if (obj == null) continue;

                //물 레이어가 아니라면?
                if (obj.gameObject.layer != layerID)
                {
                    _waterLayerError = true;
                    return;
                }
            }
        }

        private void SetObjectsOnWaterLayer()
        {
            int layerID = LayerMask.NameToLayer("Water");

            foreach (WaterObject obj in _renderer.WaterObjects)
            {
                // 해당 객체에 물 레이어가 없다면?
                if (obj.gameObject.layer != layerID)
                {
                    obj.gameObject.layer = layerID;
                    EditorUtility.SetDirty(obj);
                }
            }

            _waterLayerError = false;
        }

        private void RecalculateBounds()
        {
            _renderer.RecalculateBounds();
            _curBounds = _renderer.Bounds;
            EditorUtility.SetDirty(target);
        }
    }
}