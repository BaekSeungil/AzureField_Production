using System;
using System.Collections.Generic;
using UnityEngine;

namespace NKStudio
{
    [Serializable]
    public class WaterMesh
    {
        public enum EShape
        {
            Rectangle,
            Disk
        }
        public EShape Shape;

        [Range(10, 1000)]
        public float Scale = 100f;
        
        [Tooltip("버텍스 사이의 거리")]
        [Range(0.15f, 10f)]
        public float VertexDistance = 1f;
        
        public float UVTiling = 1f;
        
        [Tooltip("버텍스을 임의의 방향으로 이동합니다. 플랫 셰이딩을 사용할 때 반드시 이것을 사용하십시오.")]
        [Range(0f, 1f)]
        public float Noise;
        
        [Min(0)]
        [Tooltip("표면은 일반적으로 평평하지만 파도와 같은 GPU의 버텍스 변위는 표면에 인위적인 높이를 제공할 수 있습니다." +
                 "\n\n이로 인해 메시 렌더러가 실제로 표시됨에도 불구하고 조기에 컬링될 수 있습니다." +
                 "\n\n이 값은 생성 메시의 경계에 인위적인 높이를 추가하여 이러한 일이 발생하지 않도록 합니다.")]
        public float BoundsPadding = 4f;
        
        /// <summary>
        /// 생성된 출력 메시. 기본적으로 비어 있습니다. Rebuild() 함수를 사용하여 현재 설정에서 하나를 생성합니다.
        /// </summary>
        public Mesh Mesh;
        
        public Mesh Rebuild()
        {
            switch (Shape)
            {
                case EShape.Rectangle: Mesh = CreatePlane();
                    break;
                case EShape.Disk: Mesh = CreateCircle();
                    break;
            }

            return Mesh;
        }

        public static Mesh Create(EShape shape, float size, float vertexDistance, float uvTiling = 1f, float noise = 0f)
        {
            WaterMesh waterMesh = new()
            {
                Shape = shape,
                Scale = size,
                VertexDistance = vertexDistance,
                UVTiling = uvTiling,
                Noise = noise
            };

            return waterMesh.Rebuild();
        }

        // 원 번호 'c'에서 점 번호 'x'의 인덱스를 가져옵니다.
        private int GetPointIndex(int c, int x)
        {
            if (c < 0) return 0;

            x = x % ((c + 1) * 6); 

            return (3 * c * (c + 1) + x + 1);
        }

        private Mesh CreateCircle()
        {
            Mesh m = new()
            {
                name = "WaterDisk"
            };

            int subdivisions = Mathf.FloorToInt(Scale / VertexDistance);
            
            float distance = 1f / subdivisions;

            List<Vector3> vertices = new();
            List<Vector2> uvs = new();
            List<Vector2> uvs2 = new();
            vertices.Add(Vector3.zero); //Center
            List<int> tris = new();

            // First pass => build vertices
            for (int loop = 0; loop < subdivisions; loop++)
            {
                float angleStep = (Mathf.PI * 2f) / ((loop + 1) * 6);
                for (int point = 0; point < (loop + 1) * 6; ++point)
                {
                    Vector3 vPos = new(
                    Mathf.Sin(angleStep * point) ,
                    0f,
                    Mathf.Cos(angleStep * point));
                    
                    UnityEngine.Random.InitState(loop + point);
                    vPos.x += UnityEngine.Random.Range(-Noise * 0.01f, Noise * 0.01f);
                    vPos.z -= UnityEngine.Random.Range(Noise * 0.01f, -Noise * 0.01f);

                    vertices.Add(vPos * (Scale * 0.5f) * distance * (loop + 1));
                }
            }

            // Planar mapping
            for (int i = 0; i < vertices.Count; i++)
            {
                uvs.Add(new Vector2(0.5f + (vertices[i].x) * UVTiling,0.5f + (vertices[i].z) * UVTiling));
                //Lightmap UV's
                uvs2.Add(new Vector2(0.5f + (vertices[i].x / Scale),0.5f + (vertices[i].z / Scale)));
            }

            // 두 번째 패스 => 버텍스을 삼각형으로 연결
            for (int circ = 0; circ < subdivisions; ++circ)
            {
                for (int point = 0, other = 0; point < (circ + 1) * 6; ++point)
                {
                    if (point % (circ + 1) != 0)
                    {
                        // Create 2 triangles
                        tris.Add(GetPointIndex(circ - 1, other + 1));
                        tris.Add(GetPointIndex(circ - 1, other));
                        tris.Add(GetPointIndex(circ, point));

                        tris.Add(GetPointIndex(circ, point));
                        tris.Add(GetPointIndex(circ, point + 1));
                        tris.Add(GetPointIndex(circ - 1, other + 1));
                        ++other;
                    }
                    else
                    {
                        // Create 1 inverse triangle
                        tris.Add(GetPointIndex(circ, point));
                        tris.Add(GetPointIndex(circ, point + 1));
                        tris.Add(GetPointIndex(circ - 1, other));
                        // Do not move to the next point in the smaller circle
                    }
                }
            }

            // Create the mesh
            
            m.SetVertices(vertices);
            m.SetTriangles(tris, 0);
            m.RecalculateNormals();
            m.RecalculateTangents();
            m.SetUVs(0, uvs);
            m.SetUVs(1, uvs2);
            m.colors = new Color[vertices.Count];

            m.bounds = new Bounds(Vector3.zero, new Vector3(Scale, BoundsPadding, Scale));
            
            return m;
        }

        private Mesh CreatePlane()
        {
            Mesh m = new()
            {
                name = "WaterPlane"
            };

            Scale = Mathf.Max(1f, Scale);
            int subdivisions = Mathf.FloorToInt(Scale / VertexDistance);
            
            int xCount = subdivisions + 1;
            int zCount = subdivisions + 1;
            int numTriangles = subdivisions * subdivisions * 6;
            int numVertices = xCount * zCount;

            Vector3[] vertices = new Vector3[numVertices];
            Vector2[] uvs = new Vector2[numVertices];
            Vector2[] uvs2 = new Vector2[numVertices];
            int[] triangles = new int[numTriangles];
            Vector4[] tangents = new Vector4[numVertices];
            Vector3[] normals = new Vector3[numVertices];
            Vector4 tangent = new(1f, 0f, 0f, -1f);

            int index = 0;
            float scaleX = Scale / subdivisions;
            float scaleY = Scale / subdivisions;

            float noiseScale = VertexDistance * 0.5f;
            
            for (int z = 0; z < zCount; z++)
            {
                for (int x = 0; x < xCount; x++)
                {
                    vertices[index] = new Vector3(x * scaleX - Scale * 0.5f, 0f, z * scaleY - Scale * 0.5f);
                    
                    UnityEngine.Random.InitState(index);
                    vertices[index].x += UnityEngine.Random.Range(-Noise * noiseScale, Noise * noiseScale);
                    vertices[index].z -= UnityEngine.Random.Range(Noise * noiseScale, -Noise * noiseScale);
                    
                    tangents[index] = tangent;
                    uvs[index] = new Vector2(0.5f + vertices[index].x * UVTiling, 0.5f + vertices[index].z * UVTiling);
                    //Lightmap UV's
                    uvs2[index] = new Vector2(0.5f + vertices[index].x / Scale, 0.5f + vertices[index].z / Scale);
                    normals[index] = Vector3.up;
                    
                    index++;
                }
            }

            index = 0;
            for (int z = 0; z < subdivisions; z++)
            {
                for (int x = 0; x < subdivisions; x++)
                {
                    triangles[index] = z * xCount + x;
                    triangles[index + 1] = (z + 1) * xCount + x;
                    triangles[index + 2] = z * xCount + x + 1;

                    triangles[index + 3] = (z + 1) * xCount + x;
                    triangles[index + 4] = (z + 1) * xCount + x + 1;
                    triangles[index + 5] = z * xCount + x + 1;
                    index += 6;
                }
            }

            m.vertices = vertices;
            m.triangles = triangles;
            m.uv = uvs;
            m.uv2 = uvs2;
            m.tangents = tangents;
            m.normals = normals;
            m.colors = new Color[vertices.Length];
            m.bounds = new Bounds(Vector3.zero, new Vector3(Scale, BoundsPadding, Scale));

            return m;
        }
    }
}