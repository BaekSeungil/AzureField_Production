using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


namespace NKStudio
{
    public class WaterShaderGUI : ShaderGUI
    {
        #region foldout bools variable
        private static bool _showGeneral;
        private static bool _showRendering;
        private static bool _showLighting;
        private static bool _showColor;
        private static bool _showNormals;
        private static bool _showFoam;
        private static bool _showIntersectionFoam;
        private static bool _showReflections;
        private static bool _showWaves;
        private static bool _showUnderWater;
        #endregion

        private MaterialEditor _materialEditor;

        private MaterialProperty _zWrite;
        private MaterialProperty _zClip;
        private MaterialProperty _cull;
        private MaterialProperty _shadingMode;
        private MaterialProperty _direction;
        private MaterialProperty _speed;

        // private MaterialProperty _slopeStretching;
        // private MaterialProperty _slopeSpeed;
        // private MaterialProperty _slopeThreshold;
        // private MaterialProperty _slopeFoam;

        private MaterialProperty _baseColor;
        private MaterialProperty _shallowColor;
        private MaterialProperty _colorAbsorption;

        private MaterialProperty _horizonColor;
        private MaterialProperty _horizonDistance;
        private MaterialProperty _depthVertical;
        private MaterialProperty _depthHorizontal;
        private MaterialProperty _depthExp;
        private MaterialProperty _vertexColorDepth;

        private MaterialProperty _waveTint;
        private MaterialProperty _worldSpaceUV;
        private MaterialProperty _translucencyStrength;
        private MaterialProperty _translucencyExp;
        private MaterialProperty _translucencyCurvatureMask;
        private MaterialProperty _edgeFade;
        private MaterialProperty _shadowStrength;

        private MaterialProperty _causticsTex;
        private MaterialProperty _causticsBrightness;
        private MaterialProperty _causticsTiling;
        private MaterialProperty _causticsSpeed;
        private MaterialProperty _causticsDistortion;
        private MaterialProperty _refractionStrength;
        private MaterialProperty _refractionChromaticAberration;


        private MaterialProperty _intersectionSource;
        private MaterialProperty _intersectionStyle;
        private MaterialProperty _intersectionNoise;
        private MaterialProperty _intersectionColor;
        private MaterialProperty _intersectionLength;
        private MaterialProperty _intersectionClipping;
        private MaterialProperty _intersectionFalloff;
        private MaterialProperty _intersectionTiling;
        private MaterialProperty _intersectionRippleDist;
        private MaterialProperty _intersectionRippleStrength;
        private MaterialProperty _intersectionSpeed;

        private MaterialProperty _foamTex;
        private MaterialProperty _foamColor;
        private MaterialProperty _foamSpeed;
        private MaterialProperty _foamSubSpeed;
        private MaterialProperty _foamTiling;
        private MaterialProperty _foamSubTiling;
        private MaterialProperty _foamDistortion;
        private MaterialProperty _foamWaveAmount;
        private MaterialProperty _foamBaseAmount;
        private MaterialProperty _foamClipping;
        private MaterialProperty _vertexColorFoam;

        private MaterialProperty _bumpMap;
        private MaterialProperty _bumpMapSlope;
        private MaterialProperty _bumpMapLarge;
        private MaterialProperty _normalTiling;
        private MaterialProperty _normalSubTiling;
        private MaterialProperty _normalStrength;
        private MaterialProperty _normalSpeed;
        private MaterialProperty _normalSubSpeed;
        private MaterialProperty _distanceNormalsFadeDist;
        private MaterialProperty _distanceNormalsTiling;
        private MaterialProperty _sparkleIntensity;
        private MaterialProperty _sparkleSize;

        private MaterialProperty _sunReflectionSize;
        private MaterialProperty _sunReflectionStrength;
        private MaterialProperty _sunReflectionDistortion;
        private MaterialProperty _pointSpotLightReflectionStrength;
        private MaterialProperty _pointSpotLightReflectionSize;
        private MaterialProperty _pointSpotLightReflectionDistortion;

        private MaterialProperty _reflectionStrength;
        private MaterialProperty _reflectionDistortion;
        private MaterialProperty _reflectionBlur;
        private MaterialProperty _reflectionFresnel;
        private MaterialProperty _reflectionLighting;

        private MaterialProperty _waveSpeed;
        private MaterialProperty _waveHeight;
        private MaterialProperty _vertexColorWaveFlattening;
        private MaterialProperty _waveNormalStr;
        private MaterialProperty _waveDistance;
        private MaterialProperty _waveFadeDistance;
        private MaterialProperty _waveSteepness;
        private MaterialProperty _waveCount;
        private MaterialProperty _waveDirection;

        private MaterialProperty _tessValue;
        private MaterialProperty _tessMin;
        private MaterialProperty _tessMax;

        //Keyword states
        private MaterialProperty _lightingOn;
        private MaterialProperty _receiveShadows;
        private MaterialProperty _flatShadingOn;
        private MaterialProperty _translucencyOn;
        private MaterialProperty _specularReflectionsOn;
        private MaterialProperty _environmentReflectionsOn;
        private MaterialProperty _disableDepthTexture;
        private MaterialProperty _causticsOn;
        private MaterialProperty _normalMapOn;
        private MaterialProperty _distanceNormalsOn;
        private MaterialProperty _foamOn;
        private MaterialProperty _refractionOn;
        private MaterialProperty _wavesOn;

        private GUIContent _simpleShadingContent;
        private GUIContent _advancedShadingContent;

        private bool _initialized;
        private bool _transparentShadowsEnabled;
        private bool _depthAfterTransparents;


        private bool _fogAutomatic;

        private void FindProperties(MaterialProperty[] props, Material material)
        {
            _intersectionSource = FindProperty("_IntersectionSource", props);
            _intersectionStyle = FindProperty("_IntersectionStyle", props);

            _tessValue = FindProperty("_TessValue", props);
            _tessMin = FindProperty("_TessMin", props);
            _tessMax = FindProperty("_TessMax", props);

            _cull = FindProperty("_Cull", props);
            _zWrite = FindProperty("_ZWrite", props);
            _zClip = FindProperty("_ZClip", props);
            _shadingMode = FindProperty("_ShadingMode", props);
            _shadowStrength = FindProperty("_ShadowStrength", props);
            _direction = FindProperty("_Direction", props);
            _speed = FindProperty("_Speed", props);

            // _slopeStretching = FindProperty("_SlopeStretching", props);
            // _slopeSpeed = FindProperty("_SlopeSpeed", props);
            // _slopeThreshold = FindProperty("_SlopeThreshold", props);
            // _slopeFoam = FindProperty("_SlopeFoam", props);

            _disableDepthTexture = FindProperty("_DisableDepthTexture", props);
            _refractionOn = FindProperty("_RefractionOn", props);

            _baseColor = FindProperty("_BaseColor", props);
            _shallowColor = FindProperty("_ShallowColor", props);
            _colorAbsorption = FindProperty("_ColorAbsorption", props);
            _horizonColor = FindProperty("_HorizonColor", props);
            _horizonDistance = FindProperty("_HorizonDistance", props);
            _depthVertical = FindProperty("_DepthVertical", props);
            _depthHorizontal = FindProperty("_DepthHorizontal", props);
            _depthExp = FindProperty("_DepthExp", props);
            _vertexColorDepth = FindProperty("_VertexColorDepth", props);

            _waveTint = FindProperty("_WaveTint", props);
            _worldSpaceUV = FindProperty("_WorldSpaceUV", props);
            _translucencyStrength = FindProperty("_TranslucencyStrength", props);
            _translucencyExp = FindProperty("_TranslucencyExp", props);
            _translucencyCurvatureMask = FindProperty("_TranslucencyCurvatureMask", props);
            _edgeFade = FindProperty("_EdgeFade", props);

            _causticsOn = FindProperty("_CausticsOn", props);
            _causticsTex = FindProperty("_CausticsTex", props);
            _causticsBrightness = FindProperty("_CausticsBrightness", props);
            _causticsTiling = FindProperty("_CausticsTiling", props);
            _causticsSpeed = FindProperty("_CausticsSpeed", props);
            _causticsDistortion = FindProperty("_CausticsDistortion", props);
            _refractionStrength = FindProperty("_RefractionStrength", props);
            _refractionChromaticAberration = FindProperty("_RefractionChromaticAberration", props);

            _intersectionNoise = FindProperty("_IntersectionNoise", props);
            _intersectionColor = FindProperty("_IntersectionColor", props);
            _intersectionLength = FindProperty("_IntersectionLength", props);
            _intersectionClipping = FindProperty("_IntersectionClipping", props);
            _intersectionFalloff = FindProperty("_IntersectionFalloff", props);
            _intersectionTiling = FindProperty("_IntersectionTiling", props);
            _intersectionRippleDist = FindProperty("_IntersectionRippleDist", props);
            _intersectionRippleStrength = FindProperty("_IntersectionRippleStrength", props);
            _intersectionSpeed = FindProperty("_IntersectionSpeed", props);

            _foamTex = FindProperty("_FoamTex", props);
            _foamColor = FindProperty("_FoamColor", props);
            _foamSpeed = FindProperty("_FoamSpeed", props);
            _foamSubSpeed = FindProperty("_FoamSubSpeed", props);
            _foamTiling = FindProperty("_FoamTiling", props);
            _foamSubTiling = FindProperty("_FoamSubTiling", props);
            _foamDistortion = FindProperty("_FoamDistortion", props);
            _foamBaseAmount = FindProperty("_FoamBaseAmount", props);
            _foamClipping = FindProperty("_FoamClipping", props);
            _foamWaveAmount = FindProperty("_FoamWaveAmount", props);
            _vertexColorFoam = FindProperty("_VertexColorFoam", props);

            _bumpMap = FindProperty("_BumpMap", props);
            _bumpMapSlope = FindProperty("_BumpMapSlope", props);
            _normalTiling = FindProperty("_NormalTiling", props);
            _normalSubTiling = FindProperty("_NormalSubTiling", props);
            _normalStrength = FindProperty("_NormalStrength", props);
            _normalSpeed = FindProperty("_NormalSpeed", props);
            _normalSubSpeed = FindProperty("_NormalSubSpeed", props);

            _bumpMapLarge = FindProperty("_BumpMapLarge", props);
            _distanceNormalsFadeDist = FindProperty("_DistanceNormalsFadeDist", props);
            _distanceNormalsTiling = FindProperty("_DistanceNormalsTiling", props);

            _sparkleIntensity = FindProperty("_SparkleIntensity", props);
            _sparkleSize = FindProperty("_SparkleSize", props);

            _sunReflectionSize = FindProperty("_SunReflectionSize", props);
            _sunReflectionStrength = FindProperty("_SunReflectionStrength", props);
            _sunReflectionDistortion = FindProperty("_SunReflectionDistortion", props);
            _pointSpotLightReflectionStrength = FindProperty("_PointSpotLightReflectionStrength", props);
            _pointSpotLightReflectionSize = FindProperty("_PointSpotLightReflectionSize", props);
            _pointSpotLightReflectionDistortion = FindProperty("_PointSpotLightReflectionDistortion", props);

            _reflectionStrength = FindProperty("_ReflectionStrength", props);
            _reflectionDistortion = FindProperty("_ReflectionDistortion", props);
            _reflectionBlur = FindProperty("_ReflectionBlur", props);
            _reflectionFresnel = FindProperty("_ReflectionFresnel", props);
            _reflectionLighting = FindProperty("_ReflectionLighting", props);

            _waveSpeed = FindProperty("_WaveSpeed", props);
            _waveHeight = FindProperty("_WaveHeight", props);
            _vertexColorWaveFlattening = FindProperty("_VertexColorWaveFlattening", props);
            _waveNormalStr = FindProperty("_WaveNormalStr", props);
            _waveDistance = FindProperty("_WaveDistance", props);
            _waveFadeDistance = FindProperty("_WaveFadeDistance", props);
            _waveSteepness = FindProperty("_WaveSteepness", props);
            _waveCount = FindProperty("_WaveCount", props);
            _waveDirection = FindProperty("_WaveDirection", props);

            //Keyword states
            _lightingOn = FindProperty("_LightingOn", props);
            _receiveShadows = FindProperty("_ReceiveShadows", props);
            _flatShadingOn = FindProperty("_FlatShadingOn", props);
            _translucencyOn = FindProperty("_TranslucencyOn", props);
            _foamOn = FindProperty("_FoamOn", props);
            _specularReflectionsOn = FindProperty("_SpecularReflectionsOn", props);
            _environmentReflectionsOn = FindProperty("_EnvironmentReflectionsOn", props);
            _normalMapOn = FindProperty("_NormalMapOn", props);
            _distanceNormalsOn = FindProperty("_DistanceNormalsOn", props);
            _wavesOn = FindProperty("_WavesOn", props);

            _simpleShadingContent = new GUIContent("Simple",
                "Mobile friendly");

            _advancedShadingContent = new GUIContent("Advanced",
                "고급 모드는:\n\n" +
                "• 물리 기반 굴절 + 색수차\n" +
                "• 포인트/스포트 라이트에 대한 커스틱스 및 반투명도 셰이딩\n" +
                "• 수중 그림자로 가려진 커스틱" +
                "• 정확한 굴절을 위해 수심/안개를 이중 샘플링합니다.\n" +
                "• 반투명 셰이딩을 위한 밝은 색상의 정확한 블렌딩\n" +
                "• 거리 법선에 대한 추가 텍스처 샘플");
        }

        private class WaterContent
        {
            public static readonly GUIContent General = new GUIContent("General");
            public static readonly GUIContent Rendering = new GUIContent("Rendering");
            public static readonly GUIContent Lighting = new GUIContent("Lighting");
            public static readonly GUIContent Color = new GUIContent("Color", "물의 기본 색상과 투명도를 제어합니다.");

            public static readonly GUIContent Normals =
                new GUIContent("Normals", "노멀 맵은 수면의 소규모 곡률을 나타냅니다. 조명과 반사에 사용됩니다.");

            public static readonly GUIContent
                Reflections = new GUIContent("Reflections", "태양 정반사 및 환경 반사(반사 프로브 및 평면 반사)");

            public static readonly GUIContent
                UnderWater = new GUIContent("Underwater",
                    "물 표면 아래에서 볼 수 있는 모든 것에 관련이 있습니다. 실제로 수중 렌더링과는 관련이 없습니다.");

            public static readonly GUIContent SurfaceFoam = new GUIContent("Surface Foam");

            public static readonly GUIContent IntersectionFoam =
                new GUIContent("Intersection Foam", "물에 닿는 불투명한 물체에 거품 효과를 그립니다.");

            public static readonly GUIContent Waves =
                new GUIContent("Waves", "표면 곡률을 수정하고 메시의 정점에 애니메이션을 적용하는 파라메트릭 거스트너 파동");
        }


        private void OnEnable(MaterialEditor materialEditorIn)
        {
            _transparentShadowsEnabled = PipelineUtilities.TransparentShadowsEnabled();
            _depthAfterTransparents = PipelineUtilities.IsDepthAfterTransparents();

            foreach (UnityEngine.Object target in materialEditorIn.targets)
                MaterialChanged((Material)target);

            _initialized = true;
        }

        public override void OnClosed(Material material)
        {
            _initialized = false;
        }

        public override void OnGUI(MaterialEditor materialEditorIn, MaterialProperty[] props)
        {
            _materialEditor = materialEditorIn;

            Material material = _materialEditor.target as Material;
            FindProperties(props, material);

            if (!_initialized)
                OnEnable(_materialEditor);

            ShaderPropertiesGUI(material);
        }

        private void ShaderPropertiesGUI(Material material)
        {
            EditorGUILayout.Space(5);
            WaterUI.DrawHeader("Water FX", material.shader);
            EditorGUILayout.Space(5);
            EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);
            DrawNotifications();
            EditorGUI.BeginChangeCheck();

            DrawGeneral();
            DrawRendering(material);
            DrawLighting();
            DrawColor();
            DrawNormals();
            DrawUnderwater();
            DrawFoam();
            DrawIntersection();
            DrawReflections();
            DrawWaves();

            EditorGUILayout.Space();

            if (EditorGUI.EndChangeCheck())
            {
                foreach (var obj in _materialEditor.targets)
                    MaterialChanged((Material)obj);
            }
        }

        // 단순한 렌더링으로 인해 미리보기는 대부분 쓸모가 없습니다. 대신 아이콘을 오버레이 합니다.
        public override void OnMaterialPreviewGUI(MaterialEditor materialEditor, Rect rect, GUIStyle background)
        {
            GUI.DrawTexture(rect, WaterUI.AssetIcon, ScaleMode.ScaleToFit);
        }

        void DrawNotifications()
        {
            WaterUI.DrawNotification(!UniversalRenderPipeline.asset,
                "유니버설 렌더 파이프라인은 현재 활성화되어 있지 않습니다!", "Show me",
                WaterEditor.OpenGraphicsSettings, MessageType.Error);

            if (UniversalRenderPipeline.asset && _initialized)
            {
                WaterUI.DrawNotification(
                    UniversalRenderPipeline.asset.supportsCameraDepthTexture == false &&
                    _disableDepthTexture.floatValue == 0f,
                    "머티리얼의 현재 구성에 필요한 깊이 텍스처가 비활성화되었습니다.",
                    "Enable",
                    WaterEditor.EnableDepthTexture,
                    MessageType.Error);

                WaterUI.DrawNotification(
                    UniversalRenderPipeline.asset.supportsCameraOpaqueTexture == false &&
                    _refractionOn.floatValue == 1f,
                    "머티리얼의 현재 구성에 필요한 불투명 텍스처가 비활성화되었습니다.",
                    "Enable",
                    WaterEditor.EnableOpaqueTexture,
                    MessageType.Error);
            }

            WaterUI.DrawNotification(_depthAfterTransparents && _zWrite.floatValue > 0,
                "\nZWrite 옵션이 활성화되어 있고 렌더러에서 깊이 텍스처 모드가 'After Transparents\\'로 설정되어 있습니다\\n\\n이 조합으로는 물을 제대로 렌더링할 수 없습니다.\n",
                MessageType.Error);
        }

        private void MaterialChanged(Material material)
        {
            if (material == null) throw new ArgumentNullException("material");

            SetMaterialKeywords(material);

            material.SetTexture("_CausticsTex", _causticsTex.textureValue);
            material.SetTexture("_BumpMap", _bumpMap.textureValue);
            material.SetTexture("_BumpMapSlope", _bumpMapSlope.textureValue);
            material.SetTexture("_BumpMapLarge", _bumpMapLarge.textureValue);
            material.SetTexture("_FoamTex", _foamTex.textureValue);
            material.SetTexture("_IntersectionNoise", _intersectionNoise.textureValue);
        }

        private void SetMaterialKeywords(Material material)
        {
            //Keywords
            CoreUtils.SetKeyword(material, "_ADVANCED_SHADING", material.GetFloat("_ShadingMode") == 1f);
            CoreUtils.SetKeyword(material, "_SHARP_INERSECTION", material.GetFloat("_IntersectionStyle") == 1);
            CoreUtils.SetKeyword(material, "_SMOOTH_INTERSECTION", material.GetFloat("_IntersectionStyle") == 2);
        }

        #region Sections
        private void DrawGeneral()
        {
            EditorGUILayout.BeginVertical();

            _showGeneral = WaterUI.Foldout(WaterContent.General, _showGeneral);
            if (_showGeneral)
            {
                GUILayout.Space(10);
                WaterUI.DrawShaderProperty(_materialEditor, _worldSpaceUV,
                    new GUIContent(_worldSpaceUV.displayName,
                        "Mesh의 UV 또는 World Space 위치 좌표를 텍스처 타일링의 기반으로 사용"), 0);
                EditorGUILayout.LabelField("Animation", EditorStyles.boldLabel);
                WaterUI.DrawVector2(_direction, "Direction");
                WaterUI.DrawFloatField(_speed, "Speed");
                if (EditorWindow.focusedWindow && EditorWindow.focusedWindow.GetType() == typeof(SceneView))
                {
                    if (SceneView.lastActiveSceneView.sceneViewState.alwaysRefreshEnabled == false)
                    {
                        GUILayout.Space(10);
                        WaterUI.DrawNotification(
                            "\"Always Refresh\" 옵션은 씬 뷰에서 비활성화됩니다.\n수면 애니메이션이 불안해 보입니다.",
                            messageType: MessageType.Warning);
                    }
                }

                EditorGUILayout.Space(10);
            }

            EditorGUILayout.EndVertical();
        }

        private void DrawRendering(Material material)
        {
            EditorGUILayout.BeginVertical();

            _showRendering = WaterUI.Foldout(WaterContent.Rendering, _showRendering);
            if (_showRendering)
            {
                GUILayout.Space(10);
                using (new EditorGUILayout.HorizontalScope())
                {
                    MaterialEditor.BeginProperty(_shadingMode);

                    if (_shadingMode.hasMixedValue)
                    {
                        WaterUI.DrawShaderProperty(_materialEditor, _shadingMode, _advancedShadingContent);
                    }
                    else
                    {
                        EditorGUI.BeginChangeCheck();
                        EditorGUI.showMixedValue = _shadingMode.hasMixedValue;
                        EditorGUILayout.LabelField(_shadingMode.displayName,
                            GUILayout.Width(EditorGUIUtility.labelWidth));

                        float shadingMode = GUILayout.Toolbar((int)_shadingMode.floatValue,
                            new GUIContent[] { _simpleShadingContent, _advancedShadingContent, },
                            GUILayout.MaxWidth((250f)));

                        if (EditorGUI.EndChangeCheck())
                        {
                            _shadingMode.floatValue = shadingMode;
                        }

                        EditorGUI.showMixedValue = false;
                    }

                    MaterialEditor.EndProperty();
                }

                EditorGUILayout.Space();

                _materialEditor.EnableInstancingField();
                _materialEditor.RenderQueueField();
                if (material.renderQueue <= 2450 || material.renderQueue >= 3500)
                {
                    WaterUI.DrawNotification(
                        "머티리얼은 Transparent 렌더링 대기열(2450-3500)에 있어야 합니다. 그렇지 않으면 렌더링 아티팩트가 발생합니다.",
                        MessageType.Error);
                }

                EditorGUILayout.Space();

                WaterUI.DrawShaderProperty(_materialEditor, _cull,
                    new GUIContent(_cull.displayName,
                        "물 메시 표면의 어느 면이 보이지 않게 렌더링되는지(Cull) 제어합니다."));
                WaterUI.DrawShaderProperty(_materialEditor, _zWrite, new GUIContent("Depth writing (ZWrite)",
                    "물이 스스로 깊이 기반 정렬을 수행하도록 설정합니다. 겹치는 투명 지오메트리를 허용합니다. 파도가 높을 때 권장됩니다.\n\n이 옵션을 비활성화하면 다른 투명 머티리얼은 머티리얼에 설정된 렌더링 대기열/우선순위에 따라 물의 뒤 또는 앞에 렌더링됩니다."));
                WaterUI.DrawShaderProperty(_materialEditor, _zClip,
                    new GUIContent("Frustum clipping (ZClip)",
                        "표면이 카메라의 Far Clipping Plane을 넘어 확장될 때 표면을 클립할 수 있도록 활성화합니다. 모든 셰이더의 기본값입니다.\n\n지평선 쪽으로 확장되는 물을 만들려면 비활성화합니다.\n\n 노트 : Edge Fading 및 교차되는 거품(Foam)과 같은 효과는 카메라의 Far Clipping Plane을 고려하며, 이는 정상입니다."));
                EditorGUILayout.Space();

                WaterUI.DrawShaderProperty(_materialEditor, _disableDepthTexture, new GUIContent(
                    "Disable depth texture",
                    "깊이 텍스처는 렌더 파이프라인에서 사용할 수 있으며 수면과 그 뒤/앞의 불투명 지오메트리 사이의 거리와 위치를 측정하는 데 사용됩니다.\n\n색 그라데이션, 교차 효과, 가성 및 굴절과 같은 다양한 효과에 사용됩니다.\n\n뎁스 프리패스가 없는 기본적인 Rendering 설정을 대상으로 하는 경우 비활성화합니다."));


                EditorGUILayout.Space();

                EditorGUI.BeginChangeCheck();
                var tessellationTooltip =
                    "Mesh의 트라이앵글을 동적으로 세분화하여 카메라 근처에 더 조밀한 토폴로지를 생성합니다.\n\n이를 통해 보다 세밀한 웨이브 애니메이션이 가능합니다.\n\nShader Model 4.6 이상 및 Mac/iOS의 Metal 그래픽 API가 설치된 GPU에서만 지원됩니다. 실패하면 자동으로 테셀레이션되지 않은 셰이더로 돌아갑니다.";

                EditorGUILayout.LabelField(new GUIContent("Tessellation", tessellationTooltip));

                WaterUI.DrawNotification(_flatShadingOn.floatValue > 0 || _flatShadingOn.hasMixedValue,
                    "Flat shading이 활성화된 경우 원하는 효과를 얻기 위해 테셀레이션을 사용해서는 안 됩니다.",
                    MessageType.Warning);

                EditorGUI.indentLevel++;
                WaterUI.DrawShaderProperty(_materialEditor, _tessValue, _tessValue.displayName);
                WaterUI.DrawFloatField(_tessMin);
                _tessMin.floatValue = Mathf.Clamp(_tessMin.floatValue, 0f, _tessMax.floatValue - 0.01f);
                WaterUI.DrawFloatField(_tessMax);
                EditorGUI.indentLevel--;

                WaterUI.DrawNotification(material.enableInstancing,
                    "GPU 인스턴싱이 활성화된 경우 테셀레이션이 올바르게 작동하지 않습니다.", MessageType.Warning);


                EditorGUILayout.Space(10);
            }

            EditorGUILayout.EndVertical();
        }

        private void DrawLighting()
        {
            EditorGUILayout.BeginVertical();

            _showLighting = WaterUI.Foldout(WaterContent.Lighting, _showLighting);
            if (_showLighting)
            {
                GUILayout.Space(10);

                WaterUI.DrawShaderProperty(_materialEditor, _lightingOn,
                    new GUIContent("Enable lighting",
                        "조명 및 주변광(Flat/Gradient/Skybox)의 색상이 머티리얼에 영향을 미칩니다. 씬에서 전체적으로 조명되지 않은 셰이더를 사용하거나 고정 조명을 사용하는 경우 조명 계산을 건너뛰려면 비활성화합니다."));

                WaterUI.DrawShaderProperty(_materialEditor, _flatShadingOn,
                    new GUIContent("Flat/low-poly shading",
                        "이 옵션을 활성화하면 메시 면마다 노멀이 계산되어 패싯 모양(낮은 폴리 모양)이 됩니다. 효과를 제대로 발휘하려면 메시의 버텍스가 충분해야 합니다(예: 쿼드 메시로는 안 됨)."));
                WaterUI.DrawNotification(_flatShadingOn.floatValue > 0,
                    "테셀레이션이 활성화된 경우 원하는 효과를 얻기 위해 사용해서는 안 됩니다.",
                    MessageType.Warning);

                WaterUI.DrawNotification(_flatShadingOn.floatValue > 0f && _wavesOn.floatValue == 0f,
                    "테셀레이션이 활성화된 경우 원하는 효과를 얻기 위해 사용해서는 안 됩니다.", MessageType.Warning);

                WaterUI.DrawShaderProperty(_materialEditor, _receiveShadows,
                    new GUIContent("Receive shadows",
                        "머티리얼이 그림자를 받도록 허용합니다.\n\n반사, 부식 등 빛 기반 이펙트가 그림자 속에 숨을 수 있도록 합니다."));
                if ((_receiveShadows.floatValue > 0 || _receiveShadows.hasMixedValue) && !_transparentShadowsEnabled &&
                    _shadingMode.floatValue != 0)
                    _transparentShadowsEnabled = PipelineUtilities.TransparentShadowsEnabled();

                WaterUI.DrawNotification(
                    (_receiveShadows.floatValue > 0 || _receiveShadows.hasMixedValue) && !_transparentShadowsEnabled,
                    "기본적으로 포워드 렌더러에서는 Transparent에는 그림자가 비활성화됩니다.", "Show me",
                    WaterEditor.SelectForwardRenderer, MessageType.Warning);

                using (new EditorGUI.DisabledScope(_lightingOn.floatValue < 1f || _lightingOn.hasMixedValue))
                {
                    if ((_receiveShadows.floatValue > 0 || _receiveShadows.hasMixedValue))
                        WaterUI.DrawShaderProperty(_materialEditor, _shadowStrength, "Strength", 1);
                }

                WaterUI.DrawShaderProperty(_materialEditor, _normalStrength,
                    new GUIContent("Diffuse lighting",
                        "노멀 맵의 곡률이 디렉셔널 라이팅에 얼마나 영향을 미치는지 제어합니다."));
                if (_lightingOn.floatValue < 1f || _lightingOn.hasMixedValue)
                {
                    WaterUI.DrawNotification("조명이 비활성화되어 있어, 'normal strength' 설정이 시각적인 효과를 발휘하지 못하고 있습니다.",
                        MessageType.Info);
                }

                EditorGUILayout.Space();

                using (new EditorGUI.DisabledScope(_normalMapOn.floatValue == 0f))
                {
                    EditorGUILayout.LabelField("Sparkles", EditorStyles.boldLabel);
                    WaterUI.DrawShaderProperty(_materialEditor, _sparkleIntensity,
                        new GUIContent("Intensity",
                            "여기에 Main Direction Light의 색상/강도가 곱해집니다."));
                    WaterUI.DrawShaderProperty(_materialEditor, _sparkleSize, "Size");
                }

                WaterUI.DrawNotification(_normalMapOn.floatValue == 0f,
                    "스파클을 사용하려면 노멀 맵 기능을 활성화해야 합니다.", MessageType.None);

                EditorGUILayout.Space();

                WaterUI.DrawShaderProperty(_materialEditor, _translucencyOn,
                    new GUIContent("Translucency",
                        "태양 빛이 물을 통과하여 산란하는 것처럼 보이게 합니다.\n\n이 효과는 대부분 스쳐 지나가는 빛의 각도에서 볼 수 있습니다."));

                if (_translucencyOn.floatValue > 0 || _translucencyOn.hasMixedValue)
                {
                    WaterUI.DrawShaderProperty(_materialEditor, _translucencyStrength,
                        new GUIContent("Strength", "반투명한 그 너머에 무엇이 있는지 명확하게 볼 수 있게 할지 말지에 대한 세기"), 1);
                    WaterUI.DrawShaderProperty(_materialEditor, _translucencyExp,
                        new GUIContent("Exponent", "기본적으로 이펙트의 폭/스케일을 제어합니다."), 1);
                    WaterUI.DrawShaderProperty(_materialEditor, _translucencyCurvatureMask,
                        new GUIContent("Curvature mask",
                            "표면의 방향에 따라 효과를 마스킹합니다. 태양을 반대 방향으로 향하는 표면은 이펙트가 덜 적용됩니다. 구체 메시에서는 이펙트가 가장자리/실루엣 쪽으로 몰리게 됩니다."),
                        1);
                }

                EditorGUILayout.Space(10);
            }

            EditorGUILayout.EndVertical();
        }

        private void DrawColor()
        {
            EditorGUILayout.BeginVertical();

            _showColor = WaterUI.Foldout(WaterContent.Color, _showColor);
            if (_showColor)
            {
                GUILayout.Space(10);
                WaterUI.DrawColorField(_baseColor, true, _baseColor.displayName,
                    "기본적인 물 색상, 알파 체널은 투명도를 조절");
                WaterUI.DrawColorField(_shallowColor, true, _shallowColor.displayName,
                    "얕은 영역의 물색, 알파 채널은 투명도를 제어합니다. 여기에는 Caustic(부식) 효과가 표현되며 알파를 100%로 설정하면 Caustic(부식)이 사라집니다.");

                using (new EditorGUI.DisabledGroupScope(_disableDepthTexture.floatValue == 1f &&
                    !_disableDepthTexture.hasMixedValue))
                {
                    EditorGUILayout.Space();

                    EditorGUILayout.LabelField("Fog/Density", EditorStyles.boldLabel);
                    WaterUI.DrawShaderProperty(_materialEditor, _depthVertical,
                        new GUIContent("Distance Depth",
                            "카메라 시점에서 물 표면을 따라 보거나 물을 통해 보게 되면, 물 표면 아래의 객체까지의 거리와 함께 물이 더욱 밀집해 보이는 현상"));
                    WaterUI.DrawShaderProperty(_materialEditor, _depthHorizontal,
                        new GUIContent("Vertical Depth",
                            "물 표면에서 바로 아래로 측정한 밀도를 가리키며, 이는 유형의 인공적인 높이 안개로 작용합니다."));

                    WaterUI.DrawShaderProperty(_materialEditor, _depthExp,
                        new GUIContent("Exponential",
                            tooltip: "지수적 깊이는 얕은 물과 상대적으로 평평한 해안에 가장 잘 작동합니다."), 1);
                }

                EditorGUILayout.Space();

                if (_shadingMode.floatValue == 1 || _shadingMode.hasMixedValue) //Advanced shading
                {
                    using (new EditorGUI.DisabledGroupScope(_refractionOn.floatValue == 0 &&
                        !_refractionOn.hasMixedValue))
                    {
                        WaterUI.DrawShaderProperty(_materialEditor, _colorAbsorption,
                            new GUIContent(_colorAbsorption.displayName,
                                "물의 깊이를 기반으로 수중색을 어둡게 합니다. 이것은 물의 특별한 물리적 성질로, 실제적인 외관에 기여합니다."));
                    }

                    if (_refractionOn.floatValue == 0)
                        EditorGUILayout.HelpBox("이 기능을 사용하려면 Refraction 기능을 활성화해야 합니다.", MessageType.None);

                    EditorGUILayout.Space();
                }

                WaterUI.DrawShaderProperty(_materialEditor, _vertexColorDepth,
                    new GUIContent("Vertex color depth (G)", "녹색 Vertex Color 채널은 물의 깊이를 줄여 얕게 보이게 합니다."));
                using (new EditorGUI.DisabledGroupScope(_disableDepthTexture.floatValue == 1f &&
                    !_disableDepthTexture.hasMixedValue))
                {
                    WaterUI.DrawFloatField(_edgeFade, "Edge fading",
                        "물이 불투명한 물체와 만나는 부분을 흐릿하게 하는 기능이며, 이를 사용하려면 깊이 텍스처 옵션을 활성화해야 합니다.");
                    _edgeFade.floatValue = Mathf.Max(0f, _edgeFade.floatValue);
                }

                EditorGUILayout.Space();

                WaterUI.DrawColorField(_horizonColor, true, _horizonColor.displayName,
                    "물을 가로질러 볼 때, 지평선에서 인식되는 색상을 의미합니다.");
                WaterUI.DrawShaderProperty(_materialEditor, _horizonDistance, _horizonDistance.displayName);

                WaterUI.DrawShaderProperty(_materialEditor, _waveTint,
                    new GUIContent(_waveTint.displayName,
                        "파도 높이에 따라 밝은/어두운 색조를 추가합니다. \n\n파도 기능이 활성화되어야 합니다."));

                EditorGUILayout.Space(10);
            }

            EditorGUILayout.EndVertical();
        }

        private void DrawNormals()
        {
            EditorGUILayout.BeginVertical();

            _showNormals = WaterUI.Foldout(WaterContent.Normals, _showNormals);
            if (_showNormals)
            {
                GUILayout.Space(10);
                WaterUI.DrawShaderProperty(_materialEditor, _normalMapOn,
                    new GUIContent("Enable",
                        "Normals은 물 표면에 소규모 디테일 곡선을 추가하며, 이는 다양한 조명 기법에서 사용됩니다."));

                EditorGUILayout.Space();

                if (_normalMapOn.floatValue > 0f || _normalMapOn.hasMixedValue)
                {
                    _materialEditor.TextureProperty(_bumpMap, "Normal map");

                    EditorGUILayout.LabelField("Tiling & Offset", EditorStyles.boldLabel);
                    WaterUI.DrawFloatField(_normalTiling,
                        tooltip:
                        "텍스처가 UV 좌표 상에서 얼마나 자주 반복되는지 결정합니다. 값이 작을수록 텍스처가 더 크게 늘어나며, 값이 크면 텍스처가 더 작아집니다.");
                    EditorGUI.indentLevel++;
                    WaterUI.DrawFloatField(_normalSubTiling, "Sub-layer (multiplier)",
                        "효과는 다양성을 위해 두 번째 텍스처 샘플을 사용합니다. 이 값은 이 레이어의 속도를 제어합니다.");
                    EditorGUI.indentLevel--;
                    WaterUI.DrawFloatField(_normalSpeed,
                        tooltip:
                        "[General 탭에서 설정한 애니메이션 속도에 곱해집니다]\n\n텍스처가 애니메이션 방향으로 얼마나 빠르게 움직이는지 제어합니다. 음수 값(-)은 그것을 반대 방향으로 움직이게 만듭니다.");
                    EditorGUI.indentLevel++;
                    WaterUI.DrawFloatField(_normalSubSpeed, "Sub-layer (multiplier)",
                        tooltip: "두 번째 텍스처 샘플의 곱셈 요소입니다.");
                    EditorGUI.indentLevel--;

                    EditorGUILayout.Space();

                    WaterUI.DrawShaderProperty(_materialEditor, _distanceNormalsOn,
                        new GUIContent("Distance normals",
                            "원거리에서 Normals를 더 큰 스케일로 리샘플링합니다. 추가적인 셰이딩 계산의 비용으로, 타일링 아티팩트를 크게 줄일 수 있습니다."));

                    if (_distanceNormalsOn.floatValue > 0 || _distanceNormalsOn.hasMixedValue)
                    {
                        _materialEditor.TextureProperty(_bumpMapLarge, "Normal map");
                        WaterUI.DrawFloatField(_distanceNormalsTiling, "Tiling");

                        WaterUI.DrawMinMaxSlider(_distanceNormalsFadeDist, 0f, 500,
                            "Blend distance range",
                            tooltip: "효과가 혼합되어야 하는 카메라로부터의 최소/최대 거리 범위를 나타냅니다.");
                    }
                }

                EditorGUILayout.Space(10);
            }

            EditorGUILayout.EndVertical();
        }

        private void DrawUnderwater()
        {
            EditorGUILayout.BeginVertical();

            _showUnderWater = WaterUI.Foldout(WaterContent.UnderWater, _showUnderWater);
            if (_showUnderWater)
            {
                GUILayout.Space(10);
                WaterUI.DrawShaderProperty(_materialEditor, _causticsOn, new GUIContent("Caustics",
                    "카우스틱은 일반적으로 빛이 표면을 통과하고 굴절함으로써 생성되는 복잡한 광학 효과입니다." +
                    "\n\n정적인 카우스틱 텍스처를 사용하여 이 효과를 물 표면 뒤의 불투명 기하학에 투영함으로써 근사할 수 있습니다." +
                    "\n\n고급 셰이딩이 활성화되면, 포인트 라이트와 스포트 라이트도 이 효과를 생성합니다."));

                if (_causticsOn.floatValue == 1 || _causticsOn.hasMixedValue)
                {
                    _materialEditor.TextureProperty(_causticsTex, "Texture (Additively blended)");
                    WaterUI.DrawFloatField(_causticsBrightness, "Brightness",
                        "들어오는 빛의 강도는 효과가 얼마나 강하게 나타나는지 제어합니다. 이 매개변수는 승수 역할을 합니다.");
                    if (!_causticsBrightness.hasMixedValue)
                        _causticsBrightness.floatValue = Mathf.Max(0, _causticsBrightness.floatValue);

                    WaterUI.DrawShaderProperty(_materialEditor, _causticsDistortion,
                        new GUIContent(_causticsDistortion.displayName,
                            "노멀 맵을 기반으로 커스틱을 왜곡합니다."));

                    EditorGUILayout.Space();

                    WaterUI.DrawFloatField(_causticsTiling);
                    WaterUI.DrawFloatField(_causticsSpeed);
                }

                if (_disableDepthTexture.floatValue == 1f && _causticsOn.floatValue == 1f)
                {
                    WaterUI.DrawNotification(
                        "\"깊이 텍스처 비활성화\" 옵션이 활성화되어 있기 때문에 Caustics는 수면 자체에 투영됩니다.",
                        MessageType.None);

                    WaterUI.DrawNotification(
                        _vertexColorDepth.floatValue == 0 && !_vertexColorDepth.hasMixedValue,
                        "\\n뎁스 텍스처가 비활성화되어 있으므로 얕은 물을 만들 수 없습니다. 커스틱이 보이지 않습니다.\\n\\n수심이 얕은 물을 수동으로 칠하려면 버텍스 컬러 불투명도 사용을 활성화합니다.\\n",
                        "Enable", () => _vertexColorDepth.floatValue = 1);
                }

                EditorGUILayout.Space();

                WaterUI.DrawShaderProperty(_materialEditor, _refractionOn,
                    new GUIContent("Refraction",
                        "빛이 물의 곡선 표면을 통과하기 때문에 물 뒤의 표면이 어떻게 왜곡되어 나타나는지 시뮬레이션합니다."));

                if (_refractionOn.floatValue == 1f || _refractionOn.hasMixedValue)
                {
                    if (UniversalRenderPipeline.asset)
                    {
                        WaterUI.DrawNotification(
                            UniversalRenderPipeline.asset.opaqueDownsampling != Downsampling.None,
                            "불투명 텍스처는 낮은 해상도로 렌더링되므로 물이 흐릿하게 보일 수 있습니다.");
                    }

                    if (_normalMapOn.floatValue == 0f && _wavesOn.floatValue == 0f)
                    {
                        WaterUI.DrawNotification(
                            "노멀과 웨이브가 비활성화되면 굴절은 거의 영향을 미치지 않습니다.",
                            MessageType.Warning);
                    }

                    WaterUI.DrawShaderProperty(_materialEditor, _refractionStrength,
                        new GUIContent("Strength",
                            "Note: 왜곡 강도는 노멀 맵 텍스처의 강도에 영향을 받습니다."), 1);
                    if (_shadingMode.floatValue == 1f || _shadingMode.hasMixedValue)
                    {
                        WaterUI.DrawShaderProperty(_materialEditor, _refractionChromaticAberration,
                            new GUIContent("Chromatic Aberration (Max)",
                                "굴절이 가장 강한 곳에 프림과 같은 무지개 효과를 만듭니다. 최대 오프셋을 제어하며, 굴절 강도(파라미터와 컨텍스트 모두)에 따라 달라집니다\n\n수중 안개에 약간의 불일치를 만들 수 있습니다!"));
                    }
                }

                EditorGUILayout.Space(10);
            }

            EditorGUILayout.EndVertical();
        }

        private void DrawFoam()
        {
            EditorGUILayout.BeginVertical();

            _showFoam = WaterUI.Foldout(WaterContent.SurfaceFoam, _showFoam);
            if (_showFoam)
            {
                GUILayout.Space(10);
                WaterUI.DrawShaderProperty(_materialEditor, _foamOn,
                    new GUIContent("Enable", "물 표면에 거품 텍스처 애니메이션을 적용하는 기능"));
                if (_foamOn.floatValue > 0 || _foamOn.hasMixedValue)
                {
                    _materialEditor.TextureProperty(_foamTex, "Texture (R)");

                    EditorGUILayout.LabelField("Application", EditorStyles.boldLabel);
                    WaterUI.DrawShaderProperty(_materialEditor, _foamBaseAmount,
                        new GUIContent("Base amount", "균일한 양의 거품을 추가합니다."));
                    WaterUI.DrawShaderProperty(_materialEditor, _foamClipping,
                        new GUIContent("Clipping", "그라데이션을 기반으로 텍스처를 점차적으로 잘라냅니다."));

                    WaterUI.DrawShaderProperty(_materialEditor, _vertexColorFoam, new GUIContent(
                        "Vertex color painting (A)",
                        "버텍스 색상 알파 채널의 사용을 활성화하여 거품을 추가합니다."));

                    WaterUI.DrawColorField(_foamColor, true, "Color",
                        "거품의 색상을 정하고, 알파 채널을 사용하여 불투명도를 조정합니다.");

                    WaterUI.DrawShaderProperty(_materialEditor, _foamWaveAmount,
                        new GUIContent(_foamWaveAmount.displayName, "파도의 가장 높은 부분에 거품을 추가합니다."));

                    EditorGUILayout.Space();

                    EditorGUILayout.LabelField("Tiling & Offset", EditorStyles.boldLabel);
                    WaterUI.DrawFloatField(_foamTiling,
                        tooltip: "텍스처가 UV 좌표 상에서 얼마나 자주 반복되는지를 결정합니다. 값이 작을수록 텍스처가 더 크게 늘어나며, 값이 크면 텍스처가 더 작아집니다.");
                    EditorGUI.indentLevel++;
                    WaterUI.DrawFloatField(_foamSubTiling, "Sub-layer (multiplier)",
                        "효과는 다양성을 위해 두 번째 텍스처 샘플을 사용합니다. 이 값은 이 레이어의 속도를 제어합니다.");
                    EditorGUI.indentLevel--;
                    WaterUI.DrawFloatField(_foamSpeed,
                        tooltip:
                        "[General 탭에서 설정한 애니메이션 속도에 곱해집니다]\n\n텍스처가 애니메이션 방향으로 얼마나 빠르게 움직이는지 제어합니다. 음수 값(-)은 그것을 반대 방향으로 움직이게 만듭니다."
                    );
                    EditorGUI.indentLevel++;
                    WaterUI.DrawFloatField(_foamSubSpeed, "Sub-layer (multiplier)",
                        tooltip: "두 번째 텍스처 샘플의 배수입니다.");
                    EditorGUI.indentLevel--;

                    EditorGUILayout.Space();

                    WaterUI.DrawShaderProperty(_materialEditor, _foamDistortion,
                        new GUIContent(_foamDistortion.displayName,
                            "파도에 의해 생성되는 것과 같은 수직 변위량에 따라 폼을 왜곡합니다."));
                }

                EditorGUILayout.Space(10);
            }

            EditorGUILayout.EndVertical();
        }

        private void DrawIntersection()
        {
            EditorGUILayout.BeginVertical();

            _showIntersectionFoam = WaterUI.Foldout(WaterContent.IntersectionFoam, _showIntersectionFoam);
            if (_showIntersectionFoam)
            {
                GUILayout.Space(10);
                using (new EditorGUILayout.HorizontalScope())
                {
                    MaterialEditor.BeginProperty(_intersectionStyle);

                    EditorGUI.BeginChangeCheck();
                    EditorGUI.showMixedValue = _intersectionStyle.hasMixedValue;

                    if (_intersectionStyle.hasMixedValue)
                    {
                        WaterUI.DrawShaderProperty(_materialEditor, _intersectionStyle, "Style");
                    }
                    else
                    {
                        EditorGUILayout.LabelField("Style", GUILayout.Width(EditorGUIUtility.labelWidth));

                        float intersectionStyle = GUILayout.Toolbar((int)_intersectionStyle.floatValue,
                            new GUIContent[] {
                                new GUIContent("None"), new GUIContent("Sharp"), new GUIContent("Smooth"),
                            }, GUILayout.MaxWidth((250f))
                        );

                        if (EditorGUI.EndChangeCheck())
                            _intersectionStyle.floatValue = intersectionStyle;
                    }

                    EditorGUI.showMixedValue = false;

                    MaterialEditor.EndProperty();
                }

                if (WaterUI.ExpandTooltips)
                    EditorGUILayout.HelpBox(
                        "물이 불투명한 기하학적 영역과 교차하는 부분에 애니메이션 거품 효과를 그립니다.",
                        MessageType.None);

                if (_intersectionStyle.floatValue > 0 || _intersectionStyle.hasMixedValue)
                {
                    WaterUI.DrawShaderProperty(_materialEditor, _intersectionSource, new GUIContent(
                        "Gradient source", null,
                        "이 효과는 작동하기 위해 선형 그래디언트를 필요로 하며, 이는 교차점부터 물쪽까지의 거리를 나타내는 것입니다.\n\n\n이 매개변수는 이 정보를 추정하는 데 사용되는 소스를 제어합니다."));
                    if (_intersectionSource.floatValue == 0 && _disableDepthTexture.floatValue == 1f)
                    {
                        WaterUI.DrawNotification("렌더링 탭에서 깊이 텍스처 옵션이 비활성화되어 있습니다.",
                            MessageType.Error);
                    }

                    _materialEditor.TextureProperty(_intersectionNoise, "Texture (R=Mask)");
                    WaterUI.DrawColorField(_intersectionColor, true, "Color",
                        "알파 채널은 불투명도를 제어합니다.");

                    WaterUI.DrawShaderProperty(_materialEditor, _intersectionLength,
                        new GUIContent(_intersectionLength.displayName, "물체/해안으로부터의 거리"));
                    WaterUI.DrawShaderProperty(_materialEditor, _intersectionFalloff,
                        new GUIContent(_intersectionFalloff.displayName, "Falloff는 그라데이션을 나타냅니다."));
                    WaterUI.DrawFloatField(_intersectionTiling);
                    WaterUI.DrawFloatField(_intersectionSpeed,
                        tooltip: "이 값은 General 탭의 Animation Speed 값에 곱해집니다.");

                    if (_intersectionStyle.floatValue == 1f || _intersectionStyle.hasMixedValue)
                    {
                        WaterUI.DrawShaderProperty(_materialEditor, _intersectionClipping,
                            new GUIContent(_intersectionClipping.displayName,
                                "텍스처의 그래디언트에 따라 효과를 클립합니다."));
                        WaterUI.DrawFloatField(_intersectionRippleDist,
                            _intersectionRippleDist.displayName,
                            "전체 교차 길이에 걸쳐 각 리플 사이의 거리입니다.");
                        WaterUI.DrawShaderProperty(_materialEditor, _intersectionRippleStrength,
                            new GUIContent(_intersectionRippleStrength.displayName,
                                "리플이 효과와 얼마나 혼합될지 설정합니다."));
                    }
                }

                EditorGUILayout.Space(10);
            }

            EditorGUILayout.EndVertical();
        }

        private void DrawReflections()
        {
            EditorGUILayout.BeginVertical();

            _showReflections = WaterUI.Foldout(WaterContent.Reflections, _showReflections);
            if (_showReflections)
            {
                GUILayout.Space(10);

                EditorGUILayout.LabelField("Light reflections", EditorStyles.boldLabel);
                WaterUI.DrawShaderProperty(_materialEditor, _specularReflectionsOn, new GUIContent("Enable",
                    "라이팅, 카메라, 그리고 물 표면 각도 사이의 관계를 기반으로 하는 스펙큘러 반사를 생성합니다.\n\n\nSize와 Distortion 매개변수의 조합을 통해 다양한 시각적 스타일을 효과할 수 있습니다."));

                EditorGUI.indentLevel++;
                if (_specularReflectionsOn.floatValue > 0f || _specularReflectionsOn.hasMixedValue)
                {
                    EditorGUILayout.Space();

                    EditorGUILayout.LabelField("Directional Light", EditorStyles.boldLabel);

                    WaterUI.DrawShaderProperty(_materialEditor, _sunReflectionStrength,
                        new GUIContent("Strength", "이 값은 태양광의 강도에 곱해집니다."));
                    if (UniversalRenderPipeline.asset)
                    {
                        if (UniversalRenderPipeline.asset.supportsHDR == false)
                            EditorGUILayout.HelpBox("노트: 현재 파이프라인 자산에서 HDR은 비활성화되어 있습니다.",
                                MessageType.None);
                    }

                    if (!_sunReflectionStrength.hasMixedValue)
                        _sunReflectionStrength.floatValue = Mathf.Max(0, _sunReflectionStrength.floatValue);

                    WaterUI.DrawShaderProperty(_materialEditor, _sunReflectionSize,
                        new GUIContent("Size", "반사가 얼마나 넓게 보이는지를 결정합니다."));
                    WaterUI.DrawShaderProperty(_materialEditor, _sunReflectionDistortion,
                        new GUIContent("Distortion", "왜곡은 노멀 맵 텍스처의 강도와 웨이브 곡률의 영향을 크게 받습니다."));

                    if (_lightingOn.floatValue > 0f || _lightingOn.hasMixedValue)
                    {
                        EditorGUILayout.Space();

                        EditorGUILayout.LabelField("Point & Spot lights", EditorStyles.boldLabel);

                        WaterUI.DrawShaderProperty(_materialEditor, _pointSpotLightReflectionStrength,
                            new GUIContent("Strength", "이 값은 빛의 강도에 곱해집니다."));
                        if (UniversalRenderPipeline.asset)
                        {
                            if (UniversalRenderPipeline.asset.supportsHDR == false)
                                EditorGUILayout.HelpBox("노트: 현재 파이프라인 자산에서 HDR이 비활성화 되어 있습니다.",
                                    MessageType.None);
                        }

                        if (!_pointSpotLightReflectionStrength.hasMixedValue)
                            _pointSpotLightReflectionStrength.floatValue =
                                Mathf.Max(0, _pointSpotLightReflectionStrength.floatValue);

                        WaterUI.DrawShaderProperty(_materialEditor, _pointSpotLightReflectionSize,
                            new GUIContent("Size", "포인트/스팟 라이트에 대한 스펙큘러 반사 크기."));
                        WaterUI.DrawShaderProperty(_materialEditor, _pointSpotLightReflectionDistortion,
                            new GUIContent("Distortion",
                                "왜곡은 노멀 맵 텍스처의 강도와 웨이브 곡률의 영향을 크게 받습니다."));
                    }
                }

                EditorGUI.indentLevel--;

                EditorGUILayout.Space();

                EditorGUILayout.LabelField("Environment Reflections", EditorStyles.boldLabel);

                WaterUI.DrawShaderProperty(_materialEditor, _environmentReflectionsOn,
                    new GUIContent("Enable",
                        "Skybox, Reflection Probes, 그리고 Planar Reflection에서의 반사를 활성화합니다."));

                var customReflection = RenderSettings.customReflectionTexture;

                if (_environmentReflectionsOn.floatValue > 0 &&
                    RenderSettings.defaultReflectionMode == DefaultReflectionMode.Custom && !customReflection)
                {
                    WaterUI.DrawNotification(
                        "Lighting settings: 환경 반사 원이 \"Custom\"으로 설정되었지만, 큐브맵이 할당되지 않았습니다. 반사가 보이지 않을 수 있습니다.",
                        MessageType.Warning);
                }

                if (_environmentReflectionsOn.floatValue > 0 && QualitySettings.realtimeReflectionProbes == false &&
                    PlanarReflectionRenderer.Instances.Count == 0)
                {
                    WaterUI.DrawNotification("퀄리티 설정에서 실시간 Reflection Probes가 비활성화되었습니다.",
                        MessageType.Warning);
                }

                EditorGUILayout.Space();

                if (_environmentReflectionsOn.floatValue > 0 || _environmentReflectionsOn.hasMixedValue)
                {
                    WaterUI.DrawShaderProperty(_materialEditor, _reflectionStrength,
                        _reflectionStrength.displayName);
                    if (_lightingOn.floatValue > 0f || _lightingOn.hasMixedValue)
                    {
                        WaterUI.DrawShaderProperty(_materialEditor, _reflectionLighting,
                            new GUIContent(_reflectionLighting.displayName,
                                "기술적으로 보면, 반사 이미지에 라이팅을 적용하는 것은 바람직하지 않습니다. 그러나 반사가 실시간으로 업데이트되지 않지만 라이팅은 실시간으로 업데이트되는 경우, 이 설정은 여전히 유익할 수 있습니다.\n\n이는 라이팅이 반사에 얼마나 영향을 미치는지를 제어합니다."));
                    }

                    EditorGUILayout.Space();

                    WaterUI.DrawShaderProperty(_materialEditor, _reflectionFresnel,
                        new GUIContent(_reflectionFresnel.displayName,
                            "표면(파도 곡률 포함)에 대한 시야각에 따른 반사를 마스킹하여 자연에 더 가깝게 표현합니다(프레넬이라고 함)."));
                    WaterUI.DrawShaderProperty(_materialEditor, _reflectionDistortion,
                        new GUIContent(_reflectionDistortion.displayName,
                            "파도(Wave)의 노멀과 노멀 맵에 의해 반사를 왜곡합니다."));
                    WaterUI.DrawShaderProperty(_materialEditor, _reflectionBlur,
                        new GUIContent(_reflectionBlur.displayName,
                            "반사 프로브를 흐리게 만들면 색상의 보다 일반적인 반사 효과를 얻을 수 있습니다."));

                    EditorGUILayout.Space();

                    EditorGUILayout.LabelField(
                        $"Planar Reflections renderers in scene: {PlanarReflectionRenderer.Instances.Count}",
                        EditorStyles.miniLabel);
                    if (PlanarReflectionRenderer.Instances.Count > 0)
                    {
                        using (new EditorGUILayout.VerticalScope(EditorStyles.textArea))
                        {
                            foreach (PlanarReflectionRenderer r in PlanarReflectionRenderer.Instances)
                            {
                                using (new EditorGUILayout.HorizontalScope())
                                {
                                    EditorGUILayout.LabelField(r.name);
                                    if (GUILayout.Button("Select"))
                                    {
                                        Selection.activeGameObject = r.gameObject;
                                    }
                                }
                            }
                        }
                    }

                    EditorGUILayout.Space(10);
                }
            }

            EditorGUILayout.EndVertical();
        }

        private void DrawWaves()
        {
            EditorGUILayout.BeginVertical();

            _showWaves = WaterUI.Foldout(WaterContent.Waves, _showWaves);
            if (_showWaves)
            {
                GUILayout.Space(10);
                WaterUI.DrawShaderProperty(_materialEditor, _wavesOn, "Enable");

                EditorGUILayout.Space();

                if ((_wavesOn.floatValue == 1 || _wavesOn.hasMixedValue))
                {
                    WaterUI.DrawFloatField(_waveSpeed, label: "Speed multiplier");
                    WaterUI.DrawShaderProperty(_materialEditor, _vertexColorWaveFlattening, new GUIContent(
                        "Vertex color flattening (B)",
                        "파란색 Vertex Color 채널은 파도를 평평하게 합니다\n\n노트: 이는 부력 계산에 영향을 미치지 않습니다!"));

                    WaterUI.DrawShaderProperty(_materialEditor, _waveHeight,
                        new GUIContent(_waveHeight.displayName,
                            "파도는 항상 기본 높이에서 물을 밀어 올리므로 파도의 높이가 음수일 수 없습니다."));

                    WaterUI.DrawIntSlider(_waveCount,
                        tooltip:
                        "파도 계산을 X 번 반복합니다, 하지만 매번 더 작은 파도로 계산합니다.\n이 기능은 더욱 부드러운 파도 효과를 생성하는데 사용");

                    Vector4 waveDir = _waveDirection.vectorValue;


                    MaterialEditor.BeginProperty(_waveDirection);


                    EditorGUI.BeginChangeCheck();
                    EditorGUI.showMixedValue = _waveDirection.hasMixedValue;
                    Vector2 waveDir1;
                    Vector2 waveDir2;
                    waveDir1.x = waveDir.x;
                    waveDir1.y = waveDir.y;
                    waveDir2.x = waveDir.z;
                    waveDir2.y = waveDir.w;

                    EditorGUILayout.LabelField("Direction");
                    EditorGUI.indentLevel++;
                    waveDir1 = EditorGUILayout.Vector2Field("Sub layer 1 (Z)", waveDir1);
                    waveDir2 = EditorGUILayout.Vector2Field("Sub layer 2 (X)", waveDir2);
                    EditorGUI.indentLevel--;

                    waveDir = new Vector4(waveDir1.x, waveDir1.y, waveDir2.x, waveDir2.y);

                    if (EditorGUI.EndChangeCheck())
                    {
                        _waveDirection.vectorValue = waveDir;
                    }

                    EditorGUI.showMixedValue = false;


                    MaterialEditor.EndProperty();


                    WaterUI.DrawShaderProperty(_materialEditor, _waveDistance,
                        new GUIContent(_waveDistance.displayName, "파도 사이의 거리"));
                    WaterUI.DrawShaderProperty(_materialEditor, _waveSteepness,
                        new GUIContent(_waveSteepness.displayName,
                            "선명도 설정은 너무 높게 설정하면 정점들이 겹치는 문제를 일으킬 수 있으며, 이는 수평 이동 효과를 만들어낸다"));
                    WaterUI.DrawShaderProperty(_materialEditor, _waveNormalStr,
                        new GUIContent(_waveNormalStr.displayName,
                            "노멀은 직접적인 라이팅과 주변 라이팅에 대해 표면이 얼마나 곡선적으로 보이는지를 제어하는 기능이며, 이 기능이 없으면 물의 표면은 평평하게 보일 것"));

                    WaterUI.DrawMinMaxSlider(_waveFadeDistance, 0f, 500f, "Fade Distance",
                        "시작 거리와 종료 거리 사이에서 파도를 서서히 사라지게 합니다. 이는 멀리서 보는 타일링 아티팩트를 방지할 수 있습니다.");
                }

                EditorGUILayout.Space(10);
            }

            EditorGUILayout.EndVertical();
        }
        #endregion
    }
}
