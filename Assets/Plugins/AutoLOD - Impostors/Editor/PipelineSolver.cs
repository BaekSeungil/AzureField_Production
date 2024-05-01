// Copyright (c) 2021-2022 Léo Chaumartin

using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEditor;
using UnityEngine;

namespace AutoLOD.Impostors
{
    public class PipelineSolverWindow : EditorWindow
    {
        private GUIStyle centeredStyle;

        private int pipelineIndex = 0;
        private string[] pipelineOptions = new string[2] { "Standard", "Universal" };

        public void OnEnable()
        {
            AssetDatabase.Refresh();
        }

        public void OnGUI()
        {
            EditorUtility.ClearProgressBar();

            if (centeredStyle == null)
            {
                centeredStyle = new GUIStyle
                {
                    alignment = TextAnchor.MiddleCenter,
                    fontStyle = FontStyle.Bold
                };
            }

            EditorGUI.DrawRect(new Rect(0, 0, Screen.width, Screen.height), new Color(0.156f, 0.156f, 0.156f));
            GUILayout.Label(Resources.Load<Texture>("Logo_AutoLOD_Impostors"), centeredStyle, GUILayout.Height(64f), GUILayout.ExpandWidth(true));
            EditorGUILayout.Separator();
            pipelineIndex = EditorGUILayout.Popup("Render pipeline ", pipelineIndex, pipelineOptions);
            EditorGUILayout.BeginHorizontal(EditorStyles.helpBox);
            EditorGUILayout.LabelField("Baking is not compatible with HDRP but you can still render impostors baked in URP thanks to the HDRP Toolkit.", EditorStyles.wordWrappedMiniLabel);
            if(GUILayout.Button("HDRP\nToolkit", EditorStyles.linkLabel))
            {
                Application.OpenURL("https://drive.google.com/file/d/1bwT4uMsH9o3AepEdnPYujVQIhPFmJ8mt/view?usp=sharing");
            }
            EditorGUILayout.EndHorizontal();
            if (GUILayout.Button("Finish setup"))
            {
                Close();
                AssetDatabase.ImportPackage("Assets/AutoLOD - Impostors/" + (pipelineIndex == 1 ? "UniversalRP" : "StandardRP") + ".unitypackage", false);
                AssetDatabase.DeleteAsset("Assets/AutoLOD - Impostors/StandardRP.unitypackage");
                AssetDatabase.DeleteAsset("Assets/AutoLOD - Impostors/UniversalRP.unitypackage");
                AssetDatabase.DeleteAsset("Assets/AutoLOD - Impostors/AutoLOD.UNINITIALIZED");
            }
        }
    }

    class PipelineSolver : AssetPostprocessor
    {

        static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths)
        {
            foreach (string str in importedAssets)
            {
                if (str.Contains("AutoLOD.UNINITIALIZED"))
                {
                    EditorUtility.ClearProgressBar();
                    PipelineSolverWindow win = EditorWindow.GetWindow(typeof(PipelineSolverWindow)) as PipelineSolverWindow;
                    win.titleContent = new GUIContent("Pipeline Solver", Resources.Load<Texture>("Logo_AutoLOD_small"));
                    win.minSize = new Vector2(276, 160);
                    win.Show();
                }
            }
        }
    }
}
