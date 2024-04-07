using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "NewOceanProfile", menuName = "CreateNewOceanProfile", order = 1)]
public class OceanProfile : SerializedScriptableObject
{
    //================================================
    //
    // 현재 바다 표면의 정보를 담는 스크립터블 오브젝트입니다.
    //
    //================================================

    [SerializeField,ColorUsage(false,true)] private Color oceanColor;           // 바다 머트리얼 Emmision 색상
    [SerializeField, ColorUsage(false, true)] private Color oceanTipColor;      // 바다 머트리얼 고점 Emmision 색상
    public Color OceanColor { get { return oceanColor; } }
    public Color OceanTipColor { get { return oceanTipColor; } }
    [SerializeField, Range(0.1f, 1.5f)] private float oceanIntensity;
    public float OceanIntensity { get { return oceanIntensity; } }              // 파도 강도 곱
    
    public struct Waveform
    {
        public Vector3 vector;              // 파도 벡터
        public float amplitude;             // 파도 강도
    }

    [SerializeField] private Waveform waveform1;                                // 1번 파형
    public Waveform Waveform1 { get { return waveform1; } }
    [SerializeField] private Waveform waveform2;                                // 2번 파형
    public Waveform Waveform2 { get { return waveform2; } }
    [SerializeField] private Waveform waveform3;                                // 3번 파형
    public Waveform Waveform3 { get { return waveform3; } }
    [SerializeField] private Waveform waveform4;                                // 4번 파형
    public Waveform Waveform4 { get { return waveform4; } }

    public void InitilzeOceanProfile(Color _color,Color _tipColor, float _oceanIntensity, Vector3 _wv1, float _wa1, Vector3 _wv2, float _wa2, Vector3 _wv3, float _wa3, Vector3 _wv4, float _wa4) 
    {   
        oceanColor = _color; oceanTipColor = _tipColor; oceanIntensity = _oceanIntensity; 
        waveform1.vector = _wv1; waveform1.amplitude = _wa1;
        waveform2.vector = _wv2; waveform2.amplitude = _wa2;
        waveform3.vector = _wv3; waveform3.amplitude = _wa3;
        waveform4.vector = _wv4; waveform4.amplitude = _wa4;
    }
}
