using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Terrain))]
public class TerrainSoundMaterialBehavior : SoundMaterialBehavior
{
    [SerializeField] private SoundMaterial[] soundPerLayer;

    private Terrain terrain;

    TerrainData terrainData;

    float[,,] splatmap;
    int textureCount;

    private void Awake()
    {
        terrain = GetComponent<Terrain>();
        terrainData = terrain.terrainData;

        splatmap = terrainData.GetAlphamaps(0, 0, terrainData.alphamapWidth, terrainData.alphamapHeight);
        textureCount = terrainData.alphamapLayers;

    }

    private Vector3 ConvertToSplatMapCoordinate(Vector3 worldPosition)
    {
        Vector3 splatPosition = new Vector3Int();
        Vector3 terPosition = terrain.transform.position;
        splatPosition.x = (worldPosition.x - terPosition.x) / terrain.terrainData.size.x * terrain.terrainData.alphamapWidth;
        splatPosition.z = (worldPosition.z - terPosition.z) / terrain.terrainData.size.z * terrain.terrainData.alphamapHeight;
        return splatPosition;
    }

    public override SoundMaterial GetSoundMaterial(Vector3 position)
    {
        Vector3 terrain_coord = ConvertToSplatMapCoordinate(position);
        Vector3Int integer_coord = new Vector3Int((int)terrain_coord.x,(int)terrain_coord.y,(int)terrain_coord.z);
        int retTex = 0;

        for(int i= 0; i < textureCount; i++)
        {
            retTex = splatmap[integer_coord.z, integer_coord.x, i] > splatmap[integer_coord.z, integer_coord.x, retTex] ? i : retTex ;
        }

        return soundPerLayer[retTex];
    }
}
