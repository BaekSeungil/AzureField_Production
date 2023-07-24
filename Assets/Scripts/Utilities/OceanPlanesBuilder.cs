using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Tilemaps;
using UnityEngine;

public class OceanPlanesBuilder : MonoBehaviour
{
    public GameObject oceanPrefab;

    public int iteration = 1;
    public float size = 64f;

    [Button("Build")]
    public void Build()
    {
        for (int i = 0; i < iteration; i++)
        {
            for (int z = -i; z <= i; z++)
            {
                for (int x = -i; x <= i; x++)
                {
                    if (x == 0 && z == 0) continue;
                    GameObject obj = PrefabUtility.InstantiatePrefab(oceanPrefab, transform) as GameObject;
                    obj.transform.position = new Vector3(x * size, 0f ,z * size);
                }
            }
        }
    }

}
