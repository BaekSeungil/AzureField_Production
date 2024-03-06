using Sirenix.OdinInspector;
using System.Collections.Generic;
using UnityEngine;

public enum DataType
{
    BOOL,
    INT,
    FLOAT,
    STRING
}

public struct TypeValuePair
{
    public string Value;
    public DataType Type;
}

public class GlobalGameParameters : PersistentSerializedMonoBehaviour<GlobalGameParameters>
{
    //====================================
    //
    // [싱글턴 오브젝트]
    // 글로벌 패러미터는 게임에서 각종 변수가 생겼을 때, 다른 곳에서도 값을 참조할 수 있도록 문자열 값으로 저장하여 전역으로 저장하는 데이터들입니다.
    // 새로운 글로벌 패러미터를 추가하고자 한다면, Asset/ScriptableObjects에 있는 GlobalParameterSettings 스크립터블 오브젝트에 추가하고
    // 아래 노션 리스트에 패러미터 관련 정보를 적어두세요.
    // https://www.notion.so/badtoast/662cb4e0b4154db5a40b76c0af61c4e7?pvs=4
    //
    //====================================

    [SerializeField] private GlobalParameterSettings settingsAsset;
    [SerializeField, ReadOnly] static private Dictionary<string, TypeValuePair> data;

    protected override void Awake()
    {
        base.Awake();
        if (settingsAsset != null)
            data = settingsAsset.Settings;
    }

    /// <summary>
    /// string 형식으로 된 글로벌 데이터를 가져옵니다.
    /// </summary>
    /// <param name="key"> key값 </param>
    /// <returns></returns>
    public string GetString(string key)
    {
        if (data.ContainsKey(key))
        {
            if (data[key].Type != DataType.STRING)
            {
                Debug.LogError("GobalGameParameter에서 맞지 않는 형식의 값을 참조하려고 했습니다. " + key + " /시도 형식 : STRING, Value의 형식 :" + data[key].Type);
                return string.Empty;
            }
            else
            {
                return data[key].Value;
            }
        }
        else
        {
            Debug.LogError("GobalGameParameter에 존재하지 않는 Key값을 찾으려 했습니다 KEY 값 : " + key);
            return string.Empty;
        }
    }

    /// <summary>
    /// string 형식으로 된 글로벌 데이터를 설정합니다.
    /// </summary>
    /// <param name="key"> key값 </param>
    /// <param name="value"> 넣을 값 </param>
    /// <returns></returns>
    public bool SetString(string key,string value)
    {
        if(data.ContainsKey(key))
        {
            TypeValuePair pair = data[key];
            pair.Value = value;
            data[key] = pair;
            return true;
        }
        else
        {
            Debug.LogError("Key값을 찾올 수 없었습니다. Key : " + key);
            return false;
        }
    }

    /// <summary>
    /// float 형식으로 된 글로벌 데이터를 가져옵니다.
    /// </summary>
    /// <param name="key"> key값 </param>
    /// <returns></returns>
    public float GetFloat(string key)
    {
        if (data.ContainsKey(key))
        {
            if (data[key].Type != DataType.FLOAT)
            {
                Debug.LogError("GobalGameParameter에서 맞지 않는 형식의 값을 참조하려고 했습니다. "+ key +" / 시도 형식 : FLOAT, Value의 형식 :" + data[key].Type);
                return 0f;
            }
            else
            {
                return float.Parse(data[key].Value);
            }
        }
        else
        {
            Debug.LogError("GobalGameParameter에 존재하지 않는 Key값을 찾으려 했습니다 KEY 값 : " + key);
            return 0f;
        }
    }

    /// <summary>
    /// float 형식으로 된 글로벌 데이터를 설정합니다.
    /// </summary>
    /// <param name="key"> key값 </param>
    /// <param name="value"> 넣을 값 </param>
    /// <returns></returns>
    public bool SetFloat(string key, float value)
    {
        if (data.ContainsKey(key))
        {
            TypeValuePair pair = data[key];
            pair.Value = value.ToString();
            data[key] = pair;
            return true;
        }
        else
        {
            Debug.LogError("Key값을 찾올 수 없었습니다. Key : " + key);
            return false;
        }
    }

    /// <summary>
    /// bool 형식으로 된 글로벌 데이터를 가져옵니다.
    /// </summary>
    /// <param name="key"> key값 </param>
    /// <returns></returns>
    public bool GetBool(string key)
    {
        if (data.ContainsKey(key))
        {
            if (data[key].Type != DataType.BOOL)
            {
                Debug.LogError("GobalGameParameter에서 맞지 않는 형식의 값을 참조하려고 했습니다. " + key + " / 시도 형식 : BOOL, Value의 형식 :" + data[key].Type);
                return false;
            }
            else
            {
                return bool.Parse(data[key].Value);
            }
        }
        else
        {
            Debug.LogError("GobalGameParameter에 존재하지 않는 Key값을 찾으려 했습니다 KEY 값 : " + key);
            return false;
        }
    }

    /// <summary>
    /// bool 형식으로 된 글로벌 데이터를 설정합니다.
    /// </summary>
    /// <param name="key"> key값 </param>
    /// <param name="value"> 넣을 값 </param>
    /// <returns></returns>
    public bool SetBool(string key, bool value)
    {
        if (data.ContainsKey(key))
        {
            TypeValuePair pair = data[key];
            pair.Value = value.ToString();
            data[key] = pair;
            return true;
        }
        else
        {
            Debug.LogError("Key값을 찾올 수 없었습니다. Key : " + key);
            return false;
        }
    }

    /// <summary>
    /// int 형식으로 된 글로벌 데이터를 가져옵니다.
    /// </summary>
    /// <param name="key"> key값 </param>
    /// <returns></returns>
    public int GetInt(string key)
    {
        if (data.ContainsKey(key))
        {
            if (data[key].Type != DataType.INT)
            {
                Debug.LogError("GobalGameParameter에서 맞지 않는 형식의 값을 참조하려고 했습니다. " + key + " /시도 형식 : INT, Value의 형식 :" + data[key].Type);
                return 0;
            }
            else
            {
                return int.Parse(data[key].Value);
            }
        }
        else
        {
            Debug.LogError("GobalGameParameter에 존재하지 않는 Key값을 찾으려 했습니다 KEY 값 : " + key);
            return 0;
        }
    }

    /// <summary>
    /// int 형식으로 된 글로벌 데이터를 설정합니다.
    /// </summary>
    /// <param name="key"> key값 </param>
    /// <param name="value"> 넣을 값 </param>
    /// <returns></returns>
    public bool SetInt(string key, int value)
    {
        if (data.ContainsKey(key))
        {
            TypeValuePair pair = data[key];
            pair.Value = value.ToString();
            data[key] = pair;
            return true;
        }
        else
        {
            Debug.LogError("Key값을 찾올 수 없었습니다. Key : " + key);
            return false;
        }
    }
    
}
