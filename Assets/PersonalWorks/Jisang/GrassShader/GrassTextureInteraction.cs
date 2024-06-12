using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;
using System.Linq;

public class GrassTextureInteraction : MonoBehaviour
{
    public static readonly List<GameObject> players = new List<GameObject>();

    [SerializeField]
    private float heightOverrideValue;

    [SerializeField]
    private Texture2D defaultGrassTexture;

    [SerializeField]
    private float radius;

    [SerializeField]
    private Collider GrassCollider;
    
    [SerializeField]
    private MeshFilter grassGroundMeshFilter;

    [SerializeField]
    private RenderTexture renderTexture;

    private Texture2D texture;

    private readonly List<Vector2> HitPoints = new List<Vector2>();
    private readonly List<Vector2> BendPoints = new List<Vector2>();
    private readonly List<Vector2> HeightSettings = new List<Vector2>();

    void Awake()
    {
        texture = new Texture2D(renderTexture.width, renderTexture.height);
    }

    private void OnEnable()
    {
        Initialize();
        StartCoroutine(UpdateTexture());
    }

    private void Initialize()
    {
        texture.SetPixels32(defaultGrassTexture.GetPixels32(), 0);
        Graphics.Blit(defaultGrassTexture, renderTexture);
    }


    IEnumerator UpdateTexture()
    {
        while(enabled)
        {
            HitPoints.Clear();

            var list = players.ToList();
            foreach (var target in list)
            {
                if (target == null)
                {
                    players.Remove(target);
                    continue;
                }

                var ray = new Ray(target.transform.position + Vector3.up * 1000, Vector3.down);

                if (GrassCollider.Raycast(ray, out var hit, 2000f))
                {
                    HitPoints.Add(hit.textureCoord);
                }
            }

            ApplyToRenderTexture();

            yield return null;
            yield return null;
        }
    }

    private void ApplyToRenderTexture()
    {
        if (HitPoints.Count == 0)
            return;
        
        var bound = grassGroundMeshFilter.mesh.bounds.size;
        Vector2Int factor = new Vector2Int(
            Mathf.RoundToInt(radius * texture.width / (bound.x * grassGroundMeshFilter.transform.lossyScale.x)),
            Mathf.RoundToInt(radius * texture.height / (bound.z * grassGroundMeshFilter.transform.lossyScale.z)));

        if (PaintColor(factor, HitPoints, Color.green + Color.blue, heightOverrideValue))
        {
            texture.Apply();
            Graphics.Blit(texture, renderTexture);
        }
    }

    private bool PaintColor(in Vector2Int factor, in List<Vector2> points, in Color mask, in float value)
    {
        bool isPainted = false;
        foreach (var point in points)
        {
            var pos = new Vector2Int(Mathf.FloorToInt(point.x * texture.width), Mathf.FloorToInt(point.y * texture.height));

            var xMin = Mathf.Clamp(pos.x - factor.x, 0, texture.width);
            var xMax = Mathf.Clamp(pos.x + factor.x, 0, texture.width);
            var yMin = Mathf.Clamp(pos.y - factor.y, 0, texture.height);
            var yMax = Mathf.Clamp(pos.y + factor.y, 0, texture.height);

            for (int x = xMin; x < xMax; ++x)
            {
                for (int y = yMin; y < yMax; ++y)
                {
                    var color = defaultGrassTexture.GetPixel(x, y);

                    color -= color * mask;
                    color += mask * value;

                    texture.SetPixel(x, y, color);
                }
            }
            isPainted = true;
        }
        return isPainted;
    }
}
