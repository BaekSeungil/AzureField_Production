/*
 * Copyright (c) Léo CHAUMARTIN 2021-2023
 * All Rights Reserved
 * 
 * File: ImpostorReferenceSolver.cs
 */

using UnityEngine;
using UnityEditor;
using UnityEngine.SceneManagement;
using UnityEditor.SceneManagement;
using System.Linq;

namespace AutoLOD.Impostors
{
    /// <summary>
    /// 'Impostor References' were added in version 3.3, previous versions bakes were missing it. 
    /// Later with version 4.1, ImpostorReference scope changed from editor-only to all scopes, losing all the existing components in the scene.
    /// This class was designed to solve both issues with a simple, invariant, formalism.
    /// The process can slow down scene opening (in the editor only), but it shouldn't be noticeable even in large scenes.
    /// If your project always used AutoLOD - Impostors version 4.1 or above, you don't need this file.
    /// </summary>
    [InitializeOnLoad]
    public class ImpostorReferenceSolver
    {
        static ImpostorReferenceSolver()
        {
            EditorSceneManager.sceneOpened += OnSceneOpened;
        }

        private static void OnSceneOpened(Scene scene, OpenSceneMode mode)
        {
            foreach (GameObject obj in scene.GetRootGameObjects())
            {
                RemoveMissingScriptReferences(obj);
                CheckAndAddImpostorReference(obj);
            }
        }

        private static void RemoveMissingScriptReferences(GameObject obj)
        {
            // Recursively process all children
            foreach (Transform child in obj.transform)
            {
                RemoveMissingScriptReferences(child.gameObject);
            }

            // Remove missing scripts from the current GameObject
            GameObjectUtility.RemoveMonoBehavioursWithMissingScript(obj);
        }

        private static void CheckAndAddImpostorReference(GameObject obj)
        {
            // There is already an ImpostorReference script.
            if (obj.GetComponent<ImpostorReference>() != null)
                return;

            LODGroup lodGroup = obj.GetComponent<LODGroup>();
            if (lodGroup != null)
            {
                LOD[] lods = lodGroup.GetLODs();
                if (lods.Length > 0)
                {
                    Renderer lastRenderer = lods.Last().renderers.LastOrDefault();
                    if (lastRenderer != null)
                    {
                        Material material = lastRenderer.sharedMaterial;
                        if (material != null && material.shader != null)
                        {
                            string shaderName = material.shader.name.ToLower();
                            if (shaderName.Contains("autolod") && shaderName.Contains("impostor"))
                            {
                                obj.AddComponent<ImpostorReference>().impostorObject = lastRenderer.gameObject;
                            }
                        }
                    }
                }
            }

            // Recursively process all children
            foreach (Transform child in obj.transform)
            {
                CheckAndAddImpostorReference(child.gameObject);
            }
        }
    }
}