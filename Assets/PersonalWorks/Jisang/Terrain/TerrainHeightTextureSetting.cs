using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;
using UnityEditor;

public class TerrainHeightTextureSetting : MonoBehaviour
{
#if UNITY_EDITOR
    [SerializeField]
    private Terrain target;

    public float heightThreshold = 5.0f; // 특정 높이 임계값
    public int textureIndex = 0; // 사용할 텍스처 인덱스 (터레인 레이어 인덱스)

    [Button]
    void PaintTerrain()
    {
        if (target == null)
        {
            Debug.LogError("Terrain is not assigned.");
            return;
        }

        Undo.RecordObject(target,"FillPaint");

        TerrainData terrainData = target.terrainData;
        int alphamapWidth = terrainData.alphamapWidth;
        int alphamapHeight = terrainData.alphamapHeight;
        int numTextures = terrainData.alphamapLayers;

        float[,,] alphaMaps = terrainData.GetAlphamaps(0, 0, alphamapWidth, alphamapHeight);
        for (int y = 0; y < alphamapHeight; y++)
        {
            for (int x = 0; x < alphamapWidth; x++)
            {
                float height = terrainData.GetHeight(x, y);

                if (height < heightThreshold)
                {
                    for (int t = 0; t < numTextures; t++)
                    {
                        var value = t == textureIndex ? 1 : 0;
                        alphaMaps[y, x, t] = value; //coordination problem
                    }
                }
            }
        }

        terrainData.SetAlphamaps(0, 0, alphaMaps);

        Debug.Log("Terrain painted below height: " + heightThreshold);
    }


    [Space(30)]
    [SerializeField]
    private Texture2D texture;
    private Color targetColor; // 추출할 목표 색상
    private float colorThreshold = 0.1f; // 색상 유사도 임계값

    [Button]
    void ExtractColor()
    {
        if (target == null)
        {
            Debug.LogError("Source texture is not assigned.");
            return;
        }

        var terrainData = target.terrainData;
        int alphamapWidth = terrainData.alphamapWidth;
        int alphamapHeight = terrainData.alphamapHeight;
        int numTextures = terrainData.alphamapLayers;
        var alphamap = terrainData.GetAlphamaps(0, 0, alphamapWidth, alphamapHeight);

        if (texture == null)
        {
            texture = new Texture2D(alphamapWidth, alphamapHeight, UnityEngine.Experimental.Rendering.DefaultFormat.LDR, UnityEngine.Experimental.Rendering.TextureCreationFlags.None);
        }

        for (int y = 0; y < alphamapHeight; y++)
        {
            for (int x = 0; x < alphamapWidth; x++)
            {
                if (alphamap[y, x, 1] > 0.5f || alphamap[y, x, 3] > 0.5f)
                {
                    //renderTarget
                    texture.SetPixel(x, y, Color.white);
                }
                else
                {
                    //none(black)
                    texture.SetPixel(x, y, Color.black);
                }
            }
        }

        SaveTextureAsPNG(texture, Application.dataPath + "/PersonalWorks/Jisang/Terrain/ExtractedTexture.png");
    }

    bool IsColorClose(Color a, Color b, float threshold)
    {
        return Mathf.Abs(a.r - b.r) < threshold &&
               Mathf.Abs(a.g - b.g) < threshold &&
               Mathf.Abs(a.b - b.b) < threshold;
    }

    void SaveTextureAsPNG(Texture2D texture, string path)
    {
        byte[] bytes = texture.EncodeToPNG();
        System.IO.File.WriteAllBytes(path, bytes);
        Debug.Log("Export Complete at " + path);
    }

    [Button]
    void RefreshDatabase()
    {
        AssetDatabase.Refresh();
    }

#endif //UNITY_EDITOR
}