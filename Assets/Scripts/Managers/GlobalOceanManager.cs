using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;
using Unity.Jobs;
using Unity.Collections;
using UnityEngine.Rendering;

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
    [SerializeField,Range(0.0f,1.5f)] private float intensity;
    public float IslandregionIntensityFactor = 1.0f;
    public float Intensity { get { return intensity * IslandregionIntensityFactor; } }

    [SerializeField,DisableInPlayMode()] private float depth;
    [SerializeField,DisableInPlayMode()] private float phase;
    [SerializeField,DisableInPlayMode()] private float gravity;
    [Title("")]
    [SerializeField,DisableInPlayMode()] private Vector3 Wave1_Vector;
    [SerializeField,DisableInPlayMode()] private float Wave1_Amplitude;
    [Title("")]
    [SerializeField, DisableInPlayMode()] private Vector3 Wave2_Vector;
    [SerializeField, DisableInPlayMode()] private float Wave2_Amplitude;
    [Title("")]
    [SerializeField, DisableInPlayMode()] private Vector3 Wave3_Vector;
    [SerializeField, DisableInPlayMode()] private float Wave3_Amplitude;
    [Title("")]
    [SerializeField, DisableInPlayMode()] private Vector3 Wave4_Vector;
    [SerializeField, DisableInPlayMode()] private float Wave4_Amplitude;

    private struct WavePositionJob : IJob
    {
        public Vector3 input;
        public NativeArray<Vector3> output;

        public float intensity;
        public float gravity;
        public float depth;
        public float phase;
        public float time;

        public NativeArray<Vector3> waveVectors;
        public NativeArray<float> waveAmplitudes;

        private Vector3 SingleGerstnerWavePosition(Vector3 position, Vector3 direction, float amplitude)
        {
            float freq = Mathf.Sqrt(gravity * direction.magnitude * (float)(System.Math.Tanh(depth * direction.magnitude)));
            float theta = (direction.x * position.x + direction.z * position.z) - freq * time - phase;

            float x = -(amplitude * intensity / ((float)(System.Math.Tanh(direction.magnitude * depth))) * direction.x / direction.magnitude * Mathf.Sin(theta));
            float y = Mathf.Cos(theta) * amplitude * intensity;
            float z = -(amplitude * intensity / ((float)(System.Math.Tanh(direction.magnitude * depth))) * direction.z / direction.magnitude * Mathf.Sin(theta));

            return new Vector3(x, y, z);
        }

        public void Execute()
        {
            Vector3 result = Vector3.zero;

            if (waveVectors.Length != waveAmplitudes.Length) return; // failed for invalid arrayInput;

            for (int i = 0; i < waveVectors.Length; i++)
            {
                result += SingleGerstnerWavePosition(input, waveVectors[i], waveAmplitudes[i]);
            }

            output[0] = result;
        }

    }

    private struct WaveHeightJob : IJob
    {
        public Vector3 input;
        public NativeArray<float> output;

        public float intensity;
        public float gravity;
        public float depth;
        public float phase;
        public float time;

        public NativeArray<Vector3> waveVectors;
        public NativeArray<float> waveAmplitudes;

        private Vector3 SingleGerstnerWavePosition(Vector3 position, Vector3 direction, float amplitude, bool calculateY = true)
        {
            float freq = Mathf.Sqrt(gravity * direction.magnitude * (float)(System.Math.Tanh(depth * direction.magnitude)));
            float theta = (direction.x * position.x + direction.z * position.z) - freq * time - phase;

            float x = -(amplitude * intensity / ((float)(System.Math.Tanh(direction.magnitude * depth))) * direction.x / direction.magnitude * Mathf.Sin(theta));
            float y = 0f;
            if (calculateY) y = Mathf.Cos(theta) * amplitude * intensity;
            float z = -(amplitude * intensity / ((float)(System.Math.Tanh(direction.magnitude * depth))) * direction.z / direction.magnitude * Mathf.Sin(theta));

            return new Vector3(x, y, z);
        }

        private Vector3 GetComlexWavePostion(Vector3 input,bool calculateY = true)
        {
            Vector3 result = Vector3.zero;

            if (waveVectors.Length != waveAmplitudes.Length) return input; // failed for invalid arrayInput;

            for (int i = 0; i < waveVectors.Length; i++)
            {
                result += SingleGerstnerWavePosition(input, waveVectors[i], waveAmplitudes[i],calculateY);
            }

            return result;
        }

        public void Execute()
        {
            Vector3 pointXZ = new Vector3(input.x, 0f, input.z);
            Vector3 iteration = pointXZ - GetComlexWavePostion(pointXZ,false);
            iteration = pointXZ - GetComlexWavePostion(iteration,false);
            iteration = pointXZ - GetComlexWavePostion(iteration,false);

            output[0] = GetComlexWavePostion(iteration,true).y;
        }
    }

    private void Awake() 
    {
        if (instance == null) instance = this;
        else
        {
            Debug.Log(gameObject.name + " : 중복된 싱글턴 인스턴스, 삭제됨.");
            Destroy(gameObject);
        }
    }

    private void OnEnable() {
        UpdateReferencingMaterials();
    }

    private void UpdateReferencingMaterials()
    {
        foreach(Material m in ReferencingMaterials)
        {
            m.SetFloat("_Intensity",Intensity);
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

    public Vector3 GetWavePosition(Vector3 point)
    {
        Vector3[] vecs = new Vector3[] { Wave1_Vector, Wave2_Vector, Wave3_Vector, Wave4_Vector };
        float[] amps = new float[] { Wave1_Amplitude, Wave2_Amplitude, Wave3_Amplitude, Wave4_Amplitude };

        WavePositionJob job = new WavePositionJob()
        {
            input = point,
            output = new NativeArray<Vector3>(1,Allocator.Persistent),

            intensity = this.Intensity,
            gravity = this.gravity,
            depth = this.depth,
            phase = this.phase,
            time = Time.time,

            waveVectors = new NativeArray<Vector3>(vecs, Allocator.Persistent),
            waveAmplitudes = new NativeArray<float>(amps, Allocator.Persistent),
        };

        JobHandle handle = job.Schedule();
        handle.Complete();

        Vector3 result = job.output[0];

        job.output.Dispose();
        job.waveVectors.Dispose();
        job.waveAmplitudes.Dispose();

        return result;
    }

    public float GetWaveHeight(Vector3 point)
    {
        Vector3[] vecs = new Vector3[] { Wave1_Vector, Wave2_Vector, Wave3_Vector, Wave4_Vector };
        float[] amps = new float[] { Wave1_Amplitude, Wave2_Amplitude, Wave3_Amplitude, Wave4_Amplitude };

        WaveHeightJob job = new WaveHeightJob()
        {
            input = point,
            output = new NativeArray<float>(1,Allocator.TempJob),

            intensity = this.Intensity,
            gravity = this.gravity,
            depth = this.depth,
            phase = this.phase,
            time = Time.time,

            waveVectors = new NativeArray<Vector3>(vecs, Allocator.TempJob),
            waveAmplitudes = new NativeArray<float>(amps, Allocator.TempJob),
        };


        JobHandle handle = job.Schedule();
        handle.Complete();

        float result = job.output[0];

        job.output.Dispose();
        job.waveVectors.Dispose();
        job.waveAmplitudes.Dispose();

        return result;
    }

    private void OnGUI()
    {
        UpdateReferencingMaterials();
    }

}
