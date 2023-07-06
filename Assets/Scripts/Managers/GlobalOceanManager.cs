using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;

public class GlobalOceanManager : SerializedMonoBehaviour
{
    private static GlobalOceanManager instance;
    public static GlobalOceanManager Instance
    {
        get
        {
            return instance;
        }
    }

    [SerializeField] private Material[] ReferencingMaterials;


    [Title("GlobalWaveProperties")]
    [SerializeField,Range(0.0f,1.5f),DisableInPlayMode()] private float intensity;
    [SerializeField,DisableInPlayMode()] private float depth;
    [SerializeField,DisableInPlayMode()] private float phase;
    [SerializeField,DisableInPlayMode()] private float gravity;
    [Title("")]
    [SerializeField,ReadOnly()] private Vector3 Wave1_Vector;
    [SerializeField,ReadOnly()] private float Wave1_Amplitude;
    [Title("")]
    [SerializeField,ReadOnly()] private Vector3 Wave2_Vector;
    [SerializeField,ReadOnly()] private float Wave2_Amplitude;
    [Title("")]
    [SerializeField,ReadOnly()] private Vector3 Wave3_Vector;
    [SerializeField,ReadOnly()] private float Wave3_Amplitude;
    [Title("")]
    [SerializeField,ReadOnly()] private Vector3 Wave4_Vector;
    [SerializeField,ReadOnly()] private float Wave4_Amplitude;

    private void Awake() 
    {
        if(instance == null) instance = this;
        else Destroy(gameObject);
    }

    private void OnEnable() {
        UpdateReferencingMaterials();
        GameObject[] shorelines = GameObject.FindGameObjectsWithTag("Shoreline");
        foreach(GameObject sh in shorelines)
        {
            sh.GetComponent<Terrain>();
        }
    }

    private void UpdateReferencingMaterials()
    {
        foreach(Material m in ReferencingMaterials)
        {
            m.SetFloat("_Intensity",intensity);
            m.SetFloat("_Depth",depth);
            m.SetFloat("_Phase",phase);
            m.SetFloat("_Gravity",gravity);
            m.SetVector("_Direction1",Wave1_Vector);
            m.SetFloat("_Amplitude1",Wave1_Amplitude);
            m.SetVector("_Direction2",Wave2_Vector);
            m.SetFloat("_Amplitude2",Wave2_Amplitude);
            m.SetVector("_Direction3",Wave3_Vector);
            m.SetFloat("_Amplitude3",Wave3_Amplitude);
            m.SetVector("_Direction4",Wave4_Vector);
            m.SetFloat("_Amplitude4",Wave4_Amplitude);
        }
    }
    private void SetIntensity(float value)
    {
        intensity = value;
        UpdateReferencingMaterials();
    }

    #if UNITY_EDITOR
    [Button(ButtonSizes.Small)]
    #endif
    private void SetWave(int index, Vector3 vector, float amplitude)
    {
        if(index == 1)
        {
            Wave1_Vector = vector;
            Wave1_Amplitude = amplitude;
        }
        else if (index == 2)
        {
            Wave2_Vector = vector;
            Wave2_Amplitude = amplitude;
        }
        else if (index == 3)
        {
            Wave3_Vector = vector;
            Wave3_Amplitude = amplitude;
        }
        else if (index == 4)
        {
            Wave4_Vector = vector;
            Wave4_Amplitude = amplitude;
        }
        else
        {
            Debug.LogError(index + "번 WAVE의 인덱스를 찾으러 하였지만 실패하였습니다.");
        }

        UpdateReferencingMaterials();
    }

    public float GetWaveHeight(Vector3 point)
    {
        Vector3 pointXZ = new Vector3(point.x,0f,point.z);
        Vector3 iteration = pointXZ - GetWavePositionXZ(pointXZ);
        iteration = pointXZ - GetWavePositionXZ(iteration);
        iteration = pointXZ - GetWavePositionXZ(iteration);
        
        return  GetWavePosition(iteration).y;
    }

    public Vector3 GetWavePosition(Vector3 input)
    {
        Vector3 result;

        result = SingleGerstnerWavePosition(input,Wave1_Vector,Wave1_Amplitude);
        result += SingleGerstnerWavePosition(input,Wave2_Vector,Wave2_Amplitude);
        result += SingleGerstnerWavePosition(input,Wave3_Vector,Wave3_Amplitude);
        result += SingleGerstnerWavePosition(input,Wave4_Vector,Wave4_Amplitude);

        return result;
    }

    public Vector3 GetWavePositionXZ(Vector3 input)
    {
        Vector3 result;

        result = SingleGerstnerWavePositionXZ(input,Wave1_Vector,Wave1_Amplitude);
        result += SingleGerstnerWavePositionXZ(input,Wave2_Vector,Wave2_Amplitude);
        result += SingleGerstnerWavePositionXZ(input,Wave3_Vector,Wave3_Amplitude);
        result += SingleGerstnerWavePositionXZ(input,Wave4_Vector,Wave4_Amplitude);

        return result;
    }

    private Vector3 SingleGerstnerWavePosition(Vector3 position,Vector3 direction,float amplitude)
    {
        float freq = Mathf.Sqrt( gravity * direction.magnitude * (float)(System.Math.Tanh(depth*direction.magnitude)));
        float theta = (direction.x * position.x + direction.z * position.z) - freq * Time.time - phase;

        float x = -(amplitude * intensity/((float)(System.Math.Tanh(direction.magnitude*depth))) * direction.x/direction.magnitude * Mathf.Sin(theta));
        float y = Mathf.Cos(theta) * amplitude * intensity;
        float z = -(amplitude * intensity/((float)(System.Math.Tanh(direction.magnitude*depth))) * direction.z/direction.magnitude * Mathf.Sin(theta));
    
        return new Vector3(x,y,z);
    }

    private Vector3 SingleGerstnerWavePositionXZ(Vector3 position,Vector3 direction,float amplitude)
    {
        float freq = Mathf.Sqrt( gravity * direction.magnitude * (float)(System.Math.Tanh(depth*direction.magnitude)));
        float theta = (direction.x * position.x + direction.z * position.z) - freq * Time.time - phase;

        float x = -(amplitude * intensity/((float)(System.Math.Tanh(direction.magnitude*depth))) * direction.x/direction.magnitude * Mathf.Sin(theta));
        float z = -(amplitude * intensity/((float)(System.Math.Tanh(direction.magnitude*depth))) * direction.z/direction.magnitude * Mathf.Sin(theta));
    
        return new Vector3(x,0f,z);
    }

    private float SingleGerstnerWaveHeight(Vector3 position,Vector3 direction,float amplitude)
    {
        float freq = Mathf.Sqrt( gravity * direction.magnitude * (float)(System.Math.Tanh(depth*direction.magnitude)));
        float theta = (direction.x * position.x + direction.z * position.z) - freq * Time.time - phase;
        return Mathf.Cos(theta) * amplitude * intensity;
    }

}
