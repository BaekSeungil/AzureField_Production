#if USE_FMOD
using System.Reflection;
using FMODUnity;
using UnityEditor;
using UnityEngine;

namespace NKStudio
{
    public class FMODDebugToolbars
    {
        public static void OnToolbarGUI()
        {
            // 왼쪽 마진을 3정도 적용함.
            GUILayout.Space(4);
            EditorGUILayout.BeginHorizontal(EditorStyles.toolbar);
            EditorGUI.BeginDisabledGroup(EditorApplication.isPlaying);
            EditorGUILayout.LabelField("FMOD Debug", GUILayout.Width(80));
            bool currentFMODDebugEnable = GetDebugOverlay() == TriStateBool.Enabled ? true : false;
            bool FMODDebugEnableToggle = EditorGUILayout.Toggle(currentFMODDebugEnable, GUILayout.Width(16));
            TriStateBool nextFMODDebugOverlay = FMODDebugEnableToggle ? TriStateBool.Enabled : TriStateBool.Disabled;
            SetDebugOverlay(nextFMODDebugOverlay);
            EditorGUI.EndDisabledGroup();
            EditorGUILayout.EndHorizontal();
        }

        private static void SetDebugOverlay(TriStateBool value)
        {
            // var EditorPlatform = FMODUnity.Settings.Instance.PlayInEditorPlatform;

            // Lastly, access the Overlay property.
            var properties = Settings.Instance.PlayInEditorPlatform.GetType().GetField("Properties",
                BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);

            if (properties == null)
                return;
            
            var editorPlatformSettings = properties.GetValue(Settings.Instance.PlayInEditorPlatform);

            var overlayProperty = editorPlatformSettings.GetType().GetField("Overlay",
                BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);

            if (overlayProperty == null)
                return;
            
            var overlayValue = overlayProperty.GetValue(editorPlatformSettings);

            var valueProperty = overlayValue.GetType().GetField("Value",
                BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);

            if (valueProperty != null)
                valueProperty.SetValue(overlayValue, value);
        }

        private static TriStateBool GetDebugOverlay()
        {
            return Settings.Instance.PlayInEditorPlatform.Overlay;
        }
    }
}
#endif