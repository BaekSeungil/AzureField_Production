using DistantLands.Cozy;
using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class AtmosphereManager : StaticSerializedMonoBehaviour<AtmosphereManager>
{
    //weatherprofile
    //oceanprofile
    //postporcessFX

    [SerializeField, Title("ChildReference")]
    private Volume ppGlobalFirst;
    private Volume ppGlobalSecond;

    private CozyWeather cozyWeatherInstance;

    private void OnEnable()
    {
        if(cozyWeatherInstance == null)
            cozyWeatherInstance = FindFirstObjectByType<CozyWeather>(); 

        if(cozyWeatherInstance == null)
            Debug.LogError("CozyWeather 오브젝트를 찾을 수 없었습니다. 날씨 제어가 제한됩니다.");

        if (!GlobalOceanManager.IsInstanceValid)
            Debug.LogError("GlobalOceanManager 오브젝트를 찾을 수 없습니다. 바다 제어가 제한됩니다.");
    }
}
