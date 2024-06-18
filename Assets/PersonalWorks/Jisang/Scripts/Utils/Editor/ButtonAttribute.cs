//File ButtonAttribute.cs
using System;
using System.Reflection;
using System.Diagnostics; //Conditional
using System.Linq;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

[AttributeUsage(AttributeTargets.All, AllowMultiple = false, Inherited = false)]
[Conditional("UNITY_EDITOR")]
public class ButtonAttribute : Attribute { }

public class DevMono : MonoBehaviour
{
#if UNITY_EDITOR
    [CustomEditor(typeof(DevMono), true)]
    public class DevEditor : Editor
    {
        private List<MethodInfo> ButtonAttributeInfos = new List<MethodInfo>();

        private void OnEnable() => Initialize();

        private void OnValidate() => Initialize();

        private void Initialize()
        {
            var flag = BindingFlags.Static | BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public;

            ButtonAttributeInfos = target.GetType().GetMethods(flag)
                .Where(method => method.GetCustomAttributes(typeof(ButtonAttribute), false).Length > 0).ToList();
        }

        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            BuildButtons();
        }

        void BuildButtons()
        {
            foreach (var method in ButtonAttributeInfos)
            {
                if (GUILayout.Button("Run " + method.Name))
                {
                    method.Invoke(target, null);
                }
            }
        }
    }
#endif
}