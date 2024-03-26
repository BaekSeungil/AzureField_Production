using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;


public enum Weather
{
    Sun = 0,
    Cloud = 1,
    Rain = 2
};
public class AtmosphereProfile : ScriptableObject
{
    public static AtmosphereProfile instance;

    public Weather currentWeather;

    [Header("시간설정")]
    [SerializeField] private float StartTimer;
    [SerializeField] private float EndTimer;
    private GameObject gameObject;
    
    private void Awake() 
    {   
        if(instance == null)
            instance = this;
        else
            Destroy(gameObject);            
    
        
    }

    void Start()
    {
        currentWeather = Weather.Sun;

    }

    
    void Update()
    {
        
    }
    private IEnumerator WeatherChangeRoutine()
    {
        while (true)
        {
            yield return new WaitForSeconds(Random.Range(StartTimer, EndTimer)); // 5에서 15초 사이의 랜덤한 간격으로 변경
            ChangeWeather(); // 날씨 변경
        }
    }

     private void ChangeWeather()
    {
        // 날씨를 랜덤하게 변경
        currentWeather = (Weather)Random.Range(0, System.Enum.GetValues(typeof(Weather)).Length);
        Debug.Log("날씨가 변경되었습니다: " + currentWeather);
    }
}
