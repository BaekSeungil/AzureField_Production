using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EtherSystem : MonoBehaviour
{

    [SerializeField, LabelText("파도 x축 크기")] public float TargetWaveScaleX;
    [SerializeField, LabelText("파도 Y축 크기")] public float TargetWaveScaleY;
    [SerializeField, LabelText("파도 Z축 크기")] public float TargetWaveScaleZ;

    [SerializeField, LabelText("크기 증가 속도")] public float ScaleSpeed;

    private bool CalledWave = false;
    private ParticleSystem particleSystem;

    private float currentWaveScaleX = 0f;
    private float currentWaveScaleY = 0f;
    private float currentWaveScaleZ = 0f;



    // Start is called before the first frame update
    private void Start()
    {
        particleSystem = GetComponent<ParticleSystem>();
        var main = particleSystem.main;
        currentWaveScaleX = main.startSizeX.constant;
        currentWaveScaleY = main.startSizeY.constant;
        currentWaveScaleZ = main.startSizeZ.constant;
    }

    // Update is called once per frame
    private void Update()
    {
        UpdateWaveParticleScale();
        
    }

    private void UpdateWaveParticleScale()
    {

        if (particleSystem == null) return;

        if(CalledWave == true)
        {
            if(currentWaveScaleX <= TargetWaveScaleX)
            {
                currentWaveScaleX += ScaleSpeed * Time.deltaTime;
                if(currentWaveScaleX > TargetWaveScaleX)
                {
                    currentWaveScaleX = TargetWaveScaleX;
                }
            }

            if(currentWaveScaleY <= TargetWaveScaleY)
            {
                currentWaveScaleY += ScaleSpeed * Time.deltaTime;
                if(currentWaveScaleY > TargetWaveScaleY)
                {
                    currentWaveScaleY = TargetWaveScaleY;
                }
            }

            if(currentWaveScaleZ <= TargetWaveScaleZ)
            {
                currentWaveScaleZ += ScaleSpeed * Time.deltaTime;
                if(currentWaveScaleZ > TargetWaveScaleZ)
                {
                    currentWaveScaleZ = TargetWaveScaleZ;
                }
            }
        }


    }
}
