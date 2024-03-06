using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "NewGlobalParameterSettings", menuName = "NewGlobalParameterSettings")]
public class GlobalParameterSettings : SerializedScriptableObject
{
    [SerializeField] private Dictionary<string, TypeValuePair> settings;
    public Dictionary<string, TypeValuePair> Settings { get { return settings; } }
}