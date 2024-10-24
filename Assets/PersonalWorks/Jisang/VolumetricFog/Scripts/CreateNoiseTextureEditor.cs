using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

#if UNITY_EDITOR
[CustomEditor(typeof(CreateNoiseTexture))]
public class CreateNoiseTextureEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (GUILayout.Button("CreateNoiseTexture"))
        {
            (target as CreateNoiseTexture).CreateNoise();
        }
    }
}
#endif
