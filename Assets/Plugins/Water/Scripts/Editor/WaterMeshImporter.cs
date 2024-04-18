//Stylized Water 2
//Staggart Creations (http://staggart.xyz)
//Copyright protected under Unity Asset Store EULA


using UnityEditor.AssetImporters;
using System.IO;
using UnityEngine;
using UnityEditor;
using Object = UnityEngine.Object;

namespace NKStudio
{
    [ScriptedImporter(3, FILE_EXTENSION)]
    public class WaterMeshImporter : ScriptedImporter
    {
        private const string FILE_EXTENSION = "watermesh";
        
        [SerializeField] public WaterMesh waterMesh = new WaterMesh();

        public override void OnImportAsset(AssetImportContext context)
        {
            waterMesh.Rebuild();

            context.AddObjectToAsset("mesh", waterMesh.Mesh);
            context.SetMainObject(waterMesh.Mesh);
        }
        
        [UnityEditor.Callbacks.OnOpenAsset]
        public static bool OnOpenAsset(int instanceID, int line)
        {
            Object target = EditorUtility.InstanceIDToObject(instanceID);

            if (target is Mesh)
            {
                var path = AssetDatabase.GetAssetPath(instanceID);
                
                if (Path.GetExtension(path) != "." + FILE_EXTENSION) return false;

                Selection.activeObject = target;
                return true;
            }
            
            return false;
        }

    }
	
	[CustomEditor(typeof(WaterMeshImporter))]
    public class WaterMeshImporterEditor: ScriptedImporterEditor
    {
        private SerializedProperty waterMesh;
        
        private SerializedProperty shape;
        
        private SerializedProperty scale;
        private SerializedProperty UVTiling;
        
        private SerializedProperty vertexDistance;
        
        private SerializedProperty noise;
        private SerializedProperty boundsPadding;
        
        private WaterMeshImporter importer;
        
		private bool autoApplyChanges;
        private bool previewInSceneView
        {
            get => EditorPrefs.GetBool("PREVIEW_WATER_MESH_ENABLED", true);
            set => EditorPrefs.SetBool("PREVIEW_WATER_MESH_ENABLED", value);
        }

        public override void OnEnable()
        {
			base.OnEnable();
			
            importer = (WaterMeshImporter)target;
            
            waterMesh = serializedObject.FindProperty("waterMesh");
            
            shape = waterMesh.FindPropertyRelative("Shape");
            scale = waterMesh.FindPropertyRelative("Scale");
            UVTiling = waterMesh.FindPropertyRelative("UVTiling");
            vertexDistance = waterMesh.FindPropertyRelative("VertexDistance");
            noise = waterMesh.FindPropertyRelative("Noise");
            boundsPadding = waterMesh.FindPropertyRelative("BoundsPadding");

            SceneView.duringSceneGui += OnSceneGUI;
        }

        public override void OnInspectorGUI()
        {
            using (new EditorGUILayout.HorizontalScope())
            {
                GUILayout.Space(EditorGUIUtility.labelWidth);
                previewInSceneView =
                    GUILayout.Toggle(previewInSceneView, new GUIContent("  Preview in scene view", EditorGUIUtility.IconContent(
                        (previewInSceneView ? "animationvisibilitytoggleon" : "animationvisibilitytoggleoff")).image), "Button");
            }
            if (previewInSceneView && WaterObject.Instances.Count > 0)
            {
                using (new EditorGUILayout.HorizontalScope())
                {
                    GUILayout.Space(EditorGUIUtility.labelWidth);
                    EditorGUILayout.HelpBox($"Drawing on WaterObject instances in the scene ({WaterObject.Instances.Count})", MessageType.None);
                }
            }
            
            EditorGUILayout.Space();

            serializedObject.Update();
            EditorGUI.BeginChangeCheck();
            
            EditorGUILayout.PropertyField(shape);
            
            EditorGUILayout.Space();
            
            EditorGUILayout.PropertyField(scale);
            EditorGUILayout.PropertyField(vertexDistance);
            
            int subdivisions = Mathf.FloorToInt(scale.floatValue / vertexDistance.floatValue);
            int vertexCount = Mathf.FloorToInt(subdivisions * subdivisions);

            using (new EditorGUILayout.HorizontalScope())
            {
                GUILayout.Space(EditorGUIUtility.labelWidth);
                
                Rect rect = EditorGUILayout.GetControlRect();
                EditorGUI.ProgressBar(rect, (float)vertexCount/65535f, $"Vertex count: {vertexCount:N1}/{65535f:N1}");
            }
            if(vertexCount > 65535)
            {
                EditorGUILayout.HelpBox("Vertex count (" + vertexCount + ") is too high. Decrease the scale, or increase the vertex distance.", MessageType.Error);
            }
            
            EditorGUILayout.Space();

            EditorGUILayout.PropertyField(UVTiling);
            EditorGUILayout.PropertyField(noise);
            EditorGUILayout.PropertyField(boundsPadding);
            
            EditorGUILayout.Space();

            autoApplyChanges = EditorGUILayout.Toggle("Auto-apply changes", autoApplyChanges);
            
            if (EditorGUI.EndChangeCheck())
            {
                serializedObject.ApplyModifiedProperties();
                
                if (autoApplyChanges && HasModified())
                {
                    SaveChanges();
                    importer = (WaterMeshImporter)target;
                }
            }
            
            ApplyRevertGUI();
        }
        
        private void OnDestroy()
        {
            SceneView.duringSceneGui -= OnSceneGUI;
        }

        private Material mat;
        private void OnSceneGUI(SceneView obj)
        {
            if (!previewInSceneView)
            {
                GL.wireframe = false;
                return;
            }

            if (!mat)
            {
                mat = new Material(Shader.Find("Unlit/Color"));
                mat.color = new Color(0,0,0, 0.25f);
                mat.mainTexture = Texture2D.whiteTexture;
            }
            mat.SetPass(0);
            
            if (importer.waterMesh.Mesh)
            {
                GL.wireframe = true;
                if (WaterObject.Instances.Count > 0)
                {
                    foreach (WaterObject waterObject in WaterObject.Instances)
                    {
                        Graphics.DrawMeshNow(importer.waterMesh.Mesh, waterObject.transform.localToWorldMatrix);
                    }
                }
                else
                {
                    if (SceneView.lastActiveSceneView)
                    {
                        //Position in view
                        Vector3 position = SceneView.lastActiveSceneView.camera.transform.position + (SceneView.lastActiveSceneView.camera.transform.forward * importer.waterMesh.Scale * 0.5f);
                        Graphics.DrawMeshNow(importer.waterMesh.Mesh, position, Quaternion.identity);
                    }
                }
                GL.wireframe = false;
            }
        }
    }
}
