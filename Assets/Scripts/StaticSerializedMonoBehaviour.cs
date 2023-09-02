using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StaticSerializedMonoBehaviour<T> : SerializedMonoBehaviour 
    where T : SerializedMonoBehaviour
{
    [SerializeField, ReadOnly,LabelText("INSTANCE OBJECT"),InfoBox("THIS OBJECT IS SINGLETON")]
    private string debug_static_objcect;

    static private T instance;
    static public T Instance { get { return instance; } }
    static public bool IsInstanceValid { get { return instance != null; } }

    protected virtual void Awake()
    {
        if(instance == null) { instance = this as T; debug_static_objcect = gameObject.name; }
        else { Debug.LogWarning(typeof(T).Name + " : Duplicated SingletonObject, "+ gameObject.name + " : This Object Will be Destroyed."); Destroy(gameObject); }
    }

}
