using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

#if UNITY_2023
using UnityEditor.Build;
#endif

namespace NKStudio
{
    public static class FMODLinkRemove
    {
        private const string SYMBOL = "USE_FMOD";

        [MenuItem("Tools/Toolbar/FMOD/Define Remove")]
        private static void RemoveDefine()
        {
            BuildTargetGroup buildTargetGroup = EditorUserBuildSettings.selectedBuildTargetGroup;
            
#if UNITY_2023
            List<string> defines =
                PlayerSettings.GetScriptingDefineSymbols(NamedBuildTarget.FromBuildTargetGroup(buildTargetGroup)).Split(';')
                    .ToList();
            
            // FMOD 폴더가 없으면 USE_FMOD 심볼을 제거합니다.
            if (defines.Contains(SYMBOL))
            {
                defines.Remove(SYMBOL);
                defines = defines.Distinct().ToList();
                
                PlayerSettings.SetScriptingDefineSymbols(NamedBuildTarget.FromBuildTargetGroup(buildTargetGroup), string.Join(";", defines.ToArray()));
            }
            else
                Debug.LogWarning("USE_FMOD 심볼이 존재하지 않습니다.");
#else
            List<string> defines = PlayerSettings.GetScriptingDefineSymbolsForGroup(buildTargetGroup).Split(';').ToList();

            // FMOD 폴더가 없으면 USE_FMOD 심볼을 제거합니다.
            if (defines.Contains(SYMBOL))
            {
                defines.Remove(SYMBOL);
                defines = defines.Distinct().ToList();
                
                PlayerSettings.SetScriptingDefineSymbolsForGroup(buildTargetGroup, string.Join(";", defines.ToArray()));
            }
            else
                Debug.LogWarning("USE_FMOD 심볼이 존재하지 않습니다.");
#endif
        }
    }
}