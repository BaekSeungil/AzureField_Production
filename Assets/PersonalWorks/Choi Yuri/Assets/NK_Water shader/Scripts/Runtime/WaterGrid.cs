using System;
using System.Collections.Generic;
using UnityEngine;

namespace NKStudio
{
    [ExecuteInEditMode]
    [AddComponentMenu("Water/Water Grid")]
    public class WaterGrid : MonoBehaviour
    {
        [Tooltip("타일 메쉬에 사용된 머티리얼")]
        public Material material;
        
        [Tooltip("플레이 모드가 아닐 때는 물이 씬 뷰 카메라 위치를 따라 움직입니다.")]
        public bool followSceneCamera = false;
        [Tooltip("활성화하면 재생 모드로 전환할 때 \"Main Camera\" 태그가 있는 오브젝트가 팔로우 타깃으로 할당됩니다.")]
        public bool autoAssignCamera;
        [Tooltip("그리드는 XZ 축에서 이 트랜스폼의 위치를 따릅니다. 카메라의 트랜스폼으로 설정하는 것이 가장 이상적입니다.")]
        public Transform followTarget;
        
        [Tooltip("전체 그리드의 길이 및 너비 배율")]
        public float scale = 500f;
        [Range(0.15f, 10f)] 
        [Tooltip("정점 사이의 거리, 낮기보다는 오히려 높음")]
        public float vertexDistance = 2f;
        [Min(1)]
        public int rowsColumns = 4;

        [HideInInspector]
        public int m_rowsColumns = 4;
        [SerializeField]
        [HideInInspector]
        private Mesh mesh;
        [SerializeField]
        [HideInInspector]
        private List<WaterObject> objects = new List<WaterObject>();
        
        [NonSerialized]
        private float tileSize;
        [NonSerialized]
        private WaterObject m_waterObject = null;
        [NonSerialized]
        private Transform actualFollowTarget;
        [NonSerialized]
        private Vector3 targetPosition;

        #if UNITY_EDITOR
        public static bool DisplayGrid = true;
        public static bool DisplayWireframe;
        #endif

        private void Reset()
        {
            Recreate();
        }
        
        private void Start()
        {
            if (autoAssignCamera) followTarget = Camera.main ? Camera.main.transform : followTarget;
        }
        
        private void OnEnable()
        {
#if UNITY_EDITOR
            UnityEditor.SceneView.duringSceneGui += OnSceneGUI;

#endif
            m_rowsColumns = rowsColumns;

            //Mesh is serialized with the scene, if component is used as a prefab, regenerate it
            if (mesh == null)
            {
                RecreateMesh();
                ReassignMesh();
            }
        }

#if UNITY_EDITOR
        private void OnDisable()
        {
            UnityEditor.SceneView.duringSceneGui -= OnSceneGUI;
        }
#endif

        void Update()
        {
            if (Application.isPlaying) actualFollowTarget = followTarget;

            if (actualFollowTarget)
            {
                targetPosition = actualFollowTarget.transform.position;

                targetPosition = SnapToGrid(targetPosition, vertexDistance);
                targetPosition.y = this.transform.position.y;
                this.transform.position = targetPosition;
            }
        }

        public void Recreate()
        {
            RecreateMesh();

            bool requireRecreate = (m_rowsColumns != rowsColumns) || objects.Count < (rowsColumns * rowsColumns);
            if (requireRecreate) m_rowsColumns = rowsColumns;

            //Only destroy/recreate objects if grid subdivision has changed
            if (requireRecreate && objects.Count > 0)
            {
                foreach (WaterObject obj in objects)
                {
                    if (obj) DestroyImmediate(obj.gameObject);
                }
                objects.Clear();
            }

            int index = 0;
            for (int x = 0; x < rowsColumns; x++)
            {
                for (int z = 0; z < rowsColumns; z++)
                {
                    if (requireRecreate)
                    {
                        m_waterObject = WaterObject.New(material, mesh);
                        objects.Add(m_waterObject);
                        
                        m_waterObject.transform.parent = this.transform;
                        m_waterObject.name = "WaterTile_x" + x + "z" + z;
                    }
                    else
                    {
                        m_waterObject = objects[index];
                        m_waterObject.AssignMesh(mesh);
                        m_waterObject.AssignMaterial(material);
                    }

                    m_waterObject.transform.localPosition = GridLocalCenterPosition(x, z);
                    m_waterObject.transform.localScale = Vector3.one;

                    index++;
                }
            }
        }

        private void RecreateMesh()
        {
            rowsColumns = Mathf.Max(rowsColumns, 1);
            tileSize = Mathf.Max(1f, scale / rowsColumns);
            
            mesh = WaterMesh.Create(WaterMesh.EShape.Rectangle, tileSize, vertexDistance, tileSize);
        }

        private void ReassignMesh()
        {
            foreach (WaterObject obj in objects)
            {
                obj.AssignMesh(mesh);
            }
        }

        private Vector3 GridLocalCenterPosition(int x, int z)
        {
            return new Vector3(x * tileSize - ((tileSize * (rowsColumns)) * 0.5f) + (tileSize * 0.5f), 0f,
                z * tileSize - ((tileSize * (rowsColumns)) * 0.5f) + (tileSize * 0.5f));
        }

        private static Vector3 SnapToGrid(Vector3 position, float cellSize)
        {
            return new Vector3(SnapToGrid(position.x, cellSize), SnapToGrid(position.y, cellSize), SnapToGrid(position.z, cellSize));
        }

        private static float SnapToGrid(float position, float cellSize)
        {
            return Mathf.FloorToInt(position / cellSize) * (cellSize) + (cellSize * 0.5f);
        }

#if UNITY_EDITOR
        private void OnDrawGizmosSelected()
        {
            if (DisplayWireframe)
            {
                Gizmos.color = new Color(0, 0, 0, 0.5f);

                foreach (WaterObject waterObject in objects)
                {
                    if(waterObject.MeshFilter.sharedMesh) Gizmos.DrawWireMesh(waterObject.MeshFilter.sharedMesh, waterObject.transform.position);
                }
            }

            if (DisplayGrid)
            {
                Gizmos.color = new Color(1f, 0.25f, 0.25f, 0.5f);
                Gizmos.matrix = this.transform.localToWorldMatrix;
                
                for (int x = 0; x < rowsColumns; x++)
                {
                    for (int z = 0; z < rowsColumns; z++)
                    {
                        Vector3 pos = GridLocalCenterPosition(x, z);

                        Gizmos.DrawWireCube(pos, new Vector3(tileSize, 0f, tileSize));
                    }
                }
            }
        }

        private void OnSceneGUI(UnityEditor.SceneView sceneView)
        {
            if (followSceneCamera)
            {
                actualFollowTarget = sceneView.camera.transform;
                Update();
            }
            else
            {
                actualFollowTarget = null;
            }
        }
#endif
    }
}