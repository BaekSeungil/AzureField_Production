using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using ForwardRendererData = UnityEngine.Rendering.Universal.UniversalRendererData;


namespace NKStudio
{
    public class WaterEditor : Editor
    {
        [MenuItem("GameObject/3D Object/Water/Object", false, 0)]
        public static void CreateWaterObject()
        {
            Material mat = AssetDatabase.LoadAssetAtPath<Material>(AssetDatabase.GUIDToAssetPath("fbb04271505a76f40b984e38071e86f3"));
            Mesh mesh = AssetDatabase.LoadAssetAtPath<Mesh>(AssetDatabase.GUIDToAssetPath("1e01d80fdc2155d4692276500db33fc9"));

            WaterObject obj = WaterObject.New(mat, mesh);
            
            //Position in view
            if (SceneView.lastActiveSceneView)
            {
                obj.transform.position = SceneView.lastActiveSceneView.camera.transform.position + (SceneView.lastActiveSceneView.camera.transform.forward * (Mathf.Max(mesh.bounds.size.x, mesh.bounds.size.z)) * 0.5f);
            }
            
            if (Selection.activeGameObject) obj.transform.parent = Selection.activeGameObject.transform;

            Selection.activeObject = obj;
            
            if(Application.isPlaying == false) EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
        }

        [MenuItem("GameObject/3D Object/Water/Grid", false, 1)]
        [MenuItem("Window/Water/Create water grid", false, 2001)]
        public static void CreateWaterGrid()
        {
            GameObject obj = new GameObject("Water Grid", typeof(WaterGrid));
            Undo.RegisterCreatedObjectUndo(obj, "Created Water Grid");

            obj.layer = LayerMask.NameToLayer("Water");
            
            WaterGrid grid = obj.GetComponent<WaterGrid>();
            grid.Recreate();

            if (Selection.activeGameObject) obj.transform.parent = Selection.activeGameObject.transform;
            
            Selection.activeObject = obj;

            // Position in view
            if (SceneView.lastActiveSceneView)
            {
                Vector3 position = SceneView.lastActiveSceneView.camera.transform.position + (SceneView.lastActiveSceneView.camera.transform.forward * grid.scale * 0.5f);
                position.y = 0f;
                
                grid.transform.position = position;
            }
            
            if(Application.isPlaying == false) EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
        }
        
        [MenuItem("GameObject/3D Object/Water/Planar Reflections Renderer", false, 2)]
        [MenuItem("Window/Water/Set up planar reflections", false, 2000)]
        public static void CreatePlanarReflectionRenderer()
        {
            GameObject obj = new GameObject("Planar Reflections Renderer", typeof(PlanarReflectionRenderer));
            Undo.RegisterCreatedObjectUndo(obj, "Created PlanarReflectionRenderer");
            PlanarReflectionRenderer planarReflectionRenderer = obj.GetComponent<PlanarReflectionRenderer>();
            planarReflectionRenderer.ApplyToAllWaterInstances();

            Selection.activeObject = obj;
            
            if(Application.isPlaying == false) EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
        }

        
        [MenuItem("Assets/Create/Water/Mesh")]
        private static void CreateWaterPlaneAsset()
        {
            ProjectWindowUtil.CreateAssetWithContent("New Watermesh.watermesh", "");
        }
        
        [MenuItem("CONTEXT/Transform/Add floating transform")]
        private static void AddFloatingTransform(MenuCommand cmd)
        {
            Transform t = (Transform)cmd.context;

            if (!t.gameObject.GetComponent<FloatingObject>())
            {
                FloatingObject component = t.gameObject.AddComponent<FloatingObject>();
                EditorUtility.SetDirty(t);
            }
        }
        
        public static void OpenGraphicsSettings()
        {
            SettingsService.OpenProjectSettings("Project/Graphics");
        }
        
        public static void EnableDepthTexture()
        {
            if (!UniversalRenderPipeline.asset) return;

            UniversalRenderPipeline.asset.supportsCameraDepthTexture = true;
            EditorUtility.SetDirty(UniversalRenderPipeline.asset);

            if (PipelineUtilities.IsDepthTextureOptionDisabledAnywhere())
            {
                if (EditorUtility.DisplayDialog("Water", "The Depth Texture option is still disabled on other pipeline assets (likely for other quality levels).\n\nWould you like to enable it on those as well?", "OK", "Cancel"))
                {
                    PipelineUtilities.SetDepthTextureOnAllAssets(true);   
                }
            }
        }
        
        public static void EnableOpaqueTexture()
        {
            if (!UniversalRenderPipeline.asset) return;

            UniversalRenderPipeline.asset.supportsCameraOpaqueTexture = true;
            EditorUtility.SetDirty(UniversalRenderPipeline.asset);
            
            if (PipelineUtilities.IsOpaqueTextureOptionDisabledAnywhere())
            {
                if (EditorUtility.DisplayDialog("Water", "불투명 텍스처 옵션이 다른 렌더링 에셋에서는 비활성화되어 있습니다.\n\n다른 에셋에서도 이 옵션을 활성화하시겠습니까?", "넵", "아뇨!"))
                {
                    PipelineUtilities.SetOpaqueTextureOnAllAssets(true);   
                }
            }
        }
        
        /// <summary>
        /// 포워드 렌더러 에셋을 선택합니다.
        /// </summary>
        public static void SelectForwardRenderer()
        {
            if (!UniversalRenderPipeline.asset) return;

            System.Reflection.BindingFlags bindings = System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance;
            ScriptableRendererData[] m_rendererDataList = (ScriptableRendererData[])typeof(UniversalRenderPipelineAsset).GetField("m_RendererDataList", bindings).GetValue(UniversalRenderPipeline.asset);

            ForwardRendererData main = m_rendererDataList[0] as ForwardRendererData;
            Selection.activeObject = main;
        }
        
    }
}