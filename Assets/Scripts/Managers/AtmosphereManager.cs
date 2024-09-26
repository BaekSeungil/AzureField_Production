using DistantLands.Cozy;
using DistantLands.Cozy.Data;
using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class AtmosphereManager : StaticSerializedMonoBehaviour<AtmosphereManager>
{

    private struct AtmosTransition
    {
        public AzfAtmosProfile atmosProfile;
        public float transitionTime;
    }

    [Title("ChildReference")]
    [SerializeField] private Volume ppGlobalFirst;
    [SerializeField] private Volume ppGlobalSecond;

    [Title("Debug")]
    [SerializeField,ReadOnly,LabelText("CozyWeather 활성화")] private bool debug_cozyWeatherValid = false;
    [SerializeField,ReadOnly,LabelText("OceanProfile 활성화")] private bool debug_oceanProfileValid = false;

    private CozyWeather cozyWeatherInstance;
    private Coroutine transitionCoroutine;
    private Queue<AtmosTransition> transitionQueue;

    protected override void Awake()
    {
        base.Awake();
        transitionQueue = new Queue<AtmosTransition>();
    }

    private void OnEnable()
    {
        if (cozyWeatherInstance == null)
            cozyWeatherInstance = FindFirstObjectByType<CozyWeather>();

        if (cozyWeatherInstance == null)
            

        if (!GlobalOceanManager.IsInstanceValid)
           

#if UNITY_EDITOR

        if (cozyWeatherInstance == null)
        {
            Debug.LogError("CozyWeather 오브젝트를 찾을 수 없었습니다. 날씨 제어가 제한됩니다.");
            debug_cozyWeatherValid = false;
        }
        else
            debug_cozyWeatherValid = true;

        if (!GlobalOceanManager.IsInstanceValid)
        {
            Debug.LogError("GlobalOceanManager 오브젝트를 찾을 수 없습니다. 바다 제어가 제한됩니다.");
            debug_oceanProfileValid = false;
        }
        else
            debug_oceanProfileValid = true;

#endif
    }

    public static void ChangeAtmosphere(AzfAtmosProfile profile, float transitionTime)
    {
        if (Instance == null) { Debug.LogError("AtmosphereManager가 없습니다."); return; }

        AtmosTransition newTransition = new AtmosTransition();
        newTransition.atmosProfile = profile; newTransition.transitionTime = transitionTime;

        Instance.transitionQueue.Enqueue(newTransition);

        if (Instance.transitionCoroutine != null)
            Instance.StartCoroutine(Instance.Cor_ChangeAtmosInQueued());
    }

    [Button("(디버그) 기후 프로필 적용")]
    public void Debug_TryAtmosphereProfile(AzfAtmosProfile profile, float transitionTime)
    {
        ChangeAtmosphere(profile, transitionTime);
    }

    private IEnumerator Cor_ChangeAtmosInQueued()
    {
        while (transitionQueue.Count > 0)
        {
            AtmosTransition currentAtmos = transitionQueue.Dequeue();

            if(currentAtmos.atmosProfile.weatherProfile != null && cozyWeatherInstance != null)
            {
                cozyWeatherInstance.weatherModule.ecosystem.SetWeather(currentAtmos.atmosProfile.weatherProfile,currentAtmos.transitionTime);
            }
            if(currentAtmos.atmosProfile.oceanProfile != null && GlobalOceanManager.IsInstanceValid)
            {
                GlobalOceanManager.Instance.SetWave(currentAtmos.atmosProfile.oceanProfile, currentAtmos.transitionTime);
            }

            // other transitions
        }

        transitionCoroutine = null;
        yield return null;
    }
}
